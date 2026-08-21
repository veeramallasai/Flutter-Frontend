import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/address_model.dart';
import '../../data/repositories/address_repository.dart';
import 'widgets/address_form.dart';

class EditAddressScreen extends StatefulWidget {
  const EditAddressScreen({super.key, required this.address});

  final AddressModel address;

  @override
  State<EditAddressScreen> createState() => _EditAddressScreenState();
}

class _EditAddressScreenState extends State<EditAddressScreen> {
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
        SnackBar(content: Text(error.toString().replaceFirst('Bad state: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Edit Address')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          AddressForm(
            initialAddress: widget.address,
            onSubmit: _save,
            isSaving: _isSaving,
          ),
        ],
      ),
    );
  }
}
