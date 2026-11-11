import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../routing/app_router.dart';
import '../widgets/login_branding_panel.dart';
import '../widgets/login_form_panel.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ResponsiveLayout(
        desktop: Row(
          children: [
            const Expanded(
              child: LoginBrandingPanel(),
            ),
            Expanded(
              child: Container(
                color: AppColors.background,
                child: LoginFormPanel(
                  onSuccessLogin: () {
                    Navigator.of(context).pushReplacementNamed(AppRouter.dashboard);
                  },
                ),
              ),
            ),
          ],
        ),
        mobile: Container(
          color: AppColors.background,
          child: SafeArea(
            child: Column(
              children: [
                // Mobile Top Banner
                Container(
                  color: AppColors.darkNavy,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
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
                Expanded(
                  child: LoginFormPanel(
                    onSuccessLogin: () {
                      Navigator.of(context).pushReplacementNamed(AppRouter.dashboard);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
