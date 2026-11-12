import 'dart:js_interop';
import 'package:web/web.dart' as web;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/widgets/app_sidebar.dart';
import '../../../core/widgets/app_topbar.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/widgets/tracking_map_view.dart';
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
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _currentOrder = widget.order;
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  // 4.3 Dedicated Retail Store Printable Invoice System
  void _printInvoice() {
    try {
      final order = _currentOrder;
      final itemsHtml = order.items.map((item) => '''
        <tr>
          <td>
            <strong>${item.productName}</strong>
            <div style="font-size: 11px; color: #64748B;">${item.sku}</div>
          </td>
          <td style="text-align: right;">${item.qty}</td>
          <td style="text-align: right;">৳ ${item.unitPrice.toStringAsFixed(0)}</td>
          <td style="text-align: right;"><strong>৳ ${item.subtotal.toStringAsFixed(0)}</strong></td>
        </tr>
      ''').join('');

      final invoiceHtml = '''
        <!DOCTYPE html>
        <html>
        <head>
          <meta charset="utf-8">
          <title>Invoice - ${order.invoiceNo}</title>
          <style>
            body { font-family: 'Inter', system-ui, sans-serif; color: #0F172A; padding: 24px; margin: 0; background: #fff; }
            .invoice-box { max-width: 750px; margin: auto; padding: 28px; border: 1px solid #E2E8F0; border-radius: 8px; }
            .header { display: flex; justify-content: space-between; align-items: flex-start; border-bottom: 2px solid #2563EB; padding-bottom: 16px; }
            .brand { font-size: 22px; font-weight: bold; color: #2563EB; }
            .details-grid { display: flex; justify-content: space-between; margin: 20px 0; font-size: 12.5px; }
            .table { width: 100%; border-collapse: collapse; margin-top: 16px; }
            .table th { background: #F8FAFC; text-align: left; padding: 10px; font-size: 11px; text-transform: uppercase; color: #64748B; border-bottom: 1px solid #E2E8F0; }
            .table td { padding: 10px; border-bottom: 1px solid #E2E8F0; font-size: 12.5px; }
            .totals { margin-top: 16px; text-align: right; }
            .totals table { margin-left: auto; width: 280px; font-size: 13px; }
            .totals td { padding: 4px 0; }
            .footer { margin-top: 32px; text-align: center; font-size: 11.5px; color: #64748B; border-top: 1px solid #E2E8F0; padding-top: 16px; }
            @media print {
              body { padding: 0; }
              .invoice-box { border: none; padding: 0; }
            }
          </style>
        </head>
        <body>
          <div class="invoice-box">
            <div class="header">
              <div>
                <div class="brand">Dhaka Dealership Ltd.</div>
                <div style="font-size: 12px; color: #64748B; margin-top: 2px;">House 42, Road 11, Banani, Dhaka · +880 1711-000000</div>
              </div>
              <div style="text-align: right;">
                <h2 style="margin: 0; color: #0F172A; font-size: 18px;">RETAIL INVOICE</h2>
                <div style="font-size: 13px; font-weight: bold; color: #2563EB; margin-top: 3px;">${order.invoiceNo}</div>
                <div style="font-size: 11.5px; color: #64748B;">Date: ${order.date}, ${order.time}</div>
              </div>
            </div>

            <div class="details-grid">
              <div>
                <div style="color: #64748B; font-size: 11px; font-weight: bold; text-transform: uppercase;">Billed To (Retailer)</div>
                <div style="font-size: 13.5px; font-weight: bold; margin-top: 3px;">${order.retailerName}</div>
                <div style="color: #64748B;">Owner: ${order.retailerOwner}</div>
                <div style="color: #64748B;">Phone: ${order.retailerPhone}</div>
                <div style="color: #64748B;">Address: ${order.retailerAddress}</div>
              </div>
              <div style="text-align: right;">
                <div style="color: #64748B; font-size: 11px; font-weight: bold; text-transform: uppercase;">Sales & Delivery</div>
                <div style="font-size: 13px; font-weight: bold; margin-top: 3px;">Salesman: ${order.salesmanName}</div>
                <div style="color: #64748B;">Payment Method: Cash Only</div>
                <div style="color: #64748B;">Payment Status: <strong>${order.paymentStatus}</strong></div>
                <div style="color: #64748B;">Shipment: <strong>${order.shipmentStatus}</strong></div>
              </div>
            </div>

            <table class="table">
              <thead>
                <tr>
                  <th>Product Item</th>
                  <th style="text-align: right;">Qty</th>
                  <th style="text-align: right;">Unit Price</th>
                  <th style="text-align: right;">Subtotal</th>
                </tr>
              </thead>
              <tbody>
                $itemsHtml
              </tbody>
            </table>

            <div class="totals">
              <table>
                <tr>
                  <td>Subtotal:</td>
                  <td style="text-align: right;"><strong>৳ ${order.totalAmount.toStringAsFixed(0)}</strong></td>
                </tr>
                <tr>
                  <td>Amount Paid (Cash):</td>
                  <td style="text-align: right;">৳ ${order.paidAmount.toStringAsFixed(0)}</td>
                </tr>
                <tr style="border-top: 1.5px solid #0F172A;">
                  <td><strong style="font-size: 15px;">Grand Total:</strong></td>
                  <td style="text-align: right; color: #2563EB;"><strong style="font-size: 16px;">৳ ${order.totalAmount.toStringAsFixed(0)}</strong></td>
                </tr>
              </table>
            </div>

            <div class="footer">
              <p>Thank you for doing business with Dhaka Dealership Ltd.</p>
              <p style="font-size: 10px; color: #94A3B8;">Computer-generated retail invoice · Sales-Man System</p>
            </div>
          </div>
          <script>
            window.onload = function() {
              window.print();
            };
          </script>
        </body>
        </html>
      ''';

      final iframe = web.document.createElement('iframe') as web.HTMLIFrameElement;
      iframe.style.position = 'fixed';
      iframe.style.right = '0';
      iframe.style.bottom = '0';
      iframe.style.width = '0';
      iframe.style.height = '0';
      iframe.style.border = '0';
      web.document.body?.appendChild(iframe);

      final doc = iframe.contentWindow?.document;
      doc?.open();
      doc?.write(invoiceHtml.toJS);
      doc?.close();

      Future.delayed(const Duration(seconds: 2), () {
        iframe.remove();
      });
    } catch (_) {
      web.window.print();
    }
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
                        // Top Navigation & Actions Bar
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
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
                              ],
                            ),

                            // 4.3 Print Invoice Button & Actions
                            Wrap(
                              spacing: 8,
                              children: [
                                OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: AppColors.surface,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    side: const BorderSide(color: AppColors.cardBorder),
                                  ),
                                  icon: const Icon(Icons.print_rounded, size: 18, color: AppColors.textPrimary),
                                  label: const Text('Print Invoice', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                                  onPressed: _printInvoice,
                                ),

                                // Mark as Failed Button
                                if (_currentOrder.paymentStatus != 'Failed' && _currentOrder.shipmentStatus != 'Failed')
                                  OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: AppColors.surface,
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      side: const BorderSide(color: AppColors.danger),
                                    ),
                                    icon: const Icon(Icons.cancel_outlined, size: 18, color: AppColors.danger),
                                    label: const Text('Mark as Failed', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold)),
                                    onPressed: () async {
                                      await viewModel.updateOrderStatus(
                                        _currentOrder.id,
                                        paymentStatus: 'Failed',
                                        shipmentStatus: 'Failed',
                                      );
                                      setState(() {
                                        _currentOrder = _currentOrder.copyWith(
                                          paymentStatus: 'Failed',
                                          shipmentStatus: 'Failed',
                                        );
                                      });
                                    },
                                  ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // 4.1 Compact Order Date & Delivery Timeline Bar
                        _buildCompactTimelineCard(),

                        const SizedBox(height: 20),

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
                                    const SizedBox(height: 20),
                                    _buildCashPaymentCard(viewModel),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 20),
                              // Right: Retailer Location Map, Retailer Info, Salesman
                              Expanded(
                                flex: 5,
                                child: Column(
                                  children: [
                                    // Retailer Location Map & Info Card
                                    _buildRetailerCardWithMap(),
                                    const SizedBox(height: 20),
                                    _buildSalesmanCard(),
                                    const SizedBox(height: 20),
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
                              const SizedBox(height: 20),
                              _buildCashPaymentCard(viewModel),
                              const SizedBox(height: 20),
                              _buildRetailerCardWithMap(),
                              const SizedBox(height: 20),
                              _buildSalesmanCard(),
                              const SizedBox(height: 20),
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

  // 4.1 Compact Order Date and Delivery Timeline
  Widget _buildCompactTimelineCard() {
    final isDelivered = _currentOrder.shipmentStatus == 'Delivered';
    final isFailed = _currentOrder.shipmentStatus == 'Failed';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          // Order Date Info
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Ordered: ${_currentOrder.date}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  Text('Shipped: ${_formatShippedDate(_currentOrder.shippedAt)}',
                      style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary)),
                ],
              ),
            ],
          ),

          const SizedBox(width: 12),
          const SizedBox(height: 20, child: VerticalDivider(width: 1, color: AppColors.cardBorder)),
          const SizedBox(width: 12),

          // Compact Timeline Steps
          Expanded(
            child: Row(
              children: [
                _compactTimelineStep('Placed', isCompleted: true),
                _compactTimelineLine(isCompleted: !isFailed),
                _compactTimelineStep('Pending', isCompleted: !isFailed),
                _compactTimelineLine(isCompleted: isDelivered),
                _compactTimelineStep(isFailed ? 'Failed' : 'Delivered', isCompleted: isDelivered, isFailed: isFailed),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _compactTimelineStep(String title, {required bool isCompleted, bool isFailed = false}) {
    final color = isFailed ? AppColors.danger : (isCompleted ? AppColors.primary : AppColors.cardBorder);
    final icon = isFailed ? Icons.cancel : (isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 3),
        Text(title, style: TextStyle(fontSize: 10.5, fontWeight: isCompleted || isFailed ? FontWeight.bold : FontWeight.normal, color: isCompleted || isFailed ? AppColors.textPrimary : AppColors.textMuted)),
      ],
    );
  }

  String _formatShippedDate(DateTime? date) {
    if (date == null) return '—';
    final localDate = date.toLocal();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${localDate.day} ${months[localDate.month - 1]} ${localDate.year}';
  }

  Widget _compactTimelineLine({required bool isCompleted}) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        color: isCompleted ? AppColors.primary : AppColors.cardBorder,
      ),
    );
  }

  // Retailer Location Map & Info
  Widget _buildRetailerCardWithMap() {
    const retailerLoc = LatLng(23.8103, 90.4125);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Retailer Map at top
          SizedBox(
            height: 160,
            child: TrackingMapView(
              controller: _mapController,
              initialCenter: retailerLoc,
              markers: [
                TrackingMapMarker(
                  id: 'retailer-pin',
                  point: retailerLoc,
                  label: _currentOrder.retailerName,
                  initials: 'RET',
                  color: AppColors.primary,
                  isSelected: true,
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Retailer Info', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: AppColors.infoBg, borderRadius: BorderRadius.circular(6)),
                      child: const Text('GPS Mapped', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(_currentOrder.retailerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text('Owner: ${_currentOrder.retailerOwner}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                Text('Phone: ${_currentOrder.retailerPhone}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                Text('Address: ${_currentOrder.retailerAddress}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemsCard() {
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
          Text(
            'Order items (${_currentOrder.items.length})',
            style: AppTypography.h3Bold.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 14),
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
          const Divider(height: 20, color: AppColors.cardBorder),
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
              const Text('Cash Collection Record', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              StatusBadge(status: _currentOrder.paymentStatus),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Payment method supported: Cash only',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),
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
          if (_currentOrder.dueAmount > 0 && _currentOrder.paymentStatus != 'Failed') ...[
            const SizedBox(height: 14),
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

  Widget _buildSalesmanCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary,
            child: Text('RH', style: TextStyle(color: AppColors.surface, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_currentOrder.salesmanName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                Text(_currentOrder.salesmanPhone, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShipmentControlCard(OrdersViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Shipment Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 10),
          Row(
            children: [
              const Text('Current Status: ', style: TextStyle(fontSize: 12.5)),
              StatusBadge(status: _currentOrder.shipmentStatus),
            ],
          ),
          const SizedBox(height: 14),
          if (_currentOrder.shipmentStatus != 'Delivered' && _currentOrder.shipmentStatus != 'Failed') ...[
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
