class PaymentModel {
  final String id;
  final String trxId;
  final String invoiceNo;
  final String salesmanName;
  final String retailerName;
  final double amount;
  final String status; // 'Paid', 'Pending', 'Failed'
  final String paidAt;
  final String paymentMethod; // Always 'Cash'
  final String? notes;

  const PaymentModel({
    required this.id,
    required this.trxId,
    required this.invoiceNo,
    required this.salesmanName,
    required this.retailerName,
    required this.amount,
    required this.status,
    required this.paidAt,
    this.paymentMethod = 'Cash',
    this.notes,
  });

  PaymentModel copyWith({
    String? id,
    String? trxId,
    String? invoiceNo,
    String? salesmanName,
    String? retailerName,
    double? amount,
    String? status,
    String? paidAt,
    String? notes,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      trxId: trxId ?? this.trxId,
      invoiceNo: invoiceNo ?? this.invoiceNo,
      salesmanName: salesmanName ?? this.salesmanName,
      retailerName: retailerName ?? this.retailerName,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      paidAt: paidAt ?? this.paidAt,
      paymentMethod: 'Cash',
      notes: notes ?? this.notes,
    );
  }
}
