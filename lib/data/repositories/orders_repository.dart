import '../models/order_model.dart';
import '../mock/mock_orders_data.dart';

class OrdersRepository {
  final List<OrderModel> _orders = MockOrdersData.getInitialOrders();

  Future<List<OrderModel>> getOrders() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.from(_orders);
  }

  Future<OrderModel?> getOrderById(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    try {
      return _orders.firstWhere((o) => o.id == id || o.invoiceNo == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> updateOrderStatus(
    String id, {
    String? paymentStatus,
    String? shipmentStatus,
    double? paidAmount,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _orders.indexWhere((o) => o.id == id || o.invoiceNo == id);
    if (index != -1) {
      final current = _orders[index];
      final newPaid = paidAmount ?? current.paidAmount;
      final newPaymentStatus = paymentStatus ?? current.paymentStatus;
      final newShipmentStatus = shipmentStatus ?? current.shipmentStatus;

      _orders[index] = current.copyWith(
        paidAmount: newPaid,
        paymentStatus: newPaymentStatus,
        shipmentStatus: newShipmentStatus,
      );
    }
  }
}
