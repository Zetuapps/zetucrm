import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../core/services/passkey_service.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_typography.dart';
import '../../../shared/components/app_button.dart';
import '../../../shared/components/app_text_field.dart';
import '../../../shared/components/app_logo.dart';
import 'passkey_setup_sheet.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _autoSetupPasskey = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isNotEmpty && password.isNotEmpty) {
      final success = await ref.read(authProvider.notifier).loginWithEmail(email, password);
      if (success) {
        await _onLoginCompletedSuccessfully();
      }
    }
  }

  Future<void> _onLoginCompletedSuccessfully() async {
    if (!mounted) return;
    if (_autoSetupPasskey) {
      final user = ref.read(authProvider).user;
      final userId = user?.id ?? 'default';
      await PasskeySetupSheet.show(
        context,
        userId: userId,
        canSkip: true,
      );
    }
  }

  Future<void> _handleContinueWithPasskey() async {
    final hasAny = await PasskeyService.hasAnyPasskey();
    if (!mounted) return;

    if (hasAny) {
      final success = await ref
          .read(authProvider.notifier)
          .loginWithBiometricPasskey();

      if (success && mounted) {
        // Logged in successfully via native device biometric passkey!
        return;
      }
    } else {
      // User has not set up a passkey yet
      setState(() {
        _autoSetupPasskey = true;
      });

      final biometricLabel = await PasskeyService.getBiometricLabel();
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(LucideIcons.fingerprint, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'No passkey active on this device. Sign in once to activate $biometricLabel passkey for your account!',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF1B59F8),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );

      if (_emailController.text.trim().isEmpty) {
        _emailFocusNode.requestFocus();
      } else if (_passwordController.text.trim().isEmpty) {
        _passwordFocusNode.requestFocus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo & Header
                const Center(
                  child: AppLogo(
                    height: 48,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Log in to your enterprise account',
                  style: AppTypography.body2(
                    color: isDark ? AppColors.grey500 : AppColors.grey600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),

                // Auto-passkey setup indicator banner
                if (_autoSetupPasskey) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B59F8).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF1B59F8).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          LucideIcons.fingerprint,
                          size: 20,
                          color: Color(0xFF1B59F8),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Passkey setup active: Enter your credentials once to automatically activate Face ID / Fingerprint passkey login.',
                            style: TextStyle(
                              color: isDark ? Colors.white70 : const Color(0xFF1E293B),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                if (authState.errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.errorLighter,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      authState.errorMessage!,
                      style: AppTypography.body2(color: AppColors.error),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Email Input
                AppTextField(
                  label: 'Email Address',
                  hint: 'email@example.com',
                  controller: _emailController,
                  focusNode: _emailFocusNode,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined, size: 20),
                ),
                const SizedBox(height: 16),

                // Password Input
                AppTextField(
                  label: 'Password',
                  hint: 'Enter password',
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  isPassword: true,
                  prefixIcon: const Icon(Icons.lock_outline, size: 20),
                ),
                const SizedBox(height: 24),

                // Email Login CTA
                AppButton(
                  label: 'Log In',
                  isLoading: authState.isLoading,
                  onPressed: _handleLogin,
                ),
                const SizedBox(height: 20),

                // Divider
                Row(
                  children: [
                    const Expanded(child: Divider(color: AppColors.borderLight)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'OR CONTINUE WITH',
                        style: AppTypography.overline(color: AppColors.grey500),
                      ),
                    ),
                    const Expanded(child: Divider(color: AppColors.borderLight)),
                  ],
                ),
                const SizedBox(height: 20),

                // Continue with Passkey CTA
                AppButton(
                  label: 'Continue with Passkey',
                  variant: AppButtonVariant.outlined,
                  icon: LucideIcons.keyRound,
                  onPressed: authState.isLoading ? null : _handleContinueWithPasskey,
                ),
                const SizedBox(height: 12),

                // Google Sign-In CTA
                AppButton(
                  label: 'Continue with Google',
                  variant: AppButtonVariant.outlined,
                  icon: Icons.g_mobiledata_rounded,
                  onPressed: authState.isLoading
                      ? null
                      : () async {
                          final success = await ref
                              .read(authProvider.notifier)
                              .loginWithGoogle();
                          if (success) {
                            await _onLoginCompletedSuccessfully();
                          }
                        },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
