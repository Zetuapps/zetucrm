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
  bool _isSearchOpen = false;

  final List<String> _statusFilters = [
    'All',
    'New',
    'Contacted',
    'Qualified',
    'Proposal',
    'Won',
    'Lost',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openContactForm([Map<String, dynamic>? contact]) {
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

    final primaryBlue = const Color(0xFF1B59F8);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF10141D) : primaryBlue,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top Royal Blue Banner Header (Matching Reference Image)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Leads & Contacts',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                    ),
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
                      IconButton(
                        icon: const Icon(
                          LucideIcons.slidersHorizontal,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Collapsible Search Input Field
            if (_isSearchOpen)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search leads by name, company, or phone...',
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

            // White Main Body Card (Curved top overlay)
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
                    // Horizontal Status Tabs Bar (Matching Image: Claimed, Interested, Meeting Done...)
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

                    // Contacts Reactive Stream List with Shimmer UX Loading State
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          await ref.read(syncProvider.notifier).pullAllInitialData();
                        },
                        child: StreamBuilder(
                          stream: db.select(db.contactsTable).watch(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return AppShimmer.cardListShimmer(isDark: isDark, count: 5);
                            }

                            final contacts = snapshot.data ?? [];
                            final filtered = contacts.where((c) {
                              // Filter by search query
                              if (_searchQuery.isNotEmpty) {
                                final fullName = '${c.firstName} ${c.middleName ?? ''} ${c.lastName ?? ''}'.toLowerCase();
                                final company = (c.company ?? '').toLowerCase();
                                final phone = (c.phone ?? '').toLowerCase();
                                final matches = fullName.contains(_searchQuery) || company.contains(_searchQuery) || phone.contains(_searchQuery);
                                if (!matches) return false;
                              }

                              // Filter by status tab
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
                                actionLabel: '+ Add Lead',
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
        backgroundColor: const Color(0xFFFF5722), // Vibrant Coral FAB matching reference image
        elevation: 6,
        onPressed: () => _openContactForm(),
        child: const Icon(LucideIcons.plus, color: Colors.white, size: 26),
      ),
    );
  }

  /// Lead / Contact Card Component (Exact Visual Match to User's Reference Image)
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

    // Palette for avatar tint (matching pink, green, amber from reference image)
    final List<Color> avatarColors = [
      const Color(0xFFFFE4E6), // Soft Pink
      const Color(0xFFD1FADF), // Soft Green
      const Color(0xFFFEF0C7), // Soft Amber
      const Color(0xFFE0EAFF), // Soft Blue
    ];
    final avatarBg = avatarColors[contact.localId % avatarColors.length];

    return Container(
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
          // Top Row: Avatar + Name & Info + Kebab Menu
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar with bottom overlay badge (matching image)
              Stack(
                clipBehavior: Clip.none,
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
                  Positioned(
                    bottom: -3,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF5722),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        LucideIcons.ticket,
                        size: 10,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),

              // Full Name & Subtitle Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName,
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF101828),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${contact.title ?? 'Lead'} • ${contact.company ?? 'Individual'} • Score: ${contact.leadScore}',
                      style: TextStyle(
                        color: isDark ? Colors.white54 : const Color(0xFF667085),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // Kebab Menu Icon
              IconButton(
                icon: const Icon(LucideIcons.moreVertical, size: 18),
                color: isDark ? Colors.white54 : const Color(0xFF98A2B3),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => ContactDetailsSheet(contact: contact),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF2F4F7)),
          const SizedBox(height: 12),

          // Bottom Action & Status Row (Matching reference image)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Highlight Status Text
              Expanded(
                child: Text(
                  '— ${contact.leadStatus ?? 'New'} • Updated recently',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF12B76A), // Emerald green highlight
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              // Action Buttons Row (Calendar + Phone circular buttons)
              Row(
                children: [
                  _buildCircleActionButton(
                    icon: LucideIcons.calendar,
                    isDark: isDark,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Task scheduled for $fullName')),
                      );
                    },
                  ),
                  const SizedBox(width: 10),
                  _buildCircleActionButton(
                    icon: LucideIcons.phone,
                    isDark: isDark,
                    onTap: () {
                      if (contact.phone != null && contact.phone!.isNotEmpty) {
                        launchUrl(Uri.parse('tel:${contact.phone}'));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('No phone number recorded')),
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCircleActionButton({
    required IconData icon,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF252D42) : const Color(0xFFF2F4F7),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 16,
          color: isDark ? Colors.white70 : const Color(0xFF344054),
        ),
      ),
    );
  }
}

// ── Contact Form Sheet (Matching Unified Form System) ──────
class _ContactFormSheet extends ConsumerStatefulWidget {
  final Map<String, dynamic>? contact;
  const _ContactFormSheet({this.contact});

  @override
  ConsumerState<_ContactFormSheet> createState() => _ContactFormSheetState();
}

class _ContactFormSheetState extends ConsumerState<_ContactFormSheet> {
  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _middleNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _companyCtrl;
  late final TextEditingController _titleCtrl;
  late final TextEditingController _tinCtrl;
  late final TextEditingController _vrnCtrl;

  String _leadStatus = 'New';
  int _leadScore = 0;
  bool _createDeal = false;
  final TextEditingController _dealTitleCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _firstNameCtrl = TextEditingController(text: widget.contact?['firstName'] ?? '');
    _middleNameCtrl = TextEditingController(text: widget.contact?['middleName'] ?? '');
    _lastNameCtrl = TextEditingController(text: widget.contact?['lastName'] ?? '');
    _emailCtrl = TextEditingController(text: widget.contact?['email'] ?? '');
    _phoneCtrl = TextEditingController(text: widget.contact?['phone'] ?? '');
    _companyCtrl = TextEditingController(text: widget.contact?['company'] ?? '');
    _titleCtrl = TextEditingController(text: widget.contact?['title'] ?? '');
    _tinCtrl = TextEditingController(text: widget.contact?['tin'] ?? '');
    _vrnCtrl = TextEditingController(text: widget.contact?['vrn'] ?? '');
    _leadStatus = widget.contact?['leadStatus'] ?? 'New';
    _leadScore = widget.contact?['leadScore'] ?? 0;
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _middleNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _companyCtrl.dispose();
    _titleCtrl.dispose();
    _tinCtrl.dispose();
    _vrnCtrl.dispose();
    _dealTitleCtrl.dispose();
    super.dispose();
  }

  void _saveContact() async {
    final firstName = _firstNameCtrl.text.trim();
    if (firstName.isEmpty && _companyCtrl.text.trim().isEmpty) return;

    final db = ref.read(databaseProvider);

    final entry = ContactsTableCompanion.insert(
      firstName: firstName.isEmpty ? _companyCtrl.text.trim() : firstName,
      middleName: Value(_middleNameCtrl.text.trim()),
      lastName: Value(_lastNameCtrl.text.trim()),
      email: Value(_emailCtrl.text.trim()),
      phone: Value(_phoneCtrl.text.trim()),
      company: Value(_companyCtrl.text.trim()),
      title: Value(_titleCtrl.text.trim()),
      tin: Value(_tinCtrl.text.trim()),
      vrn: Value(_vrnCtrl.text.trim()),
      leadStatus: Value(_leadStatus),
      leadScore: Value(_leadScore),
      localUpdatedAt: DateTime.now(),
    );

    final contactLocalId = await db.into(db.contactsTable).insert(entry);

    if (_createDeal) {
      final dealTitle = _dealTitleCtrl.text.trim().isNotEmpty
          ? _dealTitleCtrl.text.trim()
          : 'Deal with ${firstName.isEmpty ? _companyCtrl.text.trim() : firstName}';

      await db.into(db.dealsTable).insert(
        DealsTableCompanion.insert(
          title: dealTitle,
          contactLocalId: Value(contactLocalId),
          stageName: const Value('Qualification'),
          amount: const Value(1000.0),
          localUpdatedAt: DateTime.now(),
        ),
      );
    }

    await db.into(db.syncQueueTable).insert(
      SyncQueueTableCompanion.insert(
        entityType: 'contact',
        entityLocalId: contactLocalId,
        operation: 'create',
        payloadJson: '{"first_name": "$firstName", "phone": "${_phoneCtrl.text.trim()}"}',
        createdAt: DateTime.now(),
      ),
    );

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return UnifiedFormSheet(
      title: widget.contact != null ? 'Edit Lead' : 'New Lead / Contact',
      subtitle: 'Enter contact details and lead information',
      submitLabel: widget.contact != null ? 'Update Lead' : 'Save Lead',
      onSubmit: _saveContact,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('BASIC INFORMATION', style: AppTypography.overline(color: AppColors.grey500)),
          const SizedBox(height: 10),
          UnifiedTextField(label: 'First Name *', controller: _firstNameCtrl, hint: 'e.g. Manoj'),
          UnifiedTextField(label: 'Middle Name', controller: _middleNameCtrl, hint: 'e.g. Kumar'),
          UnifiedTextField(label: 'Last Name', controller: _lastNameCtrl, hint: 'e.g. Chawla'),
          UnifiedTextField(label: 'Email Address', controller: _emailCtrl, hint: 'manoj@example.com', keyboardType: TextInputType.emailAddress),
          UnifiedTextField(label: 'Phone Number', controller: _phoneCtrl, hint: '+1 555 0192', keyboardType: TextInputType.phone),

          Text('COMPANY INFORMATION', style: AppTypography.overline(color: AppColors.grey500)),
          const SizedBox(height: 10),
          UnifiedTextField(label: 'Company Name', controller: _companyCtrl, hint: 'e.g. Global Real Estate'),
          UnifiedTextField(label: 'Job Title', controller: _titleCtrl, hint: 'e.g. Director'),
          Row(
            children: [
              Expanded(child: UnifiedTextField(label: 'TIN Number', controller: _tinCtrl, hint: '100-200-300')),
              const SizedBox(width: 12),
              Expanded(child: UnifiedTextField(label: 'VRN Number', controller: _vrnCtrl, hint: '400-500-600')),
            ],
          ),

          Text('LEAD STATUS & DEAL CREATION', style: AppTypography.overline(color: AppColors.grey500)),
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
            ],
            onChanged: (val) {
              if (val != null) setState(() => _leadStatus = val);
            },
          ),

          SwitchListTile(
            title: Text('Create Deal in Pipeline', style: AppTypography.subtitle2(color: isDark ? Colors.white : AppColors.grey900)),
            subtitle: Text('Instantly create an active deal for this lead', style: AppTypography.caption(color: AppColors.grey500)),
            value: _createDeal,
            activeThumbColor: AppColors.primary,
            onChanged: (val) => setState(() => _createDeal = val),
          ),

          if (_createDeal) ...[
            const SizedBox(height: 8),
            UnifiedTextField(label: 'Deal Title', controller: _dealTitleCtrl, hint: 'e.g. Enterprise CRM Deal'),
          ],
        ],
      ),
    );
  }
}
