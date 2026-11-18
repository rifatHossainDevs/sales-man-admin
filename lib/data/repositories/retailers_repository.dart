import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../../core/utils/web_platform.dart';
import '../models/retailer_model.dart';
import '../mock/mock_retailers_data.dart';
import 'auth_repository.dart';

class RetailersRepository {
  final http.Client _client;
  final List<RetailerModel> _localRetailers = List.from(MockRetailersData.retailers);
  static const String _overridesKey = 'retailer_profile_overrides';

  static final Uint8List _defaultPngBytes = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==',
  );

  static final Map<int, String> _subDisNames = {
    101: 'Mirpur',
    102: 'Savar',
    103: 'Keraniganj',
    104: 'Nawabganj',
    105: 'Dohar',
    201: 'Gazipur Sadar',
    202: 'Kaliakair',
    301: 'Narayanganj Sadar',
    302: 'Sonargaon',
    401: 'Narsingdi Sadar',
    501: 'Manikganj Sadar',
    601: 'Munshiganj Sadar',
  };

  static final Map<int, String> _areaNames = {
    1001: 'Mirpur-10',
    1002: 'Mirpur-11',
    1003: 'Pallabi',
    1101: 'Savar Bazar',
    1401: 'Dohar Bazar',
    1402: 'Joypara',
    2001: 'Joydebpur',
    2003: 'Board Bazar',
    2101: 'Kaliakair Bazar',
    3001: 'Chashara',
    3003: 'Siddhirganj',
    3101: 'Sonargaon Bazar',
    3102: 'Mograpara',
  };

  RetailersRepository({http.Client? client}) : _client = client ?? http.Client();

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

  void _saveOverride(RetailerModel retailer) {
    try {
      final map = _loadOverrides();
      map[retailer.id] = {
        'storeName': retailer.storeName,
        'ownerName': retailer.ownerName,
        'phone': retailer.phone,
        'address': retailer.address,
        'subDistrict': retailer.subDistrict,
        'area': retailer.area,
        'registeredBy': retailer.registeredBy,
      };
      WebPlatform.setLocalStorageItem(_overridesKey, json.encode(map));
    } catch (_) {}
  }

  List<dynamic> _extractStoresList(String body) {
    final decoded = json.decode(body)['data'];
    if (decoded is List) return decoded;
    if (decoded is Map && decoded['stores'] is List) {
      return decoded['stores'] as List;
    }
    return const [];
  }

  Future<List<RetailerModel>> getRetailers({String? companyId, String? search}) async {
    final cid = companyId ?? AuthRepository().loadSavedUserSync()?.companyId ?? '';
    try {
      List<dynamic> rawStores = [];
      if (cid.isNotEmpty) {
        final compRes = await _client.get(
          Uri.parse('${ApiConstants.baseUrl}/stores/get-store-by-company/$cid'),
          headers: AuthRepository.getAuthHeaders(),
        );
        if (compRes.statusCode == 200) {
          rawStores = _extractStoresList(compRes.body);
        }
      }
      if (rawStores.isEmpty) {
        final allRes = await _client.get(
          Uri.parse('${ApiConstants.stores}?limit=200'),
          headers: AuthRepository.getAuthHeaders(),
        );
        if (allRes.statusCode == 200) {
          rawStores = _extractStoresList(allRes.body);
        }
      }

      if (rawStores.isNotEmpty) {
        // Fetch live territories and orders in parallel to enrich store location hierarchy and order history
        final auxResults = await Future.wait([
          _client.get(Uri.parse(ApiConstants.divisions)),
          _client.get(Uri.parse(ApiConstants.districts)),
          _client.get(Uri.parse(ApiConstants.subDistricts)),
          _client.get(Uri.parse(ApiConstants.areas)),
          _client.get(Uri.parse('${ApiConstants.orders}?limit=200')),
        ]);

        final divByNo = <int, String>{};
        final disByNo = <int, Map<String, dynamic>>{};
        final subDisByNo = <int, Map<String, dynamic>>{};
        final areaByNo = <int, Map<String, dynamic>>{};

        if (auxResults[0].statusCode == 200) {
          final List list = json.decode(auxResults[0].body)['data'] ?? [];
          for (final d in list) {
            final no = int.tryParse((d['divNo'] ?? '').toString());
            if (no != null) divByNo[no] = (d['divName'] ?? 'Dhaka').toString();
          }
        }
        if (auxResults[1].statusCode == 200) {
          final List list = json.decode(auxResults[1].body)['data'] ?? [];
          for (final d in list) {
            final no = int.tryParse((d['disNo'] ?? '').toString());
            if (no != null && d is Map<String, dynamic>) disByNo[no] = d;
          }
        }
        if (auxResults[2].statusCode == 200) {
          final List list = json.decode(auxResults[2].body)['data'] ?? [];
          for (final sd in list) {
            final no = int.tryParse((sd['subDisNo'] ?? '').toString());
            if (no != null && sd is Map<String, dynamic>) subDisByNo[no] = sd;
          }
        }
        if (auxResults[3].statusCode == 200) {
          final List list = json.decode(auxResults[3].body)['data'] ?? [];
          for (final a in list) {
            final no = int.tryParse((a['areaNo'] ?? '').toString());
            if (no != null && a is Map<String, dynamic>) areaByNo[no] = a;
          }
        }

        final ordersByStoreKey = <String, List<RetailerOrderSummary>>{};
        final dueByStoreKey = <String, double>{};

        if (auxResults[4].statusCode == 200) {
          final ordersData = json.decode(auxResults[4].body)['data'];
          final List ordersList = ordersData is Map
              ? (ordersData['orders'] ?? [])
              : (ordersData is List ? ordersData : []);
          const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
          for (final o in ordersList) {
            final cust = o['customerId'];
            final custId = (cust is Map ? cust['_id'] : cust)?.toString() ?? '';
            final storeInfo = o['storeInfo'] is Map ? o['storeInfo'] : {};
            final storeNameKey = (storeInfo['storeName'] ?? '').toString().trim().toLowerCase();

            final created = DateTime.tryParse(o['createdAt'] ?? '') ?? DateTime.now();
            final dateStr = '${created.day.toString().padLeft(2, '0')} ${months[created.month - 1]} ${created.year}';
            final totalAmt = (o['totalPrice'] as num?)?.toDouble() ?? 0.0;
            final rawPaid = (o['amountPaid'] as num?)?.toDouble() ?? 0.0;
            final status = (o['paymentStatus'] ?? 'Pending').toString();
            final paidAmt = (status == 'Paid' && rawPaid <= 0) ? totalAmt : rawPaid;
            final due = status == 'Pending' ? (totalAmt - paidAmt).clamp(0.0, double.infinity) : 0.0;

            final historyItem = RetailerOrderSummary(
              invoiceNo: (o['invoiceNumber'] ?? 'INV-000').toString(),
              date: dateStr,
              amount: totalAmt,
              status: status,
            );

            if (custId.isNotEmpty) {
              ordersByStoreKey.putIfAbsent(custId, () => []).add(historyItem);
              dueByStoreKey[custId] = (dueByStoreKey[custId] ?? 0.0) + due;
            }
            if (storeNameKey.isNotEmpty) {
              ordersByStoreKey.putIfAbsent(storeNameKey, () => []).add(historyItem);
              dueByStoreKey[storeNameKey] = (dueByStoreKey[storeNameKey] ?? 0.0) + due;
            }
          }
        }

        final overrides = _loadOverrides();

        return rawStores.map((item) {
          final id = (item['_id'] ?? '').toString();
          final ov = overrides[id] ?? const {};

          double lat = 23.8103;
          double lng = 90.4125;
          final coords = item['coordinates'];
          if (coords is List && coords.length >= 2) {
            lat = double.tryParse(coords[0].toString()) ?? 23.8103;
            lng = double.tryParse(coords[1].toString()) ?? 90.4125;
          }

          final user = item['userId'] is Map ? item['userId'] : {};
          final userIdStr = (item['userId'] is Map ? item['userId']['_id'] : item['userId'])?.toString() ?? '';
          final registeredBy = (ov['registeredBy'] ?? user['fullName'] ?? 'Sales Rep').toString();
          final created = DateTime.tryParse(item['createdAt'] ?? '') ?? DateTime.now();
          const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
          final regDate = '${created.day} ${months[created.month - 1]} ${created.year}';

          final subDisNo = int.tryParse((item['subDisNo'] ?? '').toString()) ?? 101;
          final areaNo = int.tryParse((item['areaNo'] ?? '').toString()) ?? 1001;

          final areaDoc = areaByNo[areaNo];
          final subDisDoc = subDisByNo[subDisNo] ??
              subDisByNo[int.tryParse((areaDoc?['subdisNo'] ?? '').toString()) ?? -1];
          final disNo = int.tryParse((subDisDoc?['disNo'] ?? '').toString()) ?? (subDisNo ~/ 100);
          final disDoc = disByNo[disNo];
          final divNo = int.tryParse((disDoc?['divNo'] ?? '').toString()) ?? 1;

          final divisionResolved = divByNo[divNo] ?? 'Dhaka';
          final districtResolved = (disDoc?['disName'] ?? 'Dhaka').toString();
          final subDistrictResolved = (ov['subDistrict'] ??
                  subDisDoc?['subDisName'] ??
                  _subDisNames[subDisNo] ??
                  'Sub-District $subDisNo')
              .toString();
          final areaResolved = (ov['area'] ??
                  areaDoc?['areaName'] ??
                  _areaNames[areaNo] ??
                  'Area $areaNo')
              .toString();

          final storeName = (ov['storeName'] ?? item['storeName'] ?? 'Retail Store').toString();
          final storeNameKey = storeName.trim().toLowerCase();

          final history = ordersByStoreKey[id] ??
              ordersByStoreKey[userIdStr] ??
              ordersByStoreKey[storeNameKey] ??
              const <RetailerOrderSummary>[];
          final due = dueByStoreKey[id] ??
              dueByStoreKey[userIdStr] ??
              dueByStoreKey[storeNameKey] ??
              0.0;

          return RetailerModel(
            id: id,
            storeName: storeName,
            ownerName: (ov['ownerName'] ?? item['storeOwnerName'] ?? 'Store Owner').toString(),
            phone: (ov['phone'] ?? item['phone'] ?? '').toString(),
            division: divisionResolved,
            district: districtResolved,
            subDistrict: subDistrictResolved,
            area: areaResolved,
            address: (ov['address'] ?? item['address'] ?? 'Dhaka').toString(),
            registeredBy: registeredBy,
            registeredDate: regDate,
            ordersCount: history.length,
            dueAmount: due,
            isGpsMapped: true,
            lat: lat,
            lng: lng,
            orderHistory: history,
          );
        }).toList();
      }
    } catch (_) {}

    await Future.delayed(const Duration(milliseconds: 100));
    return List.from(_localRetailers);
  }

  Future<void> addRetailer(RetailerModel retailer, {String? companyId}) async {
    try {
      final savedUser = AuthRepository().loadSavedUserSync();
      String userId = savedUser?.id ?? '';
      final cid = companyId ?? savedUser?.companyId ?? '';

      if (cid.isNotEmpty) {
        try {
          final usersRes = await _client.get(Uri.parse(ApiConstants.allCompanyUsers(cid)));
          if (usersRes.statusCode == 200) {
            final List users = json.decode(usersRes.body)['data'] ?? [];
            final seller = users.where((u) => u['userType'] == 'seller').firstOrNull;
            if (seller != null && seller['_id'] != null) {
              userId = seller['_id'].toString();
            }
          }
        } catch (_) {}
      }

      int resolvedSubDisNo = 101;
      int resolvedAreaNo = 1001;
      try {
        final subRes = await _client.get(Uri.parse(ApiConstants.subDistricts));
        if (subRes.statusCode == 200) {
          final List subs = json.decode(subRes.body)['data'] ?? [];
          for (final s in subs) {
            if ((s['subDisName'] ?? '').toString().toLowerCase() ==
                retailer.subDistrict.trim().toLowerCase()) {
              resolvedSubDisNo = int.tryParse((s['subDisNo'] ?? '').toString()) ?? 101;
              break;
            }
          }
        }
        final areaRes = await _client.get(Uri.parse(ApiConstants.areas));
        if (areaRes.statusCode == 200) {
          final List areas = json.decode(areaRes.body)['data'] ?? [];
          for (final a in areas) {
            if ((a['areaName'] ?? '').toString().toLowerCase() ==
                retailer.area.trim().toLowerCase()) {
              resolvedAreaNo = int.tryParse((a['areaNo'] ?? '').toString()) ?? 1001;
              resolvedSubDisNo = int.tryParse((a['subdisNo'] ?? '').toString()) ?? resolvedSubDisNo;
              break;
            }
          }
        }
      } catch (_) {}

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConstants.baseUrl}/stores/create-store'),
      );
      final authHeaders = AuthRepository.getAuthHeaders();
      if (authHeaders['Authorization'] != null) {
        request.headers['Authorization'] = authHeaders['Authorization']!;
      }

      request.fields['userId'] = userId;
      request.fields['storeOwnerName'] = retailer.ownerName;
      request.fields['phone'] = retailer.phone;
      request.fields['storeName'] = retailer.storeName;
      request.fields['address'] = retailer.address;
      request.fields['areaNo'] = resolvedAreaNo.toString();
      request.fields['subDisNo'] = resolvedSubDisNo.toString();
      request.fields['coordinates[0]'] = retailer.lat.toString();
      request.fields['coordinates[1]'] = retailer.lng.toString();

      request.files.add(
        http.MultipartFile.fromBytes('avatar', _defaultPngBytes, filename: 'owner_avatar.png'),
      );
      request.files.add(
        http.MultipartFile.fromBytes('storePictures', _defaultPngBytes, filename: 'store_front.png'),
      );

      final streamedRes = await request.send();
      if (streamedRes.statusCode == 200 || streamedRes.statusCode == 201) {
        return;
      }
    } catch (_) {}

    _localRetailers.insert(0, retailer);
  }

  Future<void> updateRetailer(RetailerModel retailer) async {
    _saveOverride(retailer);
    try {
      await _client.patch(
        Uri.parse('${ApiConstants.baseUrl}/stores/update-store/${retailer.id}'),
        headers: AuthRepository.getAuthHeaders(),
        body: json.encode({
          'storeName': retailer.storeName,
          'coordinates': ['${retailer.lat}', '${retailer.lng}'],
        }),
      );
    } catch (_) {}

    final index = _localRetailers.indexWhere((r) => r.id == retailer.id);
    if (index != -1) {
      _localRetailers[index] = retailer;
    }
  }

  Future<void> deleteRetailer(String retailerId) async {
    try {
      await _client.delete(
        Uri.parse('${ApiConstants.baseUrl}/stores/delete-store/$retailerId'),
        headers: AuthRepository.getAuthHeaders(),
      );
    } catch (_) {}

    _localRetailers.removeWhere((r) => r.id == retailerId);
  }
}
