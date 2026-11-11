import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../data/models/payment_model.dart';

class PaymentDetailsDialog extends StatelessWidget {
  final PaymentModel payment;
  final Function(String newStatus)? onStatusChanged;

  const PaymentDetailsDialog({
    super.key,
    required this.payment,
    this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Cash Collection Receipt', style: AppTypography.h3Bold),
                      const SizedBox(height: 2),
                      Text('Transaction ID: ${payment.trxId}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textSecondary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),

              const Divider(height: 24, color: AppColors.cardBorder),

              // Highlight Amount Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  children: [
                    const Text('Amount Collected', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(height: 6),
                    Text(
                      '৳ ${payment.amount.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        StatusBadge(status: payment.status),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF1F6),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('Method: Cash', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Key Details
              _detailRow('Invoice Number', payment.invoiceNo),
              const SizedBox(height: 10),
              _detailRow('Customer / Retailer', payment.retailerName),
              const SizedBox(height: 10),
              _detailRow('Collecting Salesman', payment.salesmanName),
              const SizedBox(height: 10),
              _detailRow('Collection Date', payment.paidAt),
              const SizedBox(height: 10),
              _detailRow('Payment Method', 'Cash (Only supported method)'),
              if (payment.notes != null && payment.notes!.isNotEmpty) ...[
                const SizedBox(height: 10),
                _detailRow('Notes', payment.notes!),
              ],

              const Divider(height: 28, color: AppColors.cardBorder),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (payment.status == 'Pending' && onStatusChanged != null)
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                      icon: const Icon(Icons.check_circle_outline, size: 16),
                      label: const Text('Mark as Paid'),
                      onPressed: () {
                        onStatusChanged!('Paid');
                        Navigator.of(context).pop();
                      },
                    )
                  else
                    const SizedBox.shrink(),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Close', style: TextStyle(color: AppColors.textPrimary)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
        Text(value, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      ],
    );
  }
}
