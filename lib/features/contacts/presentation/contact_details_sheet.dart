import '../../../core/auth/auth_provider.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:drift/drift.dart' hide Column;
import '../../../core/sync/sync_provider.dart';
import '../../../core/database/app_database.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_typography.dart';
import '../../../shared/components/unified_form.dart';

class ContactDetailsSheet extends ConsumerStatefulWidget {
  final ContactEntry contact;
  final VoidCallback? onEdit;

  const ContactDetailsSheet({
    super.key,
    required this.contact,
    this.onEdit,
  });

  static void show(BuildContext context, {required ContactEntry contact, VoidCallback? onEdit}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ContactDetailsSheet(contact: contact, onEdit: onEdit),
    );
  }

  @override
  ConsumerState<ContactDetailsSheet> createState() => _ContactDetailsSheetState();
}

class _ContactDetailsSheetState extends ConsumerState<ContactDetailsSheet> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _callPhone(String? phone) {
    if (phone != null && phone.trim().isNotEmpty) {
      launchUrl(Uri.parse('tel:${phone.trim()}'));
    } else {
      _showSnack('No phone number recorded');
    }
  }

  void _sendWhatsApp(String? phone) {
    if (phone != null && phone.trim().isNotEmpty) {
      final clean = phone.replaceAll(RegExp(r'[^0-9]'), '');
      launchUrl(Uri.parse('https://wa.me/$clean'), mode: LaunchMode.externalApplication);
    } else {
      _showSnack('No phone number recorded');
    }
  }

  void _sendEmail(String? email) {
    if (email != null && email.trim().isNotEmpty) {
      launchUrl(Uri.parse('mailto:${email.trim()}'));
    } else {
      _showSnack('No email address recorded');
    }
  }

  void _openWebsite(String? url) {
    if (url != null && url.trim().isNotEmpty) {
      var uriStr = url.trim();
      if (!uriStr.startsWith('http://') && !uriStr.startsWith('https://')) {
        uriStr = 'https://$uriStr';
      }
      launchUrl(Uri.parse(uriStr), mode: LaunchMode.externalApplication);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _deleteContact() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Contact?'),
        content: Text('Are you sure you want to delete ${widget.contact.firstName}? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final db = ref.read(databaseProvider);
    final apiClient = ref.read(apiClientProvider);

    // 1. Delete locally
    await (db.delete(db.contactsTable)..where((t) => t.localId.equals(widget.contact.localId))).go();

    // 2. Delete on server if serverId exists
    if (widget.contact.serverId != null && widget.contact.serverId!.isNotEmpty) {
      try {
        await apiClient.dio.delete('/contacts/${widget.contact.serverId}');
      } catch (_) {}
    }

    if (mounted) {
      Navigator.pop(context);
      _showSnack('Contact deleted successfully');
    }
  }

  void _showLogActivityDialog() {
    final c = widget.contact;
    String type = 'call';
    final subjectCtrl = TextEditingController(text: 'Touchpoint with ${c.firstName}');
    final notesCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => UnifiedFormSheet(
          title: 'Log Interaction',
          subtitle: 'Record call, meeting, or message with ${c.firstName}',
          submitLabel: 'Save Activity',
          onSubmit: () async {
            final db = ref.read(databaseProvider);
            await db.into(db.activitiesTable).insert(
                  ActivitiesTableCompanion.insert(
                    contactLocalId: Value(c.localId),
                    type: type,
                    subject: Value(subjectCtrl.text.trim()),
                    description: Value(notesCtrl.text.trim()),
                    direction: const Value('outbound'),
                    completedAt: Value(DateTime.now()),
                    localUpdatedAt: DateTime.now(),
                  ),
                );
            if (mounted) {
              Navigator.pop(ctx);
              _showSnack('Interaction logged');
            }
          },
          child: Column(
            children: [
              UnifiedDropdownField<String>(
                label: 'Interaction Type',
                value: type,
                items: const [
                  DropdownMenuItem(value: 'call', child: Text('Phone Call')),
                  DropdownMenuItem(value: 'whatsapp', child: Text('WhatsApp Message')),
                  DropdownMenuItem(value: 'meeting', child: Text('Meeting / Demo')),
                  DropdownMenuItem(value: 'email', child: Text('Email Sent')),
                  DropdownMenuItem(value: 'note', child: Text('Internal Note')),
                ],
                onChanged: (val) {
                  if (val != null) setSheetState(() => type = val);
                },
              ),
              UnifiedTextField(label: 'Subject *', controller: subjectCtrl, hint: 'e.g. Discovery Call'),
              UnifiedTextField(label: 'Outcome / Notes', controller: notesCtrl, hint: 'Details discussed...', maxLines: 3),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddTaskDialog() {
    final c = widget.contact;
    final titleCtrl = TextEditingController(text: 'Follow up with ${c.firstName}');
    final descCtrl = TextEditingController();
    String priority = 'medium';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => UnifiedFormSheet(
          title: 'Schedule Follow-up Task',
          subtitle: 'Create a task linked to ${c.firstName}',
          submitLabel: 'Create Task',
          onSubmit: () async {
            final db = ref.read(databaseProvider);
            await db.into(db.tasksTable).insert(
                  TasksTableCompanion.insert(
                    contactLocalId: Value(c.localId),
                    title: titleCtrl.text.trim(),
                    description: Value(descCtrl.text.trim()),
                    dueDate: Value(DateTime.now().add(const Duration(days: 3))),
                    priority: Value(priority),
                    status: const Value('pending'),
                    localUpdatedAt: DateTime.now(),
                  ),
                );
            if (mounted) {
              Navigator.pop(ctx);
              _showSnack('Task scheduled');
            }
          },
          child: Column(
            children: [
              UnifiedTextField(label: 'Task Title *', controller: titleCtrl, hint: 'e.g. Follow up on proposal'),
              UnifiedDropdownField<String>(
                label: 'Priority',
                value: priority,
                items: const [
                  DropdownMenuItem(value: 'low', child: Text('Low')),
                  DropdownMenuItem(value: 'medium', child: Text('Medium')),
                  DropdownMenuItem(value: 'high', child: Text('High')),
                  DropdownMenuItem(value: 'urgent', child: Text('Urgent')),
                ],
                onChanged: (val) {
                  if (val != null) setSheetState(() => priority = val);
                },
              ),
              UnifiedTextField(label: 'Task Description', controller: descCtrl, hint: 'Instructions or agenda...', maxLines: 2),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddDealDialog() {
    final c = widget.contact;
    final titleCtrl = TextEditingController(text: 'Deal with ${c.firstName}');
    final amountCtrl = TextEditingController(text: '1000');
    String stage = 'Qualification';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => UnifiedFormSheet(
          title: 'Create Pipeline Deal',
          subtitle: 'Associate an opportunity with ${c.firstName}',
          submitLabel: 'Create Deal',
          onSubmit: () async {
            final db = ref.read(databaseProvider);
            final amount = double.tryParse(amountCtrl.text.trim()) ?? 0.0;
            await db.into(db.dealsTable).insert(
                  DealsTableCompanion.insert(
                    contactLocalId: Value(c.localId),
                    title: titleCtrl.text.trim(),
                    stageName: Value(stage),
                    amount: Value(amount),
                    status: const Value('open'),
                    localUpdatedAt: DateTime.now(),
                  ),
                );
            if (mounted) {
              Navigator.pop(ctx);
              _showSnack('Deal created');
            }
          },
          child: Column(
            children: [
              UnifiedTextField(label: 'Deal Title *', controller: titleCtrl, hint: 'e.g. Enterprise License'),
              UnifiedTextField(label: 'Deal Value (\$)', controller: amountCtrl, hint: '1000', keyboardType: TextInputType.number),
              UnifiedDropdownField<String>(
                label: 'Pipeline Stage',
                value: stage,
                items: const [
                  DropdownMenuItem(value: 'Lead In / Qualification', child: Text('Lead In / Qualification')),
                  DropdownMenuItem(value: 'Contacted / Meeting', child: Text('Contacted / Meeting')),
                  DropdownMenuItem(value: 'Proposal Sent', child: Text('Proposal Sent')),
                  DropdownMenuItem(value: 'Negotiation', child: Text('Negotiation')),
                  DropdownMenuItem(value: 'Closed Won', child: Text('Closed Won')),
                  DropdownMenuItem(value: 'Closed Lost', child: Text('Closed Lost')),
                ],
                onChanged: (val) {
                  if (val != null) setSheetState(() => stage = val);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(databaseProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = widget.contact;

    final nameParts = [c.firstName, c.middleName, c.lastName].where((p) => p != null && p.trim().isNotEmpty).join(' ').trim();
    final displayName = nameParts.isNotEmpty ? nameParts : (c.company ?? 'Unnamed Contact');
    final initial = displayName.isNotEmpty ? displayName.substring(0, 1).toUpperCase() : 'C';

    Map<String, dynamic> customFields = {};
    if (c.customFieldsJson != null && c.customFieldsJson!.isNotEmpty) {
      try {
        final decoded = jsonDecode(c.customFieldsJson!);
        if (decoded is Map<String, dynamic>) customFields = decoded;
      } catch (_) {}
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141A28) : Colors.white,
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

          // Header Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: const Color(0xFF1B59F8).withOpacity(0.12),
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: Color(0xFF1B59F8),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              displayName,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF101828),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          if (c.isCustomer)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF12B76A).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'CUSTOMER',
                                style: TextStyle(color: Color(0xFF12B76A), fontSize: 9, fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${c.title ?? 'Contact'} • ${c.company ?? 'Individual'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white60 : const Color(0xFF667085),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.x, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Quick Action Buttons Row (Call, WhatsApp, Email, Edit, Delete)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  icon: LucideIcons.phone,
                  label: 'Call',
                  color: const Color(0xFF1B59F8),
                  onTap: () => _callPhone(c.phone),
                  isDark: isDark,
                ),
                _buildActionButton(
                  icon: LucideIcons.messageSquare,
                  label: 'WhatsApp',
                  color: const Color(0xFF12B76A),
                  onTap: () => _sendWhatsApp(c.phone),
                  isDark: isDark,
                ),
                _buildActionButton(
                  icon: LucideIcons.mail,
                  label: 'Email',
                  color: const Color(0xFF7A5AF8),
                  onTap: () => _sendEmail(c.email),
                  isDark: isDark,
                ),
                _buildActionButton(
                  icon: LucideIcons.edit2,
                  label: 'Edit',
                  color: const Color(0xFFF79009),
                  onTap: () {
                    Navigator.pop(context);
                    if (widget.onEdit != null) widget.onEdit!();
                  },
                  isDark: isDark,
                ),
                _buildActionButton(
                  icon: LucideIcons.trash2,
                  label: 'Delete',
                  color: const Color(0xFFF04438),
                  onTap: _deleteContact,
                  isDark: isDark,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Computed Deal Metrics Banner
          StreamBuilder<List<DealEntry>>(
            stream: (db.select(db.dealsTable)..where((tbl) => tbl.contactLocalId.equals(c.localId))).watch(),
            builder: (context, snapshot) {
              final deals = snapshot.data ?? [];
              final wonDeals = deals.where((d) => d.status == 'won').fold<double>(0, (sum, d) => sum + d.amount);
              final pipelineValue = deals.where((d) => d.status == 'open').fold<double>(0, (sum, d) => sum + d.amount);
              final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1B2336) : const Color(0xFFF8F9FC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isDark ? const Color(0xFF28344D) : const Color(0xFFE4E7EC)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _metricCol('Won Value', fmt.format(wonDeals), const Color(0xFF12B76A)),
                    _metricCol('Pipeline Value', fmt.format(pipelineValue), const Color(0xFF1B59F8)),
                    _metricCol('Lead Score', '${c.leadScore} pts', const Color(0xFFF79009)),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 10),

          // Navigation Tabs
          TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF1B59F8),
            unselectedLabelColor: isDark ? Colors.white54 : const Color(0xFF667085),
            indicatorColor: const Color(0xFF1B59F8),
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            tabs: const [
              Tab(text: 'Details'),
              Tab(text: 'Activities'),
              Tab(text: 'Tasks'),
              Tab(text: 'Deals'),
            ],
          ),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Detailed Specifications & Custom Attributes
                _buildDetailsTab(c, isDark, customFields),

                // Tab 2: Activities Stream with Add Button
                _buildActivitiesTab(db, c, isDark),

                // Tab 3: Tasks Stream with Add Button & Toggle
                _buildTasksTab(db, c, isDark),

                // Tab 4: Deals Stream with Add Button
                _buildDealsTab(db, c, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsTab(ContactEntry c, bool isDark, Map<String, dynamic> customFields) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Specifications Card
        _buildSectionCard(
          title: 'BASIC & SPECIFICATIONS',
          icon: LucideIcons.user,
          isDark: isDark,
          children: [
            _specRow('First Name', c.firstName),
            if (c.middleName != null && c.middleName!.isNotEmpty) _specRow('Middle Name', c.middleName!),
            if (c.lastName != null && c.lastName!.isNotEmpty) _specRow('Last Name', c.lastName!),
            _specRow('Email', c.email ?? '—'),
            _specRow('Phone', c.phone ?? '—'),
            if (c.alternatePhone != null && c.alternatePhone!.isNotEmpty) _specRow('Alt. Phone', c.alternatePhone!),
            if (c.tin != null && c.tin!.isNotEmpty) _specRow('TIN Number', c.tin!),
            if (c.vrn != null && c.vrn!.isNotEmpty) _specRow('VRN Number', c.vrn!),
          ],
        ),
        const SizedBox(height: 14),

        // Company & Sales Funnel Card
        _buildSectionCard(
          title: 'SALES & STATUS',
          icon: LucideIcons.briefcase,
          isDark: isDark,
          children: [
            _specRow('Company', c.company ?? '—'),
            _specRow('Job Title', c.title ?? '—'),
            _specRow('Lead Status', c.leadStatus ?? 'New'),
            _specRow('Lead Score', '${c.leadScore} pts'),
            if (c.infoSource != null && c.infoSource!.isNotEmpty) _specRow('Info Source', c.infoSource!),
            if (c.lifecycleStageId != null && c.lifecycleStageId!.isNotEmpty) _specRow('Lifecycle Stage', c.lifecycleStageId!),
            _specRow('Customer Type', c.isCustomer ? 'Paying Customer' : 'Sales Prospect / Lead'),
          ],
        ),
        const SizedBox(height: 14),

        // Address & Location Card
        if ((c.address != null && c.address!.isNotEmpty) ||
            (c.city != null && c.city!.isNotEmpty) ||
            (c.country != null && c.country!.isNotEmpty))
          _buildSectionCard(
            title: 'LOCATION & ADDRESS',
            icon: LucideIcons.mapPin,
            isDark: isDark,
            children: [
              if (c.address != null && c.address!.isNotEmpty) _specRow('Address', c.address!),
              if (c.city != null && c.city!.isNotEmpty) _specRow('City', c.city!),
              if (c.state != null && c.state!.isNotEmpty) _specRow('State/Region', c.state!),
              if (c.country != null && c.country!.isNotEmpty) _specRow('Country', c.country!),
              if (c.postalCode != null && c.postalCode!.isNotEmpty) _specRow('Postal Code', c.postalCode!),
            ],
          ),

        // Web & Social
        if (c.website != null && c.website!.isNotEmpty) ...[
          const SizedBox(height: 14),
          _buildSectionCard(
            title: 'ONLINE & LINKS',
            icon: LucideIcons.globe,
            isDark: isDark,
            children: [
              InkWell(
                onTap: () => _openWebsite(c.website),
                child: _specRow('Website', c.website!, isLink: true),
              ),
            ],
          ),
        ],

        // Custom Attributes Card
        if (customFields.isNotEmpty) ...[
          const SizedBox(height: 14),
          _buildSectionCard(
            title: 'CUSTOM ATTRIBUTES',
            icon: LucideIcons.tag,
            isDark: isDark,
            children: customFields.entries.map((e) => _specRow(e.key, e.value?.toString() ?? '—')).toList(),
          ),
        ],

        // Notes Card
        if (c.notes != null && c.notes!.isNotEmpty) ...[
          const SizedBox(height: 14),
          _buildSectionCard(
            title: 'NOTES & DESCRIPTION',
            icon: LucideIcons.fileText,
            isDark: isDark,
            children: [
              Text(
                c.notes!,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white70 : const Color(0xFF344054),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildActivitiesTab(AppDatabase db, ContactEntry c, bool isDark) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Interactions Logged', style: AppTypography.subtitle2(color: isDark ? Colors.white : AppColors.grey900)),
              TextButton.icon(
                onPressed: _showLogActivityDialog,
                icon: const Icon(LucideIcons.plus, size: 14),
                label: const Text('Log Interaction', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<List<ActivityEntry>>(
            stream: (db.select(db.activitiesTable)..where((tbl) => tbl.contactLocalId.equals(c.localId))).watch(),
            builder: (context, snapshot) {
              final activities = snapshot.data ?? [];
              if (activities.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(LucideIcons.messageSquare, size: 36, color: Colors.grey),
                      const SizedBox(height: 8),
                      Text('No interactions recorded yet', style: TextStyle(color: isDark ? Colors.white60 : Colors.grey[600])),
                      const SizedBox(height: 8),
                      OutlinedButton(onPressed: _showLogActivityDialog, child: const Text('Log First Interaction')),
                    ],
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: activities.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (ctx, i) {
                  final act = activities[i];
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1B2336) : const Color(0xFFF8F9FC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isDark ? const Color(0xFF28344D) : const Color(0xFFE4E7EC)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1B59F8).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(_getActivityIcon(act.type), size: 16, color: const Color(0xFF1B59F8)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                act.subject ?? act.type.toUpperCase(),
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? Colors.white : const Color(0xFF101828)),
                              ),
                              if (act.description != null && act.description!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(act.description!, style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : const Color(0xFF667085))),
                                ),
                              const SizedBox(height: 4),
                              Text(
                                act.completedAt != null ? DateFormat('MMM d, yyyy · h:mm a').format(act.completedAt!) : 'Recorded',
                                style: TextStyle(fontSize: 10, color: isDark ? Colors.white38 : const Color(0xFF98A2B3)),
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
      ],
    );
  }

  Widget _buildTasksTab(AppDatabase db, ContactEntry c, bool isDark) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Follow-up Tasks', style: AppTypography.subtitle2(color: isDark ? Colors.white : AppColors.grey900)),
              TextButton.icon(
                onPressed: _showAddTaskDialog,
                icon: const Icon(LucideIcons.plus, size: 14),
                label: const Text('Add Task', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<List<TaskEntry>>(
            stream: (db.select(db.tasksTable)..where((tbl) => tbl.contactLocalId.equals(c.localId))).watch(),
            builder: (context, snapshot) {
              final tasks = snapshot.data ?? [];
              if (tasks.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(LucideIcons.checkSquare, size: 36, color: Colors.grey),
                      const SizedBox(height: 8),
                      Text('No tasks associated with this contact', style: TextStyle(color: isDark ? Colors.white60 : Colors.grey[600])),
                      const SizedBox(height: 8),
                      OutlinedButton(onPressed: _showAddTaskDialog, child: const Text('Schedule First Task')),
                    ],
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: tasks.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (ctx, i) {
                  final task = tasks[i];
                  final isDone = task.status == 'completed';
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1B2336) : const Color(0xFFF8F9FC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isDark ? const Color(0xFF28344D) : const Color(0xFFE4E7EC)),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            isDone ? LucideIcons.checkCircle2 : LucideIcons.circle,
                            color: isDone ? const Color(0xFF12B76A) : const Color(0xFF98A2B3),
                            size: 20,
                          ),
                          onPressed: () async {
                            final next = isDone ? 'pending' : 'completed';
                            await (db.update(db.tasksTable)..where((t) => t.localId.equals(task.localId))).write(
                              TasksTableCompanion(
                                status: Value(next),
                                localUpdatedAt: Value(DateTime.now()),
                              ),
                            );
                          },
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                task.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  decoration: isDone ? TextDecoration.lineThrough : null,
                                  color: isDark ? Colors.white : const Color(0xFF101828),
                                ),
                              ),
                              if (task.description != null && task.description!.isNotEmpty)
                                Text(
                                  task.description!,
                                  style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : const Color(0xFF667085)),
                                ),
                              if (task.dueDate != null)
                                Text(
                                  'Due ${DateFormat('MMM d, yyyy').format(task.dueDate!)} • ${task.priority.toUpperCase()}',
                                  style: TextStyle(fontSize: 10, color: isDark ? Colors.white38 : const Color(0xFF98A2B3)),
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
      ],
    );
  }

  Widget _buildDealsTab(AppDatabase db, ContactEntry c, bool isDark) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Pipeline Opportunities', style: AppTypography.subtitle2(color: isDark ? Colors.white : AppColors.grey900)),
              TextButton.icon(
                onPressed: _showAddDealDialog,
                icon: const Icon(LucideIcons.plus, size: 14),
                label: const Text('Add Deal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<List<DealEntry>>(
            stream: (db.select(db.dealsTable)..where((tbl) => tbl.contactLocalId.equals(c.localId))).watch(),
            builder: (context, snapshot) {
              final deals = snapshot.data ?? [];
              if (deals.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(LucideIcons.briefcase, size: 36, color: Colors.grey),
                      const SizedBox(height: 8),
                      Text('No pipeline deals for this contact', style: TextStyle(color: isDark ? Colors.white60 : Colors.grey[600])),
                      const SizedBox(height: 8),
                      OutlinedButton(onPressed: _showAddDealDialog, child: const Text('Create First Deal')),
                    ],
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: deals.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (ctx, i) {
                  final deal = deals[i];
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1B2336) : const Color(0xFFF8F9FC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isDark ? const Color(0xFF28344D) : const Color(0xFFE4E7EC)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                deal.title,
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? Colors.white : const Color(0xFF101828)),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Stage: ${deal.stageName}',
                                style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : const Color(0xFF667085)),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '\$${deal.amount.toStringAsFixed(0)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF12B76A)),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required bool isDark,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2234) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF28344D) : const Color(0xFFEAECF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: const Color(0xFF1B59F8)),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTypography.overline(color: isDark ? Colors.white54 : const Color(0xFF667085)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  Widget _specRow(String label, String value, {bool isLink = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF667085), fontWeight: FontWeight.w500)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isLink ? const Color(0xFF1B59F8) : null,
                decoration: isLink ? TextDecoration.underline : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : const Color(0xFF344054),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricCol(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF667085))),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color)),
      ],
    );
  }

  IconData _getActivityIcon(String type) {
    switch (type.toLowerCase()) {
      case 'call':
        return LucideIcons.phone;
      case 'whatsapp':
        return LucideIcons.messageSquare;
      case 'email':
        return LucideIcons.mail;
      case 'meeting':
        return LucideIcons.users;
      default:
        return LucideIcons.fileText;
    }
  }
}
