import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool showDot;

  const StatusBadge({
    super.key,
    required this.status,
    this.showDot = true,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: config.textColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            status,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              color: config.textColor,
            ),
          ),
        ],
      ),
    );
  }

  _StatusConfig _getStatusConfig(String statusStr) {
    switch (statusStr.toLowerCase()) {
      case 'paid':
      case 'delivered':
      case 'live':
      case 'online':
      case 'active':
        return _StatusConfig(
          textColor: AppColors.success,
          backgroundColor: AppColors.successBg,
        );
      case 'pending':
      case 'low stock':
      case 'idle':
        return _StatusConfig(
          textColor: AppColors.warning,
          backgroundColor: AppColors.warningBg,
        );
      case 'failed':
      case 'offline':
      case 'out of stock':
        return _StatusConfig(
          textColor: AppColors.danger,
          backgroundColor: AppColors.dangerBg,
        );
      default:
        return _StatusConfig(
          textColor: AppColors.textSecondary,
          backgroundColor: AppColors.cardBorder,
        );
    }
  }
}

class _StatusConfig {
  final Color textColor;
  final Color backgroundColor;

  _StatusConfig({
    required this.textColor,
    required this.backgroundColor,
  });
}
