import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farm_to_home_app/core/auth/backend_auth.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/premium_toast.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository.dart';
import '../../providers/cart_provider.dart';
import '../home/widgets/floating_cart_bar.dart';
import '../home/widgets/product_card.dart';
import 'widgets/category_product_grid.dart';

class CategoryProductsScreen extends StatefulWidget {
  const CategoryProductsScreen({
    super.key,
    required this.category,
    required this.title,
    this.initialShoppingMode = 'home',
  });

  final String category;
  final String title;
  final String initialShoppingMode;

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  final TextEditingController _searchController = TextEditingController();

  final Set<String> _addingProducts = <String>{};
  final ProductRepository _productRepository = ProductRepository();
  late final CartProvider _cartProvider;

  late String _shoppingMode;

  String _searchQuery = '';
  String _filter = 'all';
  _ProductSort _sort = _ProductSort.relevance;

  @override
  void initState() {
    super.initState();

    _cartProvider = CartProvider()..listenToCart();

    _shoppingMode = widget.initialShoppingMode == 'shop' ? 'shop' : 'home';

    _loadSavedShoppingMode();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _cartProvider.dispose();
    super.dispose();
  }

  Future<void> _loadSavedShoppingMode() async {
    try {
      final User? user = BackendAuth.instance.currentUser;

      if (user == null) {
        return;
      }

      final DocumentSnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      final String mode =
          (snapshot.data()?['shoppingMode'] ?? _shoppingMode).toString();

      if (!mounted) {
        return;
      }

      if (mode == 'home' || mode == 'shop') {
        setState(() {
          _shoppingMode = mode;
        });
      }
    } catch (_) {
      // Current mode remains active.
    }
  }

  Future<void> _saveShoppingMode(String mode) async {
    try {
      final User? user = BackendAuth.instance.currentUser;

      if (user == null) {
        return;
      }

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
        <String, dynamic>{
          'shoppingMode': mode,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (_) {
      // UI remains usable if Firestore sync fails.
    }
  }

  Future<void> _refreshProducts() async {
    setState(() {});
  }

  void _go(String route, {Object? arguments}) {
    Navigator.of(context).pushNamed(route, arguments: arguments);
  }

  void _openProduct(_ProductViewModel product) {
    _go(
      '/product-details',
      arguments: <String, dynamic>{
        'productId': product.id,
        'shoppingMode': _shoppingMode,
      },
    );
  }

  Future<void> _showModeSelector() async {
    final String? selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0x28000000),
                  blurRadius: 40,
                  offset: Offset(0, 16),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: Container(
                    width: 42,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'Choose shopping mode',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'Pack sizes and prices change automatically for your selected shopping mode.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 20),

                _ModeOption(
                  icon: Icons.home_rounded,
                  title: 'For Home',
                  subtitle: 'Retail quantities • 250g • 500g • 1kg • 2kg',
                  selected: _shoppingMode == 'home',
                  onTap: () {
                    Navigator.of(sheetContext).pop('home');
                  },
                ),

                const SizedBox(height: 11),

                _ModeOption(
                  icon: Icons.storefront_rounded,
                  title: 'For Shop Owners',
                  subtitle: 'Bulk quantities • Bag • Crate • Tray • Box',
                  selected: _shoppingMode == 'shop',
                  onTap: () {
                    Navigator.of(sheetContext).pop('shop');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selected == null || selected == _shoppingMode) {
      return;
    }

    setState(() {
      _shoppingMode = selected;
    });

    await _saveShoppingMode(selected);
  }

  Future<void> _showSortSheet() async {
    final _ProductSort? selected = await showModalBottomSheet<_ProductSort>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
            ),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.78,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: Container(
                      width: 42,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Sort products',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _SortOption(
                    title: 'Recommended',
                    value: _ProductSort.relevance,
                    selected: _sort == _ProductSort.relevance,
                    onTap: () {
                      Navigator.of(sheetContext).pop(_ProductSort.relevance);
                    },
                  ),
                  _SortOption(
                    title: 'Price: Low to High',
                    value: _ProductSort.priceLow,
                    selected: _sort == _ProductSort.priceLow,
                    onTap: () {
                      Navigator.of(sheetContext).pop(_ProductSort.priceLow);
                    },
                  ),
                  _SortOption(
                    title: 'Price: High to Low',
                    value: _ProductSort.priceHigh,
                    selected: _sort == _ProductSort.priceHigh,
                    onTap: () {
                      Navigator.of(sheetContext).pop(_ProductSort.priceHigh);
                    },
                  ),
                  _SortOption(
                    title: 'Top Rated',
                    value: _ProductSort.rating,
                    selected: _sort == _ProductSort.rating,
                    onTap: () {
                      Navigator.of(sheetContext).pop(_ProductSort.rating);
                    },
                  ),
                  _SortOption(
                    title: 'Best Discount',
                    value: _ProductSort.discount,
                    selected: _sort == _ProductSort.discount,
                    onTap: () {
                      Navigator.of(sheetContext).pop(_ProductSort.discount);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (selected == null) {
      return;
    }

    setState(() {
      _sort = selected;
    });
  }

  Future<void> _addToCart(_ProductViewModel product) async {
    final String loadingKey = '${product.id}_$_shoppingMode';

    if (_addingProducts.contains(loadingKey)) {
      return;
    }

    setState(() {
      _addingProducts.add(loadingKey);
    });

    try {
      final bool success = await _cartProvider.addProduct(
        product.model,
        shoppingMode: _shoppingMode,
      );

      if (!success) {
        throw StateError(
          _cartProvider.errorMessage ?? 'Unable to add product to cart.',
        );
      }

      if (!mounted) {
        return;
      }

      PremiumToast.show(context, '${product.name} added to cart');
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(_friendlyError(error), error: true);
    } finally {
      if (mounted) {
        setState(() {
          _addingProducts.remove(loadingKey);
        });
      }
    }
  }

  void _showMessage(String message, {required bool error}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: error ? AppColors.error : AppColors.primary,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
  }

  CartItemModel? _cartItemFor(_ProductViewModel product) {
    final List<CartItemModel> items =
        _cartProvider.cart?.items ?? <CartItemModel>[];
    for (final CartItemModel item in items) {
      if (item.productId == product.id && item.shoppingMode == _shoppingMode) {
        return item;
      }
    }
    return null;
  }

  int _quantityFor(_ProductViewModel product) =>
      _cartItemFor(product)?.quantity ?? 0;

  Future<void> _changeQuantity(
    _ProductViewModel product,
    int difference,
  ) async {
    final String loadingKey = '${product.id}_$_shoppingMode';
    if (_addingProducts.contains(loadingKey)) return;

    final CartItemModel? item = _cartItemFor(product);
    if (item == null) {
      if (difference > 0) await _addToCart(product);
      return;
    }

    setState(() => _addingProducts.add(loadingKey));
    final bool success = await _cartProvider.updateQuantity(
      item.id,
      item.quantity + difference,
    );
    if (!mounted) return;
    setState(() => _addingProducts.remove(loadingKey));

    if (!success) {
      _showMessage(
        _cartProvider.errorMessage ?? 'Unable to update quantity.',
        error: true,
      );
    }
  }

  String _friendlyError(Object error) {
    String message = error.toString().trim();
    if (message.startsWith('Bad state: ')) {
      message = message.substring('Bad state: '.length);
    }
    return message.isEmpty ? 'Unable to add product to cart.' : message;
  }

  List<_ProductViewModel> _prepareProducts(List<ProductModel> values) {
    final String category = _normalize(widget.category);

    final List<_ProductViewModel> products =
        values.map(_ProductViewModel.fromModel).where((
          _ProductViewModel product,
        ) {
          final bool categoryMatch =
              category == 'seasonal' ||
              _normalize(product.category) == category;

          if (!categoryMatch) {
            return false;
          }

          if (!product.availableForMode) {
            return false;
          }

          if (_searchQuery.isNotEmpty) {
            final String query = _normalize(_searchQuery);

            final bool matches =
                _normalize(product.name).contains(query) ||
                _normalize(product.category).contains(query);

            if (!matches) {
              return false;
            }
          }

          if (_filter == 'stock' && !product.inStock) {
            return false;
          }

          if (_filter == 'offers' && product.discountPercent <= 0) {
            return false;
          }

          return true;
        }).toList();

    switch (_sort) {
      case _ProductSort.relevance:
        break;

      case _ProductSort.priceLow:
        products.sort(
          (_ProductViewModel a, _ProductViewModel b) =>
              a.price.compareTo(b.price),
        );
        break;

      case _ProductSort.priceHigh:
        products.sort(
          (_ProductViewModel a, _ProductViewModel b) =>
              b.price.compareTo(a.price),
        );
        break;

      case _ProductSort.rating:
        products.sort(
          (_ProductViewModel a, _ProductViewModel b) =>
              b.rating.compareTo(a.rating),
        );
        break;

      case _ProductSort.discount:
        products.sort(
          (_ProductViewModel a, _ProductViewModel b) =>
              b.discountPercent.compareTo(a.discountPercent),
        );
        break;
    }

    return products;
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;

    final bool desktop = screenWidth >= 1000;

    return ListenableBuilder(
      listenable: _cartProvider,
      builder:
          (BuildContext context, Widget? child) => Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: Column(
                children: <Widget>[
                  _buildAppBar(desktop: desktop),
                  Expanded(
                    child: StreamBuilder<List<ProductModel>>(
                      stream: _productRepository.watchProducts(
                        category: widget.category,
                        shoppingMode: _shoppingMode,
                        limit: 200,
                      ),
                      builder: (
                        BuildContext context,
                        AsyncSnapshot<List<ProductModel>> snapshot,
                      ) {
                        final List<_ProductViewModel> products =
                            snapshot.hasData
                                ? _prepareProducts(snapshot.data!)
                                : <_ProductViewModel>[];

                        return RefreshIndicator(
                          color: AppColors.primary,
                          onRefresh: _refreshProducts,
                          child: CustomScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            slivers: <Widget>[
                              SliverPadding(
                                padding: EdgeInsets.fromLTRB(
                                  desktop ? 32 : 16,
                                  16,
                                  desktop ? 32 : 16,
                                  0,
                                ),
                                sliver: SliverList(
                                  delegate: SliverChildListDelegate(<Widget>[
                                    _buildModeSelector(),
                                    const SizedBox(height: 14),
                                    _buildHero(),
                                    const SizedBox(height: 18),
                                    _buildSearch(),
                                    const SizedBox(height: 14),
                                    _buildFilters(
                                      productCount: products.length,
                                    ),
                                    const SizedBox(height: 22),
                                  ]),
                                ),
                              ),

                              if (snapshot.connectionState ==
                                  ConnectionState.waiting)
                                const SliverFillRemaining(
                                  hasScrollBody: false,
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              else if (snapshot.hasError)
                                SliverFillRemaining(
                                  hasScrollBody: false,
                                  child: _ErrorState(
                                    onRetry: () {
                                      setState(() {});
                                    },
                                  ),
                                )
                              else if (products.isEmpty)
                                SliverFillRemaining(
                                  hasScrollBody: false,
                                  child: _EmptyState(
                                    title: widget.title,
                                    hasSearch: _searchQuery.isNotEmpty,
                                    onClear: () {
                                      _searchController.clear();

                                      setState(() {
                                        _searchQuery = '';
                                        _filter = 'all';
                                      });
                                    },
                                  ),
                                )
                              else
                                SliverPadding(
                                  padding: EdgeInsets.fromLTRB(
                                    desktop ? 32 : 16,
                                    0,
                                    desktop ? 32 : 16,
                                    125,
                                  ),
                                  sliver: SliverGrid(
                                    delegate: SliverChildBuilderDelegate((
                                      BuildContext context,
                                      int index,
                                    ) {
                                      final _ProductViewModel product =
                                          products[index];

                                      final String loadingKey =
                                          '${product.id}_$_shoppingMode';

                                      return _ProductCard(
                                        product: product,
                                        quantity: _quantityFor(product),
                                        adding: _addingProducts.contains(
                                          loadingKey,
                                        ),
                                        onTap: () {
                                          _openProduct(product);
                                        },
                                        onAdd: () {
                                          _addToCart(product);
                                        },
                                        onDecrease: () {
                                          _changeQuantity(product, -1);
                                        },
                                        onIncrease: () {
                                          _changeQuantity(product, 1);
                                        },
                                      );
                                    }, childCount: products.length),
                                    gridDelegate: premiumCategoryProductGrid(
                                      screenWidth,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            floatingActionButton: PremiumFloatingCartButton(
              count: _cartProvider.itemCount,
              total: _cartProvider.total,
              label: 'Cart',
              onTap: () => _go('/cart'),
            ),
          ),
    );
  }

  Widget _buildAppBar({required bool desktop}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: desktop ? 30 : 8, vertical: 9),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          IconButton(
            tooltip: 'Back',
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          const SizedBox(width: 3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  widget.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _shoppingMode == 'home'
                      ? 'Fresh retail collection'
                      : 'Wholesale bulk collection',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Search',
            onPressed: () {
              _go('/search');
            },
            icon: const Icon(Icons.search_rounded),
          ),
          IconButton(
            tooltip: 'Cart',
            onPressed: () {
              _go('/cart');
            },
            icon: CartBadgeIcon(count: _cartProvider.itemCount),
          ),
        ],
      ),
    );
  }

  Widget _buildModeSelector() {
    final bool homeMode = _shoppingMode == 'home';

    return Align(
      alignment: Alignment.centerLeft,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          onTap: _showModeSelector,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    homeMode ? Icons.home_rounded : Icons.storefront_rounded,
                    size: 19,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Shopping for',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      homeMode ? 'Home' : 'Shop Owners',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 9),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textSecondary,
                  size: 21,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHero() {
    final _CategoryStyle style = _categoryStyle(widget.category);

    return Container(
      height: 175,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[style.dark, style.accent],
        ),
        borderRadius: BorderRadius.circular(27),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x1B000000),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            right: -22,
            top: -42,
            child: Container(
              width: 175,
              height: 175,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x10FFFFFF),
              ),
            ),
          ),
          Positioned(
            right: 5,
            bottom: -5,
            child: SizedBox(
              width: 125,
              height: 125,
              child: ClipOval(
                child: Container(
                  color: Colors.white.withValues(alpha: 0.12),
                  padding: const EdgeInsets.all(12),
                  child: Image.asset(
                    style.image,
                    fit: BoxFit.contain,
                    errorBuilder: (
                      BuildContext context,
                      Object error,
                      StackTrace? stackTrace,
                    ) {
                      return Icon(
                        style.icon,
                        color: Colors.white.withValues(alpha: 0.45),
                        size: 68,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    _shoppingMode == 'home' ? 'FARM FRESH' : 'BULK FRESH',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8.5,
                      letterSpacing: 0.7,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  _shoppingMode == 'home'
                      ? 'Fresh retail packs selected for your everyday needs.'
                      : 'Business-ready bulk packs with wholesale pricing.',
                  maxLines: 2,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11.5,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return TextField(
      controller: _searchController,
      onChanged: (String value) {
        setState(() {
          _searchQuery = value.trim();
        });
      },
      decoration: InputDecoration(
        hintText: 'Search in ${widget.title}',
        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
        suffixIcon:
            _searchQuery.isEmpty
                ? null
                : IconButton(
                  onPressed: () {
                    _searchController.clear();

                    setState(() {
                      _searchQuery = '';
                    });
                  },
                  icon: const Icon(Icons.close_rounded),
                ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildFilters({required int productCount}) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                '$productCount products',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            OutlinedButton.icon(
              onPressed: _showSortSheet,
              icon: const Icon(Icons.sort_rounded, size: 18),
              label: const Text('Sort'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 39,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: <Widget>[
              _FilterChip(
                label: 'All',
                selected: _filter == 'all',
                onTap: () {
                  setState(() {
                    _filter = 'all';
                  });
                },
              ),
              _FilterChip(
                label: 'In Stock',
                selected: _filter == 'stock',
                onTap: () {
                  setState(() {
                    _filter = 'stock';
                  });
                },
              ),
              _FilterChip(
                label: 'Offers',
                selected: _filter == 'offers',
                onTap: () {
                  setState(() {
                    _filter = 'offers';
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.quantity,
    required this.adding,
    required this.onTap,
    required this.onAdd,
    required this.onDecrease,
    required this.onIncrease,
  });

  final _ProductViewModel product;
  final int quantity;
  final bool adding;
  final VoidCallback onTap;
  final VoidCallback onAdd;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(21),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(21),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(21),
            border: Border.all(color: AppColors.border),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x07000000),
                blurRadius: 14,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Stack(
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F8F5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: _ProductImage(image: product.image),
                    ),

                    if (product.discountPercent > 0)
                      Positioned(
                        top: 6,
                        left: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${product.discountPercent}% OFF',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),

                    if (!product.inStock)
                      Positioned.fill(
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.72),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.textPrimary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'OUT OF STOCK',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 9),

              Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12.5,
                  height: 1.25,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 5),

              Row(
                children: <Widget>[
                  const Icon(
                    Icons.verified_rounded,
                    size: 13,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      product.unit,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              if (product.rating > 0)
                Row(
                  children: <Widget>[
                    const Icon(
                      Icons.star_rounded,
                      size: 14,
                      color: Color(0xFFFFA000),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      product.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),

              const Spacer(),

              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          _currency(product.price),
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        if (product.mrp > product.price)
                          Text(
                            _currency(product.mrp),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 9.5,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        if (product.savings > 0)
                          Text(
                            'Save ${_currency(product.savings)}',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 8.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 6),
                  ProductQuantityControl(
                    quantity: quantity,
                    loading: adding,
                    enabled: product.inStock,
                    compact: true,
                    onAdd: onAdd,
                    onDecrease: onDecrease,
                    onIncrease: onIncrease,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.image});

  final String image;

  @override
  Widget build(BuildContext context) {
    if (image.trim().isEmpty) {
      return const Center(
        child: Icon(Icons.eco_rounded, color: AppColors.primary, size: 52),
      );
    }

    return PremiumProductImage(path: image);
  }
}

class _ModeOption extends StatelessWidget {
  const _ModeOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFE8F5E9) : const Color(0xFFF9FAF9),
      borderRadius: BorderRadius.circular(19),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(19),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(19),
            border: Border.all(
              color: selected ? const Color(0xFFB7DFC7) : AppColors.border,
            ),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  icon,
                  color: selected ? Colors.white : AppColors.primary,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10.5,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: selected ? AppColors.primary : AppColors.border,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 9),
      child: Material(
        color: selected ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(30),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.border,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.textSecondary,
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SortOption extends StatelessWidget {
  const _SortOption({
    required this.title,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final _ProductSort value;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      trailing: Icon(
        selected
            ? Icons.radio_button_checked_rounded
            : Icons.radio_button_unchecked_rounded,
        color: selected ? AppColors.primary : AppColors.textSecondary,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.title,
    required this.hasSearch,
    required this.onClear,
  });

  final String title;
  final bool hasSearch;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 85,
              height: 85,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                color: AppColors.primary,
                size: 38,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              hasSearch
                  ? 'No matching products'
                  : 'No $title products available',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'Products added to Firestore will appear here automatically.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            if (hasSearch) ...<Widget>[
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: onClear,
                child: const Text('CLEAR FILTERS'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.cloud_off_outlined,
              color: AppColors.error,
              size: 52,
            ),
            const SizedBox(height: 15),
            const Text(
              'Unable to load products',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Check your connection and Firestore configuration.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 15),
            FilledButton(onPressed: onRetry, child: const Text('RETRY')),
          ],
        ),
      ),
    );
  }
}

class _ProductViewModel {
  const _ProductViewModel({
    required this.model,
    required this.id,
    required this.name,
    required this.category,
    required this.image,
    required this.unit,
    required this.price,
    required this.mrp,
    required this.rating,
    required this.inStock,
    required this.discountPercent,
    required this.availableForMode,
  });

  final ProductModel model;
  final String id;
  final String name;
  final String category;
  final String image;
  final String unit;

  final double price;
  final double mrp;
  final double rating;

  final bool inStock;
  final int discountPercent;
  final bool availableForMode;
  double get savings => mrp > price ? mrp - price : 0;

  factory _ProductViewModel.fromModel(ProductModel product) {
    return _ProductViewModel(
      model: product,
      id: product.id,
      name: product.name,
      category: product.category,
      image: product.imageUrl,
      unit: product.unit,
      price: product.price,
      mrp: product.mrp,
      rating: product.rating,
      inStock: product.inStock,
      discountPercent: product.discountPercent,
      availableForMode: true,
    );
  }
}

enum _ProductSort { relevance, priceLow, priceHigh, rating, discount }

class _CategoryStyle {
  const _CategoryStyle({
    required this.dark,
    required this.accent,
    required this.image,
    required this.icon,
  });

  final Color dark;
  final Color accent;
  final String image;
  final IconData icon;
}

_CategoryStyle _categoryStyle(String category) {
  switch (_normalize(category)) {
    case 'fruits':
      return const _CategoryStyle(
        dark: Color(0xFF8D4B11),
        accent: Color(0xFFE58D2E),
        image: 'assets/images/categories/fruits.png',
        icon: Icons.shopping_basket_rounded,
      );

    case 'dairy':
      return const _CategoryStyle(
        dark: Color(0xFF174F77),
        accent: Color(0xFF438EC4),
        image: 'assets/images/categories/dairy.png',
        icon: Icons.local_drink_rounded,
      );

    case 'seasonal':
      return const _CategoryStyle(
        dark: Color(0xFF79550B),
        accent: Color(0xFFD69B21),
        image: 'assets/images/categories/seasonal.png',
        icon: Icons.wb_sunny_rounded,
      );

    case 'vegetables':
    default:
      return const _CategoryStyle(
        dark: Color(0xFF064324),
        accent: Color(0xFF2E7D32),
        image: 'assets/images/categories/vegetables.png',
        icon: Icons.eco_rounded,
      );
  }
}

String _normalize(String value) {
  return value
      .trim()
      .toLowerCase()
      .replaceAll('_', '')
      .replaceAll('-', '')
      .replaceAll(' ', '');
}

String _currency(double value) {
  final bool whole = value == value.roundToDouble();

  final String amount =
      whole ? value.toStringAsFixed(0) : value.toStringAsFixed(2);

  return '₹$amount';
}
