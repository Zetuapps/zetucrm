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

import 'bookings/presentation/bookings_screen.dart';
import '../core/auth/auth_provider.dart';
import '../core/services/passkey_service.dart';
import 'auth/presentation/passkey_setup_sheet.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPasskeySetup();
    });
  }

  Future<void> _checkPasskeySetup() async {
    if (!mounted) return;
    if (PasskeyService.hasPromptedThisSession) return;

    final user = ref.read(authProvider).user;
    final userId = user?.id ?? 'default';

    final hasBackendPasskey = user?.hasPasskey ?? false;
    final hasLocalPasskey = await PasskeyService.hasPasskey(userId);
    final hasPasskey = hasBackendPasskey || hasLocalPasskey;

    if (!hasPasskey && mounted) {
      PasskeyService.markPromptedThisSession();
      PasskeySetupSheet.show(
        context,
        userId: userId,
        canSkip: true,
      );
    }
  }

  final List<Widget> _pages = const [
    DashboardScreen(),
    ContactsScreen(),
    BookingsScreen(),
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
            icon: Icon(LucideIcons.calendar),
            label: 'Bookings',
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
