import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/premium_toast.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository.dart';
import '../../providers/cart_provider.dart';
import '../home/widgets/floating_cart_bar.dart';
import '../home/widgets/product_card.dart';
import 'widgets/popular_searches.dart';
import 'widgets/recent_searches.dart';
import 'widgets/search_filter_sheet.dart';
import 'widgets/search_input.dart';
import 'widgets/search_result_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final ProductRepository _products = ProductRepository();
  late final CartProvider _cartProvider;
  final Set<String> _adding = <String>{};
  final List<String> _recentSearches = <String>[];
  String _query = '';
  SearchFilterSelection _filters = const SearchFilterSelection();

  @override
  void initState() {
    super.initState();
    _cartProvider = CartProvider()..listenToCart();
  }

  @override
  void dispose() {
    _controller.dispose();
    _cartProvider.dispose();
    super.dispose();
  }

  Future<void> _add(ProductModel product) async {
    if (_adding.contains(product.id)) return;
    setState(() => _adding.add(product.id));
    try {
      final bool success = await _cartProvider.addProduct(product);
      if (!success) {
        throw StateError(
          _cartProvider.errorMessage ?? 'Unable to add product to cart.',
        );
      }
      if (!mounted) return;
      PremiumToast.show(context, '${product.name} added to cart');
    } catch (error) {
      if (!mounted) return;
      PremiumToast.show(
        context,
        error.toString().replaceFirst('Bad state: ', ''),
        error: true,
      );
    } finally {
      if (mounted) setState(() => _adding.remove(product.id));
    }
  }

  CartItemModel? _cartItem(ProductModel product) {
    final List<CartItemModel> items =
        _cartProvider.cart?.items ?? <CartItemModel>[];
    for (final CartItemModel item in items) {
      if (item.productId == product.id && item.shoppingMode == 'home') {
        return item;
      }
    }
    return null;
  }

  Future<void> _changeQuantity(ProductModel product, int difference) async {
    if (_adding.contains(product.id)) return;
    final CartItemModel? item = _cartItem(product);
    if (item == null) {
      if (difference > 0) await _add(product);
      return;
    }
    setState(() => _adding.add(product.id));
    final bool success = await _cartProvider.updateQuantity(
      item.id,
      item.quantity + difference,
    );
    if (!mounted) return;
    setState(() => _adding.remove(product.id));
    if (!success) {
      PremiumToast.show(
        context,
        _cartProvider.errorMessage ?? 'Unable to update quantity.',
        error: true,
      );
    }
  }

  void _updateQuery(String value) {
    setState(() => _query = value.trim());
  }

  void _rememberQuery(String value) {
    final String query = value.trim();
    if (query.isEmpty) return;
    setState(() {
      _recentSearches
        ..removeWhere((String item) => item.toLowerCase() == query.toLowerCase())
        ..insert(0, query);
      if (_recentSearches.length > 5) _recentSearches.removeLast();
    });
  }

  void _selectSuggestion(String value) {
    _controller.text = value;
    _controller.selection = TextSelection.collapsed(offset: value.length);
    _rememberQuery(value);
    _updateQuery(value);
  }

  Future<void> _openFilters() async {
    final SearchFilterSelection? selected = await showSearchFilterSheet(
      context,
      initial: _filters,
    );
    if (selected == null || !mounted) return;
    setState(() => _filters = selected);
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    final int columns = width >= 1100 ? 5 : width >= 800 ? 4 : width >= 560 ? 3 : 2;
    return ListenableBuilder(
      listenable: _cartProvider,
      builder: (BuildContext context, Widget? child) => Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Search Products'),
        actions: <Widget>[
          IconButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.cart),
            icon: CartBadgeIcon(count: _cartProvider.itemCount),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: PremiumSearchInput(
              controller: _controller,
              onChanged: _updateQuery,
              onSubmitted: _rememberQuery,
              onClear: () {
                _controller.clear();
                _updateQuery('');
              },
              onFilterTap: _openFilters,
              hasFilters: _filters.isActive,
            ),
          ),
          if (_query.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 2, 16, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  RecentSearches(
                    queries: _recentSearches,
                    onSelected: _selectSuggestion,
                    onClear: () => setState(_recentSearches.clear),
                  ),
                  if (_recentSearches.isNotEmpty) const SizedBox(height: 12),
                  PopularSearches(onSelected: _selectSuggestion),
                ],
              ),
            ),
          Expanded(
            child: StreamBuilder<List<ProductModel>>(
              stream: _products.watchProducts(limit: 200),
              builder: (BuildContext context, AsyncSnapshot<List<ProductModel>> snapshot) {
                final String query = _query.toLowerCase();
                final List<ProductModel> values = (snapshot.data ?? <ProductModel>[])
                    .where((ProductModel product) {
                      final bool matchesQuery = query.isEmpty ||
                          product.name.toLowerCase().contains(query) ||
                          product.category.toLowerCase().contains(query);
                      final bool matchesCategory = _filters.category == 'all' ||
                          product.category.toLowerCase() == _filters.category;
                      final bool matchesOffer = !_filters.offersOnly || product.savings > 0;
                      return matchesQuery && matchesCategory && matchesOffer;
                    })
                    .toList();

                switch (_filters.sort) {
                  case 'low':
                    values.sort((ProductModel a, ProductModel b) => a.price.compareTo(b.price));
                    break;
                  case 'high':
                    values.sort((ProductModel a, ProductModel b) => b.price.compareTo(a.price));
                    break;
                  case 'rating':
                    values.sort((ProductModel a, ProductModel b) => b.rating.compareTo(a.rating));
                    break;
                  case 'discount':
                    values.sort((ProductModel a, ProductModel b) => b.discountPercent.compareTo(a.discountPercent));
                    break;
                }

                if (snapshot.connectionState == ConnectionState.waiting && values.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (values.isEmpty) {
                  return const _SearchEmpty();
                }
                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    mainAxisExtent: 306,
                  ),
                  itemCount: values.length,
                  itemBuilder: (BuildContext context, int index) {
                    final ProductModel product = values[index];
                    return _SearchProductCard(
                      product: product,
                      quantity: _cartItem(product)?.quantity ?? 0,
                      adding: _adding.contains(product.id),
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.productDetails,
                        arguments: <String, dynamic>{'productId': product.id},
                      ),
                      onAdd: () => _add(product),
                      onDecrease: () => _changeQuantity(product, -1),
                      onIncrease: () => _changeQuantity(product, 1),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      ),
    );
  }
}

class _SearchProductCard extends StatelessWidget {
  const _SearchProductCard({
    required this.product,
    required this.quantity,
    required this.adding,
    required this.onTap,
    required this.onAdd,
    required this.onDecrease,
    required this.onIncrease,
  });

  final ProductModel product;
  final int quantity;
  final bool adding;
  final VoidCallback onTap;
  final VoidCallback onAdd;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    return SearchResultCard(
      productName: product.name,
      child: Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F8F5),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: PremiumProductImage(path: product.imageUrl),
                ),
              ),
              const SizedBox(height: 9),
              Text(
                product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
              ),
              Text(
                product.unit,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 9),
              ),
              const SizedBox(height: 7),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text(
                              '₹${product.price.toStringAsFixed(0)}',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '₹${product.mrp.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 8.5,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ),
                        if (product.savings > 0)
                          Text(
                            'Save ₹${product.savings.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 8,
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
      ),
    );
  }
}

class _SearchEmpty extends StatelessWidget {
  const _SearchEmpty();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.search_off_rounded, size: 58, color: AppColors.primary),
          SizedBox(height: 12),
          Text('No matching products', style: TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}
