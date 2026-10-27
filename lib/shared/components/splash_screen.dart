import 'package:flutter/material.dart';
import 'app_logo.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF10141D) : Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            AppLogo(
              iconOnly: true,
              height: 72,
              width: 72,
            ),
            SizedBox(height: 16),
            AppLogo(
              height: 32,
            ),
            SizedBox(height: 36),
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Color(0xFF1B59F8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
