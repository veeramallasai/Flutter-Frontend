import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/premium_toast.dart';
import '../../data/local/local_product_catalog.dart';
import '../../data/models/farmer_model.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/cart_repository.dart';
import '../../data/repositories/favorite_repository.dart';
import '../../data/repositories/farmer_repository.dart';
import '../../data/repositories/product_repository.dart';
import 'widgets/add_to_cart_bar.dart';
import 'widgets/delivery_preview.dart';
import 'widgets/farmer_details_section.dart';
import 'widgets/nutrition_section.dart';
import 'widgets/product_benefits.dart';
import 'widgets/product_description.dart';
import 'widgets/product_image_gallery.dart';
import 'widgets/product_offer_section.dart';
import 'widgets/product_price_section.dart';
import 'widgets/product_reviews.dart';
import 'widgets/product_title_section.dart';
import 'widgets/product_unit_selector.dart';
import 'widgets/related_products.dart';
import 'widgets/retail_quantity_selector.dart';
import 'widgets/shop_owner_bulk_selector.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({
    super.key,
    required this.productId,
    this.initialShoppingMode = 'home',
  });

  final String productId;
  final String initialShoppingMode;

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final ProductRepository _productRepository = ProductRepository();
  final FarmerRepository _farmerRepository = FarmerRepository();
  final CartRepository _cartRepository = CartRepository();
  final FavoriteRepository _favoriteRepository = FavoriteRepository();

  ProductModel? _product;
  FarmerModel? _farmer;
  List<ProductModel> _relatedProducts = <ProductModel>[];
  String _selectedUnit = '';
  int _quantity = 1;
  int _bulkPackSize = 10;
  int _bulkPackCount = 1;
  bool _isLoading = true;
  bool _isAdding = false;
  bool _isFavorite = false;
  bool _isFavoriteBusy = false;
  String? _errorMessage;

  bool get _isShopMode {
    return widget.initialShoppingMode.trim().toLowerCase() == 'shop' ||
        (_product?.isShopProduct ?? false);
  }

  int get _cartQuantity =>
      _isShopMode ? _bulkPackSize * _bulkPackCount : _quantity;

  double get _totalPrice => (_product?.price ?? 0) * _cartQuantity;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    final String id = widget.productId.trim();
    if (id.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Product ID is missing.';
      });
      return;
    }

    try {
      ProductModel? product = await _productRepository.getProduct(id);
      if (widget.initialShoppingMode.trim().toLowerCase() == 'shop') {
        product = LocalProductCatalog.find(id, shoppingMode: 'shop') ?? product;
      }
      if (product == null) {
        throw StateError('Product not found.');
      }
      final ProductModel loadedProduct = product;

      final List<Future<dynamic>> requests = <Future<dynamic>>[
        _productRepository.getRelatedProducts(loadedProduct, limit: 10),
        if (loadedProduct.farmerId.trim().isNotEmpty)
          _farmerRepository.getFarmer(loadedProduct.farmerId),
        _loadFavorite(loadedProduct.id),
      ];
      final List<dynamic> results = await Future.wait<dynamic>(requests);

      if (!mounted) return;
      setState(() {
        _product = loadedProduct;
        _selectedUnit = loadedProduct.unit;
        _relatedProducts = results.first as List<ProductModel>;
        if (loadedProduct.farmerId.trim().isNotEmpty) {
          _farmer = results[1] as FarmerModel?;
        }
        _isFavorite = results.last as bool;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = _friendlyError(error);
      });
    }
  }

  Future<bool> _loadFavorite(String productId) async {
    try {
      return await _favoriteRepository.contains(productId);
    } catch (_) {
      return false;
    }
  }

  Future<void> _toggleFavorite() async {
    final ProductModel? product = _product;
    if (product == null || _isFavoriteBusy) return;
    final bool nextValue = !_isFavorite;
    setState(() {
      _isFavoriteBusy = true;
      _isFavorite = nextValue;
    });
    try {
      if (nextValue) {
        await _favoriteRepository.add(product.id);
      } else {
        await _favoriteRepository.remove(product.id);
      }
      if (!mounted) return;
      PremiumToast.show(
        context,
        nextValue ? 'Added to favourites' : 'Removed from favourites',
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _isFavorite = !nextValue);
      PremiumToast.show(context, _friendlyError(error), error: true);
    } finally {
      if (mounted) setState(() => _isFavoriteBusy = false);
    }
  }

  List<String> _availableUnits(ProductModel product) {
    final List<String> units = <String>[product.unit];
    final String category = product.category.toLowerCase();
    if (category.contains('dairy')) {
      units.addAll(<String>['500 ml', '1 litre']);
    } else {
      units.addAll(<String>['500 g', '1 kg', '2 kg']);
    }
    return units.toSet().toList(growable: false);
  }

  Future<bool> _addToCart({bool openCart = false}) async {
    final ProductModel? product = _product;
    if (product == null || _isAdding) return false;

    setState(() => _isAdding = true);
    try {
      await _cartRepository.addProduct(
        product,
        quantity: _cartQuantity,
        unit: _selectedUnit,
        shoppingMode: _isShopMode ? 'shop' : 'home',
      );
      if (!mounted) return true;
      PremiumToast.show(context, '${product.name} added to cart');
      if (openCart) {
        Navigator.pushNamed(context, AppRoutes.cart);
      }
      return true;
    } catch (error) {
      if (!mounted) return false;
      PremiumToast.show(context, _friendlyError(error), error: true);
      return false;
    } finally {
      if (mounted) setState(() => _isAdding = false);
    }
  }

  void _openRelatedProduct(ProductModel product) {
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.productDetails,
      arguments: <String, dynamic>{
        'productId': product.id,
        'shoppingMode': _isShopMode ? 'shop' : 'home',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ProductModel? product = _product;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Product Details'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Favourite',
            onPressed: _isFavoriteBusy ? null : _toggleFavorite,
            icon: Icon(
              _isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: _isFavorite ? AppColors.error : AppColors.textPrimary,
            ),
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
              : _errorMessage != null || product == null
              ? _ErrorView(
                message: _errorMessage ?? 'Unable to load product.',
                onRetry: () {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });
                  _loadProduct();
                },
              )
              : RefreshIndicator(
                color: AppColors.primary,
                onRefresh: _loadProduct,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
                  children: <Widget>[
                    ProductImageGallery(product: product),
                    const SizedBox(height: 20),
                    ProductTitleSection(product: product),
                    const SizedBox(height: 17),
                    ProductPriceSection(product: product),
                    const SizedBox(height: 18),
                    ProductUnitSelector(
                      units: _availableUnits(product),
                      selectedUnit: _selectedUnit,
                      onChanged: (String value) {
                        setState(() => _selectedUnit = value);
                      },
                    ),
                    const SizedBox(height: 17),
                    if (_isShopMode)
                      ShopOwnerBulkSelector(
                        selectedPackSize: _bulkPackSize,
                        packCount: _bulkPackCount,
                        unit: _selectedUnit,
                        onPackSizeChanged: (int value) {
                          setState(() => _bulkPackSize = value);
                        },
                        onPackCountChanged: (int value) {
                          setState(() => _bulkPackCount = value);
                        },
                      )
                    else
                      RetailQuantitySelector(
                        quantity: _quantity,
                        unit: _selectedUnit,
                        unitPrice: product.price,
                        maximumQuantity:
                            product.stockQuantity > 0
                                ? product.stockQuantity
                                : 20,
                        onChanged: (int value) {
                          setState(() => _quantity = value);
                        },
                      ),
                    const SizedBox(height: 17),
                    DeliveryPreview(
                      shoppingMode: _isShopMode ? 'shop' : 'home',
                    ),
                    const SizedBox(height: 22),
                    ProductOfferSection(product: product),
                    if (product.discountPercent > 0) const SizedBox(height: 22),
                    ProductDescription(product: product),
                    const SizedBox(height: 22),
                    ProductBenefits(product: product),
                    if (product.nutritionInfo.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 22),
                      NutritionSection(product: product),
                    ],
                    if (_farmer != null) ...<Widget>[
                      const SizedBox(height: 22),
                      FarmerDetailsSection(farmer: _farmer!),
                    ],
                    const SizedBox(height: 22),
                    ProductReviews(
                      rating: product.rating,
                      reviewCount: product.reviewCount,
                    ),
                    if (_relatedProducts.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 24),
                      RelatedProducts(
                        products: _relatedProducts,
                        onProductTap: _openRelatedProduct,
                        onAddTap: (ProductModel item) async {
                          try {
                            await _cartRepository.addProduct(item);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${item.name} added to cart.'),
                              ),
                            );
                          } catch (error) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(_friendlyError(error))),
                            );
                          }
                        },
                      ),
                    ],
                  ],
                ),
              ),
      bottomNavigationBar:
          product == null
              ? null
              : AddToCartBar(
                totalPrice: _totalPrice,
                quantity: _cartQuantity,
                isLoading: _isAdding,
                enabled: product.inStock,
                onAddToCart: _addToCart,
                onBuyNow: () => _addToCart(openCart: true),
              ),
    );
  }

  String _friendlyError(Object error) {
    String message = error.toString().trim();
    if (message.startsWith('Bad state: ')) {
      message = message.substring('Bad state: '.length);
    }
    return message.isEmpty
        ? 'Something went wrong. Please try again.'
        : message;
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.inventory_2_outlined,
              color: AppColors.textSecondary,
              size: 54,
            ),
            const SizedBox(height: 13),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 15),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('TRY AGAIN'),
            ),
          ],
        ),
      ),
    );
  }
}
