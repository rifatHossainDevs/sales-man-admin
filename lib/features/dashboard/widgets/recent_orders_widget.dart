import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../data/models/recent_order_model.dart';
import '../../../routing/app_router.dart';

class RecentOrdersWidget extends StatelessWidget {
  final List<RecentOrderModel> orders;

  const RecentOrdersWidget({
    super.key,
    required this.orders,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent orders',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.of(context).pushReplacementNamed(AppRouter.orders);
                },
                child: const Text(
                  'View all',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Data Table with responsive minWidth to prevent status clipping on 19-inch monitors
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              // Give every column room for its longest labels and status badges.
              constraints: const BoxConstraints(minWidth: 900),
              child: DataTable(
                columnSpacing: 16,
                horizontalMargin: 8,
                headingRowHeight: 40,
                dataRowMinHeight: 48,
                dataRowMaxHeight: 48,
                headingRowColor: WidgetStateProperty.all(AppColors.background),
                columns: const [
                  DataColumn(
                    label: Text('INVOICE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                  ),
                  DataColumn(
                    label: Text('RETAILER', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                  ),
                  DataColumn(
                    label: Text('SALESMAN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                  ),
                  DataColumn(
                    numeric: true,
                    label: Text('TOTAL', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                  ),
                  DataColumn(
                    label: Text('PAYMENT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                  ),
                  DataColumn(
                    label: Text('SHIPMENT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                  ),
                ],
                rows: orders.map((order) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          order.invoiceNo,
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                      ),
                      DataCell(
                        Text(
                          order.retailerName,
                          style: const TextStyle(fontSize: 12.5, color: AppColors.textPrimary),
                        ),
                      ),
                      DataCell(
                        Text(
                          order.salesmanName,
                          style: const TextStyle(fontSize: 12.5, color: AppColors.textPrimary),
                        ),
                      ),
                      DataCell(
                        Text(
                          '৳ ${_formatAmount(order.totalAmount)}',
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                      ),
                      DataCell(
                        StatusBadge(status: order.paymentStatus),
                      ),
                      DataCell(
                        StatusBadge(status: order.shipmentStatus),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(double amount) {
    final int val = amount.toInt();
    final String str = val.toString();
    if (str.length <= 3) return str;
    
    final lastThree = str.substring(str.length - 3);
    final otherNumbers = str.substring(0, str.length - 3);
    final result = otherNumbers.replaceAllMapped(
      RegExp(r'(\d+?)(?=(\d\d)+$)'),
      (Match m) => '${m[1]},',
    );
    return '$result,$lastThree';
  }
}
