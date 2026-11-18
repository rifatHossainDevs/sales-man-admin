import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/widgets/app_sidebar.dart';
import '../../../core/widgets/app_topbar.dart';
import '../../../features/auth/viewmodels/auth_viewmodel.dart';
import '../../../routing/app_router.dart';
import '../viewmodels/dashboard_viewmodel.dart';
import '../widgets/kpi_card_widget.dart';
import '../widgets/sales_chart_widget.dart';
import '../widgets/salesmen_duty_widget.dart';
import '../widgets/recent_orders_widget.dart';
import '../widgets/low_stock_alerts_widget.dart';
import '../widgets/order_trend_widget.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final companyId = context.watch<AuthViewModel>().currentUser?.companyId;

    return ChangeNotifierProvider(
      create: (_) => DashboardViewModel(companyId: companyId),
      child: const _DashboardViewContent(),
    );
  }
}

class _DashboardViewContent extends StatelessWidget {
  const _DashboardViewContent();

  String _getTodaySubtitle(BuildContext context) {
    final user = context.watch<AuthViewModel>().currentUser;
    final now = DateTime.now();
    final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

    final weekday = weekdays[now.weekday - 1];
    final day = now.day;
    final month = months[now.month - 1];
    final year = now.year;
    final dealership = (user?.dealershipName != null && user!.dealershipName.isNotEmpty)
        ? user.dealershipName
        : 'Dhaka Dealership Ltd.';

    return '$weekday, $day $month $year · $dealership';
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DashboardViewModel>();
    final isDesktop = ResponsiveLayout.isDesktop(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: Drawer(child: AppSidebar(activeRoute: AppRouter.dashboard)),
      body: Row(
        children: [
          // Sidebar for Desktop
          if (isDesktop) const AppSidebar(activeRoute: AppRouter.dashboard),

          // Main Content Area
          Expanded(
            child: Column(
              children: [
                AppTopbar(
                  title: 'Dashboard',
                  subtitle: _getTodaySubtitle(context),
                ),
                Expanded(
                  child: viewModel.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        )
                      : viewModel.error != null
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(viewModel.error!),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: viewModel.loadDashboardData,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 1. KPI Summary Stat Cards
                              _buildKpiGrid(context, viewModel),

                              const SizedBox(height: 24),

                              // 2. Dashboard Main Grid (Charts & Lists)
                              if (isDesktop)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Left Column: Sales Chart + Recent Orders
                                    Expanded(
                                      flex: 7,
                                      child: Column(
                                        children: [
                                          SalesChartWidget(
                                            data: viewModel.salesChartData,
                                            selectedPeriod:
                                                viewModel.selectedPeriod,
                                            onPeriodChanged:
                                                viewModel.changeChartPeriod,
                                          ),
                                          const SizedBox(height: 18),
                                          OrderTrendWidget(
                                            data: viewModel.salesChartData,
                                          ),
                                          const SizedBox(height: 24),
                                          RecentOrdersWidget(
                                            orders: viewModel.recentOrders,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 24),
                                    // Right Column: Salesmen On Duty + Low Stock Alerts
                                    Expanded(
                                      flex: 5,
                                      child: Column(
                                        children: [
                                          SalesmenDutyWidget(
                                            salesmen: viewModel.salesmenOnDuty,
                                            onlineCount:
                                                viewModel.onlineSalesmenCount,
                                            totalCount:
                                                viewModel.totalSalesmenCount,
                                          ),
                                          const SizedBox(height: 24),
                                          LowStockAlertsWidget(
                                            alerts: viewModel.lowStockAlerts,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              else
                                // Stacked layout for Mobile & Tablet
                                Column(
                                  children: [
                                    SalesChartWidget(
                                      data: viewModel.salesChartData,
                                      selectedPeriod: viewModel.selectedPeriod,
                                      onPeriodChanged:
                                          viewModel.changeChartPeriod,
                                    ),
                                    const SizedBox(height: 18),
                                    OrderTrendWidget(
                                      data: viewModel.salesChartData,
                                    ),
                                    const SizedBox(height: 24),
                                    SalesmenDutyWidget(
                                      salesmen: viewModel.salesmenOnDuty,
                                      onlineCount:
                                          viewModel.onlineSalesmenCount,
                                      totalCount: viewModel.totalSalesmenCount,
                                    ),
                                    const SizedBox(height: 24),
                                    RecentOrdersWidget(
                                      orders: viewModel.recentOrders,
                                    ),
                                    const SizedBox(height: 24),
                                    LowStockAlertsWidget(
                                      alerts: viewModel.lowStockAlerts,
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiGrid(BuildContext context, DashboardViewModel viewModel) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final isTablet = ResponsiveLayout.isTablet(context);

    if (isDesktop) {
      return Row(
        children: viewModel.kpiSummaries.map((kpi) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: kpi == viewModel.kpiSummaries.last ? 0 : 16,
              ),
              child: KpiCardWidget(model: kpi),
            ),
          );
        }).toList(),
      );
    } else if (isTablet) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: KpiCardWidget(model: viewModel.kpiSummaries[0])),
              const SizedBox(width: 16),
              Expanded(child: KpiCardWidget(model: viewModel.kpiSummaries[1])),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: KpiCardWidget(model: viewModel.kpiSummaries[2])),
              const SizedBox(width: 16),
              Expanded(child: KpiCardWidget(model: viewModel.kpiSummaries[3])),
            ],
          ),
        ],
      );
    } else {
      return Column(
        children: viewModel.kpiSummaries.map((kpi) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: KpiCardWidget(model: kpi),
          );
        }).toList(),
      );
    }
  }
}
