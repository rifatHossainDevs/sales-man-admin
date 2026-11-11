import 'package:flutter/material.dart';
import '../models/kpi_summary_model.dart';
import '../models/sales_chart_data_model.dart';
import '../models/salesman_duty_model.dart';
import '../models/recent_order_model.dart';
import '../models/low_stock_model.dart';
import '../mock/mock_dashboard_data.dart';
import '../mock/mock_orders_data.dart';
import '../mock/mock_payments_data.dart';
import '../../core/constants/app_colors.dart';

class DashboardRepository {
  Future<List<KpiSummaryModel>> fetchKpiSummaries() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final orders = MockOrdersData.getInitialOrders();
    final payments = MockPaymentsData.payments;
    final sales = orders
        .where((order) => order.paymentStatus != 'Failed')
        .fold<double>(0, (sum, order) => sum + order.totalAmount);
    final collected = payments
        .where((p) => p.status == 'Paid')
        .fold<double>(0, (sum, p) => sum + p.amount);
    final pending = orders.where((o) => o.paymentStatus == 'Pending').toList();
    final due = pending.fold<double>(0, (sum, o) => sum + o.dueAmount);
    return [
      _kpi(
        'Recorded sales',
        '৳ ${sales.toStringAsFixed(0)}',
        '${orders.length} recorded orders',
        Icons.trending_up_rounded,
        AppColors.primary,
        AppColors.infoBg,
      ),
      _kpi(
        'Recorded orders',
        '${orders.length}',
        'Across available mock dates',
        Icons.shopping_bag_outlined,
        const Color(0xFF9333EA),
        const Color(0xFFF3E8FF),
      ),
      _kpi(
        'Collected payments',
        '৳ ${collected.toStringAsFixed(0)}',
        '${payments.where((p) => p.status == 'Paid').length} paid records',
        Icons.account_balance_wallet_outlined,
        const Color(0xFF0891B2),
        const Color(0xFFCFFAFE),
      ),
      _kpi(
        'Outstanding due',
        '৳ ${due.toStringAsFixed(0)}',
        '${pending.length} pending orders',
        Icons.error_outline_rounded,
        AppColors.danger,
        AppColors.dangerBg,
      ),
    ];
  }

  Future<List<SalesBarChartData>> fetchSalesChartData(
    SalesChartPeriod period,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return MockDashboardData.getSalesChartData(period);
  }

  Future<List<SalesmanDutyModel>> fetchSalesmenOnDuty() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return MockDashboardData.getSalesmenOnDuty();
  }

  Future<List<RecentOrderModel>> fetchRecentOrders() async {
    await Future.delayed(const Duration(milliseconds: 200));
    final orders = MockOrdersData.getInitialOrders();
    return orders
        .take(5)
        .map(
          (o) => RecentOrderModel(
            invoiceNo: o.invoiceNo,
            retailerName: o.retailerName,
            salesmanName: o.salesmanName,
            totalAmount: o.totalAmount,
            paymentStatus: o.paymentStatus,
            shipmentStatus: o.shipmentStatus,
          ),
        )
        .toList();
  }

  Future<List<LowStockModel>> fetchLowStockAlerts() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return MockDashboardData.getLowStockAlerts();
  }
}

KpiSummaryModel _kpi(
  String title,
  String value,
  String trend,
  IconData icon,
  Color iconColor,
  Color background,
) => KpiSummaryModel(
  title: title,
  value: value,
  trendText: trend,
  icon: icon,
  iconColor: iconColor,
  iconBgColor: background,
  trendColor: iconColor,
);
