import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../shared/theme/app_typography.dart';
import '../data/models/scorecard_data.dart';
import 'scorecard_provider.dart';
import 'scorecard_history_sheet.dart';
import 'scorecard_new_metric_sheet.dart';

class ScorecardScreen extends ConsumerStatefulWidget {
  const ScorecardScreen({super.key});

  @override
  ConsumerState<ScorecardScreen> createState() => _ScorecardScreenState();
}

class _ScorecardScreenState extends ConsumerState<ScorecardScreen> {
  final List<String> _timeframes = ['daily', 'weekly', 'monthly', 'quarterly', 'annually'];

  String _formatTimeframeLabel(String tf) {
    switch (tf) {
      case 'daily':
        return 'Daily';
      case 'weekly':
        return 'Weekly';
      case 'monthly':
        return 'Monthly';
      case 'quarterly':
        return 'Quarterly';
      case 'annually':
        return 'Annually';
      default:
        return tf;
    }
  }

  void _openHistory() {
    final state = ref.read(scorecardProvider);
    ScorecardHistorySheet.show(
      context,
      history: state.history,
      workingDays: state.scorecard?.workingDays ?? const [],
    );
  }

  void _openNewMetric() {
    final state = ref.read(scorecardProvider);
    ScorecardNewMetricSheet.show(context, defaultTimeframe: state.timeframe);
  }

  void _openValueInputDialog(ScorecardMetricItem metric) {
    if (metric.isAutoCrm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This metric is automatically calculated from CRM data.')),
      );
      return;
    }

    final curr = metric.valueNumber ?? (metric.currentValue is num ? (metric.currentValue as num).toDouble() : 0.0);
    final textCtrl = TextEditingController(text: curr > 0 ? (curr % 1 == 0 ? curr.toInt().toString() : curr.toString()) : '');
    final notesCtrl = TextEditingController(text: metric.notes ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A2234) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Update: ${metric.title}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF101828),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.x, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: textCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  autofocus: true,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1B59F8),
                  ),
                  decoration: InputDecoration(
                    labelText: 'Score Value (${metric.unitLabel ?? 'units'})',
                    hintText: '0',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesCtrl,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Optional Execution Notes',
                    hintText: 'e.g. Met client, discussed proposal...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B59F8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      final val = double.tryParse(textCtrl.text.trim()) ?? 0.0;
                      final note = notesCtrl.text.trim();
                      ref.read(scorecardProvider.notifier).saveEntry(
                            metricId: metric.id,
                            valueNumber: val,
                            notes: note.isNotEmpty ? note : null,
                          );
                      Navigator.pop(ctx);
                    },
                    child: const Text('Save Score', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openNoteDialog(ScorecardMetricItem metric) {
    final noteCtrl = TextEditingController(text: metric.notes ?? metric.valueText ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A2234) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Notes: ${metric.title}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF101828),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.x, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: noteCtrl,
                  maxLines: 4,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Add qualitative cadence feedback or progress details...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B59F8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      final note = noteCtrl.text.trim();
                      if (metric.valueType == 'text') {
                        ref.read(scorecardProvider.notifier).saveEntry(
                              metricId: metric.id,
                              valueText: note,
                              notes: note,
                            );
                      } else {
                        ref.read(scorecardProvider.notifier).saveEntry(
                              metricId: metric.id,
                              notes: note,
                            );
                      }
                      Navigator.pop(ctx);
                    },
                    child: const Text('Save Note', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(scorecardProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const primaryBlue = Color(0xFF1B59F8);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF10141D) : primaryBlue,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top Royal Blue Banner Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Scorecard & Cadence',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        state.scorecard?.periodLabel.isNotEmpty == true
                            ? state.scorecard!.periodLabel
                            : DateFormat('EEEE, MMM d, yyyy').format(state.targetDate),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(LucideIcons.history, color: Colors.white, size: 20),
                        tooltip: 'View History',
                        onPressed: _openHistory,
                      ),
                      IconButton(
                        icon: const Icon(LucideIcons.refreshCw, color: Colors.white, size: 20),
                        tooltip: 'Refresh',
                        onPressed: () => ref.read(scorecardProvider.notifier).loadScorecard(),
                      ),
                      IconButton(
                        icon: const Icon(LucideIcons.plus, color: Colors.white, size: 22),
                        tooltip: 'Add Metric',
                        onPressed: _openNewMetric,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Timeframe Selector Tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _timeframes.map((tf) {
                  final isSelected = state.timeframe == tf;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(_formatTimeframeLabel(tf)),
                      selected: isSelected,
                      selectedColor: Colors.white,
                      backgroundColor: Colors.white.withOpacity(0.15),
                      labelStyle: TextStyle(
                        color: isSelected ? primaryBlue : Colors.white,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 12,
                      ),
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      onSelected: (_) => ref.read(scorecardProvider.notifier).setTimeframe(tf),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),

            // Main Body Canvas Container (Rounded top corners)
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F131D) : const Color(0xFFF8F9FC),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: state.isLoading && state.scorecard == null
                    ? const Center(child: CircularProgressIndicator(color: primaryBlue))
                    : state.errorMessage != null && state.scorecard == null
                        ? _buildErrorView(state.errorMessage!, isDark)
                        : _buildScorecardBody(state, isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(String msg, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.alertTriangle, size: 40, color: Color(0xFFF04438)),
            const SizedBox(height: 12),
            Text(
              'Failed to load scorecard',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF101828),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              msg,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B59F8)),
              onPressed: () => ref.read(scorecardProvider.notifier).loadScorecard(),
              icon: const Icon(LucideIcons.refreshCw, size: 16, color: Colors.white),
              label: const Text('Try Again', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScorecardBody(ScorecardState state, bool isDark) {
    final sc = state.scorecard;
    final metrics = sc?.metrics ?? [];

    return RefreshIndicator(
      color: const Color(0xFF1B59F8),
      onRefresh: () => ref.read(scorecardProvider.notifier).loadScorecard(showLoading: false),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        children: [
          // Period Navigator & Working Day Badge Row
          _buildPeriodNavigatorRow(state, isDark),
          const SizedBox(height: 14),

          // Completion Summary Ring Card
          if (sc != null) _buildSummaryCard(sc, isDark),
          const SizedBox(height: 16),

          // 7-Day Performance History mini sparkline strip
          if (state.history.isNotEmpty) _buildHistoryStrip(state.history, isDark),
          const SizedBox(height: 16),

          // Section Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TARGET METRICS (${metrics.length})',
                style: AppTypography.overline(
                  color: isDark ? Colors.white54 : const Color(0xFF667085),
                ),
              ),
              if (sc != null)
                Text(
                  '${sc.achievedMetrics} / ${sc.totalMetrics} Done',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF12B76A),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Metrics List
          if (metrics.isEmpty)
            _buildEmptyState(isDark)
          else
            ...metrics.map((m) => _buildMetricCard(m, isDark)),
        ],
      ),
    );
  }

  Widget _buildPeriodNavigatorRow(ScorecardState state, bool isDark) {
    final sc = state.scorecard;
    final isWorkingDay = sc?.isWorkingDay ?? true;
    final isToday = DateFormat('yyyy-MM-dd').format(state.targetDate) ==
        DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Row(
      children: [
        // Prev button
        InkWell(
          onTap: () => ref.read(scorecardProvider.notifier).previousPeriod(),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C2436) : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isDark ? const Color(0xFF2B3752) : const Color(0xFFE4E7EC)),
            ),
            child: Icon(LucideIcons.chevronLeft, size: 18, color: isDark ? Colors.white70 : const Color(0xFF344054)),
          ),
        ),
        const SizedBox(width: 8),

        // Date Display & Picker
        Expanded(
          child: InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: state.targetDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (picked != null) {
                ref.read(scorecardProvider.notifier).setDate(picked);
              }
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1C2436) : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isDark ? const Color(0xFF2B3752) : const Color(0xFFE4E7EC)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.calendar, size: 14, color: Color(0xFF1B59F8)),
                  const SizedBox(width: 6),
                  Text(
                    DateFormat('MMM d, yyyy').format(state.targetDate),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF101828),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Next button
        InkWell(
          onTap: () => ref.read(scorecardProvider.notifier).nextPeriod(),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C2436) : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isDark ? const Color(0xFF2B3752) : const Color(0xFFE4E7EC)),
            ),
            child: Icon(LucideIcons.chevronRight, size: 18, color: isDark ? Colors.white70 : const Color(0xFF344054)),
          ),
        ),
        if (!isToday) ...[
          const SizedBox(width: 6),
          InkWell(
            onTap: () => ref.read(scorecardProvider.notifier).goToToday(),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF1B59F8).withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Today',
                style: TextStyle(color: Color(0xFF1B59F8), fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
        const SizedBox(width: 8),

        // Working Day Pill Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: isWorkingDay
                ? (isDark ? const Color(0xFF0D3322) : const Color(0xFFECFDF3))
                : (isDark ? const Color(0xFF37220F) : const Color(0xFFFEF0C7)),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isWorkingDay ? const Color(0xFF039855).withOpacity(0.3) : const Color(0xFFF79009).withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isWorkingDay ? const Color(0xFF12B76A) : const Color(0xFFF79009),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                isWorkingDay ? 'Working Day' : 'Non-Working',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isWorkingDay ? const Color(0xFF027A48) : const Color(0xFFB54708),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(ScorecardData sc, bool isDark) {
    final rate = sc.completionRate;
    final isHigh = rate >= 80;
    final isMed = rate >= 50 && rate < 80;
    final statusColor = isHigh
        ? const Color(0xFF12B76A)
        : isMed
            ? const Color(0xFFF79009)
            : const Color(0xFFF04438);

    final statusText = isHigh
        ? 'Excellent Execution'
        : isMed
            ? 'On Track / In Progress'
            : 'Behind Targets';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF182032) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF28344D) : const Color(0xFFE4E7EC),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Circular Progress Indicator
          SizedBox(
            width: 76,
            height: 76,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: (rate / 100).clamp(0.0, 1.0),
                  strokeWidth: 8,
                  backgroundColor: isDark ? Colors.white10 : const Color(0xFFF2F4F7),
                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                ),
                Text(
                  '$rate%',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : const Color(0xFF101828),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),

          // Metric Counts and status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${sc.achievedMetrics} of ${sc.totalMetrics} Targets Achieved',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF101828),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Scorecard updates automatically as CRM interactions and deals are logged.',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white60 : const Color(0xFF667085),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryStrip(List<HistoryDay> history, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161E2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF253147) : const Color(0xFFEAECF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '7-DAY CADENCE TREND',
                style: AppTypography.overline(color: isDark ? Colors.white54 : const Color(0xFF667085)),
              ),
              InkWell(
                onTap: _openHistory,
                child: const Text(
                  'Full History ›',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B59F8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: history.take(7).map((d) {
              final isHigh = d.completionRate >= 80;
              final isMed = d.completionRate >= 50 && d.completionRate < 80;
              final color = isHigh
                  ? const Color(0xFF12B76A)
                  : isMed
                      ? const Color(0xFFF79009)
                      : const Color(0xFFF04438);

              final height = (d.completionRate * 0.45).clamp(8.0, 45.0);

              return Column(
                children: [
                  Text(
                    '${d.completionRate}%',
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 24,
                    height: height,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    d.dayName.length > 3 ? d.dayName.substring(0, 3) : d.dayName,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: d.isToday ? FontWeight.bold : FontWeight.w500,
                      color: d.isToday
                          ? const Color(0xFF1B59F8)
                          : (isDark ? Colors.white60 : const Color(0xFF667085)),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(ScorecardMetricItem m, bool isDark) {
    final isAchieved = m.isAchieved;
    final progress = m.progressPercent.clamp(0, 100);

    final statusColor = isAchieved
        ? const Color(0xFF12B76A)
        : progress >= 50
            ? const Color(0xFFF79009)
            : const Color(0xFFF04438);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF182032) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAchieved
              ? const Color(0xFF12B76A).withOpacity(0.4)
              : isDark
                  ? const Color(0xFF28344D)
                  : const Color(0xFFE4E7EC),
          width: isAchieved ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Metric Top Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              m.title,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF101828),
                              ),
                            ),
                          ),
                          if (m.isAutoCrm) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1B59F8).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                '⚡ AUTO CRM',
                                style: TextStyle(
                                  color: Color(0xFF1B59F8),
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (m.description != null && m.description!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            m.description!,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? Colors.white60 : const Color(0xFF667085),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Achievement badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isAchieved ? LucideIcons.checkCircle : LucideIcons.circleDashed,
                        size: 13,
                        color: statusColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isAchieved ? 'Achieved' : '$progress%',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Values & Progress Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Current / Target text
                _buildValueText(m, isDark),
                // Quick note badge if note exists
                if (m.notes != null && m.notes!.isNotEmpty)
                  GestureDetector(
                    onTap: () => _openNoteDialog(m),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white10 : const Color(0xFFF2F4F7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Icon(LucideIcons.messageSquare, size: 11, color: isDark ? Colors.white60 : Colors.grey[600]),
                          const SizedBox(width: 4),
                          const Text('Note', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Progress Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (progress / 100).clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: isDark ? Colors.white10 : const Color(0xFFF2F4F7),
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Divider
          Divider(
            height: 1,
            color: isDark ? const Color(0xFF242E44) : const Color(0xFFF2F4F7),
          ),

          // Action Bar (Toggle, Stepper, Note, Details)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Primary interactive controls based on valueType
                if (m.valueType == 'boolean')
                  _buildBooleanActionButton(m, isDark)
                else if (m.valueType == 'number' || m.valueType == 'currency')
                  _buildNumericActionButtons(m, isDark)
                else
                  _buildTextActionButton(m, isDark),

                // Note & Options actions
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        m.notes != null && m.notes!.isNotEmpty ? LucideIcons.messageSquare : LucideIcons.fileText,
                        size: 16,
                        color: m.notes != null && m.notes!.isNotEmpty ? const Color(0xFF1B59F8) : (isDark ? Colors.white54 : Colors.grey[500]),
                      ),
                      tooltip: 'Add note',
                      onPressed: () => _openNoteDialog(m),
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(LucideIcons.moreVertical, size: 16, color: isDark ? Colors.white54 : Colors.grey[500]),
                      onSelected: (action) {
                        if (action == 'delete') {
                          _confirmDeleteMetric(m);
                        }
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(LucideIcons.trash2, size: 14, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete Metric', style: TextStyle(color: Colors.red, fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValueText(ScorecardMetricItem m, bool isDark) {
    if (m.valueType == 'boolean') {
      final isDone = m.valueBoolean ?? false;
      return Text(
        isDone ? 'Completed (Yes)' : 'Pending (No)',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: isDone ? const Color(0xFF12B76A) : (isDark ? Colors.white60 : Colors.grey[600]),
        ),
      );
    }

    if (m.valueType == 'text') {
      final hasText = m.valueText != null && m.valueText!.isNotEmpty;
      return Text(
        hasText ? 'Response Recorded' : 'Awaiting Entry',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: hasText ? const Color(0xFF12B76A) : (isDark ? Colors.white60 : Colors.grey[600]),
        ),
      );
    }

    final curr = m.valueNumber ?? (m.currentValue is num ? (m.currentValue as num).toDouble() : 0.0);
    final target = double.tryParse(m.targetValue ?? '0') ?? 0.0;
    final unit = m.unitLabel != null ? ' ${m.unitLabel}' : '';

    String formatVal(double v) => v % 1 == 0 ? v.toInt().toString() : v.toStringAsFixed(1);

    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: 13,
          color: isDark ? Colors.white : const Color(0xFF101828),
        ),
        children: [
          TextSpan(
            text: '${formatVal(curr)}$unit',
            style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF1B59F8)),
          ),
          const TextSpan(text: ' of '),
          TextSpan(
            text: '${formatVal(target)}$unit target',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white60 : const Color(0xFF667085),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBooleanActionButton(ScorecardMetricItem m, bool isDark) {
    final isDone = m.valueBoolean ?? false;
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: isDone ? const Color(0xFF12B76A) : (isDark ? const Color(0xFF253147) : const Color(0xFFF2F4F7)),
        foregroundColor: isDone ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF344054)),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: () => ref.read(scorecardProvider.notifier).toggleBoolean(m),
      icon: Icon(isDone ? LucideIcons.check : LucideIcons.circle, size: 14),
      label: Text(
        isDone ? 'Achieved ✓' : 'Mark Achieved',
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildNumericActionButtons(ScorecardMetricItem m, bool isDark) {
    if (m.isAutoCrm) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? Colors.white10 : const Color(0xFFF2F4F7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Live Tracking Active',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white60 : const Color(0xFF667085),
          ),
        ),
      );
    }

    return Row(
      children: [
        // Decrement button
        IconButton(
          icon: const Icon(LucideIcons.minus, size: 16),
          style: IconButton.styleFrom(
            backgroundColor: isDark ? const Color(0xFF253147) : const Color(0xFFF2F4F7),
            padding: const EdgeInsets.all(6),
          ),
          onPressed: () => ref.read(scorecardProvider.notifier).stepNumber(m, -1),
        ),
        const SizedBox(width: 6),

        // Quick input button (tap to open keypad dialog)
        InkWell(
          onTap: () => _openValueInputDialog(m),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF1B59F8).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF1B59F8).withOpacity(0.3)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.edit2, size: 12, color: Color(0xFF1B59F8)),
                SizedBox(width: 4),
                Text(
                  'Set Value',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B59F8),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 6),

        // Increment button
        IconButton(
          icon: const Icon(LucideIcons.plus, size: 16),
          style: IconButton.styleFrom(
            backgroundColor: isDark ? const Color(0xFF253147) : const Color(0xFFF2F4F7),
            padding: const EdgeInsets.all(6),
          ),
          onPressed: () => ref.read(scorecardProvider.notifier).stepNumber(m, 1),
        ),
      ],
    );
  }

  Widget _buildTextActionButton(ScorecardMetricItem m, bool isDark) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1B59F8),
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: () => _openNoteDialog(m),
      icon: const Icon(LucideIcons.penTool, size: 13),
      label: const Text('Record Update', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  void _confirmDeleteMetric(ScorecardMetricItem m) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Metric?'),
        content: Text('Are you sure you want to remove "${m.title}" from this company\'s scorecard?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(scorecardProvider.notifier).deleteMetric(m.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF182032) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? const Color(0xFF28344D) : const Color(0xFFE4E7EC)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1B59F8).withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.target, size: 32, color: Color(0xFF1B59F8)),
          ),
          const SizedBox(height: 16),
          Text(
            'No cadence metrics for this timeframe',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF101828),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Set up daily or weekly KPI goals to track team operating cadence and sales velocity.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white60 : const Color(0xFF667085),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B59F8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: _openNewMetric,
            icon: const Icon(LucideIcons.plus, size: 16, color: Colors.white),
            label: const Text('Create First Metric', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
