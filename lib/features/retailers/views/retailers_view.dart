import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/widgets/app_sidebar.dart';
import '../../../core/widgets/app_topbar.dart';
import '../../../data/models/retailer_model.dart';
import '../../../routing/app_router.dart';
import '../viewmodels/retailers_viewmodel.dart';
import '../widgets/retailer_details_dialog.dart';
import '../widgets/retailer_dialog.dart';

class RetailersView extends StatelessWidget {
  const RetailersView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RetailersViewModel(),
      child: const _RetailersViewContent(),
    );
  }
}

class _RetailersViewContent extends StatelessWidget {
  const _RetailersViewContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<RetailersViewModel>();
    final isDesktop = ResponsiveLayout.isDesktop(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: Drawer(
        child: AppSidebar(activeRoute: AppRouter.retailers),
      ),
      body: Row(
        children: [
          if (isDesktop)
            const AppSidebar(activeRoute: AppRouter.retailers),
          Expanded(
            child: Column(
              children: [
                const AppTopbar(
                  title: 'Retailers',
                  subtitle: 'Stores registered by your salesmen',
                ),
                Expanded(
                  child: viewModel.isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Filter Toolbar
                              _buildToolbar(context, viewModel),
                              const SizedBox(height: 20),

                              // Main Content: List or Map View
                              if (viewModel.isMapView)
                                _buildMapView(context, viewModel)
                              else
                                _buildRetailersTable(context, viewModel),
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

  Widget _buildToolbar(BuildContext context, RetailersViewModel viewModel) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // Division Dropdown
        _dropdown(
          value: viewModel.selectedDivision,
          items: viewModel.divisions,
          onChanged: (v) => viewModel.setSelectedDivision(v),
        ),

        // District Dropdown
        _dropdown(
          value: viewModel.selectedDistrict,
          items: viewModel.districts,
          onChanged: (v) => viewModel.setSelectedDistrict(v),
        ),

        // Sub-district Dropdown
        _dropdown(
          value: viewModel.selectedSubDistrict,
          items: viewModel.subDistricts,
          onChanged: (v) => viewModel.setSelectedSubDistrict(v),
        ),

        // Area Dropdown
        _dropdown(
          value: viewModel.selectedArea,
          items: viewModel.areas,
          onChanged: (v) => viewModel.setSelectedArea(v),
        ),

        // Search Bar
        SizedBox(
          width: 240,
          height: 38,
          child: TextField(
            onChanged: viewModel.setSearchQuery,
            decoration: InputDecoration(
              hintText: 'Search store, owner or phone…',
              hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
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

        // View Mode Toggle (List / Map)
        Container(
          height: 36,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF1F6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _toggleButton(
                title: 'List',
                isSelected: !viewModel.isMapView,
                onTap: () => viewModel.setViewMode(isMap: false),
              ),
              _toggleButton(
                title: 'Map',
                isSelected: viewModel.isMapView,
                onTap: () => viewModel.setViewMode(isMap: true),
              ),
            ],
          ),
        ),

        // Add Store Button
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          icon: const Icon(Icons.add, size: 18, color: AppColors.surface),
          label: const Text('Add retailer', style: TextStyle(color: AppColors.surface, fontWeight: FontWeight.w600)),
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => RetailerDialog(
                onSave: (retailer) => viewModel.addRetailer(retailer),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _dropdown({
    required String value,
    required List<String> items,
    required Function(String) onChanged,
  }) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : items.first,
          items: items.map((it) => DropdownMenuItem(value: it, child: Text(it, style: const TextStyle(fontSize: 13)))).toList(),
          onChanged: (val) {
            if (val != null) onChanged(val);
          },
        ),
      ),
    );
  }

  Widget _toggleButton({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected
              ? [const BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1))]
              : null,
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildRetailersTable(BuildContext context, RetailersViewModel viewModel) {
    final retailers = viewModel.filteredRetailers;

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
              columnSpacing: 22,
              headingRowColor: WidgetStateProperty.all(AppColors.background),
              columns: const [
                DataColumn(label: Text('STORE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                DataColumn(label: Text('PHONE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                DataColumn(label: Text('AREA', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                DataColumn(label: Text('SUB-DISTRICT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                DataColumn(label: Text('REGISTERED BY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                DataColumn(label: Text('REGISTERED', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                DataColumn(numeric: true, label: Text('ORDERS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                DataColumn(numeric: true, label: Text('DUE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                DataColumn(label: Text('GPS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                DataColumn(label: Text('ACTIONS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
              ],
              rows: retailers.map((r) {
                return DataRow(
                  cells: [
                    DataCell(
                      InkWell(
                        onTap: () => _openDetails(context, viewModel, r),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3E2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.storefront_rounded, size: 18, color: Color(0xFFD97706)),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(r.storeName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                Text('Owner: ${r.ownerName}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    DataCell(Text(r.phone, style: const TextStyle(fontSize: 13))),
                    DataCell(Text(r.area, style: const TextStyle(fontSize: 13))),
                    DataCell(Text(r.subDistrict, style: const TextStyle(fontSize: 13))),
                    DataCell(Text(r.registeredBy, style: const TextStyle(fontSize: 13))),
                    DataCell(Text(r.registeredDate, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary))),
                    DataCell(Text('${r.ordersCount}', style: const TextStyle(fontSize: 13))),
                    DataCell(
                      Text(
                        r.dueAmount > 0 ? '৳ ${r.dueAmount.toStringAsFixed(0)}' : '—',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: r.dueAmount > 0 ? AppColors.danger : AppColors.textSecondary,
                        ),
                      ),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.successBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('Mapped', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 11)),
                      ),
                    ),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.visibility_outlined, size: 18, color: AppColors.primary),
                            tooltip: 'Store Details & History',
                            onPressed: () => _openDetails(context, viewModel, r),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.textSecondary),
                            tooltip: 'Edit Store',
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => RetailerDialog(
                                  retailer: r,
                                  onSave: (updated) => viewModel.updateRetailer(updated),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.danger),
                            tooltip: 'Delete',
                            onPressed: () => _confirmDelete(context, viewModel, r),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          if (retailers.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Text('No retailers found matching the selected filters.', style: TextStyle(color: AppColors.textSecondary)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMapView(BuildContext context, RetailersViewModel viewModel) {
    final retailers = viewModel.filteredRetailers;

    return Container(
      height: 540,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4F8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Stack(
        children: [
          // Background Map Grid Simulation
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.map_outlined, size: 48, color: AppColors.primary.withValues(alpha: 0.4)),
                const SizedBox(height: 8),
                Text(
                  'Retailers Map View · ${retailers.length} stores located',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 4),
                const Text('Dhaka Metropolitan Area', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
          ),

          // Render Store Location Badges
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: retailers.map((r) {
              return Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: InkWell(
                  onTap: () => _openDetails(context, viewModel, r),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on, color: AppColors.primary, size: 18),
                      const SizedBox(width: 6),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(r.storeName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          Text('${r.area} · Due: ৳${r.dueAmount.toStringAsFixed(0)}',
                              style: TextStyle(fontSize: 10, color: r.dueAmount > 0 ? AppColors.danger : AppColors.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _openDetails(BuildContext context, RetailersViewModel viewModel, RetailerModel r) {
    showDialog(
      context: context,
      builder: (_) => RetailerDetailsDialog(
        retailer: r,
        onEdit: () {
          showDialog(
            context: context,
            builder: (_) => RetailerDialog(
              retailer: r,
              onSave: (updated) => viewModel.updateRetailer(updated),
            ),
          );
        },
        onDelete: () => viewModel.deleteRetailer(r.id),
      ),
    );
  }

  void _confirmDelete(BuildContext context, RetailersViewModel viewModel, RetailerModel r) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Retailer'),
        content: Text('Are you sure you want to delete "${r.storeName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () {
              viewModel.deleteRetailer(r.id);
              Navigator.of(ctx).pop();
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.surface)),
          ),
        ],
      ),
    );
  }
}
