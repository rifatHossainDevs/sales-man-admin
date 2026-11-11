import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/widgets/app_sidebar.dart';
import '../../../core/widgets/app_topbar.dart';
import '../../../data/models/category_supplier_model.dart';
import '../../../routing/app_router.dart';
import '../viewmodels/categories_suppliers_viewmodel.dart';
import '../widgets/category_dialog.dart';
import '../widgets/supplier_dialog.dart';

class CategoriesSuppliersView extends StatelessWidget {
  const CategoriesSuppliersView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CategoriesSuppliersViewModel(),
      child: const _CategoriesSuppliersViewContent(),
    );
  }
}

class _CategoriesSuppliersViewContent extends StatelessWidget {
  const _CategoriesSuppliersViewContent();

  void _showAddCategoryDialog(BuildContext context) {
    final viewModel = context.read<CategoriesSuppliersViewModel>();
    showDialog(
      context: context,
      builder: (ctx) => CategoryDialog(
        onSave: (category) async {
          final success = await viewModel.addCategory(category);
          if (context.mounted && success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Category "${category.name}" added successfully')),
            );
          }
        },
      ),
    );
  }

  void _showEditCategoryDialog(BuildContext context, CategoryModel category) {
    final viewModel = context.read<CategoriesSuppliersViewModel>();
    showDialog(
      context: context,
      builder: (ctx) => CategoryDialog(
        category: category,
        onSave: (updated) async {
          final success = await viewModel.updateCategory(updated);
          if (context.mounted && success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Category "${updated.name}" updated successfully')),
            );
          }
        },
      ),
    );
  }

  void _showDeleteCategoryConfirmation(BuildContext context, CategoryModel category) {
    final viewModel = context.read<CategoriesSuppliersViewModel>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Delete Category', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete "${category.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final success = await viewModel.deleteCategory(category.id);
              if (context.mounted && success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Category "${category.name}" deleted')),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddSupplierDialog(BuildContext context) {
    final viewModel = context.read<CategoriesSuppliersViewModel>();
    showDialog(
      context: context,
      builder: (ctx) => SupplierDialog(
        onSave: (supplier) async {
          final success = await viewModel.addSupplier(supplier);
          if (context.mounted && success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Supplier "${supplier.name}" added successfully')),
            );
          }
        },
      ),
    );
  }

  void _showEditSupplierDialog(BuildContext context, SupplierModel supplier) {
    final viewModel = context.read<CategoriesSuppliersViewModel>();
    showDialog(
      context: context,
      builder: (ctx) => SupplierDialog(
        supplier: supplier,
        onSave: (updated) async {
          final success = await viewModel.updateSupplier(updated);
          if (context.mounted && success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Supplier "${updated.name}" updated successfully')),
            );
          }
        },
      ),
    );
  }

  void _showDeleteSupplierConfirmation(BuildContext context, SupplierModel supplier) {
    final viewModel = context.read<CategoriesSuppliersViewModel>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Delete Supplier', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete "${supplier.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final success = await viewModel.deleteSupplier(supplier.id);
              if (context.mounted && success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Supplier "${supplier.name}" deleted')),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CategoriesSuppliersViewModel>();
    final isDesktop = ResponsiveLayout.isDesktop(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: Drawer(
        child: AppSidebar(activeRoute: AppRouter.categoriesSuppliers),
      ),
      body: Row(
        children: [
          if (isDesktop)
            const AppSidebar(activeRoute: AppRouter.categoriesSuppliers),
          Expanded(
            child: Column(
              children: [
                AppTopbar(
                  title: 'Categories & Suppliers',
                  subtitle: 'Organise products and the companies that supply them',
                  onSearchChanged: (query) => viewModel.search(query),
                ),
                Expanded(
                  child: viewModel.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: isDesktop
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: _buildCategoriesCard(context, viewModel),
                                    ),
                                    const SizedBox(width: 24),
                                    Expanded(
                                      child: _buildSuppliersCard(context, viewModel),
                                    ),
                                  ],
                                )
                              : Column(
                                  children: [
                                    _buildCategoriesCard(context, viewModel),
                                    const SizedBox(height: 24),
                                    _buildSuppliersCard(context, viewModel),
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

  // ================= CATEGORIES CARD =================
  Widget _buildCategoriesCard(
      BuildContext context, CategoriesSuppliersViewModel viewModel) {
    final categories = viewModel.categories;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Categories',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${viewModel.totalCategoriesCount} categories',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () => _showAddCategoryDialog(context),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF1FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 16, color: AppColors.primary),
                        SizedBox(width: 6),
                        Text(
                          'Add category',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Table Header
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              border: Border(
                top: BorderSide(color: AppColors.border),
                bottom: BorderSide(color: AppColors.border),
              ),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'CATEGORY',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Text(
                    'DESCRIPTION',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                SizedBox(
                  width: 70,
                  child: Text(
                    'PRODUCTS',
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                SizedBox(width: 76), // Actions spacing
              ],
            ),
          ),

          // Table Body
          if (categories.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Text(
                  'No categories found',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categories.length,
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, color: AppColors.border),
              itemBuilder: (context, index) {
                final cat = categories[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          cat.name,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Text(
                          cat.description,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(
                        width: 70,
                        child: Text(
                          '${cat.productCount}',
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildSmallIconButton(
                            icon: Icons.edit_outlined,
                            iconColor: AppColors.textSecondary,
                            onTap: () => _showEditCategoryDialog(context, cat),
                          ),
                          const SizedBox(width: 6),
                          _buildSmallIconButton(
                            icon: Icons.delete_outline_rounded,
                            iconColor: AppColors.danger,
                            onTap: () =>
                                _showDeleteCategoryConfirmation(context, cat),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // ================= SUPPLIERS CARD =================
  Widget _buildSuppliersCard(
      BuildContext context, CategoriesSuppliersViewModel viewModel) {
    final suppliers = viewModel.suppliers;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Suppliers',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${viewModel.totalSuppliersCount} suppliers',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () => _showAddSupplierDialog(context),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF1FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 16, color: AppColors.primary),
                        SizedBox(width: 6),
                        Text(
                          'Add supplier',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Table Header
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              border: Border(
                top: BorderSide(color: AppColors.border),
                bottom: BorderSide(color: AppColors.border),
              ),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'SUPPLIER',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Text(
                    'CONTACT',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                SizedBox(
                  width: 70,
                  child: Text(
                    'PRODUCTS',
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                SizedBox(width: 76), // Actions spacing
              ],
            ),
          ),

          // Table Body
          if (suppliers.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Text(
                  'No suppliers found',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: suppliers.length,
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, color: AppColors.border),
              itemBuilder: (context, index) {
                final sup = suppliers[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sup.name,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              sup.location,
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sup.phone,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              sup.email,
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 70,
                        child: Text(
                          '${sup.productCount}',
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildSmallIconButton(
                            icon: Icons.edit_outlined,
                            iconColor: AppColors.textSecondary,
                            onTap: () => _showEditSupplierDialog(context, sup),
                          ),
                          const SizedBox(width: 6),
                          _buildSmallIconButton(
                            icon: Icons.delete_outline_rounded,
                            iconColor: AppColors.danger,
                            onTap: () =>
                                _showDeleteSupplierConfirmation(context, sup),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSmallIconButton({
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.border),
        ),
        child: Center(
          child: Icon(icon, size: 15, color: iconColor),
        ),
      ),
    );
  }
}
