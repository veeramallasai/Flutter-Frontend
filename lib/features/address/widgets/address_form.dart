import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/address_model.dart';
import 'current_location_button.dart';

class AddressForm extends StatefulWidget {
  const AddressForm({
    super.key,
    required this.onSubmit,
    this.initialAddress,
    this.isSaving = false,
  });

  final AddressModel? initialAddress;
  final Future<void> Function(AddressModel address) onSubmit;
  final bool isSaving;

  @override
  State<AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends State<AddressForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _line1;
  late final TextEditingController _line2;
  late final TextEditingController _city;
  late final TextEditingController _state;
  late final TextEditingController _postalCode;
  late final TextEditingController _landmark;
  late String _type;
  late bool _isDefault;
  double _latitude = 0;
  double _longitude = 0;
  bool _isLocating = false;

  @override
  void initState() {
    super.initState();
    final AddressModel? value = widget.initialAddress;
    _name = TextEditingController(text: value?.fullName ?? '');
    _phone = TextEditingController(text: value?.phone ?? '');
    _line1 = TextEditingController(text: value?.addressLine1 ?? '');
    _line2 = TextEditingController(text: value?.addressLine2 ?? '');
    _city = TextEditingController(text: value?.city ?? '');
    _state = TextEditingController(text: value?.state ?? '');
    _postalCode = TextEditingController(text: value?.postalCode ?? '');
    _landmark = TextEditingController(text: value?.landmark ?? '');
    _type = value?.type ?? 'Home';
    _isDefault = value?.isDefault ?? false;
    _latitude = value?.latitude ?? 0;
    _longitude = value?.longitude ?? 0;
  }

  @override
  void dispose() {
    for (final TextEditingController controller in <TextEditingController>[
      _name,
      _phone,
      _line1,
      _line2,
      _city,
      _state,
      _postalCode,
      _landmark,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _isLocating = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw StateError('Location permission is required.');
      }
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final List<Placemark> places = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      final Placemark? place = places.isEmpty ? null : places.first;
      if (!mounted) return;
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _line1.text = place?.street ?? _line1.text;
        _line2.text = place?.subLocality ?? _line2.text;
        _city.text = place?.locality ?? _city.text;
        _state.text = place?.administrativeArea ?? _state.text;
        _postalCode.text = place?.postalCode ?? _postalCode.text;
      });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString().replaceFirst('Bad state: ', '')),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final AddressModel? old = widget.initialAddress;
    await widget.onSubmit(
      AddressModel(
        id: old?.id ?? '',
        userId: old?.userId ?? '',
        fullName: _name.text.trim(),
        phone: _phone.text.trim(),
        addressLine1: _line1.text.trim(),
        addressLine2: _line2.text.trim(),
        city: _city.text.trim(),
        state: _state.text.trim(),
        postalCode: _postalCode.text.trim(),
        landmark: _landmark.text.trim(),
        type: _type,
        isDefault: _isDefault,
        latitude: _latitude,
        longitude: _longitude,
        createdAt: old?.createdAt,
        updatedAt: DateTime.now(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CurrentLocationButton(
            onPressed: _useCurrentLocation,
            isLoading: _isLocating,
          ),
          const SizedBox(height: 16),
          _field(_name, 'Full name', Icons.person_outline_rounded),
          _field(
            _phone,
            'Phone number',
            Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator:
                (String? value) =>
                    (value?.replaceAll(RegExp(r'\D'), '').length ?? 0) < 10
                        ? 'Enter a valid phone number'
                        : null,
          ),
          _field(_line1, 'House / Flat / Street', Icons.home_outlined),
          _field(
            _line2,
            'Area / Colony (optional)',
            Icons.location_city_outlined,
            required: false,
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: _field(_city, 'City', Icons.location_city_rounded),
              ),
              const SizedBox(width: 10),
              Expanded(child: _field(_state, 'State', Icons.map_outlined)),
            ],
          ),
          _field(
            _postalCode,
            'PIN code',
            Icons.markunread_mailbox_outlined,
            keyboardType: TextInputType.number,
            validator:
                (String? value) =>
                    (value?.trim().length ?? 0) != 6
                        ? 'Enter 6-digit PIN'
                        : null,
          ),
          _field(
            _landmark,
            'Landmark (optional)',
            Icons.flag_outlined,
            required: false,
          ),
          const SizedBox(height: 5),
          const Text(
            'Address type',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          Wrap(
            spacing: 8,
            children:
                <String>['Home', 'Work', 'Other'].map((String value) {
                  return ChoiceChip(
                    label: Text(value),
                    selected: _type == value,
                    onSelected: (_) => setState(() => _type = value),
                  );
                }).toList(),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _isDefault,
            activeThumbColor: AppColors.primary,
            onChanged: (bool value) => setState(() => _isDefault = value),
            title: const Text('Make this my default address'),
          ),
          const SizedBox(height: 10),
          FilledButton(
            onPressed: widget.isSaving ? null : _submit,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size.fromHeight(52),
            ),
            child: Text(widget.isSaving ? 'SAVING...' : 'SAVE ADDRESS'),
          ),
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool required = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator:
            validator ??
            (required
                ? (String? value) =>
                    value?.trim().isEmpty == true ? '$label is required' : null
                : null),
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      ),
    );
  }
}
