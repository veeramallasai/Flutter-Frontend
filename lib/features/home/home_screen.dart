import 'dart:async';

import 'package:farm_to_home_app/core/auth/backend_auth.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/premium_toast.dart';
import '../../data/local/local_product_catalog.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/models/product_model.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/user_repository.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../categories/widgets/category_product_grid.dart';
import 'widgets/floating_cart_bar.dart';
import 'widgets/banner_slider.dart';
import 'widgets/bottom_navigation.dart';
import 'widgets/category_card.dart';
import 'widgets/category_section.dart';
import 'widgets/home_app_bar.dart';
import 'widgets/home_search_bar.dart';
import 'widgets/offer_section.dart';
import 'widgets/product_card.dart';
import 'widgets/product_section.dart';
import 'widgets/recommended_section.dart';
import 'widgets/shopping_mode_selector.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _bannerController = PageController();
  late final CartProvider _cartProvider;
  late final ProductProvider _productProvider;
  final Set<String> _addingProducts = <String>{};

  Timer? _bannerTimer;

  String _shoppingMode = 'home';
  int _currentBanner = 0;

  static const List<_CategoryItem> _categories = <_CategoryItem>[
    _CategoryItem(
      title: 'Vegetables',
      subtitle: 'Farm Fresh',
      value: 'vegetables',
      image: 'assets/images/categories/vegetables.png',
      fallbackIcon: Icons.eco_rounded,
    ),
    _CategoryItem(
      title: 'Fruits',
      subtitle: 'Naturally Sweet',
      value: 'fruits',
      image: 'assets/images/categories/fruits.png',
      fallbackIcon: Icons.shopping_basket_rounded,
    ),
    _CategoryItem(
      title: 'Dairy',
      subtitle: 'Pure & Fresh',
      value: 'dairy',
      image: 'assets/images/categories/dairy.png',
      fallbackIcon: Icons.local_drink_rounded,
    ),
    _CategoryItem(
      title: 'Seasonal',
      subtitle: 'Season Picks',
      value: 'seasonal',
      image: 'assets/images/categories/seasonal.png',
      fallbackIcon: Icons.wb_sunny_rounded,
    ),
  ];

  List<_HomeBanner> get _banners {
    if (_shoppingMode == 'shop') {
      return const <_HomeBanner>[
        _HomeBanner(
          badge: 'WHOLESALE FRESH',
          title: 'Fresh stock for your business',
          subtitle:
              'Buy vegetables, fruits and dairy in bulk with special shop-owner pricing.',
          button: 'SHOP BULK',
          icon: Icons.storefront_rounded,
          startColor: Color(0xFF063B24),
          endColor: Color(0xFF149551),
          route: '/categories',
        ),
        _HomeBanner(
          badge: 'BUSINESS SAVINGS',
          title: 'Order more and save more',
          subtitle:
              'Get better value on bags, crates, trays and wholesale boxes.',
          button: 'VIEW DEALS',
          icon: Icons.inventory_2_rounded,
          startColor: Color(0xFF183E32),
          endColor: Color(0xFF3C8D63),
          route: '/categories',
        ),
        _HomeBanner(
          badge: 'PRE-ORDER STOCK',
          title: 'Reserve tomorrow\'s supply today',
          subtitle:
              'Plan bulk orders in advance and select a convenient delivery date.',
          button: 'PRE-ORDER',
          icon: Icons.calendar_month_rounded,
          startColor: Color(0xFF60450F),
          endColor: Color(0xFFD18C17),
          route: '/delivery-method',
        ),
      ];
    }

    return const <_HomeBanner>[
      _HomeBanner(
        badge: 'FARM FRESH',
        title: 'Fresh from farms to your home',
        subtitle:
            'Handpicked vegetables, fruits and dairy delivered fresh every day.',
        button: 'SHOP FRESH',
        icon: Icons.eco_rounded,
        startColor: Color(0xFF1B5E20),
        endColor: Color(0xFF2E7D32),
        route: '/categories',
      ),
      _HomeBanner(
        badge: 'DELIVERY YOUR WAY',
        title: 'Freshness that fits your schedule',
        subtitle:
            'Choose quick delivery, schedule a slot or pre-order for another day.',
        button: 'CHOOSE DELIVERY',
        icon: Icons.local_shipping_rounded,
        startColor: Color(0xFF103D37),
        endColor: Color(0xFF178D79),
        route: '/delivery-method',
      ),
      _HomeBanner(
        badge: 'SEASON SPECIAL',
        title: 'Limited harvest. Freshest picks.',
        subtitle:
            'Discover seasonal products and reserve limited farm harvests early.',
        button: 'EXPLORE NOW',
        icon: Icons.energy_savings_leaf_rounded,
        startColor: Color(0xFF67470E),
        endColor: Color(0xFFD09118),
        route: '/categories',
      ),
    ];
  }

  List<_ProductItem> get _products {
    final List<ProductModel> backendProducts = _productProvider.products
        .where(
          (ProductModel product) =>
              product.shoppingMode.isEmpty ||
              product.shoppingMode == _shoppingMode,
        )
        .toList(growable: false);
    final List<ProductModel> values =
        backendProducts.isNotEmpty
            ? backendProducts
            : LocalProductCatalog.products(
              shoppingMode: _shoppingMode,
              limit: 200,
            );
    return values.map(_ProductItem.fromModel).toList(growable: false);
  }

  @override
  void initState() {
    super.initState();

    _cartProvider = CartProvider()..listenToCart();
    _productProvider =
        ProductProvider()
          ..listenToProducts(shoppingMode: _shoppingMode, limit: 200);
    _loadShoppingMode();
    _startBannerAutoSlide();
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    _cartProvider.dispose();
    _productProvider.dispose();
    super.dispose();
  }

  void _startBannerAutoSlide() {
    _bannerTimer?.cancel();

    _bannerTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_bannerController.hasClients) {
        return;
      }

      final int next = (_currentBanner + 1) % _banners.length;

      _bannerController.animateToPage(
        next,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    });
  }

  Future<void> _loadShoppingMode() async {
    try {
      final User? user = BackendAuth.instance.currentUser;

      if (user == null) {
        return;
      }

      final UserModel userModel = await UserRepository().getCurrentUser();
      final String mode = userModel.shoppingMode;

      if (!mounted) {
        return;
      }

      if (mode == 'home' || mode == 'shop') {
        setState(() {
          _shoppingMode = mode;
        });
        _productProvider.setShoppingMode(mode);
      }
    } catch (_) {
      // Default Home mode remains active.
    }
  }

  Future<void> _saveShoppingMode(String mode) async {
    try {
      final User? user = BackendAuth.instance.currentUser;

      if (user == null) {
        return;
      }

      await UserRepository().updateShoppingMode(mode);
    } catch (_) {
      // UI continues even when network sync fails.
    }
  }

  String get _userName {
    final User? user = BackendAuth.instance.currentUser;

    final String name = user?.displayName?.trim() ?? '';

    if (name.isEmpty) {
      return 'Fresh Shopper';
    }

    return name.split(RegExp(r'\s+')).first;
  }

  void _go(String route, {Object? arguments}) {
    Navigator.of(context).pushNamed(route, arguments: arguments);
  }

  void _openCategory(_CategoryItem category) {
    _go(
      '/category-products',
      arguments: <String, dynamic>{
        'category': category.value,
        'title': category.title,
        'shoppingMode': _shoppingMode,
      },
    );
  }

  void _openProduct(_ProductItem product) {
    _go(
      '/product-details',
      arguments: <String, dynamic>{
        'productId': product.id,
        'shoppingMode': _shoppingMode,
      },
    );
  }

  Future<void> _addToCart(_ProductItem product) async {
    if (_addingProducts.contains(product.id)) return;
    setState(() => _addingProducts.add(product.id));

    final bool success = await _cartProvider.addProduct(
      product.model,
      shoppingMode: _shoppingMode,
    );
    if (!mounted) return;

    setState(() => _addingProducts.remove(product.id));
    final String message =
        success
            ? '${product.name} added to cart'
            : (_cartProvider.errorMessage ?? 'Unable to add product to cart.');
    PremiumToast.show(context, message, error: !success);
  }

  CartItemModel? _cartItemFor(_ProductItem product) {
    final List<CartItemModel> items =
        _cartProvider.cart?.items ?? <CartItemModel>[];
    for (final CartItemModel item in items) {
      if (item.productId == product.id && item.shoppingMode == _shoppingMode) {
        return item;
      }
    }
    return null;
  }

  int _quantityFor(_ProductItem product) =>
      _cartItemFor(product)?.quantity ?? 0;

  Future<void> _changeQuantity(_ProductItem product, int difference) async {
    if (_addingProducts.contains(product.id)) return;
    final CartItemModel? item = _cartItemFor(product);
    if (item == null) {
      if (difference > 0) await _addToCart(product);
      return;
    }

    setState(() => _addingProducts.add(product.id));
    final int nextQuantity = item.quantity + difference;
    final bool success = await _cartProvider.updateQuantity(
      item.id,
      nextQuantity,
    );
    if (!mounted) return;
    setState(() => _addingProducts.remove(product.id));
    if (!success) {
      PremiumToast.show(
        context,
        _cartProvider.errorMessage ?? 'Unable to update quantity.',
        error: true,
      );
    }
  }

  Future<void> _showShoppingModeSelector() async {
    final String? selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext bottomSheetContext) {
        return SafeArea(
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0x26000000),
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
                  'Prices, quantities and available deals change based on your shopping mode.',
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
                  subtitle: 'Retail shopping • 250g • 500g • 1kg • 2kg',
                  selected: _shoppingMode == 'home',
                  onTap: () {
                    Navigator.of(bottomSheetContext).pop('home');
                  },
                ),
                const SizedBox(height: 11),
                _ModeOption(
                  icon: Icons.storefront_rounded,
                  title: 'For Shop Owners',
                  subtitle: 'Bulk shopping • Bag • Crate • Tray • Box',
                  selected: _shoppingMode == 'shop',
                  onTap: () {
                    Navigator.of(bottomSheetContext).pop('shop');
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
      _currentBanner = 0;
    });

    if (_bannerController.hasClients) {
      _bannerController.jumpToPage(0);
    }

    await _saveShoppingMode(selected);
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;

    final bool desktop = screenWidth >= 950;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            PremiumHomeAppBar(child: _buildHeader(desktop: desktop)),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async {
                  await _loadShoppingMode();
                },
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: <Widget>[
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        desktop ? 34 : 16,
                        15,
                        desktop ? 34 : 16,
                        125,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate(<Widget>[
                          ShoppingModeSelector(
                            mode: _shoppingMode,
                            onTap: _showShoppingModeSelector,
                            child: _buildShoppingModeButton(),
                          ),
                          const SizedBox(height: 14),
                          PremiumHomeSearchBar(
                            onTap: () => _go('/search'),
                            child: _buildSearchBar(),
                          ),
                          const SizedBox(height: 18),
                          BannerSlider(
                            itemCount: _banners.length,
                            currentIndex: _currentBanner,
                            indicator: _buildBannerIndicator(),
                            child: _buildBannerCarousel(desktop: desktop),
                          ),
                          const SizedBox(height: 24),
                          _buildServiceStrip(),
                          const SizedBox(height: 30),
                          CategorySection(
                            categories: _buildCategoryList(),
                            onViewAll: () => _go('/categories'),
                            header: _buildSectionHeader(
                              title: 'Shop by category',
                              subtitle:
                                  'Fresh essentials, directly from trusted farms',
                              action: 'View all',
                              onTap: () => _go('/categories'),
                            ),
                          ),
                          const SizedBox(height: 30),
                          OfferSection(
                            onTap: () => _go('/categories'),
                            child: _buildSpecialOffer(),
                          ),
                          const SizedBox(height: 30),
                          ProductSection(
                            title: 'All Products',
                            subtitle: 'Explore every product available for you',
                            products: _buildProducts(desktop: desktop),
                            onViewAll: () => _go('/categories'),
                            header: _buildSectionHeader(
                              title: 'All Products',
                              subtitle:
                                  'Explore every product available for you',
                              action: 'View all',
                              onTap: () => _go('/categories'),
                            ),
                          ),
                          const SizedBox(height: 30),
                          RecommendedSection(
                            children: <Widget>[
                              _buildTrustSection(),
                              _buildDeliverySection(),
                            ],
                          ),
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
      floatingActionButton: ListenableBuilder(
        listenable: _cartProvider,
        builder: (BuildContext context, Widget? child) {
          return PremiumFloatingCartButton(
            count: _cartProvider.itemCount,
            total: _cartProvider.total,
            onTap: () => _go('/cart'),
          );
        },
      ),
      bottomNavigationBar: ListenableBuilder(
        listenable: _cartProvider,
        builder:
            (BuildContext context, Widget? child) => PremiumBottomNavigation(
              cartCount: _cartProvider.itemCount,
              selectedIndex: 0,
              onSelected: (int index) {
                switch (index) {
                  case 1:
                    _go('/categories');
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
            ),
      ),
    );
  }

  Widget _buildHeader({required bool desktop}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: desktop ? 34 : 16,
        vertical: 11,
      ),
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
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[Color(0xFF2E7D32), Color(0xFF2E7D32)],
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.eco_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Hi, $_userName 👋',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    _go('/addresses');
                  },
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        Icons.location_on_outlined,
                        color: AppColors.primary,
                        size: 15,
                      ),
                      SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          'Select delivery location',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 17,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              IconButton(
                tooltip: 'Notifications',
                onPressed: () {
                  _go('/notifications');
                },
                icon: const Icon(Icons.notifications_none_rounded),
              ),
              Positioned(
                right: 9,
                top: 8,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE64646),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 3),
          Material(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(15),
            child: InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: () {
                _go('/profile');
              },
              child: const SizedBox(
                width: 45,
                height: 45,
                child: Icon(
                  Icons.person_outline_rounded,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShoppingModeButton() {
    final bool homeMode = _shoppingMode == 'home';

    return Align(
      alignment: Alignment.centerLeft,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: _showShoppingModeSelector,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: AppColors.border),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0x08000000),
                  blurRadius: 12,
                  offset: Offset(0, 5),
                ),
              ],
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
                    const SizedBox(height: 1),
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
                const SizedBox(width: 10),
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
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          _go('/search');
        },
        child: Container(
          height: 58,
          padding: const EdgeInsets.symmetric(horizontal: 15),
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
                Icons.tune_rounded,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBannerCarousel({required bool desktop}) {
    return SizedBox(
      height: desktop ? 275 : 225,
      child: PageView.builder(
        controller: _bannerController,
        itemCount: _banners.length,
        onPageChanged: (int index) {
          setState(() {
            _currentBanner = index;
          });
        },
        itemBuilder: (BuildContext context, int index) {
          final _HomeBanner banner = _banners[index];

          return _PremiumBanner(
            banner: banner,
            desktop: desktop,
            onTap: () {
              _go(banner.route);
            },
          );
        },
      ),
    );
  }

  Widget _buildBannerIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(_banners.length, (int index) {
        final bool active = index == _currentBanner;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: active ? 25 : 7,
          height: 7,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: active ? AppColors.primary : AppColors.border,
            borderRadius: BorderRadius.circular(20),
          ),
        );
      }),
    );
  }

  Widget _buildServiceStrip() {
    return SizedBox(
      height: 72,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: const <Widget>[
          _ServiceCard(
            icon: Icons.bolt_rounded,
            title: 'Quick',
            subtitle: 'Delivery',
          ),
          _ServiceCard(
            icon: Icons.schedule_rounded,
            title: 'Schedule',
            subtitle: 'Your Slot',
          ),
          _ServiceCard(
            icon: Icons.calendar_month_rounded,
            title: 'Pre-Order',
            subtitle: 'In Advance',
          ),
          _ServiceCard(
            icon: Icons.verified_rounded,
            title: 'Trusted',
            subtitle: 'Farmers',
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList() {
    return SizedBox(
      height: 148,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (BuildContext context, int index) {
          return const SizedBox(width: 22);
        },
        itemBuilder: (BuildContext context, int index) {
          final _CategoryItem category = _categories[index];

          return _RoundCategoryCard(
            category: category,
            onTap: () {
              _openCategory(category);
            },
          );
        },
      ),
    );
  }

  Widget _buildSpecialOffer() {
    final bool home = _shoppingMode == 'home';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: <Color>[Color(0xFFFFF6DE), Color(0xFFFFFCF4)],
        ),
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: const Color(0xFFF1DFAD)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE9AE),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.local_offer_rounded,
              color: Color(0xFFAD7405),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  home ? 'Fresh deals every day' : 'Exclusive wholesale deals',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  home
                      ? 'Save more on selected farm-fresh products.'
                      : 'Unlock better margins with selected bulk packs.',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            color: AppColors.primary,
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildProducts({required bool desktop}) {
    return ListenableBuilder(
      listenable: _productProvider,
      builder:
          (BuildContext context, Widget? child) => ListenableBuilder(
            listenable: _cartProvider,
            builder:
                (BuildContext context, Widget? child) => LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final double width = constraints.maxWidth;

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: premiumCategoryProductGrid(width),
                    itemCount: _products.length,
                    itemBuilder: (BuildContext context, int index) {
                      final _ProductItem product = _products[index];
                      final int quantity = _quantityFor(product);

                      return _ProductCard(
                        product: product,
                        quantity: quantity,
                        onTap: () => _openProduct(product),
                        onAdd: () => _addToCart(product),
                        onDecrease: () => _changeQuantity(product, -1),
                        onIncrease: () => _changeQuantity(product, 1),
                        adding: _addingProducts.contains(product.id),
                      );
                    },
                    );
                  },
                ),
          ),
    );
  }

  Widget _buildTrustSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Row(
        children: <Widget>[
          Expanded(
            child: _TrustItem(icon: Icons.eco_outlined, title: 'Farm Fresh'),
          ),
          _VerticalLine(),
          Expanded(
            child: _TrustItem(
              icon: Icons.verified_outlined,
              title: 'Quality Checked',
            ),
          ),
          _VerticalLine(),
          Expanded(
            child: _TrustItem(
              icon: Icons.local_shipping_outlined,
              title: 'Safe Delivery',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliverySection() {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          _go('/delivery-method');
        },
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border),
          ),
          child: const Row(
            children: <Widget>[
              CircleAvatar(
                radius: 26,
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
                      'Delivery your way',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Quick Delivery • Scheduled Delivery • Pre-Order',
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
                size: 17,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    required String action,
    required VoidCallback onTap,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: onTap,
          child: Text(
            action,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }
}

class _PremiumBanner extends StatelessWidget {
  const _PremiumBanner({
    required this.banner,
    required this.desktop,
    required this.onTap,
  });

  final _HomeBanner banner;
  final bool desktop;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[banner.startColor, banner.endColor],
        ),
        borderRadius: BorderRadius.circular(29),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x200B7A3E),
            blurRadius: 28,
            offset: Offset(0, 13),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(29),
        child: InkWell(
          borderRadius: BorderRadius.circular(29),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(desktop ? 28 : 21),
            child: Stack(
              children: <Widget>[
                Positioned(
                  right: -35,
                  top: -45,
                  child: Container(
                    width: desktop ? 230 : 180,
                    height: desktop ? 230 : 180,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0x12FFFFFF),
                    ),
                  ),
                ),
                Positioned(
                  right: desktop ? 32 : 7,
                  bottom: 4,
                  child: Icon(
                    banner.icon,
                    size: desktop ? 165 : 105,
                    color: Colors.white.withValues(alpha: 0.15),
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
                          banner.badge,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            letterSpacing: 0.8,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(height: 13),
                      Text(
                        banner.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: desktop ? 34 : 26,
                          height: 1.08,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        banner.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11.5,
                          height: 1.4,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      FilledButton.icon(
                        onPressed: onTap,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: banner.startColor,
                        ),
                        icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                        label: Text(
                          banner.button,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoundCategoryCard extends StatelessWidget {
  const _RoundCategoryCard({required this.category, required this.onTap});

  final _CategoryItem category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PremiumCategoryCard(
      child: InkWell(
        borderRadius: BorderRadius.circular(50),
        onTap: onTap,
        child: SizedBox(
          width: 98,
          child: Column(
            children: <Widget>[
              Container(
                width: 90,
                height: 90,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFD9EDDF), width: 2),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(
                      color: Color(0x0D000000),
                      blurRadius: 15,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Container(
                    color: const Color(0xFFE8F5E9),
                    child: Image.asset(
                      category.image,
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      errorBuilder: (
                        BuildContext context,
                        Object error,
                        StackTrace? stackTrace,
                      ) {
                        return Icon(
                          category.fallbackIcon,
                          color: AppColors.primary,
                          size: 39,
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 9),
              Text(
                category.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                category.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.quantity,
    required this.onTap,
    required this.onAdd,
    required this.onDecrease,
    required this.onIncrease,
    required this.adding,
  });

  final _ProductItem product;
  final int quantity;
  final VoidCallback onTap;
  final VoidCallback onAdd;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final bool adding;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
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
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(17),
                        ),
                        child: PremiumProductImage(path: product.image),
                      ),
                    ),
                    Positioned.fill(
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(17),
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: <Color>[
                                Colors.transparent,
                                Color(0x18002012),
                              ],
                              stops: <double>[0.68, 1],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 7,
                      top: 7,
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
                          product.offer,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        width: 31,
                        height: 31,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.favorite_border_rounded,
                          size: 17,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 9),
              Text(
                product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
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
                      '${product.unit} • Farm fresh',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text(
                              product.price,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                product.mrp,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 9,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (product.savings > 0)
                          Text(
                            'Save ₹${product.savings.toStringAsFixed(0)}',
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

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 145,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 19),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 9,
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
}

class _TrustItem extends StatelessWidget {
  const _TrustItem({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Icon(icon, color: AppColors.primary, size: 25),
        const SizedBox(height: 7),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _VerticalLine extends StatelessWidget {
  const _VerticalLine();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 42,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: const Color(0xFFCDE5D5),
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
        borderRadius: BorderRadius.circular(19),
        onTap: onTap,
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
              if (selected)
                const Icon(Icons.check_circle_rounded, color: AppColors.primary)
              else
                const Icon(
                  Icons.radio_button_unchecked_rounded,
                  color: AppColors.border,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeBanner {
  const _HomeBanner({
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.button,
    required this.icon,
    required this.startColor,
    required this.endColor,
    required this.route,
  });

  final String badge;
  final String title;
  final String subtitle;
  final String button;
  final IconData icon;
  final Color startColor;
  final Color endColor;
  final String route;
}

class _CategoryItem {
  const _CategoryItem({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.image,
    required this.fallbackIcon,
  });

  final String title;
  final String subtitle;
  final String value;
  final String image;
  final IconData fallbackIcon;
}

class _ProductItem {
  const _ProductItem({
    required this.model,
    required this.id,
    required this.name,
    required this.unit,
    required this.price,
    required this.mrp,
    required this.offer,
    required this.image,
  });

  final ProductModel model;
  final String id;
  final String name;
  final String unit;
  final String price;
  final String mrp;
  final String offer;
  final String image;
  double get savings => model.savings;

  factory _ProductItem.fromModel(ProductModel product) {
    return _ProductItem(
      model: product,
      id: product.id,
      name: product.name,
      unit: product.unit,
      price: '₹${product.price.toStringAsFixed(0)}',
      mrp: '₹${product.mrp.toStringAsFixed(0)}',
      offer: '${product.discountPercent}% OFF',
      image: product.imageUrl,
    );
  }
}
