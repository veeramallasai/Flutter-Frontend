import 'package:cloud_firestore/cloud_firestore.dart';

class FarmerModel {
  const FarmerModel({
    required this.id,
    required this.name,
    required this.farmName,
    required this.location,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.isVerified,
    required this.experienceYears,
    required this.speciality,
  });

  final String id;
  final String name;
  final String farmName;
  final String location;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final bool isVerified;
  final int experienceYears;
  final String speciality;

  factory FarmerModel.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    return FarmerModel.fromMap(
      document.data() ?? <String, dynamic>{},
      documentId: document.id,
    );
  }

  factory FarmerModel.fromMap(
    Map<String, dynamic> map, {
    String documentId = '',
  }) {
    return FarmerModel(
      id: _text(documentId.isNotEmpty ? documentId : map['id']),
      name: _text(map['name'] ?? map['farmerName'], fallback: 'Local Farmer'),
      farmName: _text(map['farmName'], fallback: 'Farm To Home Partner'),
      location: _text(map['location'] ?? map['village']),
      imageUrl: _text(map['imageUrl'] ?? map['profileImage']),
      rating: _toDouble(map['rating']),
      reviewCount: _toInt(map['reviewCount'] ?? map['reviews']),
      isVerified: _toBool(map['isVerified'], fallback: true),
      experienceYears: _toInt(map['experienceYears'] ?? map['experience']),
      speciality: _text(map['speciality'] ?? map['specialty']),
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
    'id': id,
    'name': name,
    'farmName': farmName,
    'location': location,
    'imageUrl': imageUrl,
    'rating': rating,
    'reviewCount': reviewCount,
    'isVerified': isVerified,
    'experienceYears': experienceYears,
    'speciality': speciality,
  };
}

String _text(dynamic value, {String fallback = ''}) {
  final String text = value?.toString().trim() ?? '';
  return text.isEmpty ? fallback : text;
}

double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

int _toInt(dynamic value) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

bool _toBool(dynamic value, {bool fallback = false}) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final String text = _text(value).toLowerCase();
  if (text == 'true' || text == 'yes' || text == '1') return true;
  if (text == 'false' || text == 'no' || text == '0') return false;
  return fallback;
}
