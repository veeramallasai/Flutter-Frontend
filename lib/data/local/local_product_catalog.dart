import '../../core/constants/asset_paths.dart';
import '../../core/utils/product_utils.dart';
import '../models/product_model.dart';

/// Offline-first catalog built from every product image bundled with the app.
/// Firestore products can override these entries by using the same id.
class LocalProductCatalog {
  LocalProductCatalog._();

  static final List<ProductModel> all =
      List<ProductModel>.unmodifiable(<ProductModel>[
        ..._buildCategory('vegetables', AssetPaths.vegetableImages),
        ..._buildCategory('fruits', AssetPaths.fruitImages),
        ..._buildCategory('dairy', AssetPaths.dairyImages),
      ]);

  static const Set<String> _seasonalIds = <String>{
    'vegetables_corn',
    'vegetables_green_peas',
    'vegetables_pumpkin',
    'fruits_mango',
    'fruits_muskmelon',
    'fruits_strawberry',
    'fruits_watermelon',
    'fruits_tender_coconut',
  };

  static List<ProductModel> products({
    String category = '',
    String shoppingMode = 'home',
    int limit = 0,
  }) {
    final String normalizedCategory = _normalize(category);
    final String mode = _normalize(shoppingMode) == 'shop' ? 'shop' : 'home';
    Iterable<ProductModel> values = all;

    if (normalizedCategory == 'seasonal') {
      values = values.where(
        (ProductModel product) => _seasonalIds.contains(product.id),
      );
    } else if (normalizedCategory.isNotEmpty) {
      values = values.where(
        (ProductModel product) =>
            _normalize(product.category) == normalizedCategory,
      );
    }

    final List<ProductModel> result = values
        .map((ProductModel product) => _forMode(product, mode))
        .toList(growable: false);
    if (limit > 0 && result.length > limit) {
      return List<ProductModel>.unmodifiable(result.take(limit));
    }
    return List<ProductModel>.unmodifiable(result);
  }

  static List<ProductModel> featured({
    String shoppingMode = 'home',
    int limit = 12,
  }) {
    const List<String> featuredIds = <String>[
      'vegetables_tomato',
      'fruits_apple',
      'dairy_milk',
      'vegetables_carrot',
      'fruits_banana',
      'dairy_curd',
      'vegetables_broccoli',
      'fruits_mango',
      'dairy_ghee',
      'vegetables_spinach',
      'fruits_pomegranate',
      'dairy_buttermilk',
    ];
    final Map<String, ProductModel> byId = <String, ProductModel>{
      for (final ProductModel product in all) product.id: product,
    };
    return featuredIds
        .map((String id) => byId[id])
        .whereType<ProductModel>()
        .take(limit)
        .map(
          (ProductModel product) => _forMode(
            product,
            _normalize(shoppingMode) == 'shop' ? 'shop' : 'home',
          ),
        )
        .toList(growable: false);
  }

  static ProductModel? find(String productId, {String shoppingMode = 'home'}) {
    final String id = _normalize(productId);
    for (final ProductModel product in all) {
      if (_normalize(product.id) == id) {
        return _forMode(
          product,
          _normalize(shoppingMode) == 'shop' ? 'shop' : 'home',
        );
      }
    }
    return null;
  }

  static List<ProductModel> _buildCategory(
    String category,
    Map<String, String> images,
  ) {
    int index = 0;
    return images.entries
        .map((MapEntry<String, String> entry) {
          final int current = index++;
          final double price = _priceFor(category, current);
          final double mrp =
              (price * (1.12 + (current % 4) * 0.03)).roundToDouble();
          final String englishName = _title(entry.key);
          final String name = ProductUtils.localizedName(englishName);
          return ProductModel(
            id: '${category}_${entry.key}',
            name: name,
            description:
                'Fresh $englishName, carefully quality-checked and packed for Farm To Home delivery.',
            category: category,
            imageUrl: entry.value,
            images: <String>[entry.value],
            shoppingMode: 'home',
            unit: _unitFor(category, entry.key),
            price: price,
            mrp: mrp,
            stockQuantity: 50 + (current % 8) * 10,
            inStock: true,
            isFresh: true,
            rating: 4.2 + (current % 7) * 0.1,
            reviewCount: 24 + current * 3,
            farmerId: '',
            nutritionInfo: _nutritionFor(category),
            benefits: _benefitsFor(category),
          );
        })
        .toList(growable: false);
  }

  static ProductModel _forMode(ProductModel product, String mode) {
    if (mode != 'shop') return product.copyWith(shoppingMode: 'home');
    final bool dairy = product.category == 'dairy';
    final double bulkPrice = product.price * (dairy ? 10 : 18);
    return product.copyWith(
      shoppingMode: 'shop',
      unit: dairy ? '12 pack' : '10 kg crate',
      price: (bulkPrice * 0.88).roundToDouble(),
      mrp: bulkPrice.roundToDouble(),
      stockQuantity: (product.stockQuantity / 10).floor().clamp(1, 999).toInt(),
    );
  }

  static double _priceFor(String category, int index) {
    if (category == 'dairy') return 48 + (index % 9) * 17;
    if (category == 'fruits') return 55 + (index % 12) * 14;
    return 24 + (index % 11) * 9;
  }

  static String _unitFor(String category, String key) {
    if (category == 'dairy') {
      if (key.contains('milk') || key == 'buttermilk' || key == 'lassi') {
        return '1 litre';
      }
      if (key == 'ghee') return '500 ml';
      if (key.contains('butter')) return '100 g';
      if (key.contains('cheese')) return '200 g';
      if (key == 'curd' || key == 'greek_yogurt') return '400 g';
      return '500 g';
    }

    if (category == 'vegetables') {
      const Set<String> bunches = <String>{
        'amaranth',
        'coriander',
        'curry_leaves',
        'dill_leaves',
        'fenugreek',
        'mint',
        'spinach',
        'spring_onion',
      };
      const Set<String> pieces = <String>{
        'ash_gourd',
        'bottle_gourd',
        'cabbage',
        'cauliflower',
        'chow_chow',
        'pumpkin',
        'raw_banana',
        'ridge_gourd',
        'snake_gourd',
      };
      if (bunches.contains(key)) return '1 fresh bunch';
      if (pieces.contains(key)) return '1 piece';
      if (key == 'green_chilli' || key == 'red_chilli' || key == 'asparagus') {
        return '250 g';
      }
      if (key == 'corn' || key == 'drumstick') return '2 pieces';
      return '500 g';
    }

    const Set<String> smallPacks = <String>{
      'apricot',
      'blackberry',
      'blueberry',
      'cranberry',
      'dates',
      'fig',
      'gooseberry',
      'jamun',
      'longan',
      'lychee',
      'mulberry',
      'raspberry',
      'strawberry',
    };
    const Set<String> singlePieces = <String>{
      'avocado',
      'coconut',
      'custard_apple',
      'dragon_fruit',
      'jackfruit',
      'mangosteen',
      'muskmelon',
      'papaya',
      'pineapple',
      'pomelo',
      'soursop',
      'tender_coconut',
      'watermelon',
      'wood_apple',
    };
    if (smallPacks.contains(key)) return '250 g';
    if (singlePieces.contains(key)) return '1 piece';
    if (key == 'banana' || key == 'red_banana' || key == 'plantain') {
      return '6 pieces';
    }
    if (key == 'grapes' || key == 'cherry' || key == 'clementine') {
      return '500 g';
    }
    return '1 kg';
  }

  static Map<String, String> _nutritionFor(String category) {
    if (category == 'dairy') {
      return const <String, String>{
        'Protein': 'Rich source',
        'Calcium': 'Naturally present',
        'Storage': 'Keep refrigerated',
      };
    }
    return const <String, String>{
      'Fibre': 'Naturally present',
      'Vitamins': 'Farm-fresh goodness',
      'Storage': 'Store in a cool place',
    };
  }

  static List<String> _benefitsFor(String category) {
    return <String>[
      'Quality checked at the hub',
      category == 'dairy' ? 'Cold-chain packed' : 'Freshly sorted and packed',
      'Fast, hygienic delivery',
    ];
  }

  static String _title(String key) {
    return key
        .split('_')
        .where((String part) => part.isNotEmpty)
        .map(
          (String part) =>
              '${part.substring(0, 1).toUpperCase()}${part.substring(1)}',
        )
        .join(' ');
  }

  static String _normalize(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
  }
}
