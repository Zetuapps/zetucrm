import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../core/sync/sync_provider.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_typography.dart';
import '../../../shared/theme/theme_provider.dart';
import '../../../shared/components/app_card.dart';
import '../../../shared/components/app_chip.dart';
import '../../../shared/components/app_button.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final syncState = ref.watch(syncProvider);
    final currentThemeMode = ref.watch(themeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final user = authState.user;
    final activeCompany = authState.activeCompany;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings & Account',
          style: AppTypography.h3(
            color: isDark ? Colors.white : AppColors.grey900,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Profile Summary Card
          AppCard(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    user?.firstName.isNotEmpty ?? false
                        ? user!.firstName[0].toUpperCase()
                        : 'U',
                    style: AppTypography.h2(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.fullName ?? 'CRM User',
                        style: AppTypography.h4(
                          color: isDark ? Colors.white : AppColors.grey900,
                        ),
                      ),
                      Text(
                        user?.email ?? '',
                        style: AppTypography.caption(color: AppColors.grey500),
                      ),
                      const SizedBox(height: 6),
                      AppChip(
                        label: user?.role ?? 'Sales Rep',
                        color: AppColors.primaryLighter,
                        textColor: AppColors.primaryDark,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Appearance & Theme Switcher
          Text(
            'APPEARANCE & THEME',
            style: AppTypography.overline(
              color: isDark ? AppColors.grey400 : AppColors.grey600,
            ),
          ),
          const SizedBox(height: 8),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose App Theme',
                  style: AppTypography.subtitle2(
                    color: isDark ? Colors.white : AppColors.grey900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Select your preferred color theme or match system settings',
                  style: AppTypography.caption(color: AppColors.grey500),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildThemeOption(
                      context: context,
                      ref: ref,
                      label: 'System',
                      icon: LucideIcons.monitor,
                      mode: ThemeMode.system,
                      currentMode: currentThemeMode,
                      isDark: isDark,
                    ),
                    const SizedBox(width: 8),
                    _buildThemeOption(
                      context: context,
                      ref: ref,
                      label: 'Light',
                      icon: LucideIcons.sun,
                      mode: ThemeMode.light,
                      currentMode: currentThemeMode,
                      isDark: isDark,
                    ),
                    const SizedBox(width: 8),
                    _buildThemeOption(
                      context: context,
                      ref: ref,
                      label: 'Dark',
                      icon: LucideIcons.moon,
                      mode: ThemeMode.dark,
                      currentMode: currentThemeMode,
                      isDark: isDark,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Active Company Card
          Text(
            'ACTIVE WORKSPACE',
            style: AppTypography.overline(
              color: isDark ? AppColors.grey400 : AppColors.grey600,
            ),
          ),
          const SizedBox(height: 8),
          AppCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activeCompany?.name ?? 'Default Company',
                      style: AppTypography.subtitle1(
                        color: isDark ? Colors.white : AppColors.grey900,
                      ),
                    ),
                    Text(
                      'All CRM records scoped to this company',
                      style: AppTypography.caption(color: AppColors.grey500),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(
                    Icons.swap_horiz_rounded,
                    color: AppColors.primary,
                  ),
                  onPressed: () {
                    ref.read(authProvider.notifier).selectCompany(
                          authState.companies.firstWhere(
                            (c) => c.id != activeCompany?.id,
                            orElse: () =>
                                activeCompany ??
                                CompanyItem(id: '1', name: 'Default Company'),
                          ),
                        );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Sync Engine & Offline Monitor Card
          Text(
            'OFFLINE & SYNC ENGINE',
            style: AppTypography.overline(
              color: isDark ? AppColors.grey400 : AppColors.grey600,
            ),
          ),
          const SizedBox(height: 8),
          AppCard(
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    syncState.isOffline
                        ? Icons.wifi_off_rounded
                        : Icons.wifi_rounded,
                    color: syncState.isOffline
                        ? AppColors.warning
                        : AppColors.success,
                  ),
                  title: Text(
                    syncState.isOffline ? 'Offline Mode' : 'Connected to Cloud',
                    style: AppTypography.subtitle2(
                      color: isDark ? Colors.white : AppColors.grey900,
                    ),
                  ),
                  subtitle: Text(
                    '${syncState.pendingCount} pending local changes queued for sync',
                    style: AppTypography.caption(color: AppColors.grey500),
                  ),
                  trailing: AppButton(
                    label: syncState.isSyncing ? 'Syncing...' : 'Sync Now',
                    isLoading: syncState.isSyncing,
                    variant: AppButtonVariant.outlined,
                    onPressed: syncState.isOffline
                        ? null
                        : () =>
                            ref.read(syncProvider.notifier).triggerSync(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Logout Action
          AppButton(
            label: 'Log Out of Account',
            variant: AppButtonVariant.danger,
            icon: Icons.logout_rounded,
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required WidgetRef ref,
    required String label,
    required IconData icon,
    required ThemeMode mode,
    required ThemeMode currentMode,
    required bool isDark,
  }) {
    final isSelected = currentMode == mode;
    final activeColor = const Color(0xFF1B59F8);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          ref.read(themeProvider.notifier).setThemeMode(mode);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? activeColor.withOpacity(0.12)
                : (isDark ? const Color(0xFF1C2234) : const Color(0xFFF9FAFB)),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? activeColor
                  : (isDark ? const Color(0xFF2B344B) : const Color(0xFFEAECF0)),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? activeColor
                    : (isDark ? Colors.white60 : const Color(0xFF667085)),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? activeColor
                      : (isDark ? Colors.white70 : const Color(0xFF344054)),
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
