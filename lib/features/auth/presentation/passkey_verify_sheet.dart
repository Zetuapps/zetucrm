import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_typography.dart';

class PasskeyVerifySheet extends ConsumerStatefulWidget {
  final String userId;
  final String? userName;
  final String? userEmail;

  const PasskeyVerifySheet({
    super.key,
    required this.userId,
    this.userName,
    this.userEmail,
  });

  /// Displays the Passkey Verification bottom sheet
  static Future<bool?> show(
    BuildContext context, {
    required String userId,
    String? userName,
    String? userEmail,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PasskeyVerifySheet(
        userId: userId,
        userName: userName,
        userEmail: userEmail,
      ),
    );
  }

  @override
  ConsumerState<PasskeyVerifySheet> createState() => _PasskeyVerifySheetState();
}

class _PasskeyVerifySheetState extends ConsumerState<PasskeyVerifySheet> {
  String _currentInput = '';
  String? _errorMessage;
  bool _isVerifying = false;

  void _onDigitPressed(String digit) {
    if (_isVerifying || _currentInput.length >= 4) return;
    HapticFeedback.lightImpact();

    setState(() {
      _errorMessage = null;
      _currentInput += digit;
    });

    if (_currentInput.length == 4) {
      _handleVerify();
    }
  }

  void _onDeletePressed() {
    if (_isVerifying || _currentInput.isEmpty) return;
    HapticFeedback.selectionClick();
    setState(() {
      _errorMessage = null;
      _currentInput = _currentInput.substring(0, _currentInput.length - 1);
    });
  }

  void _onClearPressed() {
    if (_isVerifying || _currentInput.isEmpty) return;
    HapticFeedback.selectionClick();
    setState(() {
      _errorMessage = null;
      _currentInput = '';
    });
  }

  Future<void> _handleVerify() async {
    setState(() => _isVerifying = true);

    final success = await ref
        .read(authProvider.notifier)
        .loginWithPasskey(widget.userId, _currentInput, email: widget.userEmail);

    if (!mounted) return;

    if (success) {
      HapticFeedback.mediumImpact();
      Navigator.of(context).pop(true);
    } else {
      HapticFeedback.heavyImpact();
      final authError = ref.read(authProvider).errorMessage;
      setState(() {
        _errorMessage = authError ?? 'Incorrect passkey. Please try again.';
        _currentInput = '';
        _isVerifying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF0F172A) : Colors.white;
    final keypadButtonColor =
        isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
    final keypadTextColor = isDark ? Colors.white : AppColors.grey900;

    final displayName = widget.userName?.trim().isNotEmpty == true
        ? widget.userName!
        : (widget.userEmail?.isNotEmpty == true ? widget.userEmail! : 'User');

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Shield Icon
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFF1B59F8).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.keyRound,
                  size: 26,
                  color: Color(0xFF1B59F8),
                ),
              ),
              const SizedBox(height: 12),

              Text(
                'Log In with Passkey',
                style: AppTypography.h3(
                  color: isDark ? Colors.white : AppColors.grey900,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),

              Text(
                'Welcome back, $displayName!\nEnter your 4-digit passkey to continue.',
                style: AppTypography.caption(
                  color: isDark ? Colors.white60 : AppColors.grey600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),

              // PIN Indicator Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  final isFilled = index < _currentInput.length;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isFilled
                          ? const Color(0xFF1B59F8)
                          : Colors.transparent,
                      border: Border.all(
                        color: _errorMessage != null
                            ? const Color(0xFFEF4444)
                            : (isFilled
                                ? const Color(0xFF1B59F8)
                                : (isDark
                                    ? const Color(0xFF475569)
                                    : const Color(0xFFCBD5E1))),
                        width: 2,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 8),

              // Error message
              if (_errorMessage != null) ...[
                Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: Color(0xFFEF4444),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ] else ...[
                const SizedBox(height: 14),
              ],
              const SizedBox(height: 8),

              // Keypad
              _buildKeypad(
                buttonColor: keypadButtonColor,
                textColor: keypadTextColor,
                isDark: isDark,
              ),
              const SizedBox(height: 10),

              // Switch to password
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                ),
                child: Text(
                  'Log in with password instead',
                  style: TextStyle(
                    color: isDark ? Colors.white54 : AppColors.grey600,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeypad({
    required Color buttonColor,
    required Color textColor,
    required bool isDark,
  }) {
    return Column(
      children: [
        _buildKeypadRow(['1', '2', '3'], buttonColor, textColor),
        const SizedBox(height: 10),
        _buildKeypadRow(['4', '5', '6'], buttonColor, textColor),
        const SizedBox(height: 10),
        _buildKeypadRow(['7', '8', '9'], buttonColor, textColor),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Clear button
            _buildSpecialKey(
              icon: Icons.clear_rounded,
              onTap: _onClearPressed,
              isDark: isDark,
            ),
            const SizedBox(width: 20),
            // '0' digit
            _buildKeypadButton('0', buttonColor, textColor),
            const SizedBox(width: 20),
            // Backspace button
            _buildSpecialKey(
              icon: Icons.backspace_outlined,
              onTap: _onDeletePressed,
              isDark: isDark,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKeypadRow(
    List<String> digits,
    Color buttonColor,
    Color textColor,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < digits.length; i++) ...[
          if (i > 0) const SizedBox(width: 20),
          _buildKeypadButton(digits[i], buttonColor, textColor),
        ],
      ],
    );
  }

  Widget _buildKeypadButton(String digit, Color buttonColor, Color textColor) {
    return Material(
      color: buttonColor,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => _onDigitPressed(digit),
        child: SizedBox(
          width: 56,
          height: 56,
          child: Center(
            child: Text(
              digit,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialKey({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 56,
          height: 56,
          child: Center(
            child: Icon(
              icon,
              size: 20,
              color: isDark ? Colors.white60 : AppColors.grey600,
            ),
          ),
        ),
      ),
    );
  }
}
