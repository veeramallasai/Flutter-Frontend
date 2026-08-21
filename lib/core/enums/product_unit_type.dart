enum ProductUnitType {
  gram('g', 'Gram'),
  kilogram('kg', 'Kilogram'),
  millilitre('ml', 'Millilitre'),
  litre('litre', 'Litre'),
  piece('piece', 'Piece'),
  bunch('bunch', 'Bunch'),
  pack('pack', 'Pack'),
  crate('crate', 'Crate');

  const ProductUnitType(this.value, this.label);
  final String value;
  final String label;

  bool get isWeight => this == ProductUnitType.gram || this == ProductUnitType.kilogram;
  bool get isVolume => this == ProductUnitType.millilitre || this == ProductUnitType.litre;

  static ProductUnitType fromValue(String? value) {
    final String normalized = value?.trim().toLowerCase() ?? '';
    if (normalized == 'liter' || normalized == 'l') return ProductUnitType.litre;
    if (normalized == 'milliliter') return ProductUnitType.millilitre;
    return ProductUnitType.values.firstWhere(
      (ProductUnitType item) => item.value == normalized,
      orElse: () => ProductUnitType.piece,
    );
  }
}
