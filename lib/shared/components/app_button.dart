import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

enum AppButtonVariant { primary, outlined, text, danger }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final double? width;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                variant == AppButtonVariant.primary || variant == AppButtonVariant.danger
                    ? Colors.white
                    : AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ] else if (icon != null) ...[
          Icon(icon, size: 18),
          const SizedBox(width: 8),
        ],
        Text(label),
      ],
    );

    ButtonStyle style;
    switch (variant) {
      case AppButtonVariant.primary:
        style = ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: AppTypography.button(),
        );
        break;
      case AppButtonVariant.outlined:
        style = OutlinedButton.styleFrom(
          foregroundColor: isDark ? Colors.white : AppColors.grey800,
          side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.borderLight),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: AppTypography.button(color: isDark ? Colors.white : AppColors.grey800),
        );
        break;
      case AppButtonVariant.text:
        style = TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: AppTypography.button(color: AppColors.primary),
        );
        break;
      case AppButtonVariant.danger:
        style = ElevatedButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: AppTypography.button(),
        );
        break;
    }

    Widget btn;
    if (variant == AppButtonVariant.outlined) {
      btn = OutlinedButton(onPressed: isLoading ? null : onPressed, style: style, child: child);
    } else if (variant == AppButtonVariant.text) {
      btn = TextButton(onPressed: isLoading ? null : onPressed, style: style, child: child);
    } else {
      btn = ElevatedButton(onPressed: isLoading ? null : onPressed, style: style, child: child);
    }

    if (width != null) {
      return SizedBox(width: width, child: btn);
    }
    return btn;
  }
}
