import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../models/payment_model.dart';
import '../models/salesman_collection_model.dart';
import '../mock/mock_payments_data.dart';
import 'auth_repository.dart';

class PaymentsRepository {
  final http.Client _client;
  final List<PaymentModel> _localPayments = List.from(MockPaymentsData.payments);
  static final List<PaymentModel> _manualPayments = [];

  PaymentsRepository({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> fetchKpiSummary({String? companyId}) async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConstants.baseUrl}/payments/admin/kpi-summary?companyId=${companyId ?? ''}'),
        headers: AuthRepository.getAuthHeaders(),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        if (data != null) return data;
      }
    } catch (_) {}

    return {
      'monthName': 'November',
      'collectedMonthValue': 482500.0,
      'growthTrendPercent': 12.4,
      'cashCollected': 142000.0,
      'cashPending': 35400.0,
      'failedAmount': 12500.0,
      'failedCount': 2
    };
  }

  Future<List<SalesmanCollectionModel>> fetchCollectionsBySalesman({String? companyId}) async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConstants.baseUrl}/payments/admin/collection-by-salesman?companyId=${companyId ?? ''}'),
        headers: AuthRepository.getAuthHeaders(),
      );
      if (response.statusCode == 200) {
        final List data = json.decode(response.body)['data'] ?? [];
        if (data.isNotEmpty) {
          final maxAmt = data.fold<double>(1.0, (max, item) {
            final amt = (item['totalAmount'] as num?)?.toDouble() ?? 0.0;
            return amt > max ? amt : max;
          });

          return data.map((item) {
            final amt = (item['totalAmount'] as num?)?.toDouble() ?? 0.0;
            final fullName = (item['salesmanName'] ?? 'Salesman').toString().trim();
            final nameParts = fullName.split(RegExp(r'\s+'));
            final initials = nameParts.length > 1
                ? '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase()
                : (fullName.isNotEmpty ? fullName.substring(0, fullName.length.clamp(1, 2)).toUpperCase() : 'SR');

            return SalesmanCollectionModel(
              id: (item['salesmanId'] ?? '').toString(),
              salesmanName: fullName,
              avatarInitials: initials,
              amountCollected: amt,
              progressPercentage: maxAmt > 0 ? (amt / maxAmt) : 0.0,
            );
          }).toList();
        }
      }
    } catch (_) {}

    return const [];
  }

  Future<List<PaymentModel>> getPayments({String? companyId, int page = 1, int limit = 200, String? status, String? search}) async {
    try {
      final statusParam = (status != null && status != 'All status') ? status : '';
      final response = await _client.get(
        Uri.parse('${ApiConstants.baseUrl}/payments/admin/all-payments?companyId=${companyId ?? ''}&page=$page&limit=$limit&status=$statusParam&search=${search ?? ''}'),
        headers: AuthRepository.getAuthHeaders(),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        final List list = data?['payments'] ?? [];
        if (list.isNotEmpty) {
          final mapped = list.map((item) {
            final created = DateTime.tryParse(item['date'] ?? item['createdAt'] ?? '') ?? DateTime.now();
            final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
            final dateStr = '${created.day.toString().padLeft(2, '0')} ${months[created.month - 1]} ${created.year}';
            final idStr = (item['_id'] ?? '').toString();
            final hex = idStr.length >= 6 ? idStr.substring(idStr.length - 6).toUpperCase() : '0000';
            final rawTrx = (item['transactionId'] ?? '').toString().trim();
            final formattedTrx = rawTrx.isNotEmpty ? rawTrx : 'TRX-${created.year}${created.month.toString().padLeft(2, '0')}${created.day.toString().padLeft(2, '0')}-$hex';

            return PaymentModel(
              id: idStr,
              trxId: formattedTrx,
              invoiceNo: (item['invoiceNo'] ?? item['invoiceNumber'] ?? 'INV-000').toString(),
              retailerName: (item['retailerName'] ?? item['storeName'] ?? 'Retail Store').toString(),
              salesmanName: (item['salesmanName'] ?? 'Sales Rep').toString(),
              paidAt: dateStr,
              amount: (item['amount'] as num?)?.toDouble() ?? 0.0,
              paymentMethod: 'Cash',
              status: (item['status'] ?? item['paymentStatus'] ?? 'Pending').toString(),
            );
          }).toList();

          // Deduplicate by invoiceNo, preferring 'Paid' status if multiple records exist for the same order
          final Map<String, PaymentModel> byInvoice = {};
          for (final mp in _manualPayments) {
            byInvoice[mp.invoiceNo] = mp;
          }
          for (final p in mapped) {
            final existing = byInvoice[p.invoiceNo];
            if (existing == null || (existing.status != 'Paid' && p.status == 'Paid')) {
              byInvoice[p.invoiceNo] = p;
            }
          }
          return byInvoice.values.toList();
        }
      }
    } catch (_) {}

    // Dynamic fallback: Map payments directly from Orders in MongoDB if Payment collection is empty
    try {
      final ordersRes = await _client.get(
        Uri.parse('${ApiConstants.orders}?limit=200&companyId=${companyId ?? ''}'),
        headers: AuthRepository.getAuthHeaders(),
      );
      if (ordersRes.statusCode == 200) {
        final ordersData = json.decode(ordersRes.body)['data'];
        final List ordersList = ordersData?['orders'] ?? (ordersData is List ? ordersData : []);
        if (ordersList.isNotEmpty) {
          final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
          final fromOrders = ordersList.map((item) {
            final storeInfo = item['storeInfo'] is Map ? item['storeInfo'] : {};
            final customer = item['customerId'] is Map ? item['customerId'] : {};
            final salesman = item['salesmanId'] is Map ? item['salesmanId'] : {};
            final created = DateTime.tryParse(item['createdAt'] ?? '') ?? DateTime.now();

            final idStr = (item['_id'] ?? '').toString();
            final hex = idStr.length >= 6 ? idStr.substring(idStr.length - 6).toUpperCase() : '0000';
            final formattedTrx = 'TRX-${created.year}${created.month.toString().padLeft(2, '0')}${created.day.toString().padLeft(2, '0')}-$hex';
            final dateStr = '${created.day.toString().padLeft(2, '0')} ${months[created.month - 1]} ${created.year}';

            final storeName = (storeInfo['storeName'] ?? customer['storeName'] ?? customer['fullName'] ?? 'Retail Store').toString();
            final ownerName = (storeInfo['storeOwnerName'] ?? customer['storeOwnerName'] ?? customer['ownerName'] ?? customer['fullName'] ?? '').toString();
            final retailerDisplay = ownerName.isNotEmpty && ownerName != storeName ? '$storeName ($ownerName)' : storeName;

            return PaymentModel(
              id: idStr,
              trxId: formattedTrx,
              invoiceNo: (item['invoiceNumber'] ?? 'INV-000').toString(),
              retailerName: retailerDisplay,
              salesmanName: (salesman['fullName'] ?? 'Sales Rep').toString(),
              paidAt: dateStr,
              amount: (item['totalPrice'] as num?)?.toDouble() ?? 0.0,
              paymentMethod: 'Cash',
              status: (item['paymentStatus'] ?? 'Pending').toString(),
            );
          }).toList();
          return [..._manualPayments, ...fromOrders];
        }
      }
    } catch (_) {}

    return List.from(_manualPayments);
  }

  Future<void> updatePaymentStatus(String paymentId, String status) async {
    try {
      final res = await _client.patch(
        Uri.parse('${ApiConstants.baseUrl}/payments/update-payment/$paymentId'),
        headers: AuthRepository.getAuthHeaders(),
        body: json.encode({'paymentStatus': status}),
      );
      if (res.statusCode != 200) {
        // Fallback if paymentId is an Order._id
        await _client.patch(
          Uri.parse('${ApiConstants.baseUrl}/orders/update-order-payment-status/$paymentId/$status'),
          headers: AuthRepository.getAuthHeaders(),
          body: json.encode({'paymentStatus': status}),
        );
      }
    } catch (_) {}

    for (var i = 0; i < _manualPayments.length; i++) {
      if (_manualPayments[i].id == paymentId) {
        _manualPayments[i] = _manualPayments[i].copyWith(status: status);
      }
    }
    final index = _localOrdersPaymentIndex(paymentId);
    if (index != -1) {
      _localPayments[index] = _localPayments[index].copyWith(status: status);
    }
  }

  int _localOrdersPaymentIndex(String id) {
    return _localPayments.indexWhere((p) => p.id == id);
  }

  Future<void> addPayment(PaymentModel payment) async {
    try {
      // First try to resolve the real Order._id and salesmanId from backend orders by invoiceNo
      String? resolvedOrderId;
      String? resolvedSalesmanId;
      final ordersRes = await _client.get(
        Uri.parse('${ApiConstants.orders}?limit=200'),
        headers: AuthRepository.getAuthHeaders(),
      );
      if (ordersRes.statusCode == 200) {
        final decoded = json.decode(ordersRes.body)['data'];
        final List ordersList = decoded is Map
            ? (decoded['orders'] ?? [])
            : (decoded is List ? decoded : []);
        for (final o in ordersList) {
          final inv = (o['invoiceNumber'] ?? '').toString().trim().toLowerCase();
          if (inv == payment.invoiceNo.trim().toLowerCase()) {
            resolvedOrderId = (o['_id'] ?? '').toString();
            final sm = o['salesmanId'];
            resolvedSalesmanId = (sm is Map ? sm['_id'] : sm)?.toString();
            break;
          }
        }
      }

      if (resolvedOrderId != null && resolvedOrderId.isNotEmpty) {
        final patchRes = await _client.patch(
          Uri.parse('${ApiConstants.baseUrl}/orders/update-order-payment-status/$resolvedOrderId/${payment.status}'),
          headers: AuthRepository.getAuthHeaders(),
          body: json.encode({
            'paymentStatus': payment.status,
            'amountPaid': payment.amount,
          }),
        );
        if (patchRes.statusCode == 200) {
          return;
        }
        if (resolvedSalesmanId != null && resolvedSalesmanId.isNotEmpty) {
          final createRes = await _client.post(
            Uri.parse('${ApiConstants.baseUrl}/payments/create-payment'),
            headers: AuthRepository.getAuthHeaders(),
            body: json.encode({
              'orderId': resolvedOrderId,
              'salesmanId': resolvedSalesmanId,
              'paymentMethod': 'Cash',
              'paymentStatus': payment.status,
              'amount': payment.amount,
            }),
          );
          if (createRes.statusCode == 200 || createRes.statusCode == 201) {
            return;
          }
        }
      }
    } catch (_) {}

    _manualPayments.removeWhere((p) => p.invoiceNo == payment.invoiceNo);
    _manualPayments.insert(0, payment);
    _localPayments.insert(0, payment);
  }
}
