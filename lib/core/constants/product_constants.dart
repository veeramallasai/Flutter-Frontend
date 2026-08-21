class ProductConstants {
  ProductConstants._();

  static const String vegetables = 'vegetables';
  static const String fruits = 'fruits';
  static const String dairy = 'dairy';
  static const String seasonal = 'seasonal';
  static const String homeMode = 'home';
  static const String shopMode = 'shop';

  static const List<String> categories = <String>[
    vegetables,
    fruits,
    dairy,
    seasonal,
  ];

  static const int defaultStockQuantity = 50;
  static const int lowStockThreshold = 10;
  static const int defaultProductLimit = 100;
  static const double minimumRating = 0;
  static const double maximumRating = 5;

  static const List<String> supportedUnits = <String>[
    '100 g', '250 g', '500 g', '1 kg', '1 piece', '1 fresh bunch',
    '500 ml', '1 litre', '6 pieces', '12 pack', '10 kg crate',
  ];
}
