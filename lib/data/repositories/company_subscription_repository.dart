import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../mock/mock_phase5_data.dart';
import 'auth_repository.dart';

class CompanySubscriptionRepository {
  final http.Client _client;
  static final Map<String, String> _mockAssignments = {};
  static final Map<String, DateTime> _assignmentStartDates = {};
  static List<CompanyRecord> _cachedCompanies = List.from(MockPhase5Data.companies);

  CompanySubscriptionRepository({http.Client? client})
      : _client = client ?? http.Client();

  String _normalizePlanId(String? raw) {
    final val = (raw ?? 'starter').trim().toLowerCase();
    if (val == 'professional') return 'business';
    if (val == 'starter' || val == 'business' || val == 'enterprise') {
      return val;
    }
    return 'starter';
  }

  String _capitalizeStatus(String? raw) {
    final val = (raw ?? 'Active').trim();
    if (val.isEmpty) return 'Active';
    return val[0].toUpperCase() + val.substring(1).toLowerCase();
  }

  Future<CompanyRecord?> _fetchCompanyWithUsage(String companyId) async {
    try {
      final response = await _client.get(
        Uri.parse(ApiConstants.companyDetails(companyId)),
        headers: AuthRepository.getAuthHeaders(),
      );
      if (response.statusCode == 200) {
        final item = json.decode(response.body)['data'];
        if (item is Map) {
          final usage = item['usage'] is Map ? item['usage'] : {};
          final planId = _normalizePlanId(item['subscriptionType']?.toString());
          final now = DateTime.now();
          DateTime start = DateTime(now.year, 1, 1);
          DateTime end = DateTime(now.year, 12, 31);
          String status = 'Active';

          // Check if subscription history has explicit start/end dates
          final subs = await _fetchRawSubscriptions(companyId);
          if (subs.isNotEmpty) {
            final latest = subs.first;
            start = latest.start;
            end = latest.end;
            status = latest.status;
          }

          return CompanyRecord(
            id: (item['companyId'] ?? item['_id'] ?? companyId).toString(),
            name: (item['companyName'] ?? 'Dealership Company').toString(),
            email: (item['companyEmail'] ?? '').toString(),
            phone: (item['companyPhone'] ?? '').toString(),
            address: (item['companyAddress'] ?? 'Dhaka, Bangladesh').toString(),
            planId: planId,
            status: status,
            subscriptionStart: start,
            subscriptionEnd: end,
            admins: (usage['admins'] as num?)?.toInt() ?? 1,
            salesRepresentatives: (usage['salesRepresentatives'] as num?)?.toInt() ?? 0,
            customers: (usage['customers'] as num?)?.toInt() ?? 0,
          );
        }
      }
    } catch (_) {}
    return null;
  }

  Future<List<SubscriptionHistoryRecord>> _fetchRawSubscriptions(String companyId) async {
    try {
      final response = await _client.get(
        Uri.parse(ApiConstants.subscriptionsByCompany(companyId)),
        headers: AuthRepository.getAuthHeaders(),
      );
      if (response.statusCode == 200) {
        final List data = json.decode(response.body)['data'] ?? [];
        if (data.isNotEmpty) {
          final records = data.map((item) {
            final start = DateTime.tryParse(item['startDate']?.toString() ?? '') ??
                DateTime(DateTime.now().year, 1, 1);
            final end = DateTime.tryParse(item['endDate']?.toString() ?? '') ??
                DateTime(DateTime.now().year, 12, 31);
            final priceNum = item['price'] as num?;
            return SubscriptionHistoryRecord(
              companyId: (item['companyId'] ?? companyId).toString(),
              planId: _normalizePlanId(item['subscriptionType']?.toString()),
              status: _capitalizeStatus(item['status']?.toString()),
              start: start,
              end: end,
              price: priceNum?.toDouble(),
            );
          }).toList();
          records.sort((a, b) => b.start.compareTo(a.start));
          return records;
        }
      }
    } catch (_) {}
    return [];
  }

  Future<List<CompanyRecord>> getCompanies({String? companyId}) async {
    final cid = companyId ?? AuthRepository().loadSavedUserSync()?.companyId;

    // 1. Try fetching the logged-in admin's company directly with live usage
    if (cid != null && cid.isNotEmpty && !cid.startsWith('CMP-') && !cid.startsWith('cmp_')) {
      final record = await _fetchCompanyWithUsage(cid);
      if (record != null) {
        _cachedCompanies = [record];
        return List.unmodifiable(_cachedCompanies);
      }
    }

    // 2. Fallback: fetch all companies from backend and enrich with usage
    try {
      final response = await _client.get(
        Uri.parse(ApiConstants.allCompanies),
        headers: AuthRepository.getAuthHeaders(),
      );
      if (response.statusCode == 200) {
        final List data = json.decode(response.body)['data'] ?? [];
        if (data.isNotEmpty) {
          final List<CompanyRecord> loaded = [];
          for (final item in data) {
            final id = (item['_id'] ?? '').toString();
            final detailed = id.isNotEmpty ? await _fetchCompanyWithUsage(id) : null;
            if (detailed != null) {
              loaded.add(detailed);
            } else {
              final now = DateTime.now();
              loaded.add(
                CompanyRecord(
                  id: id,
                  name: (item['companyName'] ?? 'Dealership Company').toString(),
                  email: (item['companyEmail'] ?? '').toString(),
                  phone: (item['companyPhone'] ?? '').toString(),
                  address: (item['companyAddress'] ?? 'Dhaka, Bangladesh').toString(),
                  planId: _normalizePlanId(item['subscriptionType']?.toString()),
                  status: 'Active',
                  subscriptionStart: DateTime(now.year, 1, 1),
                  subscriptionEnd: DateTime(now.year, 12, 31),
                  admins: 1,
                  salesRepresentatives: 0,
                  customers: 0,
                ),
              );
            }
          }
          if (loaded.isNotEmpty) {
            _cachedCompanies = loaded;
            return List.unmodifiable(_cachedCompanies);
          }
        }
      }
    } catch (_) {}

    return List.unmodifiable(_cachedCompanies);
  }

  Future<List<SubscriptionPlan>> getPlans() async =>
      List.unmodifiable(MockPhase5Data.plans);

  Future<List<SubscriptionHistoryRecord>> getHistory(String companyId) async {
    final liveRecords = await _fetchRawSubscriptions(companyId);
    if (liveRecords.isNotEmpty) {
      return liveRecords;
    }

    // Synthesize active subscription history record from live company data if no subscription docs exist yet
    CompanyRecord? company;
    for (final c in _cachedCompanies) {
      if (c.id == companyId) {
        company = c;
        break;
      }
    }
    if (company != null) {
      final activePlanId = planIdFor(company);
      double? planPrice;
      for (final p in MockPhase5Data.plans) {
        if (p.id == activePlanId) {
          planPrice = p.annualPrice;
          break;
        }
      }
      return [
        SubscriptionHistoryRecord(
          companyId: company.id,
          planId: activePlanId,
          status: company.status,
          start: subscriptionStartFor(company),
          end: company.subscriptionEnd,
          price: planPrice,
        ),
      ];
    }

    return MockPhase5Data.history
        .where((record) => record.companyId == companyId)
        .toList();
  }

  String planIdFor(CompanyRecord company) =>
      _mockAssignments[company.id] ?? _normalizePlanId(company.planId);

  DateTime subscriptionStartFor(CompanyRecord company) =>
      _assignmentStartDates[company.id] ?? company.subscriptionStart;

  Future<void> assignPlan(String companyId, String planId) async {
    final normalizedPlan = _normalizePlanId(planId);
    CompanyRecord? company;
    for (final record in _cachedCompanies) {
      if (record.id == companyId) company = record;
    }

    _mockAssignments[companyId] = normalizedPlan;
    _assignmentStartDates[companyId] = DateTime.now();

    if (company != null) {
      try {
        await _client.patch(
          Uri.parse(ApiConstants.updateCompany(companyId)),
          headers: AuthRepository.getAuthHeaders(),
          body: json.encode({
            'companyName': company.name,
            'companyEmail': company.email,
            'companyPhone': company.phone,
            'companyAddress': company.address,
            'subscriptionType': normalizedPlan,
          }),
        );
      } catch (_) {}
    }
  }
}
