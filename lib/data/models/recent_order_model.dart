class RecentOrderModel {
  final String invoiceNo;
  final String retailerName;
  final String salesmanName;
  final double totalAmount;
  final String paymentStatus; // 'Paid', 'Pending', 'Failed'
  final String shipmentStatus; // 'Delivered', 'Pending', 'Failed'
  final String paymentMethod; // 'Cash'

  RecentOrderModel({
    required this.invoiceNo,
    required this.retailerName,
    required this.salesmanName,
    required this.totalAmount,
    required this.paymentStatus,
    required this.shipmentStatus,
    this.paymentMethod = 'Cash',
  });
}
