import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  /// If true, displays only the standalone emblem mark (logo_single.png).
  /// If false, displays the full brand logo (light.png in light mode, dark.png in dark mode).
  final bool iconOnly;
  final double? height;
  final double? width;
  final BoxFit fit;

  const AppLogo({
    super.key,
    this.iconOnly = false,
    this.height,
    this.width,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final String assetPath;
    if (iconOnly) {
      assetPath = 'assets/logo/logo_single.png';
    } else {
      assetPath = isDark ? 'assets/logo/dark.png' : 'assets/logo/light.png';
    }

    return Image.asset(
      assetPath,
      height: height,
      width: width,
      fit: fit,
    );
  }
}
