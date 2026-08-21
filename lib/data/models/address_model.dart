class AddressModel {
  const AddressModel({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.phone,
    required this.addressLine1,
    required this.addressLine2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.landmark,
    required this.type,
    required this.isDefault,
    required this.latitude,
    required this.longitude,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String userId;
  final String fullName;
  final String phone;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String state;
  final String postalCode;
  final String landmark;
  final String type;
  final bool isDefault;
  final double latitude;
  final double longitude;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get fullAddress => <String>[
    addressLine1,
    addressLine2,
    landmark,
    city,
    state,
    postalCode,
  ].where((String value) => value.trim().isNotEmpty).join(', ');

  factory AddressModel.fromMap(
      Map<String, dynamic> map, {
        String documentId = '',
      }) {
    return AddressModel(
      id: _text(documentId.isNotEmpty ? documentId : map['id']),
      userId: _text(map['userId']),
      fullName: _text(map['fullName'] ?? map['name']),
      phone: _text(map['phone'] ?? map['phoneNumber']),
      addressLine1: _text(map['addressLine1'] ?? map['address']),
      addressLine2: _text(map['addressLine2']),
      city: _text(map['city']),
      state: _text(map['state']),
      postalCode: _text(map['postalCode'] ?? map['pincode']),
      landmark: _text(map['landmark']),
      type: _text(map['type'], fallback: 'Home'),
      isDefault: _toBool(map['isDefault']),
      latitude: _toDouble(map['latitude']),
      longitude: _toDouble(map['longitude']),
      createdAt: _toDateTime(map['createdAt']),
      updatedAt: _toDateTime(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
    'id': id,
    'userId': userId,
    'fullName': fullName,
    'phone': phone,
    'addressLine1': addressLine1,
    'addressLine2': addressLine2,
    'city': city,
    'state': state,
    'postalCode': postalCode,
    'landmark': landmark,
    'type': type,
    'isDefault': isDefault,
    'latitude': latitude,
    'longitude': longitude,
    if (createdAt != null) 'createdAt': createdAt!.toUtc().toIso8601String(),
    if (updatedAt != null) 'updatedAt': updatedAt!.toUtc().toIso8601String(),
  };

  AddressModel copyWith({
    String? id,
    String? userId,
    String? fullName,
    String? phone,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? postalCode,
    String? landmark,
    String? type,
    bool? isDefault,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AddressModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      landmark: landmark ?? this.landmark,
      type: type ?? this.type,
      isDefault: isDefault ?? this.isDefault,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

String _text(dynamic value, {String fallback = ''}) {
  final String text = value?.toString().trim() ?? '';
  return text.isEmpty ? fallback : text;
}
double _toDouble(dynamic value) =>
    value is num ? value.toDouble() : double.tryParse(value?.toString() ?? '') ?? 0;
bool _toBool(dynamic value) =>
    value == true || value == 1 || value?.toString().toLowerCase() == 'true';
DateTime? _toDateTime(dynamic value) {
  if (value is DateTime) return value;
  return DateTime.tryParse(value?.toString() ?? '');
}
