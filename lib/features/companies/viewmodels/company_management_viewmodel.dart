import 'package:flutter/material.dart';
import '../../../data/mock/mock_phase5_data.dart';
import '../../../data/repositories/company_subscription_repository.dart';

class CompanyManagementViewModel extends ChangeNotifier {
  CompanyManagementViewModel({CompanySubscriptionRepository? repository})
    : _repository = repository ?? CompanySubscriptionRepository() {
    load();
  }
  final CompanySubscriptionRepository _repository;
  // Render the centralized mock records immediately while the repository
  // refreshes. This keeps the screen useful even if a future API request is
  // slow, without duplicating records in the view.
  bool isLoading = false;
  String? error;
  String query = '';
  String statusFilter = 'All';
  List<CompanyRecord> companies = List.of(MockPhase5Data.companies);
  List<SubscriptionPlan> plans = List.of(MockPhase5Data.plans);

  Future<void> load() async {
    isLoading = companies.isEmpty || plans.isEmpty;
    error = null;
    notifyListeners();
    try {
      companies = await _repository.getCompanies();
      plans = await _repository.getPlans();
    } catch (_) {
      error = 'Could not load company records.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  List<CompanyRecord> get filteredCompanies => companies.where((company) {
    final matchesQuery =
        query.isEmpty ||
        '${company.name} ${company.id} ${company.email} ${company.phone}'
            .toLowerCase()
            .contains(query.toLowerCase());
    return matchesQuery &&
        (statusFilter == 'All' || company.status == statusFilter);
  }).toList();

  SubscriptionPlan? planFor(String id) {
    for (final plan in plans) {
      if (plan.id == id) return plan;
    }
    return null;
  }

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
