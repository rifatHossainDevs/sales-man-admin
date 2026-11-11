import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/widgets/app_sidebar.dart';
import '../../../core/widgets/app_topbar.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../data/models/product_model.dart';
import '../../../routing/app_router.dart';
import '../viewmodels/products_viewmodel.dart';
import '../widgets/product_dialog.dart';

class ProductsView extends StatelessWidget {
  const ProductsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProductsViewModel(),
      child: const _ProductsViewContent(),
    );
  }
}

class _ProductsViewContent extends StatelessWidget {
  const _ProductsViewContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProductsViewModel>();
    final isDesktop = ResponsiveLayout.isDesktop(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: Drawer(
        child: AppSidebar(activeRoute: AppRouter.products),
      ),
      body: Row(
        children: [
          if (isDesktop)
            const AppSidebar(activeRoute: AppRouter.products),
          Expanded(
            child: Column(
              children: [
                const AppTopbar(
                  title: 'Products',
                  subtitle: 'Manage the catalogue your salesmen sell from the app',
                ),
                Expanded(
                  child: viewModel.isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Top Action Bar & Filters
                              _buildFilterBar(context, viewModel),
                              const SizedBox(height: 20),

                              // Stat Metric Cards
                              _buildMetricsGrid(viewModel),
                              const SizedBox(height: 24),

                              // Products Data Table
                              _buildProductsTable(context, viewModel),
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

  Widget _buildFilterBar(BuildContext context, ProductsViewModel viewModel) {
    final isMobile = ResponsiveLayout.isMobile(context);

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.spaceBetween,
      children: [
        // Search & Filter Inputs
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: isMobile ? double.infinity : 260,
              height: 40,
              child: TextField(
                onChanged: viewModel.setSearchQuery,
                decoration: InputDecoration(
                  hintText: 'Search by name or SKU…',
                  prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.textMuted),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  filled: true,
                  fillColor: AppColors.surface,
                ),
              ),
            ),
            DropdownButton<String>(
              value: viewModel.selectedCategory,
              underline: const SizedBox.shrink(),
              items: viewModel.categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (val) {
                if (val != null) viewModel.setSelectedCategory(val);
              },
            ),
            DropdownButton<String>(
              value: viewModel.selectedSupplier,
              underline: const SizedBox.shrink(),
              items: viewModel.suppliers
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (val) {
                if (val != null) viewModel.setSelectedSupplier(val);
              },
            ),
            DropdownButton<String>(
              value: viewModel.selectedStatus,
              underline: const SizedBox.shrink(),
              items: ['All status', 'Active', 'Inactive']
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (val) {
                if (val != null) viewModel.setSelectedStatus(val);
              },
            ),
          ],
        ),

        // Add Product Button
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.surface,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Add product', style: TextStyle(fontWeight: FontWeight.bold)),
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => ProductDialog(
                categories: viewModel.categories,
                suppliers: viewModel.suppliers,
                onSave: (newProduct) {
                  viewModel.addProduct(newProduct);
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMetricsGrid(ProductsViewModel viewModel) {
    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;
      final cardWidth = width > 900 ? (width - 48) / 4 : (width > 500 ? (width - 16) / 2 : width);

      return Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          _metricCard('Total products', '${viewModel.totalProducts}', cardWidth),
          _metricCard('Active', '${viewModel.activeProducts}', cardWidth, color: AppColors.success),
          _metricCard('Low stock', '${viewModel.lowStockProducts}', cardWidth, color: AppColors.warning),
          _metricCard('Out of stock', '${viewModel.outOfStockProducts}', cardWidth, color: AppColors.danger),
        ],
      );
    });
  }

  Widget _metricCard(String title, String count, double width, {Color? color}) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Text(
            count,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsTable(BuildContext context, ProductsViewModel viewModel) {
    final products = viewModel.filteredProducts;

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
              columnSpacing: 20,
              headingRowColor: WidgetStateProperty.all(AppColors.background),
              columns: const [
                DataColumn(label: Text('PRODUCT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                DataColumn(label: Text('CATEGORY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                DataColumn(label: Text('SUPPLIER', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                DataColumn(numeric: true, label: Text('PRICE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                DataColumn(numeric: true, label: Text('OFFER', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                DataColumn(numeric: true, label: Text('STOCK', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                DataColumn(label: Text('UNIT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                DataColumn(label: Text('STATUS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                DataColumn(label: Text('ACTIONS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
              ],
              rows: products.map((p) {
                return DataRow(
                  cells: [
                    DataCell(
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.infoBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(Icons.inventory_2_outlined, size: 16, color: AppColors.primary),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              Text(p.sku, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    DataCell(Text(p.category, style: const TextStyle(fontSize: 12.5))),
                    DataCell(Text(p.supplier, style: const TextStyle(fontSize: 12.5))),
                    DataCell(Text('৳ ${p.price.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5))),
                    DataCell(Text(p.offerPrice != null ? '৳ ${p.offerPrice!.toStringAsFixed(0)}' : '—', style: const TextStyle(fontSize: 12.5))),
                    DataCell(
                      StatusBadge(
                        status: p.stock == 0 ? 'Out of stock' : (p.stock <= 15 ? '${p.stock} (Low)' : '${p.stock}'),
                        showDot: false,
                      ),
                    ),
                    DataCell(Text(p.unit, style: const TextStyle(fontSize: 12.5))),
                    DataCell(
                      StatusBadge(status: p.isActive ? 'Active' : 'Inactive'),
                    ),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => ProductDialog(
                                  product: p,
                                  categories: viewModel.categories,
                                  suppliers: viewModel.suppliers,
                                  onSave: (updated) {
                                    viewModel.updateProduct(updated);
                                  },
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.danger),
                            onPressed: () => _confirmDelete(context, viewModel, p),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          if (products.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Text('No products found matching the criteria.', style: TextStyle(color: AppColors.textSecondary)),
              ),
            ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, ProductsViewModel viewModel, ProductModel product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () {
              viewModel.deleteProduct(product.id);
              Navigator.of(ctx).pop();
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.surface)),
          ),
        ],
      ),
    );
  }
}
