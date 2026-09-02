import 'package:farm_to_home_app/core/auth/backend_auth.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/premium_toast.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/models/product_model.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../providers/cart_provider.dart';
import '../home/widgets/floating_cart_bar.dart';
import '../home/widgets/product_card.dart';
import 'widgets/category_product_grid.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key, this.initialShoppingMode = 'home'});

  final String initialShoppingMode;

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  late String _shoppingMode;
  final Set<String> _addingProducts = <String>{};
  final ProductRepository _productRepository = ProductRepository();
  late final CartProvider _cartProvider;

  static const List<_CategoryData> _categories = <_CategoryData>[
    _CategoryData(
      id: 'vegetables',
      title: 'Vegetables',
      subtitle: 'Fresh from trusted farms',
      description:
          'Daily essentials, leafy greens, roots and fresh vegetables.',
      image: 'assets/images/categories/vegetables.png',
      fallbackIcon: Icons.eco_rounded,
      backgroundColor: Color(0xFFE8F5E9),
      accentColor: Color(0xFF168447),
    ),
    _CategoryData(
      id: 'fruits',
      title: 'Fruits',
      subtitle: 'Naturally fresh & sweet',
      description:
          'Seasonal and everyday fruits picked for freshness and quality.',
      image: 'assets/images/categories/fruits.png',
      fallbackIcon: Icons.shopping_basket_rounded,
      backgroundColor: Color(0xFFFFF3E5),
      accentColor: Color(0xFFE18124),
    ),
    _CategoryData(
      id: 'dairy',
      title: 'Dairy',
      subtitle: 'Pure farm goodness',
      description:
          'Fresh milk and essential dairy products for your daily needs.',
      image: 'assets/images/categories/dairy.png',
      fallbackIcon: Icons.local_drink_rounded,
      backgroundColor: Color(0xFFEAF4FF),
      accentColor: Color(0xFF3883C9),
    ),
    _CategoryData(
      id: 'seasonal',
      title: 'Seasonal',
      subtitle: 'Best of the harvest',
      description: 'Limited harvest products available at their seasonal best.',
      image: 'assets/images/categories/seasonal.png',
      fallbackIcon: Icons.wb_sunny_rounded,
      backgroundColor: Color(0xFFFFF6DD),
      accentColor: Color(0xFFC88A0D),
    ),
  ];

  @override
  void initState() {
    super.initState();

    _cartProvider = CartProvider()..listenToCart();

    _shoppingMode = widget.initialShoppingMode == 'shop' ? 'shop' : 'home';

    _loadMode();
  }

  @override
  void dispose() {
    _cartProvider.dispose();
    super.dispose();
  }

  Future<void> _loadMode() async {
    try {
      final User? user = BackendAuth.instance.currentUser;

      if (user == null) {
        return;
      }

      final UserModel userModel = await UserRepository().getCurrentUser();
      final String value = userModel.shoppingMode;

      if (!mounted) {
        return;
      }

      if (value == 'home' || value == 'shop') {
        setState(() {
          _shoppingMode = value;
        });
      }
    } catch (_) {
      // Current selected mode remains active.
    }
  }

  Future<void> _saveMode(String mode) async {
    try {
      final User? user = BackendAuth.instance.currentUser;

      if (user == null) {
        return;
      }

      await UserRepository().updateShoppingMode(mode);
    } catch (_) {
      // UI mode continues even if sync is temporarily unavailable.
    }
  }

  void _go(String route, {Object? arguments}) {
    Navigator.of(context).pushNamed(route, arguments: arguments);
  }

  void _openCategory(_CategoryData category) {
    _go(
      '/category-products',
      arguments: <String, dynamic>{
        'category': category.id,
        'title': category.title,
        'shoppingMode': _shoppingMode,
      },
    );
  }

  Future<void> _showModeSelector() async {
    final String? mode = await showModalBottomSheet<String>(
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
                  blurRadius: 38,
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
                  'Products, pack sizes and pricing change automatically based on your selection.',
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
                  subtitle: 'Retail packs • 250g • 500g • 1kg • 2kg',
                  selected: _shoppingMode == 'home',
                  onTap: () {
                    Navigator.of(sheetContext).pop('home');
                  },
                ),
                const SizedBox(height: 11),
                _ModeOption(
                  icon: Icons.storefront_rounded,
                  title: 'For Shop Owners',
                  subtitle: 'Bulk packs • Bag • Crate • Tray • Box',
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

    if (mode == null || mode == _shoppingMode) {
      return;
    }

    setState(() {
      _shoppingMode = mode;
    });

    await _saveMode(mode);
  }

  Future<void> _addToCart(ProductModel product) async {
    final String loadingKey = '${product.id}_$_shoppingMode';

    if (_addingProducts.contains(loadingKey)) {
      return;
    }

    setState(() {
      _addingProducts.add(loadingKey);
    });

    try {
      final bool success = await _cartProvider.addProduct(
        product,
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

  CartItemModel? _cartItemFor(ProductModel product) {
    final List<CartItemModel> items =
        _cartProvider.cart?.items ?? <CartItemModel>[];

    for (final CartItemModel item in items) {
      if (item.productId == product.id && item.shoppingMode == _shoppingMode) {
        return item;
      }
    }

    return null;
  }

  int _quantityFor(ProductModel product) =>
      _cartItemFor(product)?.quantity ?? 0;

  Future<void> _changeQuantity(
    ProductModel product,
    int difference,
  ) async {
    final String loadingKey = '${product.id}_$_shoppingMode';

    if (_addingProducts.contains(loadingKey)) {
      return;
    }

    final CartItemModel? item = _cartItemFor(product);

    if (item == null) {
      if (difference > 0) {
        await _addToCart(product);
      }
      return;
    }

    setState(() {
      _addingProducts.add(loadingKey);
    });

    final bool success = await _cartProvider.updateQuantity(
      item.id,
      item.quantity + difference,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _addingProducts.remove(loadingKey);
    });

    if (!success) {
      _showMessage(
        _cartProvider.errorMessage ?? 'Unable to update quantity.',
        error: true,
      );
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

  String _friendlyError(Object error) {
    String message = error.toString().trim();

    if (message.startsWith('Bad state: ')) {
      message = message.substring('Bad state: '.length);
    }

    return message.isEmpty ? 'Unable to add product to cart.' : message;
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    final bool desktop = width >= 900;

    return ListenableBuilder(
      listenable: _cartProvider,
      builder:
          (BuildContext context, Widget? child) => Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: Column(
                children: <Widget>[
                  _buildAppBar(desktop),
                  Expanded(
                    child: RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: _loadMode,
                      child: CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: <Widget>[
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(
                              desktop ? 34 : 16,
                              18,
                              desktop ? 34 : 16,
                              120,
                            ),
                            sliver: SliverList(
                              delegate: SliverChildListDelegate(<Widget>[
                                _buildModeSelector(),
                                const SizedBox(height: 16),
                                _buildSearchBar(),
                                const SizedBox(height: 18),
                                _buildHeroBanner(desktop),
                                const SizedBox(height: 30),
                                _buildHeading(),
                                const SizedBox(height: 20),
                                _buildCategoryProductsSections(desktop),
                                const SizedBox(height: 30),
                                _buildDeliveryBanner(),
                                const SizedBox(height: 22),
                                const _TrustStrip(),
                              ]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (_cartProvider.itemCount > 0)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: PremiumFloatingCartButton(
                      count: _cartProvider.itemCount,
                      total: _cartProvider.total,
                      onTap: () => _go('/cart'),
                    ),
                  ),
                NavigationBar(
                  selectedIndex: 1,
                  onDestinationSelected: (int index) {
                    switch (index) {
                      case 0:
                        Navigator.of(context).pushReplacementNamed('/home');
                        break;

                      case 1:
                        break;

                      case 2:
                        _go('/cart');
                        break;

                      case 3:
                        _go('/orders');
                        break;

                      case 4:
                        _go('/profile');
                        break;
                    }
                  },
                  destinations: const <NavigationDestination>[
                    NavigationDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home_rounded),
                      label: 'Home',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.grid_view_outlined),
                      selectedIcon: Icon(Icons.grid_view_rounded),
                      label: 'Categories',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.shopping_bag_outlined),
                      selectedIcon: Icon(Icons.shopping_bag_rounded),
                      label: 'Cart',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.receipt_long_outlined),
                      selectedIcon: Icon(Icons.receipt_long_rounded),
                      label: 'Orders',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.person_outline_rounded),
                      selectedIcon: Icon(Icons.person_rounded),
                      label: 'Profile',
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildAppBar(bool desktop) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: desktop ? 34 : 10,
        vertical: 10,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Color(0x0B000000),
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
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                Navigator.of(context).pushReplacementNamed('/home');
              }
            },
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          const SizedBox(width: 4),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[AppColors.primary, Color(0xFF2E7D32)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.grid_view_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 11),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'All Products',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Explore all farm-fresh products',
                  style: TextStyle(
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
            icon: const Icon(Icons.shopping_bag_outlined),
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
                  size: 21,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: () {
          _go('/search');
        },
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 58,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: const Row(
            children: <Widget>[
              Icon(Icons.search_rounded, color: AppColors.primary),
              SizedBox(width: 11),
              Expanded(
                child: Text(
                  'Search vegetables, fruits, dairy...',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.textSecondary,
                size: 19,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroBanner(bool desktop) {
    final bool home = _shoppingMode == 'home';

    return Container(
      constraints: BoxConstraints(minHeight: desktop ? 230 : 210),
      padding: EdgeInsets.all(desktop ? 30 : 22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors:
              home
                  ? const <Color>[
                    Color(0xFF1B5E20),
                    Color(0xFF0D7B40),
                    Color(0xFF2E7D32),
                  ]
                  : const <Color>[
                    Color(0xFF15382C),
                    Color(0xFF285F45),
                    Color(0xFF3C9565),
                  ],
        ),
        borderRadius: BorderRadius.circular(29),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x220B7A3E),
            blurRadius: 28,
            offset: Offset(0, 13),
          ),
        ],
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            right: -25,
            top: -50,
            child: Container(
              width: 210,
              height: 210,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x10FFFFFF),
              ),
            ),
          ),
          Positioned(
            right: desktop ? 45 : 8,
            bottom: 0,
            child: Icon(
              home ? Icons.eco_rounded : Icons.inventory_2_rounded,
              size: desktop ? 155 : 105,
              color: Colors.white.withValues(alpha: 0.14),
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: desktop ? 650 : 300),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    home ? 'FRESH COLLECTIONS' : 'WHOLESALE COLLECTIONS',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  home
                      ? 'Everything fresh in one place'
                      : 'Bulk freshness for your business',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: desktop ? 34 : 27,
                    height: 1.08,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  home
                      ? 'Explore vegetables, fruits, dairy and the freshest seasonal harvests.'
                      : 'Explore business-ready bags, crates, trays and boxes with bulk pricing.',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.5,
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

  Widget _buildHeading() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'All Products',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _shoppingMode == 'home'
                    ? 'All farm-fresh products grouped by category'
                    : 'All wholesale products grouped by category',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Text(
            'ALL PRODUCTS',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 9,
              letterSpacing: 0.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryProductsSections(bool desktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _categories.map((_CategoryData category) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildCategoryHeader(category),
            const SizedBox(height: 12),
            StreamBuilder<List<ProductModel>>(
              stream: _productRepository.watchProducts(
                category: category.id,
                shoppingMode: _shoppingMode,
                limit: 200,
              ),
              builder: (
                BuildContext context,
                AsyncSnapshot<List<ProductModel>> snapshot,
              ) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  );
                }

                final List<ProductModel> products =
                    snapshot.data ?? <ProductModel>[];

                if (products.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Text(
                      'No products found in this category.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }

                final double width = MediaQuery.sizeOf(context).width;

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: products.length,
                  gridDelegate: premiumCategoryProductGrid(width),
                  itemBuilder: (BuildContext context, int index) {
                    final ProductModel product = products[index];

                    return _buildCategoryProductCard(product);
                  },
                );
              },
            ),
            const SizedBox(height: 28),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildCategoryHeader(_CategoryData category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: category.backgroundColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: category.accentColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                category.fallbackIcon,
                size: 20,
                color: category.accentColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  category.title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  category.subtitle,
                  style: TextStyle(
                    color: category.accentColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => _openCategory(category),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: category.accentColor.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'View All',
                    style: TextStyle(
                      color: category.accentColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 13,
                    color: category.accentColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryProductCard(ProductModel product) {
    final int qty = _quantityFor(product);
    final String loadingKey = '${product.id}_$_shoppingMode';
    final bool adding = _addingProducts.contains(loadingKey);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(21),
      child: InkWell(
        onTap: () {
          _go(
            '/product-details',
            arguments: <String, dynamic>{
              'productId': product.id,
              'shoppingMode': _shoppingMode,
            },
          );
        },
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
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          product.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (
                            BuildContext context,
                            Object error,
                            StackTrace? stackTrace,
                          ) => const Center(
                            child: Icon(
                              Icons.eco_rounded,
                              color: AppColors.primary,
                              size: 36,
                            ),
                          ),
                        ),
                      ),
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
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '₹${product.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        if (product.mrp > product.price)
                          Text(
                            '₹${product.mrp.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 10,
                              decoration: TextDecoration.lineThrough,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
                  ProductQuantityControl(
                    quantity: qty,
                    loading: adding,
                    enabled: product.inStock,
                    compact: true,
                    onAdd: () => _addToCart(product),
                    onDecrease: () => _changeQuantity(product, -1),
                    onIncrease: () => _changeQuantity(product, 1),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeliveryBanner() {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: () {
          _go('/delivery-method');
        },
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border),
          ),
          child: const Row(
            children: <Widget>[
              CircleAvatar(
                radius: 27,
                backgroundColor: Color(0xFFE8F5E9),
                child: Icon(
                  Icons.local_shipping_rounded,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Flexible delivery',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Quick • Scheduled • Pre-Order',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PremiumCategoryCard extends StatelessWidget {
  const _PremiumCategoryCard({
    required this.category,
    required this.shoppingMode,
    required this.onTap,
  });

  final _CategoryData category;
  final String shoppingMode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(26),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(26),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: AppColors.border),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 17,
                offset: Offset(0, 7),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Center(
                  child: Container(
                    width: 126,
                    height: 126,
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: category.backgroundColor,
                      border: Border.all(
                        color: category.accentColor.withValues(alpha: 0.18),
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        category.image,
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                        errorBuilder: (
                          BuildContext context,
                          Object error,
                          StackTrace? stackTrace,
                        ) {
                          return Center(
                            child: Icon(
                              category.fallbackIcon,
                              size: 53,
                              color: category.accentColor,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 13),
              Text(
                category.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                category.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: category.accentColor,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                category.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10.5,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      shoppingMode == 'home' ? 'Retail packs' : 'Bulk packs',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: category.backgroundColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: category.accentColor,
                      size: 18,
                    ),
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

class _TrustStrip extends StatelessWidget {
  const _TrustStrip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Row(
        children: <Widget>[
          Expanded(
            child: _TrustItem(icon: Icons.eco_outlined, label: 'Farm Fresh'),
          ),
          _DividerLine(),
          Expanded(
            child: _TrustItem(
              icon: Icons.verified_outlined,
              label: 'Quality Checked',
            ),
          ),
          _DividerLine(),
          Expanded(
            child: _TrustItem(
              icon: Icons.delivery_dining_outlined,
              label: 'Fresh Delivery',
            ),
          ),
        ],
      ),
    );
  }
}

class _TrustItem extends StatelessWidget {
  const _TrustItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Icon(icon, color: AppColors.primary, size: 25),
        const SizedBox(height: 7),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _DividerLine extends StatelessWidget {
  const _DividerLine();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 7),
      color: const Color(0xFFCDE4D5),
    );
  }
}

class _CategoryData {
  const _CategoryData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.image,
    required this.fallbackIcon,
    required this.backgroundColor,
    required this.accentColor,
  });

  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String image;
  final IconData fallbackIcon;
  final Color backgroundColor;
  final Color accentColor;
}
