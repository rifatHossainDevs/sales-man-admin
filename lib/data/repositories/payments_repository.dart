import '../mock/mock_payments_data.dart';
import '../models/payment_model.dart';

class PaymentsRepository {
  final List<PaymentModel> _payments = List.from(MockPaymentsData.payments);

  Future<List<PaymentModel>> getPayments() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return List.unmodifiable(_payments);
  }

  Future<void> addPayment(PaymentModel payment) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _payments.insert(0, payment);
  }

  Future<void> updatePaymentStatus(String paymentId, String status) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _payments.indexWhere((p) => p.id == paymentId);
    if (index != -1) {
      _payments[index] = _payments[index].copyWith(status: status);
    }
  }
}
