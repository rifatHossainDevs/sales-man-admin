import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/sales_chart_data_model.dart';

class SalesChartWidget extends StatelessWidget {
  final List<SalesBarChartData> data;
  final SalesChartPeriod selectedPeriod;
  final ValueChanged<SalesChartPeriod> onPeriodChanged;

  const SalesChartWidget({
    super.key,
    required this.data,
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    final total = data.fold<double>(0, (sum, item) => sum + item.amountInLakhs);
    final maximum = data.fold<double>(
      0,
      (max, item) => item.amountInLakhs > max ? item.amountInLakhs : max,
    );
    final maxY = maximum <= 0 ? 1.0 : maximum * 1.25;
    final interval = maxY / 5;
    final title = switch (selectedPeriod) {
      SalesChartPeriod.sevenDays => '7 days',
      SalesChartPeriod.thirtyDays => '30 days',
      SalesChartPeriod.ninetyDays => '90 days',
    };

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sales trend · $title',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Recorded total ৳ ${(total * 100000).toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  children: [
                    _period('7D', SalesChartPeriod.sevenDays),
                    _period('30D', SalesChartPeriod.thirtyDays),
                    _period('90D', SalesChartPeriod.ninetyDays),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (data.isEmpty)
            const SizedBox(
              height: 200,
              child: Center(child: Text('No order records for this period.')),
            )
          else
            SizedBox(
              height: 205,
              child: BarChart(
                BarChartData(
                  maxY: maxY,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => AppColors.darkNavy,
                      getTooltipItem: (group, index, rod, rodIndex) {
                        final item = data[index];
                        return BarTooltipItem(
                          '৳ ${(item.amountInLakhs * 100000).toStringAsFixed(0)}\n${item.orderCount} orders',
                          const TextStyle(color: Colors.white, fontSize: 11),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 42,
                        interval: interval,
                        getTitlesWidget: (v, _) => Text(
                          v == 0 ? '0' : '${v.toStringAsFixed(1)}L',
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
                        reservedSize: 26,
                        interval: 1,
                        getTitlesWidget: (v, meta) {
                          final i = v.toInt();
                          if (i < 0 || i >= data.length) {
                            return const SizedBox.shrink();
                          }
                          final step = data.length > 30 ? 15 : (data.length > 7 ? 5 : 1);
                          if (i % step != 0 && i != data.length - 1) {
                            return const SizedBox.shrink();
                          }
                          return SideTitleWidget(
                            meta: meta,
                            space: 4,
                            child: Text(
                              data[i].dayLabel,
                              style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: interval,
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    for (var i = 0; i < data.length; i++)
                      BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: data[i].amountInLakhs,
                            color: data[i].isToday
                                ? AppColors.primary
                                : const Color(0xFFB4C6FF),
                            width: data.length <= 7
                                ? 24
                                : data.length <= 30
                                ? 6
                                : 2.5,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(4),
                              topRight: Radius.circular(4),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _period(String text, SalesChartPeriod period) {
    final active = selectedPeriod == period;
    return InkWell(
      onTap: () => onPeriodChanged(period),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 11,
            fontWeight: active ? FontWeight.bold : FontWeight.w500,
            color: active ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
