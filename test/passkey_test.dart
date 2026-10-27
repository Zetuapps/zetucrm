import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zetucrm/core/services/passkey_service.dart';
import 'package:zetucrm/features/auth/presentation/passkey_setup_sheet.dart';
import 'package:zetucrm/features/auth/presentation/passkey_verify_sheet.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    PasskeyService.resetSessionPrompt();
    PasskeyService.mockAuthenticateResult = null;
  });

  group('PasskeyService Tests', () {
    test('initial passkey check returns false', () async {
      final hasPass = await PasskeyService.hasPasskey('user_123');
      expect(hasPass, false);
    });

    test('generates cryptographically strong 64-char hex secret', () {
      final secret1 = PasskeyService.generatePasskeySecret();
      final secret2 = PasskeyService.generatePasskeySecret();
      expect(secret1.length, 64);
      expect(secret2.length, 64);
      expect(secret1, isNot(equals(secret2)));
    });

    test('can set and verify passkey', () async {
      await PasskeyService.setPasskey('user_123', 'test_secret_123');
      
      final hasPass = await PasskeyService.hasPasskey('user_123');
      expect(hasPass, true);

      final matches = await PasskeyService.verifyPasskey('user_123', 'test_secret_123');
      expect(matches, true);

      final wrong = await PasskeyService.verifyPasskey('user_123', 'wrong_secret');
      expect(wrong, false);
    });

    test('can remove passkey', () async {
      await PasskeyService.setPasskey('user_123', 'test_secret');
      expect(await PasskeyService.hasPasskey('user_123'), true);

      await PasskeyService.removePasskey('user_123');
      expect(await PasskeyService.hasPasskey('user_123'), false);
    });

    test('tracks session prompt flag correctly', () {
      expect(PasskeyService.hasPromptedThisSession, false);
      PasskeyService.markPromptedThisSession();
      expect(PasskeyService.hasPromptedThisSession, true);
      PasskeyService.resetSessionPrompt();
      expect(PasskeyService.hasPromptedThisSession, false);
    });
  });

  group('PasskeySetupSheet Widget Tests', () {
    testWidgets('renders header, description, and "Skip for now"', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: PasskeySetupSheet(
                userId: 'user_test',
                canSkip: true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Enable Passkey Login'), findsOneWidget);
      expect(find.text('Skip for now'), findsOneWidget);
      expect(find.text('1-Tap Fast Sign-In'), findsOneWidget);
      expect(find.text('Device Hardware Security'), findsOneWidget);
    });

    testWidgets('tapping Skip for now marks session prompted and pops', (tester) async {
      bool? result;
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () async {
                      result = await PasskeySetupSheet.show(
                        context,
                        userId: 'user_test',
                        canSkip: true,
                      );
                    },
                    child: const Text('Open'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Skip for now'), findsOneWidget);
      await tester.tap(find.text('Skip for now'));
      await tester.pumpAndSettle();

      expect(result, false);
      expect(PasskeyService.hasPromptedThisSession, true);
    });

    testWidgets('tapping Enable Passkey with successful biometric activates passkey', (tester) async {
      PasskeyService.mockAuthenticateResult = true;

      bool? result;
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () async {
                      result = await PasskeySetupSheet.show(
                        context,
                        userId: 'user_biometric_test',
                        canSkip: true,
                      );
                    },
                    child: const Text('Open'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Enable'), findsWidgets);
      // Tap the primary enable button
      await tester.tap(find.byType(ElevatedButton).last);
      await tester.pumpAndSettle();

      expect(result, true);
      expect(await PasskeyService.hasPasskey('user_biometric_test'), true);
    });
  });

  group('PasskeyVerifySheet & LoginScreen Tests', () {
    testWidgets('PasskeyVerifySheet renders correctly with fallback button', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: PasskeyVerifySheet(
                userId: 'user_123',
                userName: 'David',
                userEmail: 'david@zetuapps.com',
              ),
            ),
          ),
        ),
      );

      expect(find.text('Log In with Passkey'), findsOneWidget);
      expect(find.textContaining('Welcome back, David!'), findsOneWidget);
      expect(find.text('Log in with password instead'), findsOneWidget);
    });

    test('hasAnyPasskey correctly detects saved passkey on device', () async {
      expect(await PasskeyService.hasAnyPasskey(), false);
      await PasskeyService.setPasskey('user_456', 'secret_token_123', email: 'test@example.com', userName: 'Test User');
      expect(await PasskeyService.hasAnyPasskey(), true);
      expect(await PasskeyService.getLastPasskeyUserId(), 'user_456');
      expect(await PasskeyService.getLastPasskeyEmail(), 'test@example.com');
      expect(await PasskeyService.getLastPasskeyUserName(), 'Test User');

      await PasskeyService.removePasskey('user_456');
      expect(await PasskeyService.hasAnyPasskey(), false);
    });
  });
}
