import 'package:flutter/material.dart';
import '../../../data/mock/mock_phase5_data.dart';
import '../../../data/repositories/company_subscription_repository.dart';

class SubscriptionManagementViewModel extends ChangeNotifier {
  SubscriptionManagementViewModel({CompanySubscriptionRepository? repository})
    : _repository = repository ?? CompanySubscriptionRepository() {
    load();
  }
  final CompanySubscriptionRepository _repository;
  // Start with the centralized mock records so the combined screen renders
  // immediately while the repository refreshes.
  bool isLoading = false;
  String? error;
  List<SubscriptionPlan> plans = List.of(MockPhase5Data.plans);
  List<CompanyRecord> companies = List.of(MockPhase5Data.companies);

  Future<void> load() async {
    isLoading = plans.isEmpty || companies.isEmpty;
    error = null;
    notifyListeners();
    try {
      plans = await _repository.getPlans();
      companies = await _repository.getCompanies();
    } catch (_) {
      error = 'Could not load subscription plans.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  List<CompanyRecord> get companiesByPlan => companies;
  List<SubscriptionHistoryRecord> historyFor(String companyId) {
    CompanyRecord? company;
    for (final item in companies) {
      if (item.id == companyId) {
        company = item;
      }
    }
    final assignedPlanId = company == null ? null : planIdFor(company);
    final records = MockPhase5Data.history.where((item) {
      if (item.companyId != companyId) return false;
      return assignedPlanId == company?.planId || item.status != 'Active';
    }).toList();
    if (company != null && assignedPlanId != company.planId) {
      double? price;
      for (final plan in plans) {
        if (plan.id == assignedPlanId) price = plan.annualPrice;
      }
      records.insert(
        0,
        SubscriptionHistoryRecord(
          companyId: companyId,
          planId: assignedPlanId!,
          status: 'Active (mock assignment)',
          start: _repository.subscriptionStartFor(company),
          end: company.subscriptionEnd,
          price: price,
        ),
      );
    }
    return records;
  }

  String planIdFor(CompanyRecord company) => _repository.planIdFor(company);
  DateTime subscriptionStartFor(CompanyRecord company) =>
      _repository.subscriptionStartFor(company);
  void assignPlan(String companyId, String planId) {
    _repository.assignPlan(companyId, planId);
    notifyListeners();
  }
}
