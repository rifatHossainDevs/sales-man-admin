import 'package:web/web.dart' as web;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/widgets/app_sidebar.dart';
import '../../../core/widgets/app_topbar.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../data/mock/mock_phase5_data.dart';
import '../../../routing/app_router.dart';
import '../viewmodels/company_management_viewmodel.dart';
import '../../subscriptions/viewmodels/subscription_management_viewmodel.dart';

class CompanySubscriptionView extends StatelessWidget {
  const CompanySubscriptionView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CompanyManagementViewModel()),
        ChangeNotifierProvider(create: (_) => SubscriptionManagementViewModel()),
      ],
      child: const _CompanySubscriptionViewContent(),
    );
  }
}

class _CompanySubscriptionViewContent extends StatelessWidget {
  const _CompanySubscriptionViewContent();

  void _openWhatsAppRenewal() {
    try {
      const waUrl = 'https://wa.me/8801750057251?text=Hello%2C%20I%20would%20like%20to%20renew%20our%20dealership%20subscription%20plan.';
      web.window.open(waUrl, '_blank');
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final companyVm = context.watch<CompanyManagementViewModel>();
    final isDesktop = ResponsiveLayout.isDesktop(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: Drawer(
        child: AppSidebar(activeRoute: AppRouter.companySubscription),
      ),
      body: Row(
        children: [
          if (isDesktop)
            const AppSidebar(activeRoute: AppRouter.companySubscription),
          Expanded(
            child: Column(
              children: [
                const AppTopbar(
                  title: 'Company & Subscription',
                  subtitle: 'Dealer profile and subscription plan',
                ),
                Expanded(
                  child: companyVm.isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 1. Company Profile & Current Plan Cards Row
                              if (isDesktop)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(flex: 6, child: _buildCompanyProfileCard(companyVm)),
                                    const SizedBox(width: 24),
                                    Expanded(flex: 6, child: _buildCurrentPlanCard(companyVm)),
                                  ],
                                )
                              else ...[
                                _buildCompanyProfileCard(companyVm),
                                const SizedBox(height: 24),
                                _buildCurrentPlanCard(companyVm),
                              ],

                              const SizedBox(height: 32),

                              // 2. Subscription Plans Section
                              const Text(
                                'Available Subscription Plans',
                                style: AppTypography.h3Bold,
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Compare plan limits and features for your dealership',
                                style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: 16),
                              _buildPlansGrid(context, companyVm),

                              const SizedBox(height: 32),

                              // 3. Subscription History Table
                              _buildHistoryTable(companyVm),
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

  // 9.1 Company Information with Company ID
  Widget _buildCompanyProfileCard(CompanyManagementViewModel companyVm) {
    final company = companyVm.companies.isNotEmpty
        ? companyVm.companies.first
        : MockPhase5Data.companies.first;

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
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.business_rounded, color: AppColors.surface, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(company.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      // 9.1 Company ID readable text
                      Text('Company ID: ${company.id}', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    ],
                  ),
                ],
              ),
              StatusBadge(status: company.status),
            ],
          ),
          const Divider(height: 28, color: AppColors.cardBorder),
          _infoRow(Icons.fingerprint_rounded, 'Company ID', company.id),
          const SizedBox(height: 10),
          _infoRow(Icons.email_outlined, 'Email', company.email),
          const SizedBox(height: 10),
          _infoRow(Icons.phone_outlined, 'Phone', company.phone),
          const SizedBox(height: 10),
          _infoRow(Icons.location_on_outlined, 'Address', company.address),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        SizedBox(
          width: 90,
          child: Text(label, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ),
      ],
    );
  }

  // 9.2 Renew Plan Button
  Widget _buildCurrentPlanCard(CompanyManagementViewModel companyVm) {
    final company = companyVm.companies.isNotEmpty ? companyVm.companies.first : MockPhase5Data.companies.first;

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
              const Text('Active Subscription', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('Enterprise Plan', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text('Validity: 01 Jan 2026 – 31 Dec 2026', style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          const Text('Resource Usage Limits:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          _usageBar('Admin Accounts', company.admins, null),
          const SizedBox(height: 8),
          _usageBar('Sales Representatives', company.salesRepresentatives, null),
          const SizedBox(height: 8),
          _usageBar('Customers / Retailers', company.customers, null),
          const SizedBox(height: 20),

          // 9.2 Renew Plan Button via WhatsApp (01750057251)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
              label: const Text('Renew Plan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              onPressed: _openWhatsAppRenewal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _usageBar(String label, int current, int? max) {
    final maxStr = max == null ? 'Unlimited' : '$max';

    return Row(
      children: [
        Expanded(child: Text(label, style: const TextStyle(fontSize: 12.5))),
        Text('$current / $maxStr', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.primary)),
      ],
    );
  }

  Widget _buildPlansGrid(BuildContext context, CompanyManagementViewModel companyVm) {
    final plans = companyVm.plans;

    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;
      final cardWidth = width > 900 ? (width - 32) / 3 : (width > 600 ? (width - 16) / 2 : width);

      return Wrap(
        spacing: 16,
        runSpacing: 16,
        children: plans.map((plan) {
          final isCurrent = plan.id == 'enterprise';

          return Container(
            width: cardWidth,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isCurrent ? AppColors.primary : AppColors.cardBorder,
                width: isCurrent ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(plan.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    if (isCurrent)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
                        child: const Text('Current', style: TextStyle(fontSize: 10, color: AppColors.surface, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(plan.priceLabel, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
                const Divider(height: 20, color: AppColors.cardBorder),
                _planLimitRow('Admins:', plan.limit(plan.maxAdmins)),
                _planLimitRow('Sales Reps:', plan.limit(plan.maxSalesRepresentatives)),
                _planLimitRow('Customers:', plan.limit(plan.maxCustomers)),
                const SizedBox(height: 12),
                ...plan.features.map((f) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.success),
                          const SizedBox(width: 6),
                          Expanded(child: Text(f, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                        ],
                      ),
                    )),
              ],
            ),
          );
        }).toList(),
      );
    });
  }

  Widget _planLimitRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildHistoryTable(CompanyManagementViewModel companyVm) {
    final history = MockPhase5Data.history;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text('Subscription History', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          const Divider(height: 1, color: AppColors.cardBorder),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 40,
              headingRowColor: WidgetStateProperty.all(AppColors.background),
              columns: const [
                DataColumn(label: Text('PLAN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                DataColumn(label: Text('START', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                DataColumn(label: Text('END', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                DataColumn(label: Text('PRICE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                DataColumn(label: Text('STATUS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
              ],
              rows: history.map((h) {
                return DataRow(
                  cells: [
                    DataCell(Text(h.planId.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                    DataCell(Text('${h.start.day} Jan ${h.start.year}', style: const TextStyle(fontSize: 12.5))),
                    DataCell(Text('${h.end.day} Dec ${h.end.year}', style: const TextStyle(fontSize: 12.5))),
                    DataCell(Text(h.price != null ? '৳ ${h.price!.toStringAsFixed(0)}' : 'Custom', style: const TextStyle(fontSize: 12.5))),
                    DataCell(StatusBadge(status: h.status)),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
