import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'app_button.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.grey200,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 36,
                color: isDark ? AppColors.grey500 : AppColors.grey600,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTypography.h4(color: isDark ? Colors.white : AppColors.grey900),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: AppTypography.body2(color: isDark ? AppColors.grey500 : AppColors.grey600),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              AppButton(
                label: actionLabel!,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
