import 'package:flutter/material.dart';
import '../../../data/models/kpi_summary_model.dart';
import '../../../data/models/sales_chart_data_model.dart';
import '../../../data/models/salesman_duty_model.dart';
import '../../../data/models/recent_order_model.dart';
import '../../../data/models/low_stock_model.dart';
import '../../../data/repositories/dashboard_repository.dart';
import '../../../data/mock/mock_salesmen_data.dart';

class DashboardViewModel extends ChangeNotifier {
  final DashboardRepository _repository;

  DashboardViewModel({DashboardRepository? repository})
    : _repository = repository ?? DashboardRepository() {
    loadDashboardData();
  }

  bool _isLoading = false;
  String? _error;
  SalesChartPeriod _selectedPeriod = SalesChartPeriod.sevenDays;

  List<KpiSummaryModel> _kpiSummaries = [];
  List<SalesBarChartData> _salesChartData = [];
  List<SalesmanDutyModel> _salesmenOnDuty = [];
  List<RecentOrderModel> _recentOrders = [];
  List<LowStockModel> _lowStockAlerts = [];

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  SalesChartPeriod get selectedPeriod => _selectedPeriod;

  List<KpiSummaryModel> get kpiSummaries => _kpiSummaries;
  List<SalesBarChartData> get salesChartData => _salesChartData;
  List<SalesmanDutyModel> get salesmenOnDuty => _salesmenOnDuty;
  List<RecentOrderModel> get recentOrders => _recentOrders;
  List<LowStockModel> get lowStockAlerts => _lowStockAlerts;

  int get onlineSalesmenCount =>
      _salesmenOnDuty.where((s) => s.isOnline).length;
  int get totalSalesmenCount =>
      MockSalesmenData.salesmen.where((s) => s.status == 'Active').length;

  Future<void> loadDashboardData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.fetchKpiSummaries(),
        _repository.fetchSalesChartData(_selectedPeriod),
        _repository.fetchSalesmenOnDuty(),
        _repository.fetchRecentOrders(),
        _repository.fetchLowStockAlerts(),
      ]);

      _kpiSummaries = results[0] as List<KpiSummaryModel>;
      _salesChartData = results[1] as List<SalesBarChartData>;
      _salesmenOnDuty = results[2] as List<SalesmanDutyModel>;
      _recentOrders = results[3] as List<RecentOrderModel>;
      _lowStockAlerts = results[4] as List<LowStockModel>;
    } catch (e) {
      _error = 'Could not load dashboard analytics.';
      debugPrint('Error loading dashboard data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void changeChartPeriod(SalesChartPeriod period) {
    if (_selectedPeriod == period) return;
    _selectedPeriod = period;
    notifyListeners();
    // Re-fetch chart data for selected period
    _repository
        .fetchSalesChartData(period)
        .then((data) {
          _salesChartData = data;
          _error = null;
          notifyListeners();
        })
        .catchError((Object error) {
          _error = 'Could not load the selected sales trend.';
          notifyListeners();
        });
  }
}
