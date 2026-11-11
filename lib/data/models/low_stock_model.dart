class LowStockModel {
  final String id;
  final String productName;
  final String sku;
  final int currentStock;
  final int maxThreshold;

  LowStockModel({
    required this.id,
    required this.productName,
    required this.sku,
    required this.currentStock,
    this.maxThreshold = 50,
  });

  double get stockRatio => (currentStock / maxThreshold).clamp(0.0, 1.0);
}
