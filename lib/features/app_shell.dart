import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/sync/sync_provider.dart';
import '../shared/components/offline_banner.dart';
import 'dashboard/presentation/dashboard_screen.dart';
import 'contacts/presentation/contacts_screen.dart';
import 'activities/presentation/activities_screen.dart';
import 'tasks/presentation/tasks_screen.dart';
import 'settings/presentation/settings_screen.dart';

import 'deals/presentation/deals_screen.dart';
import 'finance/presentation/finance_screen.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DashboardScreen(),
    ContactsScreen(),
    DealsScreen(),
    FinanceScreen(),
    ActivitiesScreen(),
    TasksScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final syncState = ref.watch(syncProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Column(
        children: [
          OfflineBanner(
            isOffline: syncState.isOffline,
            pendingCount: syncState.pendingCount,
          ),
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: _pages,
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF1B59F8),
        unselectedItemColor: isDark ? Colors.white38 : const Color(0xFF98A2B3),
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 11,
        unselectedFontSize: 10,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.users),
            label: 'Contacts',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.briefcase),
            label: 'Deals',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.landmark),
            label: 'Finance',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.phoneCall),
            label: 'Activities',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.checkSquare),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
