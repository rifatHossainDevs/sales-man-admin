import 'package:flutter/material.dart';
import '../../../data/mock/mock_phase5_data.dart';
import '../../../data/repositories/company_subscription_repository.dart';

class CompanyManagementViewModel extends ChangeNotifier {
  final CompanySubscriptionRepository _repository;
  final String? companyId;

  CompanyManagementViewModel({
    CompanySubscriptionRepository? repository,
    this.companyId,
  }) : _repository = repository ?? CompanySubscriptionRepository() {
    load();
  }

  bool isLoading = true;
  String? error;
  String query = '';
  String statusFilter = 'All';
  List<CompanyRecord> companies = List.of(MockPhase5Data.companies);
  List<SubscriptionPlan> plans = List.of(MockPhase5Data.plans);
  List<SubscriptionHistoryRecord> history = [];

  Future<void> load() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      companies = await _repository.getCompanies(companyId: companyId);
      plans = await _repository.getPlans();
      if (companies.isNotEmpty) {
        history = await _repository.getHistory(companies.first.id);
      } else {
        history = MockPhase5Data.history;
      }
    } catch (_) {
      error = 'Could not load company records.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  List<CompanyRecord> get filteredCompanies => companies.where((company) {
        final matchesQuery = query.isEmpty ||
            '${company.name} ${company.id} ${company.email} ${company.phone}'
                .toLowerCase()
                .contains(query.toLowerCase());
        return matchesQuery &&
            (statusFilter == 'All' || company.status == statusFilter);
      }).toList();

  SubscriptionPlan? planFor(String id) {
    final normalized = id == 'professional' ? 'business' : id.toLowerCase();
    for (final plan in plans) {
      if (plan.id == normalized) return plan;
    }
    return plans.isNotEmpty ? plans.first : null;
  }

  String planIdForCompany(CompanyRecord company) =>
      _repository.planIdFor(company);

  SubscriptionPlan? planForCompany(CompanyRecord company) =>
      planFor(_repository.planIdFor(company));

  void setQuery(String value) {
    query = value;
    notifyListeners();
  }

  void setStatus(String value) {
    statusFilter = value;
    notifyListeners();
  }
}
