enum ShoppingMode {
  home('home', 'Home', 'Fresh retail packs for your family'),
  shop('shop', 'Shop Owner', 'Bulk packs with wholesale savings');

  const ShoppingMode(this.value, this.label, this.description);
  final String value;
  final String label;
  final String description;

  bool get isHome => this == ShoppingMode.home;
  bool get isShop => this == ShoppingMode.shop;

  static ShoppingMode fromValue(String? value) {
    return value?.trim().toLowerCase() == ShoppingMode.shop.value
        ? ShoppingMode.shop
        : ShoppingMode.home;
  }
}
