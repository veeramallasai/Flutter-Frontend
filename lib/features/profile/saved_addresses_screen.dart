import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/address_model.dart';
import '../../providers/address_provider.dart';
import '../address/add_address_screen.dart';
import '../address/edit_address_screen.dart';
import '../address/widgets/address_card.dart';

class SavedAddressesScreen extends StatefulWidget {
  const SavedAddressesScreen({super.key});

  @override
  State<SavedAddressesScreen> createState() => _SavedAddressesScreenState();
}

class _SavedAddressesScreenState extends State<SavedAddressesScreen> {
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

  Future<void> _add() async {
    final AddressModel? address = await Navigator.push<AddressModel>(
      context,
      MaterialPageRoute<AddressModel>(builder: (_) => const AddAddressScreen()),
    );
    if (address != null) {
      await _provider.refreshAddresses(preferredId: address.id);
    }
  }

  Future<void> _edit(AddressModel address) async {
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

  Future<void> _delete(AddressModel address) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Delete address?'),
        content: Text('${address.type} address will be permanently removed.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
    if (confirmed == true) await _provider.deleteAddress(address.id);
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: _provider,
        builder: (BuildContext context, Widget? child) => Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Saved Addresses'),
            actions: <Widget>[
              IconButton(onPressed: _add, icon: const Icon(Icons.add_rounded)),
            ],
          ),
          body: _provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : _provider.errorMessage != null && _provider.addresses.isEmpty
                  ? _AddressLoadError(
                      message: _provider.errorMessage!,
                      onRetry: () => _provider.refreshAddresses(),
                    )
              : _provider.addresses.isEmpty
                  ? _EmptyAddresses(onAdd: _add)
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
                      children: <Widget>[
                        const _AddressHero(),
                        const SizedBox(height: 18),
                        ..._provider.addresses.map(
                          (AddressModel address) => Padding(
                            padding: const EdgeInsets.only(bottom: 11),
                            child: AddressCard(
                              address: address,
                              isSelected: address.isDefault,
                              enabled: !_provider.isUpdating,
                              onSelect: () => _provider.setDefault(address.id),
                              onSetDefault: () => _provider.setDefault(address.id),
                              onEdit: () => _edit(address),
                              onDelete: () => _delete(address),
                            ),
                          ),
                        ),
                      ],
                    ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _add,
            icon: const Icon(Icons.add_location_alt_rounded),
            label: const Text('ADD ADDRESS'),
          ),
        ),
      );
}

class _AddressHero extends StatelessWidget {
  const _AddressHero();
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: <Color>[Color(0xFF073D24), Color(0xFF159253)],
          ),
          borderRadius: BorderRadius.circular(23),
        ),
        child: const Row(
          children: <Widget>[
            Icon(Icons.location_on_rounded, color: Color(0xFFFFD66B), size: 35),
            SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Your delivery places',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Tap an address to make it your default.',
                    style: TextStyle(color: Color(0xFFC9E7D6), fontSize: 9.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class _EmptyAddresses extends StatelessWidget {
  const _EmptyAddresses({required this.onAdd});
  final VoidCallback onAdd;
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.add_location_alt_outlined, size: 62, color: AppColors.primary),
              const SizedBox(height: 13),
              const Text('No saved addresses', style: TextStyle(fontWeight: FontWeight.w900)),
              const SizedBox(height: 5),
              const Text(
                'Save home or shop locations for faster checkout.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 10),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add_rounded),
                label: const Text('ADD FIRST ADDRESS'),
              ),
            ],
          ),
        ),
      );
}

class _AddressLoadError extends StatelessWidget {
  const _AddressLoadError({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.cloud_off_rounded, size: 58, color: AppColors.error),
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
