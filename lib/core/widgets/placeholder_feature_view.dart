import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../utils/responsive_layout.dart';
import 'app_sidebar.dart';
import 'app_topbar.dart';

class PlaceholderFeatureView extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String currentRoute;
  final String phaseText;

  const PlaceholderFeatureView({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.currentRoute,
    this.phaseText = 'Module Scheduled for Implementation in Later Phase',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: AppSidebar(activeRoute: currentRoute),
      ),
      body: Row(
        children: [
          if (ResponsiveLayout.isDesktop(context))
            AppSidebar(activeRoute: currentRoute),
          Expanded(
            child: Column(
              children: [
                AppTopbar(title: title, subtitle: subtitle),
                Expanded(
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 540),
                      margin: const EdgeInsets.all(24),
                      padding: const EdgeInsets.all(36),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.cardBorder),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
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
                            child: Icon(
                              icon,
                              size: 32,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            title,
                            style: AppTypography.h3Bold,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            subtitle,
                            style: AppTypography.subtitleRegular,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.cardBorder),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.schedule_rounded, color: AppColors.primary, size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  phaseText,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
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
}
