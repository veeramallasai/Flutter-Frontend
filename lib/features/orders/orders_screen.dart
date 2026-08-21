import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/order_model.dart';
import '../../providers/orders_provider.dart';
import 'order_details_screen.dart';
import 'widgets/order_card.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late final OrdersProvider _ordersProvider;

  @override
  void initState() {
    super.initState();
    _ordersProvider = OrdersProvider();
  }

  @override
  void dispose() {
    _ordersProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _ordersProvider,
          builder: (BuildContext context, Widget? child) {
            return Column(
              children: <Widget>[
                _buildHeader(),
                Expanded(child: _buildBody()),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 9),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          IconButton(
            tooltip: 'Back',
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          const SizedBox(width: 3),
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF7EF),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 11),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'My Orders',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Track and manage your farm orders',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Refresh orders',
            onPressed: _ordersProvider.isRefreshing
                ? null
                : () => _ordersProvider.refresh(),
            icon: _ordersProvider.isRefreshing
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2.5,
              ),
            )
                : const Icon(
              Icons.refresh_rounded,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_ordersProvider.isLoading && !_ordersProvider.hasOrders) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_ordersProvider.hasError && !_ordersProvider.hasOrders) {
      return _buildErrorState();
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => _ordersProvider.refresh(),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: _buildSummaryCard(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
              child: _buildFilters(),
            ),
          ),
          if (_ordersProvider.hasError)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: _buildInlineError(),
              ),
            ),
          if (!_ordersProvider.hasFilteredOrders)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _buildEmptyState(),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
              sliver: SliverList.separated(
                itemCount: _ordersProvider.filteredOrders.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (BuildContext context, int index) {
                  final OrderModel order =
                  _ordersProvider.filteredOrders[index];

                  return OrderCard(
                    order: order,
                    isProcessing: _ordersProvider.isProcessing(order.id),
                    onTap: () => _openOrderDetails(order),
                    onTrack: order.canTrack
                        ? () => _showComingNext(
                      'Order tracking for #${order.shortOrderId}',
                    )
                        : null,
                    onCancel: order.canCancel
                        ? () => _confirmCancellation(order)
                        : null,
                    onReorder: order.canReorder
                        ? () => _showComingNext(
                      'Reorder for #${order.shortOrderId}',
                    )
                        : null,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFF043D22),
            Color(0xFF17A45B),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x2117A45B),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _summaryValue(
              value: '${_ordersProvider.totalCount}',
              label: 'Total orders',
              icon: Icons.shopping_bag_rounded,
            ),
          ),
          _summaryDivider(),
          Expanded(
            child: _summaryValue(
              value: '${_ordersProvider.activeCount}',
              label: 'Active',
              icon: Icons.local_shipping_rounded,
            ),
          ),
          _summaryDivider(),
          Expanded(
            child: _summaryValue(
              value: '${_ordersProvider.deliveredCount}',
              label: 'Delivered',
              icon: Icons.check_circle_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryValue({
    required String value,
    required String label,
    required IconData icon,
  }) {
    return Column(
      children: <Widget>[
        Icon(icon, color: Colors.white, size: 21),
        const SizedBox(height: 7),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFFDDF4E7),
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _summaryDivider() {
    return Container(
      width: 1,
      height: 55,
      color: const Color(0x35FFFFFF),
    );
  }

  Widget _buildFilters() {
    const List<_OrderFilter> filters = <_OrderFilter>[
      _OrderFilter(value: 'all', label: 'All'),
      _OrderFilter(value: 'active', label: 'Active'),
      _OrderFilter(value: 'delivered', label: 'Delivered'),
      _OrderFilter(value: 'cancelled', label: 'Cancelled'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((_OrderFilter filter) {
          final bool selected =
              _ordersProvider.selectedFilter == filter.value;

          return Padding(
            padding: const EdgeInsets.only(right: 9),
            child: ChoiceChip(
              selected: selected,
              showCheckmark: false,
              onSelected: (_) =>
                  _ordersProvider.selectFilter(filter.value),
              label: Text(filter.label),
              labelStyle: TextStyle(
                color: selected ? Colors.white : AppColors.textPrimary,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
              backgroundColor: Colors.white,
              selectedColor: AppColors.primary,
              side: BorderSide(
                color: selected ? AppColors.primary : AppColors.border,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          );
        }).toList(growable: false),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 82,
              height: 82,
              decoration: const BoxDecoration(
                color: Color(0xFFFFECEC),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: AppColors.error,
                size: 42,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Unable to load orders',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _ordersProvider.errorMessage ?? 'Please try again.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                height: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => _ordersProvider.listenToOrders(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('TRY AGAIN'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInlineError() {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFFFD2D2)),
      ),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.error_outline_rounded,
            color: AppColors.error,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _ordersProvider.errorMessage ?? 'Something went wrong.',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Close',
            onPressed: _ordersProvider.clearError,
            icon: const Icon(Icons.close_rounded, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final bool filtered = _ordersProvider.selectedFilter != 'all';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: Color(0xFFEAF7EF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                filtered
                    ? Icons.filter_alt_off_rounded
                    : Icons.shopping_bag_outlined,
                color: AppColors.primary,
                size: 48,
              ),
            ),
            const SizedBox(height: 19),
            Text(
              filtered ? 'No matching orders' : 'No orders yet',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              filtered
                  ? 'Try another order filter.'
                  : 'Your placed orders will appear here.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (filtered) ...<Widget>[
              const SizedBox(height: 17),
              OutlinedButton(
                onPressed: () => _ordersProvider.selectFilter('all'),
                child: const Text('SHOW ALL ORDERS'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _confirmCancellation(OrderModel order) async {
    final TextEditingController reasonController = TextEditingController();

    final bool? confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 13, 20, 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Cancel this order?',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'Order #${order.shortOrderId} will be cancelled.',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 17),
                TextField(
                  controller: reasonController,
                  maxLines: 3,
                  maxLength: 150,
                  decoration: InputDecoration(
                    hintText: 'Reason for cancellation (optional)',
                    filled: true,
                    fillColor: const Color(0xFFF7FAF8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () =>
                            Navigator.of(sheetContext).pop(false),
                        child: const Text('KEEP ORDER'),
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: FilledButton(
                        onPressed: () =>
                            Navigator.of(sheetContext).pop(true),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.error,
                        ),
                        child: const Text('CANCEL ORDER'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    final String reason = reasonController.text.trim();
    reasonController.dispose();

    if (confirmed != true || !mounted) {
      return;
    }

    final bool success = await _ordersProvider.cancelOrder(
      orderId: order.id,
      reason: reason,
    );

    if (!mounted) {
      return;
    }

    _showMessage(
      success
          ? 'Order cancelled successfully.'
          : _ordersProvider.errorMessage ?? 'Unable to cancel order.',
      error: !success,
    );
  }

  Future<void> _openOrderDetails(OrderModel order) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => OrderDetailsScreen(
          orderId: order.id,
          initialOrder: order,
        ),
      ),
    );
  }

  void _showComingNext(String feature) {
    _showMessage('$feature screen will be connected next.');
  }

  void _showMessage(String message, {bool error = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          backgroundColor: error ? AppColors.error : AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          content: Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
  }
}

class _OrderFilter {
  const _OrderFilter({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;
}
