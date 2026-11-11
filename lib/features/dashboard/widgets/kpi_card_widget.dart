import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/kpi_summary_model.dart';

class KpiCardWidget extends StatelessWidget {
  final KpiSummaryModel model;

  const KpiCardWidget({
    super.key,
    required this.model,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                model.title,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.normal,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                model.value,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                model.trendText,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: model.trendColor,
                ),
              ),
            ],
          ),
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: model.iconBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                model.icon,
                color: model.iconColor,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
