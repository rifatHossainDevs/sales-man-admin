import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../data/models/salesman_model.dart';

class SalesmanDetailsDialog extends StatelessWidget {
  final SalesmanModel salesman;
  final VoidCallback onEdit;
  final VoidCallback onToggleStatus;

  const SalesmanDetailsDialog({
    super.key,
    required this.salesman,
    required this.onEdit,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Avatar and Basic Info
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: salesman.isActive ? AppColors.primary : AppColors.textMuted,
                    child: Text(
                      salesman.avatarInitials,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.surface),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(salesman.name, style: AppTypography.h3Bold),
                        const SizedBox(height: 4),
                        Text(salesman.email, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            StatusBadge(status: salesman.status),
                            const SizedBox(width: 8),
                            if (salesman.isOnline)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.successBg,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  '● Online',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.success),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textSecondary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),

              const Divider(height: 28, color: AppColors.cardBorder),

              // KPI / Performance Summary Row
              Row(
                children: [
                  Expanded(
                    child: _metricBox(
                      label: 'Total Orders',
                      value: '${salesman.totalOrders}',
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _metricBox(
                      label: 'Cash Collected',
                      value: '৳ ${salesman.totalCollected.toStringAsFixed(0)}',
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Details List
              _detailRow(Icons.phone_outlined, 'Phone', salesman.phone),
              const SizedBox(height: 12),
              _detailRow(Icons.badge_outlined, 'NID Number', salesman.nid),
              const SizedBox(height: 12),
              _detailRow(Icons.location_on_outlined, 'Territory', salesman.assignedTerritory),
              const SizedBox(height: 12),
              _detailRow(Icons.access_time_rounded, 'Last Seen', salesman.lastSeen),

              const Divider(height: 28, color: AppColors.cardBorder),

              // Bottom Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton.icon(
                    icon: Icon(
                      salesman.isActive ? Icons.block_rounded : Icons.check_circle_outline,
                      size: 16,
                      color: salesman.isActive ? AppColors.danger : AppColors.success,
                    ),
                    label: Text(
                      salesman.isActive ? 'Deactivate' : 'Activate',
                      style: TextStyle(color: salesman.isActive ? AppColors.danger : AppColors.success),
                    ),
                    onPressed: () {
                      onToggleStatus();
                      Navigator.of(context).pop();
                    },
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Edit Details'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      onEdit();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metricBox({required String label, required String value, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        Text('$label: ', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
