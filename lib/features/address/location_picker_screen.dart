import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/theme/app_colors.dart';

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  Position? _position;
  Placemark? _place;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _locate();
  }

  Future<void> _locate() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
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
      final List<Placemark> values = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (!mounted) return;
      setState(() {
        _position = position;
        _place = values.isEmpty ? null : values.first;
      });
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = error.toString().replaceFirst('Bad state: ', ''),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _confirm() {
    final Position? position = _position;
    if (position == null) return;
    Navigator.pop(context, <String, dynamic>{
      'latitude': position.latitude,
      'longitude': position.longitude,
      'addressLine1': _place?.street ?? '',
      'addressLine2': _place?.subLocality ?? '',
      'city': _place?.locality ?? '',
      'state': _place?.administrativeArea ?? '',
      'postalCode': _place?.postalCode ?? '',
    });
  }

  @override
  Widget build(BuildContext context) {
    final String address = <String>[
      _place?.street ?? '',
      _place?.subLocality ?? '',
      _place?.locality ?? '',
      _place?.administrativeArea ?? '',
      _place?.postalCode ?? '',
    ].where((String value) => value.isNotEmpty).join(', ');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Current Location')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child:
              _isLoading
                  ? const CircularProgressIndicator(color: AppColors.primary)
                  : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Icon(
                        Icons.location_on_rounded,
                        color: AppColors.primary,
                        size: 70,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _error ??
                            (address.isEmpty ? 'Location detected' : address),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          height: 1.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (_position != null) ...<Widget>[
                        const SizedBox(height: 8),
                        Text(
                          '${_position!.latitude.toStringAsFixed(5)}, ${_position!.longitude.toStringAsFixed(5)}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 9,
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      if (_position != null)
                        FilledButton(
                          onPressed: _confirm,
                          child: const Text('CONFIRM LOCATION'),
                        )
                      else
                        OutlinedButton.icon(
                          onPressed: _locate,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('TRY AGAIN'),
                        ),
                    ],
                  ),
        ),
      ),
    );
  }
}
