import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/address_model.dart';
import '../../providers/address_provider.dart';
import 'add_address_screen.dart';
import 'edit_address_screen.dart';
import 'widgets/address_card.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({
    super.key,
    required this.shoppingMode,
    required this.deliveryMethod,
    required this.deliveryDate,
    required this.deliverySlot,
    required this.subtotal,
    required this.savings,
    required this.total,
    required this.itemCount,
  });

  final String shoppingMode;
  final String deliveryMethod;
  final String? deliveryDate;
  final String deliverySlot;
  final double subtotal;
  final double savings;
  final double total;
  final int itemCount;

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  late final AddressProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = AddressProvider()..listenToAddresses();
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  Future<void> _addAddress() async {
    final AddressModel? address = await Navigator.push<AddressModel>(
      context,
      MaterialPageRoute<AddressModel>(builder: (_) => const AddAddressScreen()),
    );
    if (address != null) {
      await _provider.refreshAddresses(preferredId: address.id);
    }
  }

  Future<void> _editAddress(AddressModel address) async {
    final AddressModel? updatedAddress = await Navigator.push<AddressModel>(
      context,
      MaterialPageRoute<AddressModel>(
        builder: (_) => EditAddressScreen(address: address),
      ),
    );
    if (updatedAddress != null) {
      await _provider.refreshAddresses(preferredId: updatedAddress.id);
    }
  }

  Future<void> _deleteAddress(AddressModel address) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Delete address?'),
        content: Text('${address.type} address will be removed.'),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCEL')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('DELETE')),
        ],
      ),
    );
    if (confirmed == true) await _provider.deleteAddress(address.id);
  }

  void _continue() {
    final AddressModel? address = _provider.selectedAddress;
    if (address == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a delivery address.')),
      );
      return;
    }
    Navigator.pushNamed(
      context,
      AppRoutes.checkout,
      arguments: <String, dynamic>{
        'shoppingMode': widget.shoppingMode,
        'deliveryMethod': widget.deliveryMethod,
        'deliveryDate': widget.deliveryDate,
        'deliverySlot': widget.deliverySlot,
        'addressId': address.id,
        'address': address.toMap(),
        'subtotal': widget.subtotal,
        'savings': widget.savings,
        'total': widget.total,
        'itemCount': widget.itemCount,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _provider,
      builder: (BuildContext context, Widget? child) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Delivery Address'),
            actions: <Widget>[
              IconButton(onPressed: _addAddress, icon: const Icon(Icons.add_rounded)),
            ],
          ),
          body: _provider.isLoading && _provider.addresses.isEmpty
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : _provider.errorMessage != null && _provider.addresses.isEmpty
              ? _AddressLoadError(
                  message: _provider.errorMessage!,
                  onRetry: () => _provider.refreshAddresses(),
                )
              : _provider.addresses.isEmpty
              ? _EmptyAddress(onAdd: _addAddress)
              : ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _provider.addresses.length,
            separatorBuilder: (_, __) => const SizedBox(height: 11),
            itemBuilder: (_, int index) {
              final AddressModel address = _provider.addresses[index];
              return AddressCard(
                address: address,
                isSelected: address.id == _provider.selectedAddressId,
                enabled: !_provider.isUpdating,
                onSelect: () => _provider.selectAddress(address.id),
                onEdit: () => _editAddress(address),
                onDelete: () => _deleteAddress(address),
                onSetDefault: () => _provider.setDefault(address.id),
              );
            },
          ),
          floatingActionButton: _provider.addresses.isEmpty
              ? null
              : FloatingActionButton.extended(
            onPressed: _addAddress,
            icon: const Icon(Icons.add_location_alt_rounded),
            label: const Text('ADD ADDRESS'),
          ),
          bottomNavigationBar: _provider.addresses.isEmpty
              ? null
              : SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton(
                onPressed: _provider.selectedAddress == null ? null : _continue,
                style: FilledButton.styleFrom(backgroundColor: AppColors.primary, minimumSize: const Size.fromHeight(52)),
                child: const Text('CONTINUE TO CHECKOUT'),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EmptyAddress extends StatelessWidget {
  const _EmptyAddress({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.location_off_outlined, color: AppColors.primary, size: 64),
          const SizedBox(height: 12),
          const Text('No saved addresses', style: TextStyle(color: AppColors.textPrimary, fontSize: 17, fontWeight: FontWeight.w900)),
          const SizedBox(height: 15),
          FilledButton.icon(onPressed: onAdd, icon: const Icon(Icons.add_rounded), label: const Text('ADD ADDRESS')),
        ],
      ),
    );
  }
}

class _AddressLoadError extends StatelessWidget {
  const _AddressLoadError({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.cloud_off_rounded, color: AppColors.error, size: 58),
            const SizedBox(height: 12),
            const Text(
              'Could not load addresses',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 7),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('TRY AGAIN'),
            ),
          ],
        ),
      ),
    );
  }
}
