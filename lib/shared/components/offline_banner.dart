import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class OfflineBanner extends StatelessWidget {
  final bool isOffline;
  final int pendingCount;

  const OfflineBanner({
    super.key,
    required this.isOffline,
    this.pendingCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    if (!isOffline && pendingCount == 0) {
      return const SizedBox.shrink();
    }

    final bg = isOffline ? AppColors.warning : AppColors.info;
    final text = isOffline
        ? 'Offline Mode • ${pendingCount > 0 ? '$pendingCount pending syncs' : 'Local changes saved'}'
        : 'Syncing $pendingCount changes to cloud...';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: bg,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isOffline ? Icons.wifi_off_rounded : Icons.sync_rounded,
              size: 16,
              color: AppColors.grey900,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: AppTypography.caption(color: AppColors.grey900).copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
