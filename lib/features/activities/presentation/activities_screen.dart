import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../../core/sync/sync_provider.dart';
import '../../../core/database/app_database.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_typography.dart';
import '../../../shared/components/app_card.dart';
import '../../../shared/components/app_chip.dart';
import '../../../shared/components/app_button.dart';
import '../../../shared/components/app_text_field.dart';
import '../../../shared/components/empty_state.dart';
import '../../../shared/components/app_shimmer.dart';

class ActivitiesScreen extends ConsumerStatefulWidget {
  const ActivitiesScreen({super.key});

  @override
  ConsumerState<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends ConsumerState<ActivitiesScreen> {
  String _viewMode = 'Timeline'; // Timeline, Board, Calendar

  void _openActivityForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ActivityFormSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(databaseProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Activity Log',
          style: AppTypography.h3(
            color: isDark ? Colors.white : AppColors.grey900,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_call, color: AppColors.primary),
            onPressed: _openActivityForm,
          ),
        ],
      ),
      body: Column(
        children: [
          // View Mode Selector Segmented Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: isDark ? AppColors.darkCard : AppColors.grey200,
            child: Row(
              children: ['Timeline', 'Board View', 'Calendar View'].map((mode) {
                final isSelected = _viewMode == mode;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _viewMode = mode),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark ? AppColors.darkCanvas : Colors.white)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                ),
                              ]
                            : [],
                      ),
                      child: Text(
                        mode,
                        style:
                            AppTypography.caption(
                              color: isSelected
                                  ? AppColors.primary
                                  : (isDark
                                        ? AppColors.grey400
                                        : AppColors.grey600),
                            ).copyWith(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Reactive Activity Stream from Drift DB
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await ref.read(syncProvider.notifier).pullAllInitialData();
              },
              child: StreamBuilder(
                stream: db.select(db.activitiesTable).watch(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return AppShimmer.cardListShimmer(isDark: isDark);
                  }

                  final activities = snapshot.data ?? [];
                  if (activities.isEmpty) {
                    return EmptyState(
                      icon: Icons.phone_callback_rounded,
                      title: 'No Activities Logged',
                      description:
                          'Log customer touchpoints, calls, meetings, WhatsApp notes, and emails.',
                      actionLabel: '+ Log Activity',
                      onAction: _openActivityForm,
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: activities.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final act = activities[index];
                      final isCall = act.type == 'call';
                      final isMeeting = act.type == 'meeting';

                      final icon = isCall
                          ? Icons.phone_in_talk_rounded
                          : isMeeting
                          ? Icons.groups_rounded
                          : Icons.note_alt_rounded;

                      final iconColor = isCall
                          ? AppColors.info
                          : isMeeting
                          ? AppColors.primary
                          : AppColors.warning;

                      return AppCard(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: iconColor.withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(icon, color: iconColor, size: 20),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        act.subject ?? act.type.toUpperCase(),
                                        style: AppTypography.subtitle2(
                                          color: isDark
                                              ? Colors.white
                                              : AppColors.grey900,
                                        ),
                                      ),
                                      AppChip(
                                        label: act.direction.toUpperCase(),
                                        color: act.direction == 'inbound'
                                            ? AppColors.successLighter
                                            : AppColors.primaryLighter,
                                        textColor: act.direction == 'inbound'
                                            ? AppColors.success
                                            : AppColors.primaryDark,
                                      ),
                                    ],
                                  ),
                                  if (act.description != null &&
                                      act.description!.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      act.description!,
                                      style: AppTypography.caption(
                                        color: AppColors.grey500,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.timer_outlined,
                                        size: 14,
                                        color: AppColors.grey500,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${act.duration} mins',
                                        style: AppTypography.caption(
                                          color: AppColors.grey500,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Icon(
                                        Icons.event_outlined,
                                        size: 14,
                                        color: AppColors.grey500,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        act.completedAt != null
                                            ? act.completedAt!
                                                  .toString()
                                                  .substring(0, 16)
                                            : 'Scheduled',
                                        style: AppTypography.caption(
                                          color: AppColors.grey500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('Log Activity', style: AppTypography.button()),
        onPressed: _openActivityForm,
      ),
    );
  }
}

class _ActivityFormSheet extends ConsumerStatefulWidget {
  const _ActivityFormSheet();

  @override
  ConsumerState<_ActivityFormSheet> createState() => _ActivityFormSheetState();
}

class _ActivityFormSheetState extends ConsumerState<_ActivityFormSheet> {
  String _type = 'call';
  String _direction = 'outbound';
  final _subjectCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _durationCtrl = TextEditingController(text: '15');
  final _outcomeCtrl = TextEditingController();

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _descriptionCtrl.dispose();
    _durationCtrl.dispose();
    _outcomeCtrl.dispose();
    super.dispose();
  }

  bool _requiresFollowUp = false;
  int _followUpDays = 2;
  int? _selectedContactId;

  void _saveActivity() async {
    final subject = _subjectCtrl.text.trim();
    if (subject.isEmpty) return;

    final db = ref.read(databaseProvider);
    final duration = int.tryParse(_durationCtrl.text.trim()) ?? 15;

    final entry = ActivitiesTableCompanion.insert(
      type: _type,
      subject: drift.Value(subject),
      description: drift.Value(_descriptionCtrl.text.trim()),
      direction: drift.Value(_direction),
      duration: drift.Value(duration),
      outcome: drift.Value(_outcomeCtrl.text.trim()),
      contactLocalId: drift.Value(_selectedContactId),
      completedAt: drift.Value(DateTime.now()),
      isCompleted: const drift.Value(true),
      localUpdatedAt: DateTime.now(),
    );

    final localId = await db.into(db.activitiesTable).insert(entry);

    // If follow-up task requested, insert into tasksTable
    if (_requiresFollowUp) {
      final dueDate = DateTime.now().add(Duration(days: _followUpDays));
      await db
          .into(db.tasksTable)
          .insert(
            TasksTableCompanion.insert(
              title: 'Follow-up: $subject',
              description: drift.Value('Follow up for logged $_type: $subject'),
              contactLocalId: drift.Value(_selectedContactId),
              dueDate: drift.Value(dueDate),
              priority: const drift.Value('medium'),
              status: const drift.Value('pending'),
              localUpdatedAt: DateTime.now(),
            ),
          );
    }

    // Queue sync
    await db
        .into(db.syncQueueTable)
        .insert(
          SyncQueueTableCompanion.insert(
            entityType: 'activity',
            entityLocalId: localId,
            operation: 'create',
            payloadJson: '{"type": "$_type", "subject": "$subject"}',
            createdAt: DateTime.now(),
          ),
        );

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final db = ref.watch(databaseProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Log New Activity',
                style: AppTypography.h3(
                  color: isDark ? Colors.white : AppColors.grey900,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  // Contact Selector Stream
                  StreamBuilder<List<ContactEntry>>(
                    stream: db.select(db.contactsTable).watch(),
                    builder: (context, snapshot) {
                      final contacts = snapshot.data ?? [];
                      return DropdownButtonFormField<int?>(
                        value: _selectedContactId,
                        decoration: const InputDecoration(
                          labelText: 'Linked Contact / Lead',
                          prefixIcon: Icon(Icons.person_outline_rounded),
                        ),
                        items: [
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Text('— Unassigned Contact —'),
                          ),
                          ...contacts.map((c) {
                            final name = '${c.firstName} ${c.lastName ?? ''}'
                                .trim();
                            return DropdownMenuItem<int?>(
                              value: c.localId,
                              child: Text(
                                name.isNotEmpty
                                    ? name
                                    : (c.company ?? 'Contact #${c.localId}'),
                              ),
                            );
                          }),
                        ],
                        onChanged: (val) =>
                            setState(() => _selectedContactId = val),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _type,
                    decoration: const InputDecoration(
                      labelText: 'Activity Type',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'call',
                        child: Text('Phone Call'),
                      ),
                      DropdownMenuItem(
                        value: 'whatsapp',
                        child: Text('WhatsApp Note'),
                      ),
                      DropdownMenuItem(
                        value: 'meeting',
                        child: Text('Meeting'),
                      ),
                      DropdownMenuItem(value: 'email', child: Text('Email')),
                      DropdownMenuItem(value: 'sms', child: Text('SMS')),
                      DropdownMenuItem(value: 'note', child: Text('Note')),
                      DropdownMenuItem(
                        value: 'face_to_face',
                        child: Text('Face to Face'),
                      ),
                      DropdownMenuItem(value: 'demo', child: Text('Demo')),
                    ],
                    onChanged: (val) => setState(() => _type = val!),
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'Subject / Title *',
                    controller: _subjectCtrl,
                    hint: 'e.g. Discussed pricing quotation',
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'Description',
                    controller: _descriptionCtrl,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _direction,
                          decoration: const InputDecoration(
                            labelText: 'Direction',
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'outbound',
                              child: Text('Outbound'),
                            ),
                            DropdownMenuItem(
                              value: 'inbound',
                              child: Text('Inbound'),
                            ),
                          ],
                          onChanged: (val) => setState(() => _direction = val!),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppTextField(
                          label: 'Duration (mins)',
                          controller: _durationCtrl,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'Outcome / Notes',
                    controller: _outcomeCtrl,
                  ),
                  const SizedBox(height: 16),

                  // Follow-up Task Toggle Box
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCanvas : AppColors.grey100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.grey300,
                      ),
                    ),
                    child: Column(
                      children: [
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text(
                            'Schedule Follow-up Task',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          subtitle: const Text(
                            'Creates a task in action list',
                            style: TextStyle(fontSize: 11),
                          ),
                          value: _requiresFollowUp,
                          onChanged: (val) =>
                              setState(() => _requiresFollowUp = val ?? false),
                        ),
                        if (_requiresFollowUp) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [2, 3, 7, 10].map((days) {
                              final isSelected = _followUpDays == days;
                              return ChoiceChip(
                                label: Text(
                                  'In $days Days',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.grey800,
                                  ),
                                ),
                                selected: isSelected,
                                selectedColor: AppColors.primary,
                                onSelected: (_) =>
                                    setState(() => _followUpDays = days),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  AppButton(
                    label: 'Save Activity',
                    width: double.infinity,
                    onPressed: _saveActivity,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
