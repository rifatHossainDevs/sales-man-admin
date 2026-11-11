import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/widgets/app_sidebar.dart';
import '../../../core/widgets/app_topbar.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../data/models/order_model.dart';
import '../../../routing/app_router.dart';
import '../viewmodels/orders_viewmodel.dart';
import 'order_details_view.dart';

class OrdersView extends StatelessWidget {
  const OrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OrdersViewModel(),
      child: const _OrdersViewContent(),
    );
  }
}

class _OrdersViewContent extends StatelessWidget {
  const _OrdersViewContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<OrdersViewModel>();
    final isDesktop = ResponsiveLayout.isDesktop(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: Drawer(
        child: AppSidebar(activeRoute: AppRouter.orders),
      ),
      body: Row(
        children: [
          if (isDesktop)
            const AppSidebar(activeRoute: AppRouter.orders),
          Expanded(
            child: Column(
              children: [
                const AppTopbar(
                  title: 'Orders',
                  subtitle: 'All orders placed by your salesmen',
                ),
                Expanded(
                  child: viewModel.isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Status Tabs & Filter Controls
                              _buildHeaderFilters(context, viewModel),
                              const SizedBox(height: 20),

                              // Orders Table
                              _buildOrdersTable(context, viewModel),
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

  Widget _buildHeaderFilters(BuildContext context, OrdersViewModel viewModel) {
    final isMobile = ResponsiveLayout.isMobile(context);

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.spaceBetween,
      children: [
        // Status Filter Chips
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _statusChip(viewModel, 'All', viewModel.totalOrdersCount),
            _statusChip(viewModel, 'Pending', viewModel.pendingOrdersCount),
            _statusChip(viewModel, 'Paid', viewModel.paidOrdersCount),
            _statusChip(viewModel, 'Failed', viewModel.failedOrdersCount),
          ],
        ),

        // Search & Salesman Dropdown
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: isMobile ? double.infinity : 220,
              height: 40,
              child: TextField(
                onChanged: viewModel.setSearchQuery,
                decoration: const InputDecoration(
                  hintText: 'Search order or retailer…',
                  prefixIcon: Icon(Icons.search, size: 18, color: AppColors.textMuted),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  filled: true,
                  fillColor: AppColors.surface,
                ),
              ),
            ),
            DropdownButton<String>(
              value: viewModel.selectedSalesman,
              underline: const SizedBox.shrink(),
              items: viewModel.salesmenOptions
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (val) {
                if (val != null) viewModel.setSelectedSalesman(val);
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _statusChip(OrdersViewModel viewModel, String label, int count) {
    final isSelected = viewModel.selectedStatus.toLowerCase() == label.toLowerCase();

    return ChoiceChip(
      label: Text('$label ($count)'),
      selected: isSelected,
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.surface,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.surface : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12.5,
      ),
      onSelected: (_) => viewModel.setSelectedStatus(label),
    );
  }

  Widget _buildOrdersTable(BuildContext context, OrdersViewModel viewModel) {
    final orders = viewModel.filteredOrders;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 24,
              headingRowColor: WidgetStateProperty.all(AppColors.background),
              columns: const [
                DataColumn(label: Text('INVOICE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                DataColumn(label: Text('RETAILER', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                DataColumn(label: Text('SALESMAN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                DataColumn(label: Text('DATE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                DataColumn(numeric: true, label: Text('TOTAL', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                DataColumn(numeric: true, label: Text('PAID', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                DataColumn(numeric: true, label: Text('DUE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                DataColumn(label: Text('PAYMENT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                DataColumn(label: Text('SHIPMENT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                DataColumn(label: Text('DETAILS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
              ],
              rows: orders.map((o) {
                return DataRow(
                  cells: [
                    DataCell(
                      Text(o.invoiceNo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary)),
                      onTap: () => _openDetails(context, o),
                    ),
                    DataCell(Text(o.retailerName, style: const TextStyle(fontSize: 13))),
                    DataCell(Text(o.salesmanName, style: const TextStyle(fontSize: 13))),
                    DataCell(Text(o.date, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary))),
                    DataCell(Text('৳ ${o.totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                    DataCell(Text('৳ ${o.paidAmount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13))),
                    DataCell(Text('৳ ${o.dueAmount.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: o.dueAmount > 0 ? AppColors.danger : AppColors.success))),
                    DataCell(StatusBadge(status: o.paymentStatus)),
                    DataCell(StatusBadge(status: o.shipmentStatus)),
                    DataCell(
                      IconButton(
                        icon: const Icon(Icons.chevron_right_rounded, color: AppColors.primary),
                        onPressed: () => _openDetails(context, o),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          if (orders.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Text('No orders found matching the criteria.', style: TextStyle(color: AppColors.textSecondary)),
              ),
            ),
        ],
      ),
    );
  }

  void _openDetails(BuildContext context, OrderModel order) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OrderDetailsView(order: order),
      ),
    );
  }
}
