import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/auth/auth_provider.dart';
import 'core/notifications/local_notification_service.dart';
import 'shared/theme/app_theme.dart';
import 'shared/theme/theme_provider.dart';
import 'shared/components/splash_screen.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/company_select_screen.dart';
import 'features/app_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalNotificationService.init();

  runApp(
    const ProviderScope(
      child: ZetuCrmApp(),
    ),
  );
}

class ZetuCrmApp extends ConsumerWidget {
  const ZetuCrmApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final themeMode = ref.watch(themeProvider);

    Widget homeScreen;
    if (authState.isInitializing) {
      homeScreen = const SplashScreen();
    } else if (!authState.isAuthenticated) {
      homeScreen = const LoginScreen();
    } else if (authState.activeCompany == null) {
      homeScreen = const CompanySelectScreen();
    } else {
      homeScreen = const AppShell();
    }

    return MaterialApp(
      title: 'ZetuCRM',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: homeScreen,
    );
  }
}
