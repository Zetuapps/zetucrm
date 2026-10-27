import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../data/bookings_repository.dart';
import '../data/models/booking_model.dart';
import 'bookings_provider.dart';
import '../../../core/database/app_database.dart';
import '../../../core/sync/sync_provider.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_typography.dart';

class CreateBookingSheet extends ConsumerStatefulWidget {
  final ContactEntry? preselectedContact;

  const CreateBookingSheet({super.key, this.preselectedContact});

  @override
  ConsumerState<CreateBookingSheet> createState() => _CreateBookingSheetState();
}

class _CreateBookingSheetState extends ConsumerState<CreateBookingSheet> {
  List<BookingEventTypeModel> _eventTypes = [];
  BookingEventTypeModel? _selectedEventType;

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  List<BookingSlotModel> _availableSlots = [];
  BookingSlotModel? _selectedSlot;

  bool _isLoadingEventTypes = true;
  bool _isLoadingSlots = false;
  bool _isSubmitting = false;

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  ContactEntry? _selectedContact;
  List<ContactEntry> _crmContacts = [];

  @override
  void initState() {
    super.initState();
    _selectedContact = widget.preselectedContact;
    if (_selectedContact != null) {
      _nameCtrl.text = _selectedContact!.firstName;
      _emailCtrl.text = _selectedContact!.email ?? '';
      _phoneCtrl.text = _selectedContact!.phone ?? '';
      _companyCtrl.text = _selectedContact!.company ?? '';
    }
    _fetchEventTypesAndContacts();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _companyCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchEventTypesAndContacts() async {
    final repo = ref.read(bookingsRepositoryProvider);
    final db = ref.read(databaseProvider);

    try {
      final types = await repo.getEventTypes();
      final contacts = await db.select(db.contactsTable).get();
      contacts.sort((a, b) => a.firstName.toLowerCase().compareTo(b.firstName.toLowerCase()));

      if (mounted) {
        setState(() {
          _eventTypes = types;
          if (types.isNotEmpty) {
            _selectedEventType = types.first;
          }
          _crmContacts = contacts;
          _isLoadingEventTypes = false;
        });

        if (_selectedEventType != null) {
          _fetchSlots();
        }
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingEventTypes = false);
    }
  }

  Future<void> _fetchSlots() async {
    if (_selectedEventType == null) return;
    setState(() {
      _isLoadingSlots = true;
      _availableSlots = [];
      _selectedSlot = null;
    });

    final repo = ref.read(bookingsRepositoryProvider);
    final dateStr = _selectedDate.toString().substring(0, 10);

    try {
      final slotsMap = await repo.getSlots(
        eventTypeId: _selectedEventType!.id,
        fromDate: dateStr,
        toDate: dateStr,
      );

      final slotsForDay = slotsMap[dateStr] ?? [];
      if (mounted) {
        setState(() {
          _availableSlots = slotsForDay;
          if (slotsForDay.isNotEmpty) {
            _selectedSlot = slotsForDay.first;
          }
          _isLoadingSlots = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingSlots = false);
    }
  }

  void _onContactSelected(ContactEntry? contact) {
    setState(() {
      _selectedContact = contact;
      if (contact != null) {
        _nameCtrl.text = contact.firstName;
        _emailCtrl.text = contact.email ?? '';
        _phoneCtrl.text = contact.phone ?? '';
        _companyCtrl.text = contact.company ?? '';
      }
    });
  }

  Future<void> _submitBooking() async {
    if (_selectedEventType == null) {
      _showSnack('Please select an Event Type', isError: true);
      return;
    }

    if (_selectedSlot == null) {
      _showSnack('Please select an available time slot', isError: true);
      return;
    }

    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();

    if (name.isEmpty) {
      _showSnack('Please enter guest or customer name', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final repo = ref.read(bookingsRepositoryProvider);
      await repo.createBooking(
        eventTypeId: _selectedEventType!.id,
        startAt: _selectedSlot!.start,
        contactId: _selectedContact?.serverId,
        guestName: name,
        guestEmail: email.isNotEmpty ? email : null,
        guestPhone: _phoneCtrl.text.trim().isNotEmpty ? _phoneCtrl.text.trim() : null,
        guestCompany: _companyCtrl.text.trim().isNotEmpty ? _companyCtrl.text.trim() : null,
        notes: _notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : null,
        createLead: true,
      );

      // Refresh list
      ref.read(bookingsProvider.notifier).loadBookings(refresh: true);

      if (mounted) {
        Navigator.pop(context);
        _showSnack('Appointment scheduled successfully!');
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      _showSnack('Failed to schedule: $e', isError: true);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 16,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Schedule New Appointment',
                style: AppTypography.h3(color: isDark ? Colors.white : AppColors.grey900),
              ),
              IconButton(
                icon: const Icon(LucideIcons.x),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(),

          Expanded(
            child: _isLoadingEventTypes
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Event Type Dropdown
                        Text('1. Select Service / Event Type *', style: AppTypography.subtitle2(color: isDark ? Colors.white : AppColors.grey900)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<BookingEventTypeModel>(
                          value: _selectedEventType,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                          items: _eventTypes.map((et) {
                            return DropdownMenuItem(
                              value: et,
                              child: Text('${et.title} (${et.durationMinutes} min)'),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() => _selectedEventType = val);
                            _fetchSlots();
                          },
                        ),
                        const SizedBox(height: 16),

                        // Date Picker
                        Text('2. Meeting Date *', style: AppTypography.subtitle2(color: isDark ? Colors.white : AppColors.grey900)),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 60)),
                            );
                            if (picked != null) {
                              setState(() => _selectedDate = picked);
                              _fetchSlots();
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade400),
                            ),
                            child: Row(
                              children: [
                                const Icon(LucideIcons.calendar, size: 18, color: Color(0xFF1B59F8)),
                                const SizedBox(width: 10),
                                Text(
                                  _selectedDate.toString().substring(0, 10),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                const Spacer(),
                                const Text('Change Date', style: TextStyle(color: Color(0xFF1B59F8), fontWeight: FontWeight.w600, fontSize: 13)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Time Slots
                        Text('3. Available Time Slots *', style: AppTypography.subtitle2(color: isDark ? Colors.white : AppColors.grey900)),
                        const SizedBox(height: 8),
                        if (_isLoadingSlots)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (_availableSlots.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                            ),
                            child: const Text(
                              'No slots available on this date. Please select another date.',
                              style: TextStyle(color: Colors.orange, fontSize: 13),
                            ),
                          )
                        else
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _availableSlots.map((slot) {
                              final isSelected = _selectedSlot?.startUtc == slot.startUtc;
                              return ChoiceChip(
                                label: Text(slot.timeLabel),
                                selected: isSelected,
                                selectedColor: const Color(0xFF1B59F8),
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black87),
                                  fontWeight: FontWeight.bold,
                                ),
                                onSelected: (_) => setState(() => _selectedSlot = slot),
                              );
                            }).toList(),
                          ),
                        const SizedBox(height: 20),

                        // CRM Contact Selection
                        Text('4. Link CRM Contact (Optional)', style: AppTypography.subtitle2(color: isDark ? Colors.white : AppColors.grey900)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<ContactEntry?>(
                          value: _selectedContact,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            hintText: 'Select contact from CRM...',
                          ),
                          items: [
                            const DropdownMenuItem<ContactEntry?>(
                              value: null,
                              child: Text('Manual guest input (No link)'),
                            ),
                            ..._crmContacts.map((c) {
                              return DropdownMenuItem<ContactEntry?>(
                                value: c,
                                child: Text('${c.firstName} ${c.company != null ? "(${c.company})" : ""}'),
                              );
                            }),
                          ],
                          onChanged: _onContactSelected,
                        ),
                        const SizedBox(height: 16),

                        // Guest Name
                        Text('Guest Name *', style: AppTypography.subtitle2(color: isDark ? Colors.white : AppColors.grey900)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _nameCtrl,
                          decoration: InputDecoration(
                            hintText: 'e.g. Sarah Connor',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Email & Phone
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Email', style: AppTypography.subtitle2(color: isDark ? Colors.white : AppColors.grey900)),
                                  const SizedBox(height: 6),
                                  TextField(
                                    controller: _emailCtrl,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                      hintText: 'client@example.com',
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Phone Number', style: AppTypography.subtitle2(color: isDark ? Colors.white : AppColors.grey900)),
                                  const SizedBox(height: 6),
                                  TextField(
                                    controller: _phoneCtrl,
                                    keyboardType: TextInputType.phone,
                                    decoration: InputDecoration(
                                      hintText: '+255 7...',
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Company
                        Text('Company / Organization', style: AppTypography.subtitle2(color: isDark ? Colors.white : AppColors.grey900)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _companyCtrl,
                          decoration: InputDecoration(
                            hintText: 'e.g. Acme Safari Ltd',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Notes
                        Text('Meeting Agenda / Special Notes', style: AppTypography.subtitle2(color: isDark ? Colors.white : AppColors.grey900)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _notesCtrl,
                          maxLines: 2,
                          decoration: InputDecoration(
                            hintText: 'Discussion items or client requirements...',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1B59F8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: _isSubmitting ? null : _submitBooking,
                            child: _isSubmitting
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                                    'Confirm & Book Appointment',
                                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
