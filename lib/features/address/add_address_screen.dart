import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/address_model.dart';
import '../../data/repositories/address_repository.dart';
import 'widgets/address_form.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final AddressRepository _repository = AddressRepository();
  bool _isSaving = false;

  Future<void> _save(AddressModel address) async {
    setState(() => _isSaving = true);
    try {
      final AddressModel savedAddress = await _repository.saveAddress(address);
      if (!mounted) return;
      Navigator.pop(context, savedAddress);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Bad state: ', '')),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Add Address')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[AddressForm(onSubmit: _save, isSaving: _isSaving)],
      ),
    );
  }
}
