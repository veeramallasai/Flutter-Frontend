import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/premium_toast.dart';
import '../../data/models/notification_model.dart';
import '../../data/repositories/notification_repository.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationRepository _repository = NotificationRepository();
  List<NotificationModel> _notifications = <NotificationModel>[];
  bool _orderUpdates = true;
  bool _offers = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) setState(() => _loading = true);
    try {
      final List<dynamic> results = await Future.wait<dynamic>(<Future<dynamic>>[
        _repository.getNotifications(),
        _repository.getPreferences(),
      ]);
      final Map<String, bool> preferences = results[1] as Map<String, bool>;
      if (!mounted) return;
      setState(() {
        _notifications = results[0] as List<NotificationModel>;
        _orderUpdates = preferences['orderUpdates'] ?? true;
        _offers = preferences['offers'] ?? true;
      });
    } catch (_) {
      if (mounted) {
        PremiumToast.show(context, 'Unable to load notifications.', error: true);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _savePreferences({bool? orderUpdates, bool? offers}) async {
    final bool previousOrders = _orderUpdates;
    final bool previousOffers = _offers;
    setState(() {
      _orderUpdates = orderUpdates ?? _orderUpdates;
      _offers = offers ?? _offers;
    });
    try {
      await _repository.updatePreferences(
        orderUpdates: _orderUpdates,
        offers: _offers,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _orderUpdates = previousOrders;
        _offers = previousOffers;
      });
      PremiumToast.show(context, 'Preference could not be saved.', error: true);
    }
  }

  Future<void> _read(NotificationModel notification) async {
    if (notification.isRead) return;
    setState(() {
      _notifications = _notifications
          .map((NotificationModel value) => value.id == notification.id
              ? value.copyWith(isRead: true)
              : value)
          .toList(growable: false);
    });
    try {
      await _repository.markAsRead(notification.id);
    } catch (_) {
      if (mounted) await _load();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Notifications'),
          actions: <Widget>[
            if (_notifications.any((NotificationModel value) => !value.isRead))
              TextButton(
                onPressed: () async {
                  try {
                    await _repository.markAllAsRead();
                    if (!mounted) return;
                    setState(() {
                      _notifications = _notifications
                          .map((NotificationModel value) =>
                              value.copyWith(isRead: true))
                          .toList(growable: false);
                    });
                  } catch (_) {
                    if (!context.mounted) return;
                    PremiumToast.show(
                      context,
                      'Could not update notifications.',
                      error: true,
                    );
                  }
                },
                child: const Text('READ ALL'),
              ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
            children: <Widget>[
              _PreferencesCard(
                orderUpdates: _orderUpdates,
                offers: _offers,
                onOrderChanged: (bool value) =>
                    _savePreferences(orderUpdates: value),
                onOffersChanged: (bool value) =>
                    _savePreferences(offers: value),
              ),
              const SizedBox(height: 22),
              const Text(
                'RECENT UPDATES',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 9,
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.all(28),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_notifications.isEmpty)
                const _EmptyNotifications()
              else
                ..._notifications.map(
                  (NotificationModel notification) => _NotificationTile(
                    notification: notification,
                    onTap: () => _read(notification),
                  ),
                ),
            ],
          ),
        ),
      );
}

class _PreferencesCard extends StatelessWidget {
  const _PreferencesCard({
    required this.orderUpdates,
    required this.offers,
    required this.onOrderChanged,
    required this.onOffersChanged,
  });

  final bool orderUpdates;
  final bool offers;
  final ValueChanged<bool> onOrderChanged;
  final ValueChanged<bool> onOffersChanged;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: <Widget>[
            SwitchListTile(
              value: orderUpdates,
              onChanged: onOrderChanged,
              secondary: const Icon(
                Icons.local_shipping_rounded,
                color: AppColors.primary,
              ),
              title: const Text(
                'Order updates',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              subtitle: const Text('Packing, payment and delivery alerts'),
            ),
            const Divider(height: 1),
            SwitchListTile(
              value: offers,
              onChanged: onOffersChanged,
              secondary: const Icon(
                Icons.local_offer_rounded,
                color: AppColors.primary,
              ),
              title: const Text(
                'Fresh deals',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              subtitle: const Text('Seasonal arrivals and member savings'),
            ),
          ],
        ),
      );
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, required this.onTap});

  final NotificationModel notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool read = notification.isRead;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: read ? Colors.white : const Color(0xFFEAF7EF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: read ? AppColors.border : const Color(0xFFBDE3CC),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: read ? const Color(0xFFF2F5F3) : Colors.white,
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(
            Icons.notifications_rounded,
            color: AppColors.primary,
          ),
        ),
        title: Text(
          notification.title,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
        ),
        subtitle: Text(
          notification.body,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 9, height: 1.4),
        ),
        trailing:
            read ? null : const Icon(Icons.circle, color: AppColors.primary, size: 8),
      ),
    );
  }
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 42, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.border),
        ),
        child: const Column(
          children: <Widget>[
            Icon(
              Icons.notifications_none_rounded,
              color: AppColors.primary,
              size: 48,
            ),
            SizedBox(height: 12),
            Text(
              'You are all caught up',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            SizedBox(height: 4),
            Text(
              'Order and offer updates will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      );
}
