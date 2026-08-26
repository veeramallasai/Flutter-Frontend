class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.name,
    this.description = '',
    this.imageUrl = '',
    this.iconName = '',
    this.productCount = 0,
    this.sortOrder = 0,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String iconName;
  final int productCount;
  final int sortOrder;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory CategoryModel.fromDocument(dynamic doc) {
    if (doc is Map<String, dynamic>) {
      return CategoryModel.fromMap(doc, documentId: (doc['id'] ?? '').toString());
    }
    try {
      final map = (doc as dynamic).data() as Map<String, dynamic>? ?? <String, dynamic>{};
      return CategoryModel.fromMap(map, documentId: doc.id.toString());
    } catch (_) {
      return const CategoryModel(id: '', name: '');
    }
  }

  factory CategoryModel.fromMap(
    Map<String, dynamic> map, {
    String documentId = '',
  }) {
    return CategoryModel(
      id: _text(documentId.isNotEmpty ? documentId : map['id']),
      name: _text(map['name'], fallback: 'Fresh Picks'),
      description: _text(map['description']),
      imageUrl: _text(map['imageUrl'] ?? map['image']),
      iconName: _text(map['iconName'] ?? map['icon']),
      productCount: _integer(map['productCount'] ?? map['count']),
      sortOrder: _integer(map['sortOrder'] ?? map['position']),
      isActive: _boolean(map['isActive'] ?? map['active'], fallback: true),
      createdAt: _date(map['createdAt']),
      updatedAt: _date(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
    'id': id,
    'name': name,
    'description': description,
    'imageUrl': imageUrl,
    'iconName': iconName,
    'productCount': productCount,
    'sortOrder': sortOrder,
    'isActive': isActive,
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
  };

  CategoryModel copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    String? iconName,
    int? productCount,
    int? sortOrder,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => CategoryModel(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    imageUrl: imageUrl ?? this.imageUrl,
    iconName: iconName ?? this.iconName,
    productCount: productCount ?? this.productCount,
    sortOrder: sortOrder ?? this.sortOrder,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}

String _text(dynamic value, {String fallback = ''}) {
  final String result = value?.toString().trim() ?? '';
  return result.isEmpty ? fallback : result;
}

int _integer(dynamic value) =>
    value is num ? value.toInt() : int.tryParse('$value') ?? 0;

bool _boolean(dynamic value, {bool fallback = false}) =>
    value is bool
        ? value
        : value == null
        ? fallback
        : <String>{'true', '1', 'yes'}.contains('$value'.toLowerCase());

DateTime? _date(dynamic value) =>
    value is DateTime
        ? value
        : DateTime.tryParse(value?.toString() ?? '');
