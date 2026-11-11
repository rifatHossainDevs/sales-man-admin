import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/widgets/app_sidebar.dart';
import '../../../core/widgets/app_topbar.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../data/models/payment_model.dart';
import '../../../routing/app_router.dart';
import '../viewmodels/payments_viewmodel.dart';
import '../widgets/add_payment_dialog.dart';
import '../widgets/payment_details_dialog.dart';

class PaymentsView extends StatelessWidget {
  const PaymentsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PaymentsViewModel(),
      child: const _PaymentsViewContent(),
    );
  }
}

class _PaymentsViewContent extends StatelessWidget {
  const _PaymentsViewContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PaymentsViewModel>();
    final isDesktop = ResponsiveLayout.isDesktop(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: Drawer(
        child: AppSidebar(activeRoute: AppRouter.payments),
      ),
      body: Row(
        children: [
          if (isDesktop)
            const AppSidebar(activeRoute: AppRouter.payments),
          Expanded(
            child: Column(
              children: [
                const AppTopbar(
                  title: 'Payments',
                  subtitle: 'Collections made by your salesmen (Cash only)',
                ),
                Expanded(
                  child: viewModel.isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 1. Stat KPI Metric Cards
                              _buildKpiCards(context, viewModel),
                              const SizedBox(height: 24),

                              // 2. Collection By Salesman Breakdown
                              _buildSalesmanBreakdownCard(context, viewModel),
                              const SizedBox(height: 24),

                              // 3. Payments Table
                              _buildPaymentsTable(context, viewModel),
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

  Widget _buildKpiCards(BuildContext context, PaymentsViewModel viewModel) {
    final isDesktop = ResponsiveLayout.isDesktop(context);

    final cards = [
      _metricCard(
        title: 'Collected · November',
        value: '৳ ${viewModel.totalCollected.toStringAsFixed(0)}',
        subtitle: '+8.2% vs October',
        subtitleColor: AppColors.success,
        icon: Icons.account_balance_wallet_outlined,
        iconBg: AppColors.successBg,
        iconColor: AppColors.success,
      ),
      _metricCard(
        title: 'Cash Collections',
        value: '৳ ${viewModel.totalCollected.toStringAsFixed(0)}',
        subtitle: '100% of total (Cash only policy)',
        subtitleColor: AppColors.primary,
        icon: Icons.payments_outlined,
        iconBg: AppColors.infoBg,
        iconColor: AppColors.primary,
      ),
      _metricCard(
        title: 'Pending Collections',
        value: '৳ ${viewModel.pendingAmount.toStringAsFixed(0)}',
        subtitle: 'Awaiting deposit',
        subtitleColor: AppColors.warning,
        icon: Icons.hourglass_empty_rounded,
        iconBg: AppColors.warningBg,
        iconColor: AppColors.warning,
      ),
      _metricCard(
        title: 'Failed Visits',
        value: '${viewModel.failedCount}',
        subtitle: 'Payment not collected',
        subtitleColor: AppColors.danger,
        icon: Icons.cancel_outlined,
        iconBg: AppColors.dangerBg,
        iconColor: AppColors.danger,
      ),
    ];

    if (isDesktop) {
      return Row(
        children: cards
            .map((c) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: c == cards.last ? 0 : 16),
                    child: c,
                  ),
                ))
            .toList(),
      );
    } else {
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: cards
            .map((c) => SizedBox(
                  width: (MediaQuery.of(context).size.width - 64) / 2,
                  child: c,
                ))
            .toList(),
      );
    }
  }

  Widget _metricCard({
    required String title,
    required String value,
    required String subtitle,
    required Color subtitleColor,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
  }) {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: iconColor, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          Text(subtitle, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500, color: subtitleColor)),
        ],
      ),
    );
  }

  Widget _buildSalesmanBreakdownCard(BuildContext context, PaymentsViewModel viewModel) {
    final collections = viewModel.salesmanCollections;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Collection by salesman (Cash)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              Text('Current Month', style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 20),
          if (collections.isEmpty)
            const Text('No salesman collections recorded yet.', style: TextStyle(color: AppColors.textSecondary)),
          ...collections.map((s) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  SizedBox(
                    width: 130,
                    child: Text(s.name, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: s.percentageOfMax,
                        minHeight: 12,
                        backgroundColor: AppColors.infoBg,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          s == collections.first ? AppColors.primary : const Color(0xFFBFD3FB),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 90,
                    child: Text(
                      '৳ ${s.amount.toStringAsFixed(0)}',
                      textAlign: TextAlign.end,
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPaymentsTable(BuildContext context, PaymentsViewModel viewModel) {
    final payments = viewModel.filteredPayments;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Table Toolbar
          Padding(
            padding: const EdgeInsets.all(20),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text(
                  'Recent payments',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // Status Filter Dropdown
                    Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: viewModel.selectedStatus,
                          items: viewModel.statusOptions
                              .map((st) => DropdownMenuItem(value: st, child: Text(st, style: const TextStyle(fontSize: 13))))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) viewModel.setSelectedStatus(val);
                          },
                        ),
                      ),
                    ),

                    // Search box
                    SizedBox(
                      width: 200,
                      height: 38,
                      child: TextField(
                        onChanged: viewModel.setSearchQuery,
                        decoration: InputDecoration(
                          hintText: 'Search TRX, order, salesman…',
                          hintStyle: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                          prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.textMuted),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                          filled: true,
                          fillColor: AppColors.surface,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.cardBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.primary),
                          ),
                        ),
                      ),
                    ),

                    // Record Cash Collection Button
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.add, size: 18, color: AppColors.surface),
                      label: const Text('Record payment', style: TextStyle(color: AppColors.surface, fontWeight: FontWeight.w600)),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => AddPaymentDialog(
                            onSave: (payment) => viewModel.addPayment(payment),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.cardBorder),

          // Data Table
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 24,
              headingRowColor: WidgetStateProperty.all(AppColors.background),
              columns: const [
                DataColumn(label: Text('TRANSACTION ID', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                DataColumn(label: Text('ORDER', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                DataColumn(label: Text('SALESMAN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                DataColumn(label: Text('RETAILER', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                DataColumn(label: Text('METHOD', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                DataColumn(numeric: true, label: Text('AMOUNT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                DataColumn(label: Text('STATUS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                DataColumn(label: Text('PAID AT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                DataColumn(label: Text('ACTIONS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
              ],
              rows: payments.map((p) {
                return DataRow(
                  cells: [
                    DataCell(
                      Text(p.trxId, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, fontFamily: 'monospace')),
                      onTap: () => _openDetails(context, viewModel, p),
                    ),
                    DataCell(
                      Text(p.invoiceNo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary)),
                      onTap: () => _openDetails(context, viewModel, p),
                    ),
                    DataCell(Text(p.salesmanName, style: const TextStyle(fontSize: 13))),
                    DataCell(Text(p.retailerName, style: const TextStyle(fontSize: 13))),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF1F6),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('Cash', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: AppColors.textPrimary)),
                      ),
                    ),
                    DataCell(Text('৳ ${p.amount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                    DataCell(StatusBadge(status: p.status)),
                    DataCell(Text(p.paidAt, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary))),
                    DataCell(
                      IconButton(
                        icon: const Icon(Icons.receipt_outlined, size: 18, color: AppColors.primary),
                        tooltip: 'View Receipt',
                        onPressed: () => _openDetails(context, viewModel, p),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),

          if (payments.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Text('No payment records found matching the criteria.', style: TextStyle(color: AppColors.textSecondary)),
              ),
            ),
        ],
      ),
    );
  }

  void _openDetails(BuildContext context, PaymentsViewModel viewModel, PaymentModel p) {
    showDialog(
      context: context,
      builder: (_) => PaymentDetailsDialog(
        payment: p,
        onStatusChanged: (newStatus) {
          viewModel.updatePaymentStatus(p.id, newStatus);
        },
      ),
    );
  }
}
