import '../mock/mock_phase5_data.dart';

class CompanySubscriptionRepository {
  static final Map<String, String> _mockAssignments = {};
  static final Map<String, DateTime> _assignmentStartDates = {};
  Future<List<CompanyRecord>> getCompanies() async =>
      List.unmodifiable(MockPhase5Data.companies);
  Future<List<SubscriptionPlan>> getPlans() async =>
      List.unmodifiable(MockPhase5Data.plans);
  Future<List<SubscriptionHistoryRecord>> getHistory(String companyId) async =>
      MockPhase5Data.history
          .where((record) => record.companyId == companyId)
          .toList();
  String planIdFor(CompanyRecord company) =>
      _mockAssignments[company.id] ?? company.planId;
  DateTime subscriptionStartFor(CompanyRecord company) =>
      _assignmentStartDates[company.id] ?? company.subscriptionStart;

  void assignPlan(String companyId, String planId) {
    CompanyRecord? company;
    for (final record in MockPhase5Data.companies) {
      if (record.id == companyId) company = record;
    }
    if (company != null && company.planId == planId) {
      _mockAssignments.remove(companyId);
      _assignmentStartDates.remove(companyId);
    } else {
      _mockAssignments[companyId] = planId;
      _assignmentStartDates[companyId] = DateTime.now();
    }
  }
}
