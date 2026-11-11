import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/widgets/app_sidebar.dart';
import '../../../core/widgets/app_topbar.dart';
import '../../../routing/app_router.dart';
import '../viewmodels/salesman_performance_viewmodel.dart';

class SalesmanPerformanceView extends StatelessWidget {
  const SalesmanPerformanceView({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (_) => SalesmanPerformanceViewModel(),
    child: const _PerformanceContent(),
  );
}

class _PerformanceContent extends StatelessWidget {
  const _PerformanceContent();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SalesmanPerformanceViewModel>();
    final desktop = ResponsiveLayout.isDesktop(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const Drawer(
        child: AppSidebar(activeRoute: AppRouter.salesmanPerformance),
      ),
      body: Row(
        children: [
          if (desktop)
            const AppSidebar(activeRoute: AppRouter.salesmanPerformance),
          Expanded(
            child: Column(
              children: [
                const AppTopbar(
                  title: 'Salesman Performance',
                  subtitle:
                      'Sales, orders and target progress from recorded order history',
                ),
                Expanded(child: _performanceBody(context, vm)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _performanceBody(
    BuildContext context,
    SalesmanPerformanceViewModel vm,
  ) {
    if (vm.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    if (vm.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(vm.error!),
            TextButton(onPressed: vm.load, child: const Text('Retry')),
          ],
        ),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Performance overview',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => _chooseRange(context, vm),
                icon: const Icon(Icons.date_range),
                label: Text('${_short(vm.startDate)} – ${_short(vm.endDate)}'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth > 1050
                  ? 4
                  : constraints.maxWidth > 640
                  ? 2
                  : 1;
              final cards = [
                _MetricCard(
                  label: 'Total sales',
                  value: _money(vm.totalSales),
                  icon: Icons.trending_up,
                  tint: AppColors.primary,
                ),
                _MetricCard(
                  label: 'Total orders',
                  value: '${vm.totalOrders}',
                  icon: Icons.shopping_bag_outlined,
                  tint: const Color(0xFF9333EA),
                ),
                _MetricCard(
                  label: 'Completed orders',
                  value: '${vm.completedOrders}',
                  icon: Icons.check_circle_outline,
                  tint: AppColors.success,
                ),
                _MetricCard(
                  label: 'Pending orders',
                  value: '${vm.pendingOrders}',
                  icon: Icons.pending_actions,
                  tint: AppColors.warning,
                ),
              ];
              return Wrap(
                spacing: 14,
                runSpacing: 14,
                children: [
                  for (final card in cards)
                    SizedBox(
                      width:
                          (constraints.maxWidth - 14 * (columns - 1)) / columns,
                      child: card,
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 22),
          _ComparisonChart(metrics: vm.metrics),
          const SizedBox(height: 18),
          _MonthlyPerformanceCard(months: vm.monthlyPerformance),
          const SizedBox(height: 18),
          _RankingCard(
            metrics: vm.metrics,
            totalSales: vm.totalSales,
            totalTarget: vm.totalTarget,
            achievement: vm.targetAchievement,
          ),
          const SizedBox(height: 12),
          const Text(
            'Target is the configured monthly goal prorated to the selected date range. Visit counts are omitted because visit records are not included in the mock data.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _MonthlyPerformanceCard extends StatelessWidget {
  const _MonthlyPerformanceCard({required this.months});
  final List<MonthlyPerformanceMetric> months;

  @override
  Widget build(BuildContext context) {
    final maxValue = months.fold<double>(
      0,
      (max, month) => month.sales > max ? month.sales : max,
    );
    final maxTarget = months.fold<double>(
      0,
      (max, month) => month.target > max ? month.target : max,
    );
    final maxY = (maxValue > maxTarget ? maxValue : maxTarget) * 1.2;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Monthly performance',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Monthly sales against team target for the selected date range',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),
          if (months.isEmpty)
            const SizedBox(
              height: 80,
              child: Center(
                child: Text('No monthly order records for this range.'),
              ),
            )
          else
            SizedBox(
              height: 170,
              child: BarChart(
                BarChartData(
                  maxY: maxY <= 0 ? 1 : maxY,
                  gridData: const FlGridData(
                    show: true,
                    drawVerticalLine: false,
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 45,
                        getTitlesWidget: (value, _) => Text(
                          '${(value / 1000).round()}k',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) {
                          final index = value.toInt();
                          if (index < 0 || index >= months.length) {
                            return const SizedBox.shrink();
                          }
                          return Text(
                            months[index].month,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: [
                    for (var i = 0; i < months.length; i++)
                      BarChartGroupData(
                        x: i,
                        barsSpace: 8,
                        barRods: [
                          BarChartRodData(
                            toY: months[i].sales,
                            width: 18,
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          BarChartRodData(
                            toY: months[i].target,
                            width: 18,
                            color: const Color(0xFFB4C6FF),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          if (months.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '${months.first.orderCount} recorded orders in ${months.first.month}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

Future<void> _chooseRange(
  BuildContext context,
  SalesmanPerformanceViewModel vm,
) async {
  final start = vm.startDate ?? DateTime(2026, 11, 1);
  final end = vm.endDate ?? DateTime(2026, 11, 10);
  final range = await showDateRangePicker(
    context: context,
    firstDate: DateTime(2025),
    lastDate: DateTime(2027),
    initialDateRange: DateTimeRange(start: start, end: end),
  );
  if (range != null) {
    vm.setDateRange(range);
  }
}

String _short(DateTime? date) => date == null
    ? 'All dates'
    : '${date.day.toString().padLeft(2, '0')} ${const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][date.month - 1]} ${date.year}';
String _money(double value) => '৳ ${value.toStringAsFixed(0)}';

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.tint,
  });
  final String label, value;
  final IconData icon;
  final Color tint;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: AppColors.cardBorder),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Icon(icon, color: tint, size: 23),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              FittedBox(
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
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

class _ComparisonChart extends StatelessWidget {
  const _ComparisonChart({required this.metrics});
  final List<SalesmanPerformanceMetric> metrics;

  @override
  Widget build(BuildContext context) {
    final maxValue = metrics.fold<double>(0, (max, m) {
      final value = m.sales > m.target ? m.sales : m.target;
      return value > max ? value : max;
    });
    final maxY = maxValue <= 0 ? 100000.0 : maxValue * 1.25;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Salesman comparison · target vs sales',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          const Text(
            'Recorded order value compared with the prorated target',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          if (metrics.isEmpty || metrics.every((m) => m.orders == 0))
            const SizedBox(
              height: 80,
              child: Center(child: Text('No order records for this range.')),
            )
          else
            SizedBox(
              height: 240,
              child: BarChart(
                BarChartData(
                  maxY: maxY,
                  barGroups: [
                    for (var i = 0; i < metrics.length; i++)
                      BarChartGroupData(
                        x: i,
                        barsSpace: 5,
                        barRods: [
                          BarChartRodData(
                            toY: metrics[i].sales,
                            color: AppColors.primary,
                            width: 12,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          BarChartRodData(
                            toY: metrics[i].target,
                            color: const Color(0xFFB4C6FF),
                            width: 12,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ],
                      ),
                  ],
                  gridData: const FlGridData(
                    show: true,
                    drawVerticalLine: false,
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 46,
                        getTitlesWidget: (value, _) => Text(
                          '${(value / 1000).round()}k',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 36,
                        getTitlesWidget: (value, _) {
                          final index = value.toInt();
                          if (index < 0 || index >= metrics.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              metrics[index].salesman.name.split(' ').first,
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => AppColors.darkNavy,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                          BarTooltipItem(
                            '${rodIndex == 0 ? 'Sales' : 'Target'}: ${_money(rod.toY)}',
                            const TextStyle(color: Colors.white, fontSize: 11),
                          ),
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 10),
          const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(Icons.square, size: 12, color: AppColors.primary),
              SizedBox(width: 4),
              Text('Sales', style: TextStyle(fontSize: 11)),
              SizedBox(width: 14),
              Icon(Icons.square, size: 12, color: Color(0xFFB4C6FF)),
              SizedBox(width: 4),
              Text('Target', style: TextStyle(fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

class _RankingCard extends StatelessWidget {
  const _RankingCard({
    required this.metrics,
    required this.totalSales,
    required this.totalTarget,
    required this.achievement,
  });
  final List<SalesmanPerformanceMetric> metrics;
  final double totalSales, totalTarget, achievement;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: AppColors.cardBorder),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Salesman ranking',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Team target achievement ${(achievement * 100).toStringAsFixed(1)}% · ${_money(totalSales)} of ${_money(totalTarget)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        if (metrics.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: Text('No salesman records.')),
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('RANK')),
                DataColumn(label: Text('SALESMAN')),
                DataColumn(label: Text('ORDERS')),
                DataColumn(label: Text('COMPLETED')),
                DataColumn(label: Text('PENDING')),
                DataColumn(label: Text('TOTAL SALES')),
                DataColumn(label: Text('TARGET')),
                DataColumn(label: Text('ACHIEVEMENT')),
              ],
              rows: [
                for (var i = 0; i < metrics.length; i++)
                  DataRow(
                    onSelectChanged: (_) => _details(context, metrics[i]),
                    cells: [
                      DataCell(Text('${i + 1}'.padLeft(2, '0'))),
                      DataCell(Text(metrics[i].salesman.name)),
                      DataCell(Text('${metrics[i].orders}')),
                      DataCell(Text('${metrics[i].completedOrders}')),
                      DataCell(Text('${metrics[i].pendingOrders}')),
                      DataCell(Text(_money(metrics[i].sales))),
                      DataCell(Text(_money(metrics[i].target))),
                      DataCell(
                        SizedBox(
                          width: 130,
                          child: Row(
                            children: [
                              Expanded(
                                child: LinearProgressIndicator(
                                  value: metrics[i].achievement
                                      .clamp(0, 1)
                                      .toDouble(),
                                  color: AppColors.primary,
                                  backgroundColor: AppColors.infoBg,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${(metrics[i].achievement * 100).toStringAsFixed(0)}%',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
      ],
    ),
  );
}

void _details(BuildContext context, SalesmanPerformanceMetric metric) {
  showDialog<void>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(metric.salesman.name),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Territory: ${metric.salesman.assignedTerritory}'),
          Text('Sales: ${_money(metric.sales)}'),
          Text('Collected payments: ${_money(metric.collected)}'),
          Text(
            'Target: ${_money(metric.target)} (${(metric.achievement * 100).toStringAsFixed(1)}%)',
          ),
          Text(
            'Orders: ${metric.orders} · ${metric.completedOrders} completed · ${metric.pendingOrders} pending',
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}
