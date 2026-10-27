import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/sync/sync_provider.dart';
import '../data/tasks_repository.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_typography.dart';
import '../../../shared/components/app_card.dart';
import '../../../shared/components/app_chip.dart';
import '../../../shared/components/app_button.dart';
import '../../../shared/components/app_text_field.dart';
import '../../../shared/components/empty_state.dart';
import '../../../shared/components/app_shimmer.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  String _selectedPriorityFilter = 'All';

  void _openTaskForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _TaskFormSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(databaseProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Action Tasks & Reminders',
          style: AppTypography.h3(
            color: isDark ? Colors.white : AppColors.grey900,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_task_rounded, color: AppColors.primary),
            onPressed: _openTaskForm,
          ),
        ],
      ),
      body: Column(
        children: [
          // Priority Filter Chips Bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: ['All', 'Urgent', 'High', 'Medium', 'Low'].map((p) {
                final isSelected = _selectedPriorityFilter == p;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(p),
                    selected: isSelected,
                    selectedColor: AppColors.primaryLighter,
                    checkmarkColor: AppColors.primaryDark,
                    onSelected: (selected) =>
                        setState(() => _selectedPriorityFilter = p),
                  ),
                );
              }).toList(),
            ),
          ),

          // Reactive Task Stream from Drift SQLite DB
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await ref.read(syncProvider.notifier).pullAllInitialData();
              },
              child: StreamBuilder(
                stream: db.select(db.tasksTable).watch(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return AppShimmer.cardListShimmer(isDark: isDark);
                  }

                  final tasks = snapshot.data ?? [];
                  final filtered = tasks.where((t) {
                    if (_selectedPriorityFilter == 'All') return true;
                    return t.priority.toLowerCase() ==
                        _selectedPriorityFilter.toLowerCase();
                  }).toList();

                  if (filtered.isEmpty) {
                    return EmptyState(
                      icon: Icons.task_alt_rounded,
                      title: 'No Tasks Found',
                      description:
                          'Schedule follow-up tasks, client reminders, and team action items.',
                      actionLabel: '+ Add Task',
                      onAction: _openTaskForm,
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final task = filtered[index];
                      final isCompleted = task.status == 'completed';

                      Color priorityColor;
                      switch (task.priority.toLowerCase()) {
                        case 'urgent':
                          priorityColor = AppColors.error;
                          break;
                        case 'high':
                          priorityColor = AppColors.warning;
                          break;
                        case 'medium':
                          priorityColor = AppColors.primary;
                          break;
                        default:
                          priorityColor = AppColors.grey500;
                      }

                      return AppCard(
                        child: Row(
                          children: [
                            Checkbox(
                              value: isCompleted,
                              activeColor: AppColors.primary,
                              onChanged: (val) async {
                                final newStatus = (val ?? false)
                                    ? 'completed'
                                    : 'pending';
                                await ref
                                    .read(tasksRepositoryProvider)
                                    .updateStatus(task, newStatus);
                              },
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task.title,
                                    style:
                                        AppTypography.subtitle2(
                                          color: isDark
                                              ? Colors.white
                                              : AppColors.grey900,
                                        ).copyWith(
                                          decoration: isCompleted
                                              ? TextDecoration.lineThrough
                                              : null,
                                        ),
                                  ),
                                  if (task.description != null &&
                                      task.description!.isNotEmpty)
                                    Text(
                                      task.description!,
                                      style: AppTypography.caption(
                                        color: AppColors.grey500,
                                      ),
                                    ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      AppChip(
                                        label: task.priority.toUpperCase(),
                                        color: priorityColor.withOpacity(0.15),
                                        textColor: priorityColor,
                                      ),
                                      const SizedBox(width: 8),
                                      if (task.dueDate != null) ...[
                                        const Icon(
                                          Icons.alarm_rounded,
                                          size: 14,
                                          color: AppColors.primary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          task.dueDate!.toString().substring(
                                            0,
                                            16,
                                          ),
                                          style:
                                              AppTypography.caption(
                                                color: AppColors.primary,
                                              ).copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ],
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
        heroTag: 'tasks_fab',
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_task_rounded, color: Colors.white),
        label: Text('New Task', style: AppTypography.button()),
        onPressed: _openTaskForm,
      ),
    );
  }
}

class _TaskFormSheet extends ConsumerStatefulWidget {
  const _TaskFormSheet();

  @override
  ConsumerState<_TaskFormSheet> createState() => _TaskFormSheetState();
}

class _TaskFormSheetState extends ConsumerState<_TaskFormSheet> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _priority = 'medium';
  DateTime? _dueDate;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _saveTask() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;

    final repo = ref.read(tasksRepositoryProvider);
    await repo.createReminder(
      title: title,
      description: _descCtrl.text.trim().isNotEmpty ? _descCtrl.text.trim() : null,
      priority: _priority,
      dueDate: _dueDate,
      type: 'call',
    );

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
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
                'New Action Task',
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
                  AppTextField(
                    label: 'Task Title *',
                    controller: _titleCtrl,
                    hint: 'e.g. Prepare revised quotation',
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'Description',
                    controller: _descCtrl,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _priority,
                    decoration: const InputDecoration(
                      labelText: 'Priority Level',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'low',
                        child: Text('Low Priority'),
                      ),
                      DropdownMenuItem(
                        value: 'medium',
                        child: Text('Medium Priority'),
                      ),
                      DropdownMenuItem(
                        value: 'high',
                        child: Text('High Priority'),
                      ),
                      DropdownMenuItem(
                        value: 'urgent',
                        child: Text('Urgent Priority'),
                      ),
                    ],
                    onChanged: (val) => setState(() => _priority = val!),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.borderLight,
                      ),
                    ),
                    leading: const Icon(
                      Icons.alarm_add_rounded,
                      color: AppColors.primary,
                    ),
                    title: Text(
                      _dueDate != null
                          ? 'Due: ${_dueDate!.toString().substring(0, 16)}'
                          : 'Set Offline Alarm / Due Date',
                      style: AppTypography.subtitle2(
                        color: isDark ? Colors.white : AppColors.grey900,
                      ),
                    ),
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (pickedDate != null && mounted) {
                        final pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (pickedTime != null) {
                          setState(() {
                            _dueDate = DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                              pickedTime.hour,
                              pickedTime.minute,
                            );
                          });
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    label: 'Save Task & Schedule Reminder',
                    width: double.infinity,
                    onPressed: _saveTask,
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
