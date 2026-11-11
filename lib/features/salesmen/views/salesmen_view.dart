import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/widgets/app_sidebar.dart';
import '../../../core/widgets/app_topbar.dart';
import '../../../data/models/salesman_model.dart';
import '../../../routing/app_router.dart';
import '../viewmodels/salesmen_viewmodel.dart';
import '../widgets/salesman_details_dialog.dart';
import '../widgets/salesman_dialog.dart';

class SalesmenView extends StatelessWidget {
  const SalesmenView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SalesmenViewModel(),
      child: const _SalesmenViewContent(),
    );
  }
}

class _SalesmenViewContent extends StatelessWidget {
  const _SalesmenViewContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SalesmenViewModel>();
    final isDesktop = ResponsiveLayout.isDesktop(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: Drawer(child: AppSidebar(activeRoute: AppRouter.salesmen)),
      body: Row(
        children: [
          if (isDesktop) const AppSidebar(activeRoute: AppRouter.salesmen),
          Expanded(
            child: Column(
              children: [
                const AppTopbar(
                  title: 'Salesmen',
                  subtitle: 'Approve new accounts and manage your field team',
                ),

                Expanded(
                  child: viewModel.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        )
                      : Container(
                          width: double.infinity,
                          color: AppColors.background,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildMetricsGrid(context, viewModel),

                                const SizedBox(height: 24),

                                _buildPendingApprovalCard(context, viewModel),

                                const SizedBox(height: 24),

                                _buildSalesmenTable(context, viewModel),
                              ],
                            ),
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

  Widget _buildMetricsGrid(BuildContext context, SalesmenViewModel viewModel) {
    final isDesktop = ResponsiveLayout.isDesktop(context);

    final cards = [
      _statCard('Total salesmen', '${viewModel.totalCount}', null),
      _statCard('Active', '${viewModel.activeCount}', AppColors.success),
      _statCard(
        'Pending approval',
        '${viewModel.pendingCount}',
        AppColors.warning,
      ),
      _statCard('Inactive', '${viewModel.inactiveCount}', AppColors.textMuted),
    ];

    if (isDesktop) {
      return Row(
        children: cards
            .map(
              (c) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: c == cards.last ? 0 : 16),
                  child: c,
                ),
              ),
            )
            .toList(),
      );
    } else {
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: cards
            .map(
              (c) => SizedBox(
                width: (MediaQuery.of(context).size.width - 64) / 2,
                child: c,
              ),
            )
            .toList(),
      );
    }
  }

  Widget _statCard(String title, String count, Color? color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
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

  Widget _buildPendingApprovalCard(
    BuildContext context,
    SalesmenViewModel viewModel,
  ) {
    final pending = viewModel.pendingSalesmen;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3E2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF6D8A8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.warning,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pending approval (${pending.length})',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'New registrations from the mobile app stay inactive until you approve them.',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          if (pending.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'No pending approvals.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            )
          else
            ...pending.map((s) => _buildPendingRow(context, viewModel, s)),
        ],
      ),
    );
  }

  Widget _buildPendingRow(
    BuildContext context,
    SalesmenViewModel viewModel,
    SalesmanModel s,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.5)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.warning,
              child: Text(
                s.avatarInitials,
                style: const TextStyle(
                  color: AppColors.surface,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 14),

            SizedBox(
              width: 180,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    s.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    s.email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            SizedBox(
              width: 140,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(s.phone, maxLines: 1, overflow: TextOverflow.ellipsis),
                  const Text(
                    'Phone',
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            SizedBox(
              width: 140,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(s.nid, maxLines: 1, overflow: TextOverflow.ellipsis),
                  const Text(
                    'NID number',
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            SizedBox(
              width: 120,
              child: Text(
                s.appliedDate ?? 'Applied recently',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ),

            const SizedBox(width: 16),

            OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 36),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              onPressed: () => viewModel.rejectSalesman(s.id),
              child: const Text(
                'Reject',
                style: TextStyle(color: AppColors.danger),
              ),
            ),

            const SizedBox(width: 8),

            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                minimumSize: const Size(0, 36),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              icon: const Icon(Icons.check, size: 16, color: AppColors.surface),
              label: const Text(
                'Approve',
                style: TextStyle(color: AppColors.surface),
              ),
              onPressed: () => viewModel.approveSalesman(s.id),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesmenTable(
    BuildContext context,
    SalesmenViewModel viewModel,
  ) {
    final salesmen = viewModel.filteredSalesmen;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Responsive Table Toolbar
          Padding(
            padding: const EdgeInsets.all(20),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text(
                  'All salesmen',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // Status filter dropdown
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
                              .map(
                                (st) => DropdownMenuItem(
                                  value: st,
                                  child: Text(
                                    st,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                              )
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
                          hintText: 'Search name or phone…',
                          hintStyle: const TextStyle(
                            fontSize: 12.5,
                            color: AppColors.textMuted,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            size: 18,
                            color: AppColors.textMuted,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 0,
                          ),
                          filled: true,
                          fillColor: AppColors.surface,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppColors.cardBorder,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Add Salesman button
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        minimumSize: const Size(0, 38),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(
                        Icons.add,
                        size: 18,
                        color: AppColors.surface,
                      ),
                      label: const Text(
                        'Add salesman',
                        style: TextStyle(
                          color: AppColors.surface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => SalesmanDialog(
                            onSave: (salesman) =>
                                viewModel.addSalesman(salesman),
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
                DataColumn(
                  label: Text(
                    'SALESMAN',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'PHONE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'NID',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                DataColumn(
                  numeric: true,
                  label: Text(
                    'ORDERS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                DataColumn(
                  numeric: true,
                  label: Text(
                    'COLLECTED',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'LAST SEEN',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'STATUS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'ACTIONS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
              rows: salesmen.map((s) {
                return DataRow(
                  cells: [
                    DataCell(
                      InkWell(
                        onTap: () => _openDetails(context, viewModel, s),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: s.isActive
                                  ? AppColors.primary
                                  : AppColors.textMuted,
                              child: Text(
                                s.avatarInitials,
                                style: const TextStyle(
                                  color: AppColors.surface,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  s.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  s.email,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    DataCell(
                      Text(s.phone, style: const TextStyle(fontSize: 13)),
                    ),
                    DataCell(
                      Text(
                        s.nid,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        '${s.totalOrders}',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    DataCell(
                      Text(
                        '৳ ${s.totalCollected.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    DataCell(
                      s.isOnline
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.successBg,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                '● Online',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.success,
                                ),
                              ),
                            )
                          : Text(
                              s.lastSeen,
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                    ),
                    DataCell(
                      Row(
                        children: [
                          Switch(
                            value: s.isActive,
                            activeThumbColor: AppColors.primary,
                            onChanged: (_) => viewModel.toggleStatus(s.id),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            s.isActive ? 'Active' : 'Inactive',
                            style: TextStyle(
                              fontSize: 12,
                              color: s.isActive
                                  ? AppColors.success
                                  : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.visibility_outlined,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            tooltip: 'View Profile',
                            onPressed: () =>
                                _openDetails(context, viewModel, s),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.edit_outlined,
                              size: 18,
                              color: AppColors.textSecondary,
                            ),
                            tooltip: 'Edit',
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => SalesmanDialog(
                                  salesman: s,
                                  onSave: (updated) =>
                                      viewModel.updateSalesman(updated),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              size: 18,
                              color: AppColors.danger,
                            ),
                            tooltip: 'Delete',
                            onPressed: () =>
                                _confirmDelete(context, viewModel, s),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),

          if (salesmen.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Text(
                  'No salesmen found matching the criteria.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _openDetails(
    BuildContext context,
    SalesmenViewModel viewModel,
    SalesmanModel s,
  ) {
    showDialog(
      context: context,
      builder: (_) => SalesmanDetailsDialog(
        salesman: s,
        onEdit: () {
          showDialog(
            context: context,
            builder: (_) => SalesmanDialog(
              salesman: s,
              onSave: (updated) => viewModel.updateSalesman(updated),
            ),
          );
        },
        onToggleStatus: () => viewModel.toggleStatus(s.id),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    SalesmenViewModel viewModel,
    SalesmanModel s,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Salesman'),
        content: Text(
          'Are you sure you want to delete "${s.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              minimumSize: const Size(0, 36),
            ),
            onPressed: () {
              viewModel.deleteSalesman(s.id);
              Navigator.of(ctx).pop();
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.surface),
            ),
          ),
        ],
      ),
    );
  }
}
