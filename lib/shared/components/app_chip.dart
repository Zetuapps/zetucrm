import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class AppChip extends StatelessWidget {
  final String label;
  final Color? color;
  final Color? textColor;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool isSelected;

  const AppChip({
    super.key,
    required this.label,
    this.color,
    this.textColor,
    this.icon,
    this.onTap,
    this.isSelected = true,
  });

  @override
  Widget build(BuildContext context) {
    final bg = color ?? AppColors.primaryLighter;
    final txt = textColor ?? AppColors.primaryDark;

    Widget chipContent = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isSelected ? bg : bg.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? bg : Colors.transparent,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: txt),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTypography.overline(color: txt),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: chipContent,
      );
    }

    return chipContent;
  }
}
