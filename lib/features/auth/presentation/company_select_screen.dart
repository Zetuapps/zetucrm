import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_typography.dart';
import '../../../shared/components/app_card.dart';

class CompanySelectScreen extends ConsumerWidget {
  const CompanySelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final user = authState.user;
    final companies = authState.companies;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'Welcome, ${user?.firstName ?? 'User'} 👋',
                style: AppTypography.h2(color: isDark ? Colors.white : AppColors.grey900),
              ),
              const SizedBox(height: 8),
              Text(
                'Select a workspace company to get started:',
                style: AppTypography.body1(color: isDark ? AppColors.grey500 : AppColors.grey600),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: companies.isEmpty
                    ? Center(
                        child: Text(
                          'No workspace companies associated.',
                          style: AppTypography.body1(color: AppColors.grey500),
                        ),
                      )
                    : ListView.separated(
                        itemCount: companies.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final comp = companies[index];
                          final isSelected = authState.activeCompany?.id == comp.id;

                          return AppCard(
                            onTap: () {
                              ref.read(authProvider.notifier).selectCompany(comp);
                            },
                            borderColor: isSelected ? AppColors.primary : null,
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLighter,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.store_rounded,
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        comp.name,
                                        style: AppTypography.subtitle1(
                                          color: isDark ? Colors.white : AppColors.grey900,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Active Company',
                                        style: AppTypography.caption(color: AppColors.grey500),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    color: AppColors.primary,
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
