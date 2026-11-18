import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../../core/utils/web_platform.dart';
import '../mock/mock_salesmen_data.dart';
import '../models/salesman_model.dart';
import 'auth_repository.dart';

class SalesmenRepository {
  final http.Client _client;
  final List<SalesmanModel> _localSalesmen = List.from(MockSalesmenData.salesmen);
  static const String _overridesKey = 'salesman_profile_overrides';

  SalesmenRepository({http.Client? client}) : _client = client ?? http.Client();

  Map<String, Map<String, dynamic>> _loadOverrides() {
    try {
      final raw = WebPlatform.getLocalStorageItem(_overridesKey);
      if (raw != null && raw.isNotEmpty) {
        final Map<String, dynamic> decoded = json.decode(raw);
        return decoded.map(
          (k, v) => MapEntry(k, Map<String, dynamic>.from(v as Map)),
        );
      }
    } catch (_) {}
    return {};
  }

  void _saveOverride(SalesmanModel salesman) {
    try {
      final map = _loadOverrides();
      map[salesman.id] = {
        'name': salesman.name,
        'email': salesman.email,
        'phone': salesman.phone,
        'nid': salesman.nid,
        'assignedTerritory': salesman.assignedTerritory,
      };
      WebPlatform.setLocalStorageItem(_overridesKey, json.encode(map));
    } catch (_) {}
  }

  String _formatLastSeen(dynamic rawDate, bool isOnline) {
    if (isOnline) return 'Online now';
    if (rawDate == null) return 'Offline';
    final parsed = DateTime.tryParse(rawDate.toString());
    if (parsed == null) return 'Offline';
    final diff = DateTime.now().difference(parsed.toLocal());
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    return '${diff.inDays} d ago';
  }

  String _formatAppliedDate(dynamic rawDate) {
    final parsed = rawDate != null ? DateTime.tryParse(rawDate.toString()) : null;
    if (parsed == null) return '10 Nov 2026';
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final local = parsed.toLocal();
    return '${local.day.toString().padLeft(2, '0')} ${months[local.month - 1]} ${local.year}';
  }

  Future<List<SalesmanModel>> getSalesmen({String? companyId}) async {
    final cid = companyId ?? AuthRepository().loadSavedUserSync()?.companyId ?? 'cmp_1001';
    try {
      final results = await Future.wait([
        _client.get(Uri.parse('${ApiConstants.baseUrl}/users/get-all-users/$cid')),
        _client.get(Uri.parse(ApiConstants.pendingSalesmen)),
        _client.get(Uri.parse('${ApiConstants.orders}?limit=200')),
        _client.get(Uri.parse(ApiConstants.salesmanCollections)),
      ]);

      final response = results[0];
      final pendingRes = results[1];
      final ordersRes = results[2];
      final collectionsRes = results[3];

      final orderCounts = <String, int>{};
      final orderCollected = <String, double>{};
      if (ordersRes.statusCode == 200) {
        final decoded = json.decode(ordersRes.body);
        final List ordersList = decoded['data'] is Map
            ? (decoded['data']['orders'] ?? [])
            : (decoded['data'] is List ? decoded['data'] : []);
        for (final o in ordersList) {
          final sm = o['salesmanId'];
          final smId = (sm is Map ? sm['_id'] : sm)?.toString() ?? '';
          final smName = (sm is Map ? sm['fullName'] : '')?.toString().trim().toLowerCase() ?? '';
          final isPaid = (o['paymentStatus'] ?? '') == 'Paid';
          final totalAmt = (o['totalPrice'] as num?)?.toDouble() ?? 0.0;
          final rawPaid = (o['amountPaid'] as num?)?.toDouble() ?? 0.0;
          final paidAmt = (isPaid && rawPaid <= 0) ? totalAmt : rawPaid;

          if (smId.isNotEmpty) {
            orderCounts[smId] = (orderCounts[smId] ?? 0) + 1;
            orderCollected[smId] = (orderCollected[smId] ?? 0.0) + paidAmt;
          }
          if (smName.isNotEmpty) {
            orderCounts[smName] = (orderCounts[smName] ?? 0) + 1;
            orderCollected[smName] = (orderCollected[smName] ?? 0.0) + paidAmt;
          }
        }
      }

      if (collectionsRes.statusCode == 200) {
        final List colList = json.decode(collectionsRes.body)['data'] ?? [];
        for (final c in colList) {
          final smId = (c['salesmanId'] ?? '').toString();
          final smName = (c['salesmanName'] ?? '').toString().trim().toLowerCase();
          final amt = (c['totalAmount'] as num?)?.toDouble() ?? 0.0;
          if (amt > 0) {
            if (smId.isNotEmpty && (orderCollected[smId] ?? 0) < amt) {
              orderCollected[smId] = amt;
            }
            if (smName.isNotEmpty && (orderCollected[smName] ?? 0) < amt) {
              orderCollected[smName] = amt;
            }
          }
        }
      }

      final Map<String, Map<String, dynamic>> mergedById = {};
      if (response.statusCode == 200) {
        final List data = json.decode(response.body)['data'] ?? [];
        for (final item in data) {
          if (item is Map && item['userType'] == 'seller') {
            final id = (item['_id'] ?? '').toString();
            if (id.isNotEmpty) {
              mergedById[id] = Map<String, dynamic>.from(item);
            }
          }
        }
      }

      if (pendingRes.statusCode == 200) {
        final List pendingData = json.decode(pendingRes.body)['data'] ?? [];
        for (final item in pendingData) {
          if (item is Map && item['userType'] == 'seller') {
            final id = (item['_id'] ?? '').toString();
            if (id.isNotEmpty && !mergedById.containsKey(id)) {
              mergedById[id] = Map<String, dynamic>.from(item);
            }
          }
        }
      }

      if (mergedById.isNotEmpty) {
        final overrides = _loadOverrides();
        return mergedById.values.map((item) {
          final id = (item['_id'] ?? '').toString();
          final ov = overrides[id] ?? const {};
          final fullName = (ov['name'] ?? item['fullName'] ?? 'Salesman').toString().trim();
          final nameParts = fullName.split(RegExp(r'\s+'));
          final initials = nameParts.length > 1
              ? '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase()
              : (fullName.isNotEmpty ? fullName.substring(0, fullName.length.clamp(1, 2)).toUpperCase() : 'SR');

          final isActive = item['active'] == true;
          final rawStatus = (item['status'] ?? '').toString();
          final status = isActive
              ? 'Active'
              : (rawStatus == 'Inactive' ? 'Inactive' : 'Pending');
          final rawLastSeen = item['lastSeenAt'] ?? item['updatedAt'];
          final parsedLastSeen = rawLastSeen != null ? DateTime.tryParse(rawLastSeen.toString()) : null;
          final withinTimeout = parsedLastSeen != null &&
              DateTime.now().difference(parsedLastSeen).inMinutes < 2;
          final isOnline = (item['isOnline'] == true) && withinTimeout;

          final resolvedOrders = orderCounts[id] ??
              orderCounts[fullName.toLowerCase()] ??
              0;
          final resolvedCollected = orderCollected[id] ??
              orderCollected[fullName.toLowerCase()] ??
              0.0;

          return SalesmanModel(
            id: id,
            name: fullName,
            email: (ov['email'] ?? item['email'] ?? '').toString(),
            phone: (ov['phone'] ?? item['phone'] ?? '').toString(),
            nid: (ov['nid'] ?? item['nidNumber'] ?? '').toString(),
            totalOrders: resolvedOrders,
            totalCollected: resolvedCollected,
            lastSeen: _formatLastSeen(rawLastSeen, isOnline),
            isOnline: isOnline,
            status: status,
            appliedDate: _formatAppliedDate(item['createdAt']),
            assignedTerritory: (ov['assignedTerritory'] ?? item['livePlaceName'] ?? 'Dhaka').toString(),
            avatarInitials: initials,
          );
        }).toList();
      }
    } catch (_) {}

    await Future.delayed(const Duration(milliseconds: 100));
    return List.unmodifiable(_localSalesmen);
  }

  Future<void> addSalesman(SalesmanModel salesman, {String? companyId}) async {
    final cid = companyId ?? 'cmp_1001';
    try {
      await _client.post(
        Uri.parse('${ApiConstants.baseUrl}/users/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'fullName': salesman.name,
          'email': salesman.email,
          'phone': salesman.phone,
          'nidNumber': salesman.nid,
          'password': 'Password123!',
          'userType': 'seller',
          'companyId': cid,
        }),
      );
    } catch (_) {}

    _localSalesmen.insert(0, salesman);
  }

  Future<void> updateSalesman(SalesmanModel salesman) async {
    _saveOverride(salesman);
    final index = _localSalesmen.indexWhere((s) => s.id == salesman.id);
    if (index != -1) {
      _localSalesmen[index] = salesman;
    }
  }

  Future<void> toggleSalesmanStatus(String salesmanId) async {
    try {
      await _client.patch(
        Uri.parse(ApiConstants.toggleSalesmanStatus(salesmanId)),
        headers: AuthRepository.getAuthHeaders(),
      );
    } catch (_) {}

    final index = _localSalesmen.indexWhere((s) => s.id == salesmanId);
    if (index != -1) {
      final current = _localSalesmen[index];
      final newStatus = current.status == 'Active' ? 'Inactive' : 'Active';
      _localSalesmen[index] = current.copyWith(status: newStatus);
    }
  }

  Future<void> approveSalesman(String salesmanId) async {
    try {
      await _client.patch(
        Uri.parse(ApiConstants.approveSalesman(salesmanId)),
        headers: AuthRepository.getAuthHeaders(),
      );
    } catch (_) {}

    final index = _localSalesmen.indexWhere((s) => s.id == salesmanId);
    if (index != -1) {
      _localSalesmen[index] = _localSalesmen[index].copyWith(status: 'Active');
    }
  }

  Future<void> rejectSalesman(String salesmanId) async {
    try {
      await _client.patch(
        Uri.parse(ApiConstants.rejectSalesman(salesmanId)),
        headers: AuthRepository.getAuthHeaders(),
      );
    } catch (_) {}

    _localSalesmen.removeWhere((s) => s.id == salesmanId);
  }

  Future<void> deleteSalesman(String salesmanId) async {
    try {
      await _client.delete(
        Uri.parse('${ApiConstants.baseUrl}/users/delete-profile/$salesmanId'),
        headers: AuthRepository.getAuthHeaders(),
      );
    } catch (_) {}

    _localSalesmen.removeWhere((salesman) => salesman.id == salesmanId);
  }
}
