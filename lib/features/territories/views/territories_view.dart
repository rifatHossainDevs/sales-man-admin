import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/widgets/app_sidebar.dart';
import '../../../core/widgets/app_topbar.dart';
import '../../../data/models/territory_model.dart';
import '../../../routing/app_router.dart';
import '../viewmodels/territories_viewmodel.dart';
import '../widgets/assign_salesman_dialog.dart';
import '../widgets/territory_dialog.dart';

class TerritoriesView extends StatelessWidget {
  const TerritoriesView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TerritoriesViewModel(),
      child: const _TerritoriesViewContent(),
    );
  }
}

class _TerritoriesViewContent extends StatefulWidget {
  const _TerritoriesViewContent();

  @override
  State<_TerritoriesViewContent> createState() => _TerritoriesViewContentState();
}

class _TerritoriesViewContentState extends State<_TerritoriesViewContent> {
  int _mobileTabIndex = 0;

  // --- District Dialogs ---
  void _showAddDistrict(BuildContext context) {
    final viewModel = context.read<TerritoriesViewModel>();
    showDialog(
      context: context,
      builder: (ctx) => TerritoryDialog(
        level: TerritoryLevel.district,
        onSave: (model) async {
          final success = await viewModel.addDistrict(model as DistrictModel);
          if (context.mounted && success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('District "${model.name}" added')),
            );
          }
        },
      ),
    );
  }

  void _showEditDistrict(BuildContext context, DistrictModel district) {
    final viewModel = context.read<TerritoriesViewModel>();
    showDialog(
      context: context,
      builder: (ctx) => TerritoryDialog(
        level: TerritoryLevel.district,
        district: district,
        onSave: (model) async {
          final success = await viewModel.updateDistrict(model as DistrictModel);
          if (context.mounted && success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('District "${model.name}" updated')),
            );
          }
        },
      ),
    );
  }

  void _showDeleteDistrict(BuildContext context, DistrictModel district) {
    final viewModel = context.read<TerritoriesViewModel>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Delete District', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete district "${district.name}" and all its sub-districts?'),
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
              final success = await viewModel.deleteDistrict(district.id);
              if (context.mounted && success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('District "${district.name}" deleted')),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // --- Sub-district Dialogs ---
  void _showAddSubDistrict(BuildContext context) {
    final viewModel = context.read<TerritoriesViewModel>();
    final distId = viewModel.selectedDistrictId;
    if (distId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a district first')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => TerritoryDialog(
        level: TerritoryLevel.subDistrict,
        parentId: distId,
        onSave: (model) async {
          final success = await viewModel.addSubDistrict(model as SubDistrictModel);
          if (context.mounted && success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Sub-district "${model.name}" added')),
            );
          }
        },
      ),
    );
  }

  void _showEditSubDistrict(BuildContext context, SubDistrictModel subDistrict) {
    final viewModel = context.read<TerritoriesViewModel>();
    showDialog(
      context: context,
      builder: (ctx) => TerritoryDialog(
        level: TerritoryLevel.subDistrict,
        subDistrict: subDistrict,
        onSave: (model) async {
          final success = await viewModel.updateSubDistrict(model as SubDistrictModel);
          if (context.mounted && success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Sub-district "${model.name}" updated')),
            );
          }
        },
      ),
    );
  }

  void _showDeleteSubDistrict(BuildContext context, SubDistrictModel subDistrict) {
    final viewModel = context.read<TerritoriesViewModel>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Delete Sub-district', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete sub-district "${subDistrict.name}" and all its areas?'),
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
              final success = await viewModel.deleteSubDistrict(subDistrict.id);
              if (context.mounted && success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Sub-district "${subDistrict.name}" deleted')),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // --- Area Dialogs ---
  void _showAddArea(BuildContext context) {
    final viewModel = context.read<TerritoriesViewModel>();
    final subId = viewModel.selectedSubDistrictId;
    if (subId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a sub-district first')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => TerritoryDialog(
        level: TerritoryLevel.area,
        parentId: subId,
        onSave: (model) async {
          final success = await viewModel.addArea(model as AreaModel);
          if (context.mounted && success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Area "${model.name}" added')),
            );
          }
        },
      ),
    );
  }

  void _showEditArea(BuildContext context, AreaModel area) {
    final viewModel = context.read<TerritoriesViewModel>();
    showDialog(
      context: context,
      builder: (ctx) => TerritoryDialog(
        level: TerritoryLevel.area,
        area: area,
        onSave: (model) async {
          final success = await viewModel.updateArea(model as AreaModel);
          if (context.mounted && success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Area "${model.name}" updated')),
            );
          }
        },
      ),
    );
  }

  void _showDeleteArea(BuildContext context, AreaModel area) {
    final viewModel = context.read<TerritoriesViewModel>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Delete Area', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete area "${area.name}"?'),
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
              final success = await viewModel.deleteArea(area.id);
              if (context.mounted && success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Area "${area.name}" deleted')),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAssignSalesman(BuildContext context, AreaModel area) {
    final viewModel = context.read<TerritoriesViewModel>();
    showDialog(
      context: context,
      builder: (ctx) => AssignSalesmanDialog(
        area: area,
        onAssign: (salesmanName) async {
          final success = await viewModel.assignSalesman(area.id, salesmanName ?? '', null);
          if (context.mounted && success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(salesmanName != null ? 'Assigned $salesmanName to ${area.name}' : 'Unassigned salesman from ${area.name}')),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TerritoriesViewModel>();
    final isDesktop = ResponsiveLayout.isDesktop(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: Drawer(
        child: AppSidebar(activeRoute: AppRouter.territories),
      ),
      body: Row(
        children: [
          if (isDesktop)
            const AppSidebar(activeRoute: AppRouter.territories),
          Expanded(
            child: Column(
              children: [
                AppTopbar(
                  title: 'Territories',
                  subtitle: 'Division → District → Sub-district → Area',
                  onSearchChanged: (query) => viewModel.search(query),
                ),
                Expanded(
                  child: viewModel.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : isDesktop
                          ? _buildDesktopColumns(context, viewModel)
                          : _buildMobileTabs(context, viewModel),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= DESKTOP 3-COLUMN CASCADING LAYOUT =================
  Widget _buildDesktopColumns(BuildContext context, TerritoriesViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildDistrictsColumn(context, viewModel)),
          const SizedBox(width: 20),
          Expanded(child: _buildSubDistrictsColumn(context, viewModel)),
          const SizedBox(width: 20),
          Expanded(child: _buildAreasColumn(context, viewModel)),
        ],
      ),
    );
  }

  // ================= MOBILE / TABLET TABBED LAYOUT =================
  Widget _buildMobileTabs(BuildContext context, TerritoriesViewModel viewModel) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              _buildMobileTabButton('Districts', 0),
              _buildMobileTabButton('Sub-districts', 1),
              _buildMobileTabButton('Areas', 2),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: IndexedStack(
              index: _mobileTabIndex,
              children: [
                _buildDistrictsColumn(context, viewModel),
                _buildSubDistrictsColumn(context, viewModel),
                _buildAreasColumn(context, viewModel),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileTabButton(String title, int index) {
    final isSelected = _mobileTabIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _mobileTabIndex = index),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    )
                  ]
                : null,
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  // ================= COLUMN 1: DISTRICTS =================
  Widget _buildDistrictsColumn(BuildContext context, TerritoriesViewModel viewModel) {
    final districts = viewModel.districts;
    final selectedId = viewModel.selectedDistrictId;

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
            padding: const EdgeInsets.all(18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Districts',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Division: Dhaka',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () => _showAddDistrict(context),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    height: 34,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF1FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 16, color: AppColors.primary),
                        SizedBox(width: 4),
                        Text(
                          'Add',
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
          const Divider(height: 1, color: AppColors.border),

          // Items List
          Expanded(
            child: districts.isEmpty
                ? const Center(child: Text('No districts found', style: TextStyle(color: AppColors.textSecondary)))
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: districts.length,
                    separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.border),
                    itemBuilder: (context, index) {
                      final item = districts[index];
                      final isSelected = item.id == selectedId;

                      return InkWell(
                        onTap: () {
                          viewModel.selectDistrict(item.id);
                          if (!ResponsiveLayout.isDesktop(context)) {
                            setState(() => _mobileTabIndex = 1);
                          }
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFEAF1FF) : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Code ${item.code} · ${item.retailersCount} retailers',
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.textSecondary),
                                    tooltip: 'Edit District',
                                    onPressed: () => _showEditDistrict(context, item),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.danger),
                                    tooltip: 'Delete District',
                                    onPressed: () => _showDeleteDistrict(context, item),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    size: 20,
                                    color: isSelected ? AppColors.primary : const Color(0xFF94A3B8),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ================= COLUMN 2: SUB-DISTRICTS =================
  Widget _buildSubDistrictsColumn(BuildContext context, TerritoriesViewModel viewModel) {
    final subDistricts = viewModel.subDistricts;
    final selectedId = viewModel.selectedSubDistrictId;
    final selectedDistrict = viewModel.selectedDistrict;

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
            padding: const EdgeInsets.all(18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sub-districts',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'District: ${selectedDistrict?.name ?? "Select District"}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () => _showAddSubDistrict(context),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    height: 34,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF1FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 16, color: AppColors.primary),
                        SizedBox(width: 4),
                        Text(
                          'Add',
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
          const Divider(height: 1, color: AppColors.border),

          // Items List
          Expanded(
            child: subDistricts.isEmpty
                ? const Center(
                    child: Text('No sub-districts found for this district',
                        style: TextStyle(color: AppColors.textSecondary)))
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: subDistricts.length,
                    separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.border),
                    itemBuilder: (context, index) {
                      final item = subDistricts[index];
                      final isSelected = item.id == selectedId;

                      return InkWell(
                        onTap: () {
                          viewModel.selectSubDistrict(item.id);
                          if (!ResponsiveLayout.isDesktop(context)) {
                            setState(() => _mobileTabIndex = 2);
                          }
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFEAF1FF) : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Code ${item.code} · ${item.retailersCount} retailers',
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.textSecondary),
                                    tooltip: 'Edit Sub-district',
                                    onPressed: () => _showEditSubDistrict(context, item),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.danger),
                                    tooltip: 'Delete Sub-district',
                                    onPressed: () => _showDeleteSubDistrict(context, item),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    size: 20,
                                    color: isSelected ? AppColors.primary : const Color(0xFF94A3B8),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ================= COLUMN 3: AREAS =================
  Widget _buildAreasColumn(BuildContext context, TerritoriesViewModel viewModel) {
    final areas = viewModel.areas;
    final selectedId = viewModel.selectedAreaId;
    final selectedSub = viewModel.selectedSubDistrict;

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
            padding: const EdgeInsets.all(18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Areas',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Sub-district: ${selectedSub?.name ?? "Select Sub-district"}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () => _showAddArea(context),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    height: 34,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF1FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 16, color: AppColors.primary),
                        SizedBox(width: 4),
                        Text(
                          'Add',
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
          const Divider(height: 1, color: AppColors.border),

          // Items List
          Expanded(
            child: areas.isEmpty
                ? const Center(
                    child: Text('No areas found for this sub-district',
                        style: TextStyle(color: AppColors.textSecondary)))
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: areas.length,
                    separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.border),
                    itemBuilder: (context, index) {
                      final item = areas[index];
                      final isSelected = item.id == selectedId;

                      return InkWell(
                        onTap: () => viewModel.selectArea(item.id),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFEAF1FF) : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          item.name,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                          ),
                                        ),
                                        if (item.assignedSalesman != null) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFEEF2FF),
                                              borderRadius: BorderRadius.circular(4),
                                              border: Border.all(color: const Color(0xFFC7D2FE)),
                                            ),
                                            child: Text(
                                              item.assignedSalesman!,
                                              style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF4338CA),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Code ${item.code} · ${item.retailersCount} retailers',
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.person_add_alt_1_outlined, size: 16, color: AppColors.primary),
                                    tooltip: 'Assign Salesman',
                                    onPressed: () => _showAssignSalesman(context, item),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.textSecondary),
                                    tooltip: 'Edit Area',
                                    onPressed: () => _showEditArea(context, item),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.danger),
                                    tooltip: 'Delete Area',
                                    onPressed: () => _showDeleteArea(context, item),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    size: 20,
                                    color: isSelected ? AppColors.primary : const Color(0xFF94A3B8),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
