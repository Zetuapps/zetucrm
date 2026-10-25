import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/auth/auth_provider.dart';
import 'core/notifications/local_notification_service.dart';
import 'core/notifications/firebase_messaging_service.dart';
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

class ZetuCrmApp extends ConsumerStatefulWidget {
  const ZetuCrmApp({super.key});

  @override
  ConsumerState<ZetuCrmApp> createState() => _ZetuCrmAppState();
}

class _ZetuCrmAppState extends ConsumerState<ZetuCrmApp> {
  @override
  void initState() {
    super.initState();
    // Initialize Firebase Messaging safely
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FirebaseMessagingService.init(ref);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final themeMode = ref.watch(themeProvider);

    // Whenever user is authenticated, ensure their device FCM token is synced to the backend
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (!previous!.isAuthenticated && next.isAuthenticated) {
        final apiClient = ref.read(apiClientProvider);
        FirebaseMessagingService.syncToken(apiClient);
      }
    });

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
