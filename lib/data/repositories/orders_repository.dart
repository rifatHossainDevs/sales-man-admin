import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../models/order_model.dart';
import '../mock/mock_orders_data.dart';
import 'auth_repository.dart';

class OrdersRepository {
  final http.Client _client;
  final List<OrderModel> _localOrders = MockOrdersData.getInitialOrders();

  OrdersRepository({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, Map<String, dynamic>>> _getStoresMap(String? companyId) async {
    final Map<String, Map<String, dynamic>> map = {};
    void addStoresFromBody(String body) {
      final decoded = json.decode(body)['data'];
      final List stores = decoded is Map
          ? (decoded['stores'] ?? [])
          : (decoded is List ? decoded : []);
      for (final st in stores) {
        if (st is Map<String, dynamic>) {
          final userId = (st['userId'] is Map ? st['userId']['_id'] : st['userId'])?.toString() ?? '';
          final storeId = (st['_id'] ?? '').toString();
          if (userId.isNotEmpty) map[userId] = st;
          if (storeId.isNotEmpty) map[storeId] = st;
        }
      }
    }

    try {
      if (companyId != null && companyId.isNotEmpty) {
        final res = await _client.get(
          Uri.parse('${ApiConstants.baseUrl}/stores/get-store-by-company/$companyId'),
          headers: AuthRepository.getAuthHeaders(),
        );
        if (res.statusCode == 200) {
          addStoresFromBody(res.body);
        }
      }
      final allRes = await _client.get(
        Uri.parse('${ApiConstants.stores}?limit=200'),
        headers: AuthRepository.getAuthHeaders(),
      );
      if (allRes.statusCode == 200) {
        addStoresFromBody(allRes.body);
      }
    } catch (_) {}
    return map;
  }

  Future<List<OrderModel>> getOrders({String? companyId, String? search}) async {
    try {
      final storesMap = await _getStoresMap(companyId);
      final uri = Uri.parse('${ApiConstants.orders}?limit=200&companyId=${companyId ?? ''}&search=${search ?? ''}');
      final response = await _client.get(uri, headers: AuthRepository.getAuthHeaders());
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List ordersList = data['data']?['orders'] ?? (data['data'] is List ? data['data'] : []);
        if (ordersList.isNotEmpty) {
          return ordersList.map((item) {
            final storeInfo = item['storeInfo'] is Map ? item['storeInfo'] : {};
            final customer = item['customerId'] is Map ? item['customerId'] : {};
            final salesman = item['salesmanId'] is Map ? item['salesmanId'] : {};
            final created = DateTime.tryParse(item['createdAt'] ?? '') ?? DateTime.now();

            final customerIdStr = (customer['_id'] ?? customer['id'] ?? item['customerId'] ?? '').toString();
            final matchedStore = storesMap[customerIdStr] ?? (storeInfo.isNotEmpty ? storeInfo : customer);

            final List itemsList = item['orderItems'] ?? [];
            final items = itemsList.map((it) {
              final qty = (it['purchaseQuantity'] ?? it['qty'] as num?)?.toInt() ?? 1;
              final unitPrice = (it['priceAtPurchase'] ?? it['unitPrice'] as num?)?.toDouble() ?? 0.0;
              return OrderItemModel(
                productName: it['productName'] ?? 'Product Item',
                sku: it['productId'] ?? it['sku'] ?? 'SKU-100',
                qty: qty,
                unitPrice: unitPrice,
              );
            }).toList();

            final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
            final dateStr = '${created.day.toString().padLeft(2, '0')} ${months[created.month - 1]} ${created.year}';
            final timeStr = '${created.hour % 12 == 0 ? 12 : created.hour % 12}:${created.minute.toString().padLeft(2, '0')} ${created.hour < 12 ? 'AM' : 'PM'}';

            final totalAmt = (item['totalPrice'] as num?)?.toDouble() ?? 0.0;
            final rawPaid = (item['amountPaid'] as num?)?.toDouble() ?? 0.0;
            final paymentStatus = (item['paymentStatus'] ?? 'Pending').toString();
            final paidAmt = (paymentStatus == 'Paid' && rawPaid <= 0) ? totalAmt : rawPaid;

            final retailerOwner = (matchedStore['storeOwnerName'] ?? customer['fullName'] ?? customer['storeOwnerName'] ?? customer['ownerName'] ?? 'Customer').toString();
            final retailerName = (matchedStore['storeName'] ?? customer['storeName'] ?? retailerOwner).toString();
            final retailerPhone = (matchedStore['phone'] ?? customer['phone'] ?? salesman['phone'] ?? '').toString();
            final retailerAddress = (item['shippingAddress'] ?? matchedStore['address'] ?? customer['address'] ?? 'Dhaka').toString();

            double? lat;
            double? lng;
            final coords = matchedStore['coordinates'] ?? storeInfo['coordinates'];
            if (coords is List && coords.length >= 2) {
              lat = double.tryParse(coords[0].toString());
              lng = double.tryParse(coords[1].toString());
            }

            return OrderModel(
              id: item['_id'] ?? '',
              invoiceNo: item['invoiceNumber'] ?? 'INV-${item['_id'].toString().substring(0, 6)}',
              retailerName: retailerName,
              retailerOwner: retailerOwner,
              retailerPhone: retailerPhone,
              retailerAddress: retailerAddress,
              latitude: lat,
              longitude: lng,
              salesmanName: salesman['fullName'] ?? 'Sales Rep',
              salesmanPhone: salesman['phone'] ?? '',
              date: dateStr,
              time: timeStr,
              totalAmount: totalAmt,
              paidAmount: paidAmt,
              paymentStatus: paymentStatus,
              shipmentStatus: item['shipmentStatus'] ?? 'Pending',
              paymentMethod: 'Cash',
              items: items.isEmpty
                  ? [OrderItemModel(productName: 'Retail Pack', sku: 'SKU-100', qty: 1, unitPrice: totalAmt)]
                  : items,
            );
          }).toList();
        }
      }
    } catch (_) {}

    await Future.delayed(const Duration(milliseconds: 100));
    return List.from(_localOrders);
  }

  Future<OrderModel?> getOrderById(String id) async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConstants.baseUrl}/orders/get-order/$id'),
        headers: AuthRepository.getAuthHeaders(),
      );
      if (response.statusCode == 200) {
        final item = json.decode(response.body)['data'];
        if (item != null) {
          final storeInfo = item['storeInfo'] is Map ? item['storeInfo'] : {};
          final customer = item['customerId'] is Map ? item['customerId'] : {};
          final salesman = item['salesmanId'] is Map ? item['salesmanId'] : {};
          final created = DateTime.tryParse(item['createdAt'] ?? '') ?? DateTime.now();

          final List itemsList = item['orderItems'] ?? [];
          final items = itemsList.map((it) {
            final qty = (it['purchaseQuantity'] ?? it['qty'] as num?)?.toInt() ?? 1;
            final unitPrice = (it['priceAtPurchase'] ?? it['unitPrice'] as num?)?.toDouble() ?? 0.0;
            return OrderItemModel(
              productName: it['productName'] ?? 'Product Item',
              sku: it['productId'] ?? it['sku'] ?? 'SKU-100',
              qty: qty,
              unitPrice: unitPrice,
            );
          }).toList();

          final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
          final dateStr = '${created.day.toString().padLeft(2, '0')} ${months[created.month - 1]} ${created.year}';
          final timeStr = '${created.hour % 12 == 0 ? 12 : created.hour % 12}:${created.minute.toString().padLeft(2, '0')} ${created.hour < 12 ? 'AM' : 'PM'}';

          final totalAmt = (item['totalPrice'] as num?)?.toDouble() ?? 0.0;
          final rawPaid = (item['amountPaid'] as num?)?.toDouble() ?? 0.0;
          final paymentStatus = (item['paymentStatus'] ?? 'Pending').toString();
          final paidAmt = (paymentStatus == 'Paid' && rawPaid <= 0) ? totalAmt : rawPaid;

          final retailerOwner = (storeInfo['storeOwnerName'] ?? customer['fullName'] ?? customer['storeOwnerName'] ?? customer['ownerName'] ?? 'Customer').toString();
          final retailerName = (storeInfo['storeName'] ?? customer['storeName'] ?? retailerOwner).toString();
          final retailerPhone = (storeInfo['phone'] ?? customer['phone'] ?? '').toString();
          final retailerAddress = (item['shippingAddress'] ?? storeInfo['address'] ?? customer['address'] ?? 'Dhaka').toString();

          double? lat;
          double? lng;
          final coords = storeInfo['coordinates'];
          if (coords is List && coords.length >= 2) {
            lat = double.tryParse(coords[0].toString());
            lng = double.tryParse(coords[1].toString());
          }

          return OrderModel(
            id: item['_id'] ?? '',
            invoiceNo: item['invoiceNumber'] ?? 'INV-000',
            retailerName: retailerName,
            retailerOwner: retailerOwner,
            retailerPhone: retailerPhone,
            retailerAddress: retailerAddress,
            latitude: lat,
            longitude: lng,
            salesmanName: salesman['fullName'] ?? 'Sales Rep',
            salesmanPhone: salesman['phone'] ?? '',
            date: dateStr,
            time: timeStr,
            totalAmount: totalAmt,
            paidAmount: paidAmt,
            paymentStatus: paymentStatus,
            shipmentStatus: item['shipmentStatus'] ?? 'Pending',
            paymentMethod: 'Cash',
            items: items.isEmpty
                ? [OrderItemModel(productName: 'Retail Pack', sku: 'SKU-100', qty: 1, unitPrice: totalAmt)]
                : items,
          );
        }
      }
    } catch (_) {}

    try {
      return _localOrders.firstWhere((o) => o.id == id || o.invoiceNo == id);
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
    try {
      if (shipmentStatus != null) {
        await _client.patch(
          Uri.parse('${ApiConstants.baseUrl}/orders/$id/update-shipment-status'),
          headers: AuthRepository.getAuthHeaders(),
          body: json.encode({'shipmentStatus': shipmentStatus}),
        );
      }
      if (paymentStatus == 'Failed') {
        await _client.patch(
          Uri.parse(ApiConstants.markOrderFailed(id)),
          headers: AuthRepository.getAuthHeaders(),
        );
      } else if (paymentStatus != null) {
        await _client.patch(
          Uri.parse('${ApiConstants.baseUrl}/orders/update-order-payment-status/$id/$paymentStatus'),
          headers: AuthRepository.getAuthHeaders(),
          body: json.encode({'paymentStatus': paymentStatus, 'amountPaid': paidAmount}),
        );
      }
    } catch (_) {}

    final index = _localOrders.indexWhere((o) => o.id == id || o.invoiceNo == id);
    if (index != -1) {
      final current = _localOrders[index];
      final newPaymentStatus = paymentStatus ?? current.paymentStatus;
      final newPaid = paymentStatus == 'Paid' ? current.totalAmount : (paidAmount ?? current.paidAmount);
      final newShipmentStatus = shipmentStatus ?? current.shipmentStatus;

      _localOrders[index] = current.copyWith(
        paidAmount: newPaid,
        paymentStatus: newPaymentStatus,
        shipmentStatus: newShipmentStatus,
      );
    }
  }
}
