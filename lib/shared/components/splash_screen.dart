import 'package:flutter/material.dart';

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
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFF1B59F8),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1B59F8).withOpacity(0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'G',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 36,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'ZetuCRM',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF101828),
                fontWeight: FontWeight.bold,
                fontSize: 24,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 32),
            const SizedBox(
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
