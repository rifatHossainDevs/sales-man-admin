import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../data/models/retailer_model.dart';

class RetailerDetailsDialog extends StatelessWidget {
  final RetailerModel retailer;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const RetailerDetailsDialog({
    super.key,
    required this.retailer,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 720),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3E2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.storefront_rounded, color: Color(0xFFD97706), size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(retailer.storeName, style: AppTypography.h3Bold),
                        const SizedBox(height: 2),
                        Text('Owner: ${retailer.ownerName} · Phone: ${retailer.phone}',
                            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textSecondary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),

              const Divider(height: 24, color: AppColors.cardBorder),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Simulated GPS Map Location Box
                      Container(
                        height: 100,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F4F8),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const Positioned(
                              left: 16,
                              bottom: 12,
                              child: Row(
                                children: [
                                  Icon(Icons.location_on, color: AppColors.primary, size: 20),
                                  SizedBox(width: 4),
                                  Text('GPS Mapped: 23.8069, 90.3687', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.cardBorder),
                              ),
                              child: Text(
                                '${retailer.area}, ${retailer.subDistrict}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primary),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Metrics Row
                      Row(
                        children: [
                          Expanded(
                            child: _infoCard('Total Orders', '${retailer.ordersCount}', AppColors.textPrimary),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _infoCard(
                              'Payment Due',
                              retailer.dueAmount > 0 ? '৳ ${retailer.dueAmount.toStringAsFixed(0)}' : '— No due',
                              retailer.dueAmount > 0 ? AppColors.danger : AppColors.success,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _infoCard('Registered By', retailer.registeredBy, AppColors.primary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Full Details
                      _row('Street Address', retailer.address),
                      const SizedBox(height: 8),
                      _row('Sub-district & Area', '${retailer.subDistrict} → ${retailer.area}'),
                      const SizedBox(height: 8),
                      _row('Registration Date', retailer.registeredDate),

                      const SizedBox(height: 24),

                      // Order History
                      const Text(
                        'Recent Order History',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: retailer.orderHistory.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(child: Text('No orders yet for this store.', style: TextStyle(color: AppColors.textSecondary))),
                              )
                            : Column(
                                children: retailer.orderHistory.map((h) {
                                  return ListTile(
                                    dense: true,
                                    leading: const Icon(Icons.receipt_long_outlined, size: 20, color: AppColors.primary),
                                    title: Text(h.invoiceNo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    subtitle: Text(h.date, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('৳ ${h.amount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                        const SizedBox(width: 12),
                                        StatusBadge(status: h.status),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                      ),
                    ],
                  ),
                ),
              ),

              const Divider(height: 24, color: AppColors.cardBorder),

              // Bottom Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.danger)),
                    icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.danger),
                    label: const Text('Delete', style: TextStyle(color: AppColors.danger)),
                    onPressed: () {
                      Navigator.of(context).pop();
                      onDelete();
                    },
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Edit Store'),
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

  Widget _infoCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
        Text(value, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      ],
    );
  }
}
