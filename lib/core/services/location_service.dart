import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationAddress {
  const LocationAddress({
    required this.latitude,
    required this.longitude,
    this.name = '',
    this.street = '',
    this.locality = '',
    this.district = '',
    this.state = '',
    this.country = '',
    this.postalCode = '',
  });

  final double latitude;
  final double longitude;
  final String name;
  final String street;
  final String locality;
  final String district;
  final String state;
  final String country;
  final String postalCode;

  String get formatted => <String>[
        if (street.isNotEmpty) street,
        if (locality.isNotEmpty) locality,
        if (district.isNotEmpty && district != locality) district,
        if (state.isNotEmpty) state,
        if (postalCode.isNotEmpty) postalCode,
      ].join(', ');

  Map<String, dynamic> toMap() => <String, dynamic>{
        'latitude': latitude,
        'longitude': longitude,
        'name': name,
        'street': street,
        'locality': locality,
        'district': district,
        'state': state,
        'country': country,
        'postalCode': postalCode,
      };
}

class LocationService {
  const LocationService();

  Future<LocationPermission> ensurePermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw StateError('Please enable location services.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw StateError('Location permission was denied.');
    }
    if (permission == LocationPermission.deniedForever) {
      throw StateError(
        'Location permission is permanently denied. Enable it in settings.',
      );
    }
    return permission;
  }

  Future<Position> getCurrentPosition() async {
    await ensurePermission();
    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 20),
    );
  }

  Stream<Position> watchPosition({int distanceFilter = 20}) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: distanceFilter,
      ),
    );
  }

  Future<LocationAddress> addressFromCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    final List<Placemark> places =
        await placemarkFromCoordinates(latitude, longitude);
    final Placemark? place = places.isEmpty ? null : places.first;
    return LocationAddress(
      latitude: latitude,
      longitude: longitude,
      name: place?.name ?? '',
      street: place?.street ?? '',
      locality: place?.locality ?? '',
      district: place?.subAdministrativeArea ?? '',
      state: place?.administrativeArea ?? '',
      country: place?.country ?? '',
      postalCode: place?.postalCode ?? '',
    );
  }

  Future<LocationAddress> getCurrentAddress() async {
    final Position position = await getCurrentPosition();
    return addressFromCoordinates(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }

  Future<bool> openAppSettings() => Geolocator.openAppSettings();
  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();
}
