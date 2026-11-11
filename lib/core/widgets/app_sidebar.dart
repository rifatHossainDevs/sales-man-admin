import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../../features/auth/viewmodels/auth_viewmodel.dart';
import '../../routing/app_router.dart';

class AppSidebar extends StatelessWidget {
  final String activeRoute;

  const AppSidebar({super.key, required this.activeRoute});

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final user = authViewModel.currentUser;

    return Container(
      width: 260,
      color: AppColors.darkNavy,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Logo & Branding
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.local_shipping_rounded,
                    color: AppColors.surface,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sales-Man',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.surface,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      'Dealer Console',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textLightSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Navigation Links
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('OVERVIEW'),
                  _buildNavItem(
                    context,
                    label: 'Dashboard',
                    icon: Icons.dashboard_outlined,
                    route: AppRouter.dashboard,
                  ),
                  const SizedBox(height: 16),

                  _buildSectionHeader('FIELD FORCE'),
                  _buildNavItem(
                    context,
                    label: 'Live Tracking',
                    icon: Icons.my_location_rounded,
                    route: AppRouter.liveTracking,
                  ),
                  _buildNavItem(
                    context,
                    label: 'Route History',
                    icon: Icons.route_rounded,
                    route: AppRouter.routeHistory,
                  ),
                  _buildNavItem(
                    context,
                    label: 'Salesmen',
                    icon: Icons.people_outline_rounded,
                    route: AppRouter.salesmen,
                  ),
                  const SizedBox(height: 16),

                  _buildSectionHeader('SALES'),
                  _buildNavItem(
                    context,
                    label: 'Orders',
                    icon: Icons.shopping_bag_outlined,
                    route: AppRouter.orders,
                  ),
                  _buildNavItem(
                    context,
                    label: 'Payments',
                    icon: Icons.account_balance_wallet_outlined,
                    route: AppRouter.payments,
                  ),
                  _buildNavItem(
                    context,
                    label: 'Retailers',
                    icon: Icons.storefront_outlined,
                    route: AppRouter.retailers,
                  ),
                  const SizedBox(height: 16),

                  _buildSectionHeader('CATALOG'),
                  _buildNavItem(
                    context,
                    label: 'Products',
                    icon: Icons.inventory_2_outlined,
                    route: AppRouter.products,
                  ),
                  _buildNavItem(
                    context,
                    label: 'Categories & Suppliers',
                    icon: Icons.category_outlined,
                    route: AppRouter.categoriesSuppliers,
                  ),
                  const SizedBox(height: 16),

                  _buildSectionHeader('SETTINGS'),
                  _buildNavItem(
                    context,
                    label: 'Territories',
                    icon: Icons.map_outlined,
                    route: AppRouter.territories,
                  ),
                  _buildNavItem(
                    context,
                    label: 'Salesman Performance',
                    icon: Icons.insights_rounded,
                    route: AppRouter.salesmanPerformance,
                  ),
                  _buildNavItem(
                    context,
                    label: 'Company & Subscription',
                    icon: Icons.business_outlined,
                    route: AppRouter.companySubscription,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // User Footer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFF1E293B))),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    user?.avatarInitials ?? 'AH',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.surface,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        user?.name ?? 'Anwar Hossain',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.surface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${user?.role ?? "Admin"} · ${user?.dealershipName ?? "Dhaka Dealership"}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textLightSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Logout',
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: AppColors.textLightSecondary,
                    size: 18,
                  ),
                  onPressed: () async {
                    await authViewModel.logout();
                    if (context.mounted) {
                      Navigator.of(
                        context,
                      ).pushReplacementNamed(AppRouter.login);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 8, top: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.bold,
          color: AppColors.textDarkMuted,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required String label,
    required IconData icon,
    required String route,
  }) {
    final isActive = activeRoute == route;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isActive ? AppColors.sidebarActiveNav : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          if (isActive) return;
          // Close drawer if open (for mobile)
          if (Scaffold.of(context).isDrawerOpen) {
            Navigator.of(context).pop();
          }
          Navigator.of(context).pushReplacementNamed(route);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              if (isActive)
                Container(
                  width: 3,
                  height: 16,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              Icon(
                icon,
                size: 18,
                color: isActive ? AppColors.surface : AppColors.textLightSubtle,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    color: isActive
                        ? AppColors.surface
                        : AppColors.textLightSubtle,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
