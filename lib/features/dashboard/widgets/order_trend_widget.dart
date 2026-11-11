import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/sales_chart_data_model.dart';

class OrderTrendWidget extends StatelessWidget {
  const OrderTrendWidget({super.key, required this.data});
  final List<SalesBarChartData> data;

  @override
  Widget build(BuildContext context) {
    final maxCount = data.fold<int>(
      0,
      (value, item) => item.orderCount > value ? item.orderCount : value,
    );
    return Container(
      width: double.infinity,
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
            'Order trend',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 3),
          const Text(
            'Order count from recorded order dates',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          if (data.isEmpty || maxCount == 0)
            const SizedBox(
              height: 100,
              child: Center(child: Text('No orders for this range.')),
            )
          else
            SizedBox(
              height: 155,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: (maxCount + 1).toDouble(),
                  gridData: const FlGridData(
                    show: true,
                    drawVerticalLine: false,
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 24,
                        getTitlesWidget: (value, _) => Text(
                          value.toInt().toString(),
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
                        interval: data.length > 14
                            ? (data.length / 7).ceilToDouble()
                            : 1,
                        getTitlesWidget: (value, _) {
                          final index = value.toInt();
                          if (index < 0 || index >= data.length) {
                            return const SizedBox.shrink();
                          }
                          return Text(
                            data[index].dayLabel,
                            style: const TextStyle(
                              fontSize: 9,
                              color: AppColors.textSecondary,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      color: AppColors.primary,
                      barWidth: 2.5,
                      dotData: const FlDotData(show: false),
                      spots: [
                        for (var i = 0; i < data.length; i++)
                          FlSpot(i.toDouble(), data[i].orderCount.toDouble()),
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
}
