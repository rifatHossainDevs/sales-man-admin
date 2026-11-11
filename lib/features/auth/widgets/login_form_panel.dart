import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/info_box.dart';
import '../viewmodels/auth_viewmodel.dart';

class LoginFormPanel extends StatefulWidget {
  final VoidCallback onSuccessLogin;

  const LoginFormPanel({
    super.key,
    required this.onSuccessLogin,
  });

  @override
  State<LoginFormPanel> createState() => _LoginFormPanelState();
}

class _LoginFormPanelState extends State<LoginFormPanel> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    // Default demo values as shown in Figma
    _emailController = TextEditingController(text: 'admin@dhakadealership.com');
    _passwordController = TextEditingController(text: 'password123');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin(AuthViewModel authViewModel) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final success = await authViewModel.login(
      _emailController.text,
      _passwordController.text,
    );

    if (success && mounted) {
      widget.onSuccessLogin();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome back',
                  style: AppTypography.h2Bold,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sign in to the admin panel to continue.',
                  style: AppTypography.subtitleRegular,
                ),
                const SizedBox(height: 32),

                // Error alert message if any
                if (authViewModel.errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: AppColors.dangerBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          color: AppColors.danger,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            authViewModel.errorMessage!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.danger,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 16, color: AppColors.danger),
                          onPressed: authViewModel.clearError,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                ],

                // Email or Phone field
                CustomTextField(
                  label: 'Email or phone',
                  hintText: 'admin@dhakadealership.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (_) => authViewModel.clearError(),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email or phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Password field
                CustomTextField(
                  label: 'Password',
                  hintText: '••••••••••',
                  controller: _passwordController,
                  obscureText: !authViewModel.isPasswordVisible,
                  onChanged: (_) => authViewModel.clearError(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      authViewModel.isPasswordVisible
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    onPressed: authViewModel.togglePasswordVisibility,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Checkbox & Forgot Password
                Row(
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                        value: authViewModel.keepMeSignedIn,
                        onChanged: (val) {
                          if (val != null) {
                            authViewModel.setKeepMeSignedIn(val);
                          }
                        },
                        activeColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Keep me signed in',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Please contact your system administrator to reset password.',
                            ),
                            duration: Duration(seconds: 3),
                          ),
                        );
                      },
                      child: const Text(
                        'Forgot password?',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Submit Button
                CustomButton(
                  text: 'Sign in',
                  isLoading: authViewModel.isLoading,
                  onPressed: () => _handleLogin(authViewModel),
                ),
                const SizedBox(height: 32),

                // Admin Notice Box
                const InfoBox(
                  title: 'Admin access only.',
                  message: 'Salesmen sign in from the Sales-Man Android app.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
