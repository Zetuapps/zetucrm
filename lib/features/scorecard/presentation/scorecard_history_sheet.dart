import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../data/models/scorecard_data.dart';

class ScorecardHistorySheet extends StatelessWidget {
  final List<HistoryDay> history;
  final List<String> workingDays;

  const ScorecardHistorySheet({
    super.key,
    required this.history,
    required this.workingDays,
  });

  static void show(BuildContext context, {
    required List<HistoryDay> history,
    required List<String> workingDays,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ScorecardHistorySheet(
        history: history,
        workingDays: workingDays,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final avgCompletion = history.isNotEmpty
        ? (history.map((h) => h.completionRate).reduce((a, b) => a + b) / history.length).round()
        : 0;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141925) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 6),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B59F8).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(LucideIcons.trendingUp, size: 20, color: Color(0xFF1B59F8)),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cadence Performance',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF101828),
                          ),
                        ),
                        Text(
                          'Past working days scorecard history',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white60 : const Color(0xFF667085),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(LucideIcons.x, size: 20, color: isDark ? Colors.white60 : Colors.grey[600]),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Average Execution Banner
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF1E2842), const Color(0xFF141B30)]
                      : [const Color(0xFFEBF1FF), const Color(0xFFF4F7FF)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(0xFF2E3A5A) : const Color(0xFFD3E0FF),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Average Execution Rate',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF1B59F8),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Across past ${history.length} working days',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.white60 : const Color(0xFF667085),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '$avgCompletion%',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: avgCompletion >= 80
                          ? const Color(0xFF12B76A)
                          : avgCompletion >= 50
                              ? const Color(0xFFF79009)
                              : const Color(0xFFF04438),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // History Days List
          Expanded(
            child: history.isEmpty
                ? Center(
                    child: Text(
                      'No past historical reports recorded yet',
                      style: TextStyle(color: isDark ? Colors.white60 : Colors.grey[600]),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: history.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final day = history[index];
                      final isHigh = day.completionRate >= 80;
                      final isMed = day.completionRate >= 50 && day.completionRate < 80;
                      final barColor = isHigh
                          ? const Color(0xFF12B76A)
                          : isMed
                              ? const Color(0xFFF79009)
                              : const Color(0xFFF04438);

                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1A2234) : const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: day.isToday
                                ? const Color(0xFF1B59F8)
                                : isDark
                                    ? const Color(0xFF28334B)
                                    : const Color(0xFFEAECF0),
                            width: day.isToday ? 1.5 : 1.0,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      day.dayFull.isNotEmpty ? day.dayFull : day.dayName,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? Colors.white : const Color(0xFF101828),
                                      ),
                                    ),
                                    if (day.isToday) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF1B59F8),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Text(
                                          'TODAY',
                                          style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                Text(
                                  '${day.completionRate}%',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: barColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${day.achievedMetrics} of ${day.totalMetrics} targets achieved (${day.date})',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? Colors.white60 : const Color(0xFF667085),
                              ),
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: (day.completionRate / 100).clamp(0.0, 1.0),
                                minHeight: 6,
                                backgroundColor: isDark ? Colors.white10 : const Color(0xFFE4E7EC),
                                valueColor: AlwaysStoppedAnimation<Color>(barColor),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
