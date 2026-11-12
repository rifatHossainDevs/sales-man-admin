class OrderItemModel {
  final String productName;
  final String sku;
  final int qty;
  final double unitPrice;

  OrderItemModel({
    required this.productName,
    required this.sku,
    required this.qty,
    required this.unitPrice,
  });

  double get subtotal => qty * unitPrice;
}

class OrderModel {
  final String id;
  final String invoiceNo;
  final String retailerName;
  final String retailerOwner;
  final String retailerPhone;
  final String retailerAddress;
  final String salesmanName;
  final String salesmanPhone;
  final String date;
  final String time;
  final double totalAmount;
  final double paidAmount;
  final String paymentStatus; // 'Paid', 'Pending', 'Failed'
  final String shipmentStatus; // 'Delivered', 'Pending', 'Failed'
  final String paymentMethod; // Enforced 'Cash'
  final List<OrderItemModel> items;

  OrderModel({
    required this.id,
    required this.invoiceNo,
    required this.retailerName,
    required this.retailerOwner,
    required this.retailerPhone,
    required this.retailerAddress,
    required this.salesmanName,
    required this.salesmanPhone,
    required this.date,
    required this.time,
    required this.totalAmount,
    required this.paidAmount,
    required this.paymentStatus,
    required this.shipmentStatus,
    this.paymentMethod = 'Cash',
    required this.items,
  });

  double get dueAmount => totalAmount - paidAmount;

  OrderModel copyWith({
    String? id,
    String? invoiceNo,
    String? retailerName,
    String? retailerOwner,
    String? retailerPhone,
    String? retailerAddress,
    String? salesmanName,
    String? salesmanPhone,
    String? date,
    String? time,
    double? totalAmount,
    double? paidAmount,
    String? paymentStatus,
    String? shipmentStatus,
    String? paymentMethod,
    List<OrderItemModel>? items,
  }) {
    return OrderModel(
      id: id ?? this.id,
      invoiceNo: invoiceNo ?? this.invoiceNo,
      retailerName: retailerName ?? this.retailerName,
      retailerOwner: retailerOwner ?? this.retailerOwner,
      retailerPhone: retailerPhone ?? this.retailerPhone,
      retailerAddress: retailerAddress ?? this.retailerAddress,
      salesmanName: salesmanName ?? this.salesmanName,
      salesmanPhone: salesmanPhone ?? this.salesmanPhone,
      date: date ?? this.date,
      time: time ?? this.time,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      shipmentStatus: shipmentStatus ?? this.shipmentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      items: items ?? this.items,
    );
  }
}
