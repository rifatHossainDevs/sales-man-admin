import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/widgets/app_sidebar.dart';
import '../../../core/widgets/app_topbar.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../data/models/order_model.dart';
import '../../../routing/app_router.dart';
import '../viewmodels/orders_viewmodel.dart';

class OrderDetailsView extends StatelessWidget {
  final OrderModel order;

  const OrderDetailsView({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OrdersViewModel(),
      child: _OrderDetailsViewContent(order: order),
    );
  }
}

class _OrderDetailsViewContent extends StatefulWidget {
  final OrderModel order;

  const _OrderDetailsViewContent({required this.order});

  @override
  State<_OrderDetailsViewContent> createState() => _OrderDetailsViewContentState();
}

class _OrderDetailsViewContentState extends State<_OrderDetailsViewContent> {
  late OrderModel _currentOrder;

  @override
  void initState() {
    super.initState();
    _currentOrder = widget.order;
  }

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
                AppTopbar(
                  title: 'Order ${_currentOrder.invoiceNo}',
                  subtitle: 'Orders / Order details',
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Back Button & Order Subheader
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
                              onPressed: () {
                                Navigator.of(context).pushReplacementNamed(AppRouter.orders);
                              },
                            ),
                            const SizedBox(width: 8),
                            StatusBadge(status: 'Payment ${_currentOrder.paymentStatus}'),
                            const SizedBox(width: 8),
                            StatusBadge(status: 'Shipment ${_currentOrder.shipmentStatus}'),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                'Placed ${_currentOrder.date}, ${_currentOrder.time} by ${_currentOrder.salesmanName}',
                                style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Main 2-Column Content
                        if (isDesktop)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Left: Items & Payments
                              Expanded(
                                flex: 7,
                                child: Column(
                                  children: [
                                    _buildOrderItemsCard(),
                                    const SizedBox(height: 24),
                                    _buildCashPaymentCard(viewModel),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 24),
                              // Right: Retailer, Salesman, Shipment Controls
                              Expanded(
                                flex: 5,
                                child: Column(
                                  children: [
                                    _buildRetailerCard(),
                                    const SizedBox(height: 24),
                                    _buildSalesmanCard(),
                                    const SizedBox(height: 24),
                                    _buildShipmentControlCard(viewModel),
                                  ],
                                ),
                              ),
                            ],
                          )
                        else
                          Column(
                            children: [
                              _buildOrderItemsCard(),
                              const SizedBox(height: 24),
                              _buildCashPaymentCard(viewModel),
                              const SizedBox(height: 24),
                              _buildRetailerCard(),
                              const SizedBox(height: 24),
                              _buildSalesmanCard(),
                              const SizedBox(height: 24),
                              _buildShipmentControlCard(viewModel),
                            ],
                          ),
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

  Widget _buildOrderItemsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order items (${_currentOrder.items.length})',
            style: AppTypography.h3Bold.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 24,
              headingRowColor: WidgetStateProperty.all(AppColors.background),
              columns: const [
                DataColumn(label: Text('PRODUCT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                DataColumn(numeric: true, label: Text('QTY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                DataColumn(numeric: true, label: Text('UNIT PRICE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                DataColumn(numeric: true, label: Text('SUBTOTAL', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
              ],
              rows: _currentOrder.items.map((item) {
                return DataRow(
                  cells: [
                    DataCell(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(item.productName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Text(item.sku, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    DataCell(Text('${item.qty}', style: const TextStyle(fontSize: 13))),
                    DataCell(Text('৳ ${item.unitPrice.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13))),
                    DataCell(Text('৳ ${item.subtotal.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                  ],
                );
              }).toList(),
            ),
          ),
          const Divider(height: 24, color: AppColors.cardBorder),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Amount', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Text('৳ ${_currentOrder.totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCashPaymentCard(OrdersViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(24),
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
              const Text('Cash Collection Record', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              StatusBadge(status: _currentOrder.paymentStatus),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Payment method supported: Cash only',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Amount Paid:', style: TextStyle(fontSize: 13)),
              Text('৳ ${_currentOrder.paidAmount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Payment Due:', style: TextStyle(fontSize: 13)),
              Text('৳ ${_currentOrder.dueAmount.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: _currentOrder.dueAmount > 0 ? AppColors.danger : AppColors.success)),
            ],
          ),
          if (_currentOrder.dueAmount > 0) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: AppColors.surface),
                icon: const Icon(Icons.attach_money, size: 18),
                label: const Text('Record Full Cash Payment'),
                onPressed: () async {
                  await viewModel.updateOrderStatus(
                    _currentOrder.id,
                    paymentStatus: 'Paid',
                    paidAmount: _currentOrder.totalAmount,
                  );
                  setState(() {
                    _currentOrder = _currentOrder.copyWith(
                      paymentStatus: 'Paid',
                      paidAmount: _currentOrder.totalAmount,
                    );
                  });
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRetailerCard() {
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
          const Text('Retailer Info', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          Text(_currentOrder.retailerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 4),
          Text('Owner: ${_currentOrder.retailerOwner}', style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
          Text('Phone: ${_currentOrder.retailerPhone}', style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
          Text('Address: ${_currentOrder.retailerAddress}', style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildSalesmanCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primary,
            child: Text('RH', style: TextStyle(color: AppColors.surface, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_currentOrder.salesmanName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(_currentOrder.salesmanPhone, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShipmentControlCard(OrdersViewModel viewModel) {
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
          const Text('Shipment Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Current Status: ', style: TextStyle(fontSize: 13)),
              StatusBadge(status: _currentOrder.shipmentStatus),
            ],
          ),
          const SizedBox(height: 16),
          if (_currentOrder.shipmentStatus != 'Delivered') ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label: const Text('Mark as Delivered'),
                onPressed: () async {
                  await viewModel.updateOrderStatus(
                    _currentOrder.id,
                    shipmentStatus: 'Delivered',
                  );
                  setState(() {
                    _currentOrder = _currentOrder.copyWith(shipmentStatus: 'Delivered');
                  });
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
