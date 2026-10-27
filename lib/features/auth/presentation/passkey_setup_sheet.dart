import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../core/services/passkey_service.dart';
import '../../../shared/components/app_button.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_typography.dart';

class PasskeySetupSheet extends ConsumerStatefulWidget {
  final String userId;
  final bool canSkip;
  final VoidCallback? onCompleted;

  const PasskeySetupSheet({
    super.key,
    required this.userId,
    this.canSkip = true,
    this.onCompleted,
  });

  /// Displays the Biometric Passkey Setup bottom sheet
  static Future<bool?> show(
    BuildContext context, {
    required String userId,
    bool canSkip = true,
    VoidCallback? onCompleted,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      isDismissible: canSkip,
      enableDrag: canSkip,
      backgroundColor: Colors.transparent,
      builder: (_) => PasskeySetupSheet(
        userId: userId,
        canSkip: canSkip,
        onCompleted: onCompleted,
      ),
    );
  }

  @override
  ConsumerState<PasskeySetupSheet> createState() => _PasskeySetupSheetState();
}

class _PasskeySetupSheetState extends ConsumerState<PasskeySetupSheet> {
  bool _isActivating = false;
  String _biometricLabel = 'Biometric Passkey';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBiometricLabel();
  }

  Future<void> _loadBiometricLabel() async {
    final label = await PasskeyService.getBiometricLabel();
    if (mounted) {
      setState(() {
        _biometricLabel = label;
      });
    }
  }

  Future<void> _handleEnablePasskey() async {
    setState(() {
      _isActivating = true;
      _errorMessage = null;
    });

    final apiClient = ref.read(apiClientProvider);
    final user = ref.read(authProvider).user;

    final success = await PasskeyService.enableDevicePasskey(
      widget.userId,
      apiClient: apiClient,
      email: user?.email,
      userName: user?.fullName,
    );

    if (!mounted) return;

    if (success) {
      PasskeyService.markPromptedThisSession();
      await ref.read(authProvider.notifier).checkLoginStatus();
      if (!mounted) return;
      HapticFeedback.mediumImpact();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text('$_biometricLabel enabled successfully!'),
            ],
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );

      widget.onCompleted?.call();
      Navigator.of(context).pop(true);
    } else {
      HapticFeedback.heavyImpact();
      setState(() {
        _isActivating = false;
        _errorMessage = 'Biometric authentication was cancelled or not recognized. Please try again.';
      });
    }
  }

  void _handleSkip() {
    PasskeyService.markPromptedThisSession();
    Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF0F172A) : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Hero Biometric Icon
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1B59F8), Color(0xFF4F46E5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1B59F8).withValues(alpha: 0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  LucideIcons.fingerprint,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              const SizedBox(height: 18),

              // Title
              Text(
                'Enable Passkey Login',
                style: AppTypography.h3(
                  color: isDark ? Colors.white : AppColors.grey900,
                ).copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Subtitle
              Text(
                'Sign in instantly with $_biometricLabel next time without typing your password.',
                style: AppTypography.body2(
                  color: isDark ? AppColors.grey400 : AppColors.grey600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Feature Badges
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Column(
                  children: [
                    _buildFeatureItem(
                      icon: LucideIcons.zap,
                      title: '1-Tap Fast Sign-In',
                      subtitle: 'Access your CRM pipeline in seconds',
                      isDark: isDark,
                    ),
                    const Divider(height: 18),
                    _buildFeatureItem(
                      icon: LucideIcons.shieldCheck,
                      title: 'Device Hardware Security',
                      subtitle: 'Protected by your device secure enclave',
                      isDark: isDark,
                    ),
                    const Divider(height: 18),
                    _buildFeatureItem(
                      icon: LucideIcons.cloudCheck,
                      title: 'Cloud Database Sync',
                      subtitle: 'Synced securely with your CRM account',
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.errorLighter,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.error, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: AppTypography.caption(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Enable CTA
              AppButton(
                label: 'Enable $_biometricLabel',
                icon: LucideIcons.fingerprint,
                isLoading: _isActivating,
                onPressed: _handleEnablePasskey,
              ),

              if (widget.canSkip) ...[
                const SizedBox(height: 10),
                TextButton(
                  onPressed: _isActivating ? null : _handleSkip,
                  child: Text(
                    'Skip for now',
                    style: TextStyle(
                      color: isDark ? AppColors.grey400 : AppColors.grey500,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: const Color(0xFF1B59F8).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF1B59F8), size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.grey900,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: isDark ? AppColors.grey400 : AppColors.grey500,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
