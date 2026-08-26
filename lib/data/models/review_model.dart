import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  ReviewModel({
    required this.id,
    required this.productId,
    required this.userId,
    required this.userName,
    required this.rating,
    this.comment = '',
    List<String> images = const <String>[],
    this.isVerifiedPurchase = false,
    this.createdAt,
    this.updatedAt,
  }) : images = List<String>.unmodifiable(images);

  final String id;
  final String productId;
  final String userId;
  final String userName;
  final double rating;
  final String comment;
  final List<String> images;
  final bool isVerifiedPurchase;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  int get starRating => rating.clamp(0, 5).round();

  factory ReviewModel.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) => ReviewModel.fromMap(
    doc.data() ?? <String, dynamic>{},
    documentId: doc.id,
  );

  factory ReviewModel.fromMap(
    Map<String, dynamic> map, {
    String documentId = '',
  }) => ReviewModel(
    id: _text(documentId.isNotEmpty ? documentId : map['id']),
    productId: _text(map['productId']),
    userId: _text(map['userId'] ?? map['uid']),
    userName: _text(
      map['userName'] ?? map['name'],
      fallback: 'Verified customer',
    ),
    rating: _number(map['rating']).clamp(0, 5).toDouble(),
    comment: _text(map['comment'] ?? map['review']),
    images: _strings(map['images'] ?? map['imageUrls']),
    isVerifiedPurchase: _boolean(
      map['isVerifiedPurchase'] ?? map['verifiedPurchase'],
    ),
    createdAt: _date(map['createdAt']),
    updatedAt: _date(map['updatedAt']),
  );

  Map<String, dynamic> toMap() => <String, dynamic>{
    'id': id,
    'productId': productId,
    'userId': userId,
    'userName': userName,
    'rating': rating,
    'comment': comment,
    'images': images,
    'isVerifiedPurchase': isVerifiedPurchase,
    if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
    if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
  };

  ReviewModel copyWith({
    String? id,
    String? productId,
    String? userId,
    String? userName,
    double? rating,
    String? comment,
    List<String>? images,
    bool? isVerifiedPurchase,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => ReviewModel(
    id: id ?? this.id,
    productId: productId ?? this.productId,
    userId: userId ?? this.userId,
    userName: userName ?? this.userName,
    rating: rating ?? this.rating,
    comment: comment ?? this.comment,
    images: images ?? this.images,
    isVerifiedPurchase: isVerifiedPurchase ?? this.isVerifiedPurchase,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}

String _text(dynamic value, {String fallback = ''}) {
  final String result = value?.toString().trim() ?? '';
  return result.isEmpty ? fallback : result;
}

double _number(dynamic value) =>
    value is num ? value.toDouble() : double.tryParse('$value') ?? 0;

bool _boolean(dynamic value) =>
    value is bool
        ? value
        : <String>{'true', '1', 'yes'}.contains('$value'.toLowerCase());

List<String> _strings(dynamic value) =>
    value is Iterable
        ? value
            .map((dynamic item) => _text(item))
            .where((String item) => item.isNotEmpty)
            .toList()
        : <String>[];

DateTime? _date(dynamic value) =>
    value is Timestamp
        ? value.toDate()
        : value is DateTime
        ? value
        : DateTime.tryParse(value?.toString() ?? '');
