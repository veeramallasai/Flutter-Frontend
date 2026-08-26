import 'package:flutter/material.dart';

import '../../core/config/backend_config.dart';
import '../../data/models/delivery_partner_order_model.dart';
import '../../data/remote/delivery_partner_remote_source.dart';

class DeliveryPartnerScreen extends StatefulWidget {
  const DeliveryPartnerScreen({super.key});

  @override
  State<DeliveryPartnerScreen> createState() => _DeliveryPartnerScreenState();
}

class _DeliveryPartnerScreenState extends State<DeliveryPartnerScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _partner = DeliveryPartnerRemoteSource();
  List<DeliveryPartnerOrderModel> _orders = <DeliveryPartnerOrderModel>[];
  bool _signedIn = false;
  bool _busy = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _restoreSession() async {
    final signedIn = await _partner.hasSession();
    if (signedIn) await _loadOrders();
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _login() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await _partner.login(
        email: _emailController.text,
        password: _passwordController.text,
      );
      await _loadOrders();
      if (mounted) setState(() => _signedIn = true);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _loadOrders() async {
    try {
      final orders = await _partner.getAssignedDeliveries();
      if (mounted) {
        setState(() {
          _orders = orders;
          _signedIn = true;
          _error = null;
        });
      }
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    }
  }

  Future<void> _accept(DeliveryPartnerOrderModel order) async {
    await _runAction(() => _partner.accept(order.id));
  }

  Future<void> _reject(DeliveryPartnerOrderModel order) async {
    await _runAction(() => _partner.reject(order.id));
  }

  Future<void> _runAction(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
      await _loadOrders();
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _signOut() async {
    await _partner.signOut();
    if (mounted) {
      setState(() {
        _signedIn = false;
        _orders = <DeliveryPartnerOrderModel>[];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Partner'),
        actions: [
          if (_signedIn)
            IconButton(onPressed: _signOut, icon: const Icon(Icons.logout)),
        ],
      ),
      body:
          _busy && !_signedIn
              ? const Center(child: CircularProgressIndicator())
              : _signedIn
              ? _buildOrders()
              : _buildLogin(),
    );
  }

  Widget _buildLogin() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'Partner sign in',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'API: ${BackendConfig.baseUrl}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: 'Email'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Password'),
        ),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: _busy ? null : _login,
          child: const Text('Sign in'),
        ),
        if (_error != null) ...[
          const SizedBox(height: 16),
          Text(
            _error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
      ],
    );
  }

  Widget _buildOrders() {
    return RefreshIndicator(
      onRefresh: _loadOrders,
      child:
          _orders.isEmpty
              ? ListView(
                children: const [
                  SizedBox(height: 180),
                  Center(child: Text('No assigned deliveries')),
                ],
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _orders.length,
                itemBuilder: (context, index) {
                  final order = _orders[index];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order ${order.id}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            order.customerName.isEmpty
                                ? 'Customer details unavailable'
                                : order.customerName,
                          ),
                          if (order.address.isNotEmpty) Text(order.address),
                          const SizedBox(height: 8),
                          Text('Status: ${order.status}'),
                          Row(
                            children: [
                              TextButton(
                                onPressed: _busy ? null : () => _reject(order),
                                child: const Text('Reject'),
                              ),
                              const SizedBox(width: 8),
                              FilledButton(
                                onPressed: _busy ? null : () => _accept(order),
                                child: const Text('Accept'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
