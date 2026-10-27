import '../../../core/auth/auth_provider.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:drift/drift.dart' hide Column;
import '../../../core/sync/sync_provider.dart';
import '../../../core/database/app_database.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_typography.dart';
import '../../../shared/components/empty_state.dart';
import '../../../shared/components/unified_form.dart';
import '../../../shared/components/app_shimmer.dart';
import 'contact_details_sheet.dart';

class ContactsScreen extends ConsumerStatefulWidget {
  const ContactsScreen({super.key});

  @override
  ConsumerState<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends ConsumerState<ContactsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedStatusFilter = 'All';
  String _customerFilter = 'all'; // all, leads, customers
  bool _isSearchOpen = false;

  final List<String> _statusFilters = [
    'All',
    'New',
    'Contacted',
    'Qualified',
    'Proposal',
    'Won',
    'Lost',
    'Nurturing',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openContactForm([ContactEntry? contact]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ContactFormSheet(contact: contact),
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(databaseProvider);
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
              padding: const EdgeInsets.fromLTRB(20, 12, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Leads & Contacts',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        _customerFilter == 'customers'
                            ? 'Showing Paying Customers'
                            : _customerFilter == 'leads'
                                ? 'Showing Sales Prospects & Leads'
                                : 'All Client & Lead Profiles',
                        style: const TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          _isSearchOpen ? LucideIcons.x : LucideIcons.search,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _isSearchOpen = !_isSearchOpen;
                            if (!_isSearchOpen) {
                              _searchController.clear();
                              _searchQuery = '';
                            }
                          });
                        },
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(LucideIcons.slidersHorizontal, color: Colors.white, size: 20),
                        tooltip: 'Filter by Type',
                        onSelected: (val) => setState(() => _customerFilter = val),
                        itemBuilder: (_) => [
                          PopupMenuItem(
                            value: 'all',
                            child: Row(
                              children: [
                                Icon(LucideIcons.users, size: 16, color: _customerFilter == 'all' ? primaryBlue : Colors.grey),
                                const SizedBox(width: 8),
                                const Text('All Contacts'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'leads',
                            child: Row(
                              children: [
                                Icon(LucideIcons.target, size: 16, color: _customerFilter == 'leads' ? primaryBlue : Colors.grey),
                                const SizedBox(width: 8),
                                const Text('Prospects & Leads Only'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'customers',
                            child: Row(
                              children: [
                                Icon(LucideIcons.checkCircle2, size: 16, color: _customerFilter == 'customers' ? primaryBlue : Colors.grey),
                                const SizedBox(width: 8),
                                const Text('Paying Customers Only'),
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

            // Collapsible Search Bar
            if (_isSearchOpen)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search by name, company, email, phone, TIN...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.18),
                    prefixIcon: const Icon(LucideIcons.search, color: Colors.white70, size: 18),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

            // Main Body Card (Curved top overlay)
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF10141D) : const Color(0xFFF7F9FC),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    // Status Filter Tabs
                    SizedBox(
                      height: 40,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _statusFilters.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 20),
                        itemBuilder: (context, idx) {
                          final status = _statusFilters[idx];
                          final isSelected = _selectedStatusFilter == status;

                          return GestureDetector(
                            onTap: () => setState(() => _selectedStatusFilter = status),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  status,
                                  style: TextStyle(
                                    color: isSelected
                                        ? (isDark ? Colors.white : const Color(0xFF101828))
                                        : (isDark ? Colors.white38 : const Color(0xFF98A2B3)),
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  width: 24,
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color: isSelected ? primaryBlue : Colors.transparent,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFEAECF0)),

                    // Contacts Reactive Stream List
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          await ref.read(syncProvider.notifier).pullAllInitialData();
                        },
                        child: StreamBuilder<List<ContactEntry>>(
                          stream: db.select(db.contactsTable).watch(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return AppShimmer.cardListShimmer(isDark: isDark, count: 5);
                            }

                            final contacts = snapshot.data ?? [];
                            final filtered = contacts.where((c) {
                              // Customer filter
                              if (_customerFilter == 'customers' && !c.isCustomer) return false;
                              if (_customerFilter == 'leads' && c.isCustomer) return false;

                              // Search query filter
                              if (_searchQuery.isNotEmpty) {
                                final fullName = '${c.firstName} ${c.middleName ?? ''} ${c.lastName ?? ''}'.toLowerCase();
                                final company = (c.company ?? '').toLowerCase();
                                final phone = (c.phone ?? '').toLowerCase();
                                final email = (c.email ?? '').toLowerCase();
                                final tin = (c.tin ?? '').toLowerCase();
                                final notes = (c.notes ?? '').toLowerCase();
                                final matches = fullName.contains(_searchQuery) ||
                                    company.contains(_searchQuery) ||
                                    phone.contains(_searchQuery) ||
                                    email.contains(_searchQuery) ||
                                    tin.contains(_searchQuery) ||
                                    notes.contains(_searchQuery);
                                if (!matches) return false;
                              }

                              // Status filter
                              if (_selectedStatusFilter != 'All') {
                                return (c.leadStatus ?? 'New').toLowerCase() == _selectedStatusFilter.toLowerCase();
                              }
                              return true;
                            }).toList();

                            if (filtered.isEmpty) {
                              return EmptyState(
                                icon: LucideIcons.users,
                                title: 'No Leads Found',
                                description: _searchQuery.isEmpty
                                    ? 'No contacts found under "$_selectedStatusFilter" status.'
                                    : 'No leads matched your search query "$_searchQuery".',
                                actionLabel: '+ Add Contact',
                                onAction: () => _openContactForm(),
                              );
                            }

                            return ListView.separated(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              itemCount: filtered.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 14),
                              itemBuilder: (context, index) {
                                final contact = filtered[index];
                                return _buildLeadCard(context, contact, isDark);
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'contacts_fab',
        backgroundColor: const Color(0xFFFF5722),
        elevation: 6,
        onPressed: () => _openContactForm(),
        child: const Icon(LucideIcons.plus, color: Colors.white, size: 26),
      ),
    );
  }

  Widget _buildLeadCard(BuildContext context, ContactEntry contact, bool isDark) {
    final nameParts = [contact.firstName, contact.middleName, contact.lastName]
        .where((p) => p != null && p.trim().isNotEmpty)
        .join(' ')
        .trim();
    String fullName = nameParts;
    if (fullName.isEmpty) {
      if (contact.company != null && contact.company!.trim().isNotEmpty) {
        fullName = '${contact.company!.trim()} (company)';
      } else {
        fullName = 'Unnamed Contact';
      }
    }

    final initial = fullName.isNotEmpty ? fullName.substring(0, 1).toUpperCase() : 'C';

    final List<Color> avatarColors = [
      const Color(0xFFFFE4E6),
      const Color(0xFFD1FADF),
      const Color(0xFFFEF0C7),
      const Color(0xFFE0EAFF),
    ];
    final avatarBg = avatarColors[contact.localId % avatarColors.length];

    return InkWell(
      onTap: () {
        ContactDetailsSheet.show(
          context,
          contact: contact,
          onEdit: () => _openContactForm(contact),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C2234) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? const Color(0xFF2B344B) : const Color(0xFFEAECF0),
          ),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: avatarBg,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      initial,
                      style: const TextStyle(
                        color: Color(0xFF101828),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
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
                              fullName,
                              style: TextStyle(
                                color: isDark ? Colors.white : const Color(0xFF101828),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          if (contact.isCustomer) ...[
                            const SizedBox(width: 6),
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
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${contact.title ?? 'Lead'} • ${contact.company ?? 'Individual'} • Score: ${contact.leadScore} pts',
                        style: TextStyle(
                          color: isDark ? Colors.white54 : const Color(0xFF667085),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.moreVertical, size: 18),
                  color: isDark ? Colors.white54 : const Color(0xFF98A2B3),
                  onPressed: () {
                    ContactDetailsSheet.show(
                      context,
                      contact: contact,
                      onEdit: () => _openContactForm(contact),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFF2F4F7)),
            const SizedBox(height: 10),

            // Bottom Actions & Quick Contact
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '— ${contact.leadStatus ?? 'New'} • ${contact.city ?? contact.country ?? 'Active'}',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF12B76A),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Row(
                  children: [
                    if (contact.phone != null && contact.phone!.isNotEmpty) ...[
                      _buildCircleActionButton(
                        icon: LucideIcons.messageSquare,
                        color: const Color(0xFF12B76A),
                        isDark: isDark,
                        onTap: () {
                          final clean = contact.phone!.replaceAll(RegExp(r'[^0-9]'), '');
                          launchUrl(Uri.parse('https://wa.me/$clean'), mode: LaunchMode.externalApplication);
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildCircleActionButton(
                        icon: LucideIcons.phone,
                        color: const Color(0xFF1B59F8),
                        isDark: isDark,
                        onTap: () => launchUrl(Uri.parse('tel:${contact.phone}')),
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (contact.email != null && contact.email!.isNotEmpty)
                      _buildCircleActionButton(
                        icon: LucideIcons.mail,
                        color: const Color(0xFF7A5AF8),
                        isDark: isDark,
                        onTap: () => launchUrl(Uri.parse('mailto:${contact.email}')),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleActionButton({
    required IconData icon,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}

// ── Contact Form Sheet (Matching ALL inputs and features from Web CRM) ──────
class _ContactFormSheet extends ConsumerStatefulWidget {
  final ContactEntry? contact;
  const _ContactFormSheet({this.contact});

  @override
  ConsumerState<_ContactFormSheet> createState() => _ContactFormSheetState();
}

class _ContactFormSheetState extends ConsumerState<_ContactFormSheet> {
  // Basic Info
  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _middleNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _alternatePhoneCtrl;
  late final TextEditingController _tinCtrl;
  late final TextEditingController _vrnCtrl;

  // Company Info
  late final TextEditingController _companyCtrl;
  late final TextEditingController _titleCtrl;

  // Sales & Funnel
  String _leadStatus = 'New';
  String _lifecycleStageId = 'Lead';
  String _infoSource = 'Website';
  int _leadScore = 0;
  bool _isCustomer = false;
  bool _isActive = true;

  // Address
  late final TextEditingController _addressCtrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _stateCtrl;
  late final TextEditingController _countryCtrl;
  late final TextEditingController _postalCodeCtrl;

  // Web
  late final TextEditingController _websiteCtrl;

  // Notes
  late final TextEditingController _notesCtrl;

  // Deal Creation (Optional)
  bool _createDeal = false;
  final TextEditingController _dealTitleCtrl = TextEditingController();
  final TextEditingController _dealAmountCtrl = TextEditingController(text: '1000');
  String _dealStage = 'Lead In / Qualification';

  // Schedule Task (Optional)
  bool _createTask = false;
  final TextEditingController _taskTitleCtrl = TextEditingController();
  String _taskPriority = 'medium';

  // Initial Activity (Optional)
  bool _createActivity = false;
  String _activityType = 'call';
  final TextEditingController _activitySubjectCtrl = TextEditingController();

  // Custom Attributes (key: value)
  final List<MapEntry<TextEditingController, TextEditingController>> _customAttributes = [];

  @override
  void initState() {
    super.initState();
    final c = widget.contact;
    _firstNameCtrl = TextEditingController(text: c?.firstName ?? '');
    _middleNameCtrl = TextEditingController(text: c?.middleName ?? '');
    _lastNameCtrl = TextEditingController(text: c?.lastName ?? '');
    _emailCtrl = TextEditingController(text: c?.email ?? '');
    _phoneCtrl = TextEditingController(text: c?.phone ?? '');
    _alternatePhoneCtrl = TextEditingController(text: c?.alternatePhone ?? '');
    _tinCtrl = TextEditingController(text: c?.tin ?? '');
    _vrnCtrl = TextEditingController(text: c?.vrn ?? '');
    _companyCtrl = TextEditingController(text: c?.company ?? '');
    _titleCtrl = TextEditingController(text: c?.title ?? '');
    _leadStatus = c?.leadStatus ?? 'New';
    _lifecycleStageId = c?.lifecycleStageId ?? 'Lead';
    _infoSource = c?.infoSource ?? 'Website';
    _leadScore = c?.leadScore ?? 0;
    _isCustomer = c?.isCustomer ?? false;
    _isActive = c?.isActive ?? true;

    _addressCtrl = TextEditingController(text: c?.address ?? '');
    _cityCtrl = TextEditingController(text: c?.city ?? '');
    _stateCtrl = TextEditingController(text: c?.state ?? '');
    _countryCtrl = TextEditingController(text: c?.country ?? '');
    _postalCodeCtrl = TextEditingController(text: c?.postalCode ?? '');
    _websiteCtrl = TextEditingController(text: c?.website ?? '');
    _notesCtrl = TextEditingController(text: c?.notes ?? '');

    // Parse custom attributes if present
    if (c?.customFieldsJson != null && c!.customFieldsJson!.isNotEmpty) {
      try {
        final decoded = jsonDecode(c.customFieldsJson!);
        if (decoded is Map<String, dynamic>) {
          for (final entry in decoded.entries) {
            _customAttributes.add(MapEntry(
              TextEditingController(text: entry.key),
              TextEditingController(text: entry.value?.toString() ?? ''),
            ));
          }
        }
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _middleNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _alternatePhoneCtrl.dispose();
    _tinCtrl.dispose();
    _vrnCtrl.dispose();
    _companyCtrl.dispose();
    _titleCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _countryCtrl.dispose();
    _postalCodeCtrl.dispose();
    _websiteCtrl.dispose();
    _notesCtrl.dispose();
    _dealTitleCtrl.dispose();
    _dealAmountCtrl.dispose();
    _taskTitleCtrl.dispose();
    _activitySubjectCtrl.dispose();
    for (final pair in _customAttributes) {
      pair.key.dispose();
      pair.value.dispose();
    }
    super.dispose();
  }

  void _addCustomAttribute() {
    setState(() {
      _customAttributes.add(MapEntry(
        TextEditingController(),
        TextEditingController(),
      ));
    });
  }

  void _removeCustomAttribute(int index) {
    setState(() {
      final pair = _customAttributes.removeAt(index);
      pair.key.dispose();
      pair.value.dispose();
    });
  }

  Future<void> _saveContact() async {
    final firstName = _firstNameCtrl.text.trim();
    final companyName = _companyCtrl.text.trim();
    if (firstName.isEmpty && companyName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter at least a First Name or Company Name')),
      );
      return;
    }

    final db = ref.read(databaseProvider);
    final apiClient = ref.read(apiClientProvider);

    // Build custom attributes map
    final customFields = <String, dynamic>{};
    for (final pair in _customAttributes) {
      final k = pair.key.text.trim();
      final v = pair.value.text.trim();
      if (k.isNotEmpty) customFields[k] = v;
    }
    final customFieldsStr = customFields.isNotEmpty ? jsonEncode(customFields) : null;

    final nameToUse = firstName.isNotEmpty ? firstName : companyName;

    // Build API payload matching ContactRequest.php exactly
    final apiPayload = <String, dynamic>{
      'first_name': firstName,
      'middle_name': _middleNameCtrl.text.trim().isNotEmpty ? _middleNameCtrl.text.trim() : null,
      'last_name': _lastNameCtrl.text.trim().isNotEmpty ? _lastNameCtrl.text.trim() : null,
      'email': _emailCtrl.text.trim().isNotEmpty ? _emailCtrl.text.trim() : null,
      'phone': _phoneCtrl.text.trim().isNotEmpty ? _phoneCtrl.text.trim() : null,
      'alternate_phone': _alternatePhoneCtrl.text.trim().isNotEmpty ? _alternatePhoneCtrl.text.trim() : null,
      'tin': _tinCtrl.text.trim().isNotEmpty ? _tinCtrl.text.trim() : null,
      'vrn': _vrnCtrl.text.trim().isNotEmpty ? _vrnCtrl.text.trim() : null,
      'company': companyName.isNotEmpty ? companyName : null,
      'title': _titleCtrl.text.trim().isNotEmpty ? _titleCtrl.text.trim() : null,
      'lead_status': _leadStatus,
      'lifecycle_stage_id': _lifecycleStageId,
      'info_source': _infoSource,
      'lead_score': _leadScore,
      'is_customer': _isCustomer,
      'is_active': _isActive,
      'address': _addressCtrl.text.trim().isNotEmpty ? _addressCtrl.text.trim() : null,
      'city': _cityCtrl.text.trim().isNotEmpty ? _cityCtrl.text.trim() : null,
      'state': _stateCtrl.text.trim().isNotEmpty ? _stateCtrl.text.trim() : null,
      'country': _countryCtrl.text.trim().isNotEmpty ? _countryCtrl.text.trim() : null,
      'postal_code': _postalCodeCtrl.text.trim().isNotEmpty ? _postalCodeCtrl.text.trim() : null,
      'website': _websiteCtrl.text.trim().isNotEmpty ? _websiteCtrl.text.trim() : null,
      'notes': _notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : null,
      if (customFields.isNotEmpty) 'custom_fields': customFields,
      if (_createDeal) ...{
        'create_deal': true,
        'deal_title': _dealTitleCtrl.text.trim().isNotEmpty ? _dealTitleCtrl.text.trim() : 'Deal with $nameToUse',
        'deal_amount': double.tryParse(_dealAmountCtrl.text.trim()) ?? 1000.0,
      },
      if (_createTask) ...{
        'create_task': true,
        'task_title': _taskTitleCtrl.text.trim().isNotEmpty ? _taskTitleCtrl.text.trim() : 'Follow up with $nameToUse',
        'task_priority': _taskPriority,
      },
      if (_createActivity) ...{
        'create_activity': true,
        'activity_type': _activityType,
        'activity_subject': _activitySubjectCtrl.text.trim().isNotEmpty ? _activitySubjectCtrl.text.trim() : 'Initial touchpoint',
      },
    };

    String? serverId = widget.contact?.serverId;

    // Send to backend API directly if online
    try {
      if (widget.contact == null) {
        final res = await apiClient.dio.post('/contacts', data: apiPayload);
        if (res.statusCode == 200 || res.statusCode == 201) {
          final data = res.data is Map ? (res.data['id'] != null ? res.data : res.data['data']) : null;
          if (data is Map && data['id'] != null) {
            serverId = data['id'].toString();
          }
        }
      } else if (serverId != null && serverId.isNotEmpty) {
        await apiClient.dio.put('/contacts/$serverId', data: apiPayload);
      }
    } catch (_) {
      // Offline fallback: will sync via SyncQueueTable
    }

    // Insert or update in local SQLite Drift database
    int contactLocalId;
    if (widget.contact == null) {
      contactLocalId = await db.into(db.contactsTable).insert(
            ContactsTableCompanion.insert(
              serverId: Value(serverId),
              syncStatus: Value(serverId != null ? 'synced' : 'pending_create'),
              firstName: nameToUse,
              middleName: Value(_middleNameCtrl.text.trim()),
              lastName: Value(_lastNameCtrl.text.trim()),
              email: Value(_emailCtrl.text.trim()),
              phone: Value(_phoneCtrl.text.trim()),
              alternatePhone: Value(_alternatePhoneCtrl.text.trim()),
              tin: Value(_tinCtrl.text.trim()),
              vrn: Value(_vrnCtrl.text.trim()),
              company: Value(companyName),
              title: Value(_titleCtrl.text.trim()),
              leadStatus: Value(_leadStatus),
              leadScore: Value(_leadScore),
              infoSource: Value(_infoSource),
              lifecycleStageId: Value(_lifecycleStageId),
              isCustomer: Value(_isCustomer),
              isActive: Value(_isActive),
              address: Value(_addressCtrl.text.trim()),
              city: Value(_cityCtrl.text.trim()),
              state: Value(_stateCtrl.text.trim()),
              country: Value(_countryCtrl.text.trim()),
              postalCode: Value(_postalCodeCtrl.text.trim()),
              website: Value(_websiteCtrl.text.trim()),
              notes: Value(_notesCtrl.text.trim()),
              customFieldsJson: Value(customFieldsStr),
              localUpdatedAt: DateTime.now(),
            ),
          );
    } else {
      contactLocalId = widget.contact!.localId;
      await (db.update(db.contactsTable)..where((t) => t.localId.equals(contactLocalId))).write(
        ContactsTableCompanion(
          serverId: Value(serverId),
          syncStatus: Value(serverId != null ? 'synced' : 'pending_update'),
          firstName: Value(nameToUse),
          middleName: Value(_middleNameCtrl.text.trim()),
          lastName: Value(_lastNameCtrl.text.trim()),
          email: Value(_emailCtrl.text.trim()),
          phone: Value(_phoneCtrl.text.trim()),
          alternatePhone: Value(_alternatePhoneCtrl.text.trim()),
          tin: Value(_tinCtrl.text.trim()),
          vrn: Value(_vrnCtrl.text.trim()),
          company: Value(companyName),
          title: Value(_titleCtrl.text.trim()),
          leadStatus: Value(_leadStatus),
          leadScore: Value(_leadScore),
          infoSource: Value(_infoSource),
          lifecycleStageId: Value(_lifecycleStageId),
          isCustomer: Value(_isCustomer),
          isActive: Value(_isActive),
          address: Value(_addressCtrl.text.trim()),
          city: Value(_cityCtrl.text.trim()),
          state: Value(_stateCtrl.text.trim()),
          country: Value(_countryCtrl.text.trim()),
          postalCode: Value(_postalCodeCtrl.text.trim()),
          website: Value(_websiteCtrl.text.trim()),
          notes: Value(_notesCtrl.text.trim()),
          customFieldsJson: Value(customFieldsStr),
          localUpdatedAt: Value(DateTime.now()),
        ),
      );
    }

    // Optional Deal
    if (_createDeal) {
      final dealTitle = _dealTitleCtrl.text.trim().isNotEmpty
          ? _dealTitleCtrl.text.trim()
          : 'Deal with $nameToUse';
      final dealAmount = double.tryParse(_dealAmountCtrl.text.trim()) ?? 1000.0;

      await db.into(db.dealsTable).insert(
            DealsTableCompanion.insert(
              title: dealTitle,
              contactLocalId: Value(contactLocalId),
              stageName: Value(_dealStage),
              amount: Value(dealAmount),
              localUpdatedAt: DateTime.now(),
            ),
          );
    }

    // Optional Task
    if (_createTask) {
      final taskTitle = _taskTitleCtrl.text.trim().isNotEmpty
          ? _taskTitleCtrl.text.trim()
          : 'Follow up with $nameToUse';

      await db.into(db.tasksTable).insert(
            TasksTableCompanion.insert(
              contactLocalId: Value(contactLocalId),
              title: taskTitle,
              dueDate: Value(DateTime.now().add(const Duration(days: 3))),
              priority: Value(_taskPriority),
              localUpdatedAt: DateTime.now(),
            ),
          );
    }

    // Optional Activity
    if (_createActivity) {
      final subject = _activitySubjectCtrl.text.trim().isNotEmpty
          ? _activitySubjectCtrl.text.trim()
          : 'Initial touchpoint';

      await db.into(db.activitiesTable).insert(
            ActivitiesTableCompanion.insert(
              contactLocalId: Value(contactLocalId),
              type: _activityType,
              subject: Value(subject),
              direction: const Value('outbound'),
              completedAt: Value(DateTime.now()),
              localUpdatedAt: DateTime.now(),
            ),
          );
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.contact != null ? 'Contact updated successfully' : 'Contact created successfully'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return UnifiedFormSheet(
      title: widget.contact != null ? 'Edit Contact' : 'New Contact / Lead',
      subtitle: 'Complete all client specifications & sales details',
      submitLabel: widget.contact != null ? 'Update Contact' : 'Save Contact',
      onSubmit: _saveContact,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Basic Information ─────────────────────────────
          Text('BASIC INFORMATION', style: AppTypography.overline(color: AppColors.grey500)),
          const SizedBox(height: 10),
          UnifiedTextField(label: 'First Name *', controller: _firstNameCtrl, hint: 'e.g. Alex'),
          Row(
            children: [
              Expanded(child: UnifiedTextField(label: 'Middle Name', controller: _middleNameCtrl, hint: 'e.g. John')),
              const SizedBox(width: 12),
              Expanded(child: UnifiedTextField(label: 'Last Name', controller: _lastNameCtrl, hint: 'e.g. Mercer')),
            ],
          ),
          UnifiedTextField(label: 'Email Address', controller: _emailCtrl, hint: 'alex@example.com', keyboardType: TextInputType.emailAddress),
          Row(
            children: [
              Expanded(child: UnifiedTextField(label: 'Primary Phone', controller: _phoneCtrl, hint: '+1 555 0192', keyboardType: TextInputType.phone)),
              const SizedBox(width: 12),
              Expanded(child: UnifiedTextField(label: 'Alt. Phone', controller: _alternatePhoneCtrl, hint: '+1 555 9943', keyboardType: TextInputType.phone)),
            ],
          ),
          Row(
            children: [
              Expanded(child: UnifiedTextField(label: 'TIN Number', controller: _tinCtrl, hint: '100-200-300')),
              const SizedBox(width: 12),
              Expanded(child: UnifiedTextField(label: 'VRN Number', controller: _vrnCtrl, hint: '400-500-600')),
            ],
          ),
          const SizedBox(height: 8),

          // ── Company Information ───────────────────────────
          Text('COMPANY INFORMATION', style: AppTypography.overline(color: AppColors.grey500)),
          const SizedBox(height: 10),
          UnifiedTextField(label: 'Company Name', controller: _companyCtrl, hint: 'e.g. Global Tech Solutions'),
          UnifiedTextField(label: 'Job Title', controller: _titleCtrl, hint: 'e.g. Managing Director'),
          const SizedBox(height: 8),

          // ── Sales & Funnel ────────────────────────────────
          Text('SALES & LEAD QUALIFICATION', style: AppTypography.overline(color: AppColors.grey500)),
          const SizedBox(height: 10),
          UnifiedDropdownField<String>(
            label: 'Lead Status',
            value: _leadStatus,
            items: const [
              DropdownMenuItem(value: 'New', child: Text('New')),
              DropdownMenuItem(value: 'Contacted', child: Text('Contacted')),
              DropdownMenuItem(value: 'Qualified', child: Text('Qualified')),
              DropdownMenuItem(value: 'Proposal', child: Text('Proposal')),
              DropdownMenuItem(value: 'Won', child: Text('Won')),
              DropdownMenuItem(value: 'Lost', child: Text('Lost')),
              DropdownMenuItem(value: 'Nurturing', child: Text('Nurturing')),
            ],
            onChanged: (val) {
              if (val != null) setState(() => _leadStatus = val);
            },
          ),
          UnifiedDropdownField<String>(
            label: 'Lifecycle Stage',
            value: _lifecycleStageId,
            items: const [
              DropdownMenuItem(value: 'Lead', child: Text('Lead (Default)')),
              DropdownMenuItem(value: 'Marketing Qualified Lead', child: Text('Marketing Qualified Lead (MQL)')),
              DropdownMenuItem(value: 'Sales Qualified Lead', child: Text('Sales Qualified Lead (SQL)')),
              DropdownMenuItem(value: 'Opportunity', child: Text('Opportunity')),
              DropdownMenuItem(value: 'Customer', child: Text('Customer')),
              DropdownMenuItem(value: 'Evangelist', child: Text('Evangelist / Promoter')),
            ],
            onChanged: (val) {
              if (val != null) setState(() => _lifecycleStageId = val);
            },
          ),
          UnifiedDropdownField<String>(
            label: 'Info / Lead Source',
            value: _infoSource,
            items: const [
              DropdownMenuItem(value: 'Website', child: Text('Website / Direct')),
              DropdownMenuItem(value: 'Referral', child: Text('Referral / Word of Mouth')),
              DropdownMenuItem(value: 'Social Media', child: Text('Social Media (LinkedIn, WhatsApp)')),
              DropdownMenuItem(value: 'Cold Call', child: Text('Cold Outreach / Call')),
              DropdownMenuItem(value: 'Advertisement', child: Text('Online Advertisement')),
              DropdownMenuItem(value: 'Partner', child: Text('Partner / Event')),
              DropdownMenuItem(value: 'Other', child: Text('Other')),
            ],
            onChanged: (val) {
              if (val != null) setState(() => _infoSource = val);
            },
          ),
          Row(
            children: [
              Expanded(
                child: UnifiedTextField(
                  label: 'Lead Score (0-100)',
                  controller: TextEditingController(text: _leadScore.toString()),
                  keyboardType: TextInputType.number,
                  hint: '0',
                ),
              ),
            ],
          ),
          SwitchListTile(
            title: Text('Paying Customer', style: AppTypography.subtitle2(color: isDark ? Colors.white : AppColors.grey900)),
            subtitle: Text('Mark this profile as an active customer rather than lead', style: AppTypography.caption(color: AppColors.grey500)),
            value: _isCustomer,
            activeThumbColor: const Color(0xFF12B76A),
            onChanged: (val) => setState(() => _isCustomer = val),
          ),
          SwitchListTile(
            title: Text('Active Record', style: AppTypography.subtitle2(color: isDark ? Colors.white : AppColors.grey900)),
            value: _isActive,
            activeThumbColor: const Color(0xFF1B59F8),
            onChanged: (val) => setState(() => _isActive = val),
          ),
          const SizedBox(height: 8),

          // ── Address & Location ────────────────────────────
          Text('ADDRESS & LOCATION', style: AppTypography.overline(color: AppColors.grey500)),
          const SizedBox(height: 10),
          UnifiedTextField(label: 'Street Address', controller: _addressCtrl, hint: 'e.g. 102 Business Avenue, Floor 4'),
          Row(
            children: [
              Expanded(child: UnifiedTextField(label: 'City', controller: _cityCtrl, hint: 'e.g. Dar es Salaam')),
              const SizedBox(width: 12),
              Expanded(child: UnifiedTextField(label: 'State / Region', controller: _stateCtrl, hint: 'e.g. Ilala')),
            ],
          ),
          Row(
            children: [
              Expanded(child: UnifiedTextField(label: 'Country', controller: _countryCtrl, hint: 'e.g. Tanzania')),
              const SizedBox(width: 12),
              Expanded(child: UnifiedTextField(label: 'Postal Code', controller: _postalCodeCtrl, hint: '11000')),
            ],
          ),
          const SizedBox(height: 8),

          // ── Online & Social ───────────────────────────────
          Text('ONLINE & SOCIAL', style: AppTypography.overline(color: AppColors.grey500)),
          const SizedBox(height: 10),
          UnifiedTextField(label: 'Website URL', controller: _websiteCtrl, hint: 'https://company.com', keyboardType: TextInputType.url),
          const SizedBox(height: 8),

          // ── Custom Key:Value Attributes ───────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('CUSTOM ATTRIBUTES', style: AppTypography.overline(color: AppColors.grey500)),
              TextButton.icon(
                onPressed: _addCustomAttribute,
                icon: const Icon(LucideIcons.plus, size: 14),
                label: const Text('Add Attribute', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (_customAttributes.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'No custom attributes yet (e.g. VIP Level, Region, Sector)',
                style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.grey[500]),
              ),
            )
          else
            ..._customAttributes.asMap().entries.map((entry) {
              final idx = entry.key;
              final pair = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(child: UnifiedTextField(label: 'Attribute Name', controller: pair.key, hint: 'e.g. Sector')),
                    const SizedBox(width: 8),
                    Expanded(child: UnifiedTextField(label: 'Attribute Value', controller: pair.value, hint: 'e.g. Financial')),
                    IconButton(
                      icon: const Icon(LucideIcons.trash2, size: 16, color: Colors.red),
                      onPressed: () => _removeCustomAttribute(idx),
                    ),
                  ],
                ),
              );
            }),
          const SizedBox(height: 8),

          // ── Deal Creation (Optional) ──────────────────────
          SwitchListTile(
            title: Text('Create Deal in Pipeline', style: AppTypography.subtitle2(color: isDark ? Colors.white : AppColors.grey900)),
            subtitle: Text('Instantly create an active sales opportunity', style: AppTypography.caption(color: AppColors.grey500)),
            value: _createDeal,
            activeThumbColor: const Color(0xFF1B59F8),
            onChanged: (val) => setState(() => _createDeal = val),
          ),
          if (_createDeal) ...[
            UnifiedTextField(label: 'Deal Title', controller: _dealTitleCtrl, hint: 'e.g. Enterprise CRM Package'),
            UnifiedTextField(label: 'Deal Amount (\$)', controller: _dealAmountCtrl, hint: '1000', keyboardType: TextInputType.number),
            UnifiedDropdownField<String>(
              label: 'Pipeline Stage',
              value: _dealStage,
              items: const [
                DropdownMenuItem(value: 'Lead In / Qualification', child: Text('Lead In / Qualification')),
                DropdownMenuItem(value: 'Contacted / Meeting', child: Text('Contacted / Meeting')),
                DropdownMenuItem(value: 'Proposal Sent', child: Text('Proposal Sent')),
                DropdownMenuItem(value: 'Negotiation', child: Text('Negotiation')),
                DropdownMenuItem(value: 'Closed Won', child: Text('Closed Won')),
                DropdownMenuItem(value: 'Closed Lost', child: Text('Closed Lost')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _dealStage = val);
              },
            ),
          ],

          // ── Schedule Task (Optional) ──────────────────────
          SwitchListTile(
            title: Text('Schedule Follow-up Task', style: AppTypography.subtitle2(color: isDark ? Colors.white : AppColors.grey900)),
            subtitle: Text('Automatically create a follow-up action', style: AppTypography.caption(color: AppColors.grey500)),
            value: _createTask,
            activeThumbColor: const Color(0xFF1B59F8),
            onChanged: (val) => setState(() => _createTask = val),
          ),
          if (_createTask) ...[
            UnifiedTextField(label: 'Task Title', controller: _taskTitleCtrl, hint: 'e.g. Call client back about contract'),
            UnifiedDropdownField<String>(
              label: 'Task Priority',
              value: _taskPriority,
              items: const [
                DropdownMenuItem(value: 'low', child: Text('Low')),
                DropdownMenuItem(value: 'medium', child: Text('Medium')),
                DropdownMenuItem(value: 'high', child: Text('High')),
                DropdownMenuItem(value: 'urgent', child: Text('Urgent')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _taskPriority = val);
              },
            ),
          ],

          // ── Initial Activity (Optional) ───────────────────
          SwitchListTile(
            title: Text('Log Initial Interaction', style: AppTypography.subtitle2(color: isDark ? Colors.white : AppColors.grey900)),
            subtitle: Text('Record initial call, message, or email touchpoint', style: AppTypography.caption(color: AppColors.grey500)),
            value: _createActivity,
            activeThumbColor: const Color(0xFF1B59F8),
            onChanged: (val) => setState(() => _createActivity = val),
          ),
          if (_createActivity) ...[
            UnifiedDropdownField<String>(
              label: 'Activity Type',
              value: _activityType,
              items: const [
                DropdownMenuItem(value: 'call', child: Text('Phone Call')),
                DropdownMenuItem(value: 'whatsapp', child: Text('WhatsApp Message')),
                DropdownMenuItem(value: 'meeting', child: Text('Meeting / Demo')),
                DropdownMenuItem(value: 'email', child: Text('Email Sent')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _activityType = val);
              },
            ),
            UnifiedTextField(label: 'Activity Subject', controller: _activitySubjectCtrl, hint: 'e.g. Introduced solutions catalog'),
          ],
          const SizedBox(height: 8),

          // ── Notes & Description ───────────────────────────
          Text('NOTES & DESCRIPTION', style: AppTypography.overline(color: AppColors.grey500)),
          const SizedBox(height: 10),
          UnifiedTextField(label: 'Contact Notes', controller: _notesCtrl, hint: 'Add background, preferences, or meeting notes...', maxLines: 3),
        ],
      ),
    );
  }
}
