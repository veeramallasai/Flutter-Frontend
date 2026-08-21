import 'package:cloud_firestore/cloud_firestore.dart';

class DeliverySlotModel {
  const DeliverySlotModel({
    required this.id,
    required this.method,
    required this.label,
    required this.startTime,
    required this.endTime,
    required this.fee,
    required this.isAvailable,
    required this.capacity,
    required this.bookedCount,
    this.date,
  });

  final String id;
  final String method;
  final String label;
  final String startTime;
  final String endTime;
  final double fee;
  final bool isAvailable;
  final int capacity;
  final int bookedCount;
  final DateTime? date;

  bool get hasCapacity => capacity <= 0 || bookedCount < capacity;
  bool get canBook => isAvailable && hasCapacity;

  factory DeliverySlotModel.fromDocument(
      DocumentSnapshot<Map<String, dynamic>> document,
      ) {
    return DeliverySlotModel.fromMap(
      document.data() ?? <String, dynamic>{},
      documentId: document.id,
    );
  }

  factory DeliverySlotModel.fromMap(
      Map<String, dynamic> map, {
        String documentId = '',
      }) {
    return DeliverySlotModel(
      id: _text(documentId.isNotEmpty ? documentId : map['id']),
      method: _text(map['method'], fallback: 'scheduled').toLowerCase(),
      label: _text(map['label'], fallback: 'Available slot'),
      startTime: _text(map['startTime']),
      endTime: _text(map['endTime']),
      fee: _toDouble(map['fee'] ?? map['deliveryFee']),
      isAvailable: _toBool(map['isAvailable'], fallback: true),
      capacity: _toInt(map['capacity']),
      bookedCount: _toInt(map['bookedCount']),
      date: _toDateTime(map['date']),
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
    'id': id,
    'method': method,
    'label': label,
    'startTime': startTime,
    'endTime': endTime,
    'fee': fee,
    'isAvailable': isAvailable,
    'capacity': capacity,
    'bookedCount': bookedCount,
    if (date != null) 'date': Timestamp.fromDate(date!),
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
  final String text = value?.toString().toLowerCase() ?? '';
  if (text == 'true' || text == '1' || text == 'yes') return true;
  if (text == 'false' || text == '0' || text == 'no') return false;
  return fallback;
}

DateTime? _toDateTime(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  return DateTime.tryParse(value?.toString() ?? '');
}
