import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class AppShimmer extends StatelessWidget {
  final Widget child;

  const AppShimmer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF1E2538) : const Color(0xFFE0E0E0),
      highlightColor: isDark ? const Color(0xFF2B344B) : const Color(0xFFF5F5F5),
      child: child,
    );
  }

  /// Shimmer placeholder item for Card lists (matching the reference image)
  static Widget cardListShimmer({
    required bool isDark,
    int count = 4,
    bool shrinkWrap = true,
    ScrollPhysics physics = const NeverScrollableScrollPhysics(),
    EdgeInsetsGeometry? padding,
  }) {
    return ListView.separated(
      shrinkWrap: shrinkWrap,
      physics: physics,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: count,
      separatorBuilder: (_, index) => const SizedBox(height: 14),
      itemBuilder: (_, index) => AppShimmer(
        child: Container(
          height: 125,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C2234) : Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}
