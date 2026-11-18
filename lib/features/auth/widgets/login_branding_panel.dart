import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class LoginBrandingPanel extends StatelessWidget {
  const LoginBrandingPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.darkNavy,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 48),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: (constraints.maxHeight - 96).clamp(0, double.infinity),
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Brand Header
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.local_shipping_rounded,
                            color: AppColors.surface,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sales-Man',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.surface,
                                  height: 1.1,
                                ),
                              ),
                              Text(
                                'Dealer Console',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textLightSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),
                    const SizedBox(height: 24),

                    // Hero Headline
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                          fontFamily: 'Inter',
                        ),
                        children: [
                          TextSpan(
                            text: 'Run your dealership,\nfield team and deliveries\n',
                            style: TextStyle(color: AppColors.surface),
                          ),
                          TextSpan(
                            text: 'from one place.',
                            style: TextStyle(color: AppColors.primaryLight),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Feature Highlights
                    _buildFeatureRow(
                      icon: Icons.location_on_rounded,
                      title: 'See every salesman live',
                      description: 'Real-time GPS on the map during working hours',
                    ),
                    const SizedBox(height: 24),
                    _buildFeatureRow(
                      icon: Icons.route_rounded,
                      title: 'Replay the whole day',
                      description: 'Full route, visits and time spent per retailer',
                    ),
                    const SizedBox(height: 24),
                    _buildFeatureRow(
                      icon: Icons.inventory_2_rounded,
                      title: 'Control products and stock',
                      description: 'Upload products, set prices and track orders',
                    ),

                    const Spacer(),
                    const SizedBox(height: 24),

                    // Footer
                    const Text(
                      '© 2026 Sales-Man · Dealership Sales Management System',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textDarkMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeatureRow({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF334155)),
          ),
          child: Icon(
            icon,
            color: AppColors.primaryLight,
            size: 22,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.surface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textLightSubtle,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
