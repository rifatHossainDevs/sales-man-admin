import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../features/auth/viewmodels/auth_viewmodel.dart';
import '../../../routing/app_router.dart';

class DashboardPlaceholderView extends StatelessWidget {
  const DashboardPlaceholderView({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final user = authViewModel.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.darkNavy,
        title: const Row(
          children: [
            Icon(Icons.local_shipping_rounded, color: AppColors.surface),
            SizedBox(width: 10),
            Text(
              'Sales-Man · Dealer Console',
              style: TextStyle(color: AppColors.surface, fontSize: 18),
            ),
          ],
        ),
        actions: [
          if (user != null) ...[
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.sidebarActiveNav,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        user.avatarInitials,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.surface,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.surface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout_rounded, color: AppColors.surface),
            onPressed: () async {
              await authViewModel.logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed(AppRouter.login);
              }
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.infoBg,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.infoBorder),
                ),
                child: const Icon(
                  Icons.dashboard_rounded,
                  size: 32,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Admin Dashboard Placeholder',
                style: AppTypography.h3Bold,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Authentication Phase 1 complete.\nWelcome ${user?.name ?? "Admin"} (${user?.email ?? ""}) to ${user?.dealershipName ?? "Dealer Console"}.',
                style: AppTypography.subtitleRegular,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Ready for Phase 2 Dashboard Implementation',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
