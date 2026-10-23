import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../../core/sync/sync_provider.dart';
import '../../../core/database/app_database.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_typography.dart';
import '../../../shared/components/app_card.dart';
import '../../../shared/components/app_button.dart';
import '../../../shared/components/app_text_field.dart';
import '../../../shared/components/empty_state.dart';
import '../../../shared/components/app_shimmer.dart';

class DealsScreen extends ConsumerStatefulWidget {
  const DealsScreen({super.key});

  @override
  ConsumerState<DealsScreen> createState() => _DealsScreenState();
}

class _DealsScreenState extends ConsumerState<DealsScreen> {
  final List<String> _stages = [
    'Lead',
    'Contacted',
    'Qualification',
    'Proposal',
    'Negotiation',
    'Won',
    'Lost',
  ];

  void _openDealForm([DealEntry? deal]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DealFormSheet(deal: deal),
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(databaseProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pipeline Deals',
          style: AppTypography.h3(
            color: isDark ? Colors.white : AppColors.grey900,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_chart_rounded, color: AppColors.primary),
            onPressed: () => _openDealForm(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(syncProvider.notifier).pullAllInitialData();
        },
        child: StreamBuilder<List<DealEntry>>(
          stream: db.select(db.dealsTable).watch(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return AppShimmer.cardListShimmer(isDark: isDark);
            }

            final deals = snapshot.data ?? [];
            if (deals.isEmpty) {
              return EmptyState(
                icon: Icons.monetization_on_outlined,
                title: 'No Deals in Pipeline',
                description:
                    'Track potential sales, deal stages, pipeline values, and expected close dates.',
                actionLabel: '+ New Deal',
                onAction: () => _openDealForm(),
              );
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final columnHeight = constraints.maxHeight - 32;

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _stages.map((stage) {
                      final stageDeals = deals
                          .where(
                            (d) =>
                                d.stageName == stage ||
                                (stage == 'Lead' &&
                                    ![
                                      'Contacted',
                                      'Proposal',
                                      'Negotiation',
                                      'Won',
                                      'Lost',
                                    ].contains(d.stageName)),
                          )
                          .toList();
                      final totalVal = stageDeals.fold<double>(
                        0,
                        (sum, d) => sum + d.amount,
                      );

                      return Container(
                        width: 260,
                        height: columnHeight > 100 ? columnHeight : null,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCard : AppColors.grey100,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.grey300,
                          ),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  stage.toUpperCase(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                Chip(
                                  label: Text('${stageDeals.length}'),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                ),
                              ],
                            ),
                            Text(
                              '\$${totalVal.toStringAsFixed(0)} total',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.grey500,
                              ),
                            ),
                            const Divider(),
                            Expanded(
                              child: stageDeals.isEmpty
                                  ? Center(
                                      child: Text(
                                        'No deals in this stage',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDark
                                              ? AppColors.grey600
                                              : AppColors.grey400,
                                        ),
                                      ),
                                    )
                                  : ListView.builder(
                                      padding: EdgeInsets.zero,
                                      itemCount: stageDeals.length,
                                      itemBuilder: (context, index) {
                                        final deal = stageDeals[index];
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 8),
                                          child: AppCard(
                                            onTap: () => _openDealForm(deal),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  deal.title,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      '\$${deal.amount.toStringAsFixed(0)}',
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: AppColors.success,
                                                      ),
                                                    ),
                                                    Text(
                                                      deal.status.toUpperCase(),
                                                      style: const TextStyle(
                                                        fontSize: 10,
                                                        color: AppColors.grey500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _DealFormSheet extends ConsumerStatefulWidget {
  final DealEntry? deal;
  const _DealFormSheet({this.deal});

  @override
  ConsumerState<_DealFormSheet> createState() => _DealFormSheetState();
}

class _DealFormSheetState extends ConsumerState<_DealFormSheet> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _amountCtrl;
  String _stageName = 'Lead';
  String _status = 'open';
  int? _selectedContactId;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.deal?.title ?? '');
    _amountCtrl = TextEditingController(
      text: widget.deal?.amount.toString() ?? '1000',
    );
    _stageName = widget.deal?.stageName ?? 'Lead';
    _status = widget.deal?.status ?? 'open';
    _selectedContactId = widget.deal?.contactLocalId;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  void _saveDeal() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;

    final db = ref.read(databaseProvider);
    final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0.0;

    if (widget.deal != null) {
      await (db.update(
        db.dealsTable,
      )..where((tbl) => tbl.localId.equals(widget.deal!.localId))).write(
        DealsTableCompanion(
          title: drift.Value(title),
          amount: drift.Value(amount),
          stageName: drift.Value(_stageName),
          status: drift.Value(_status),
          contactLocalId: drift.Value(_selectedContactId),
          localUpdatedAt: drift.Value(DateTime.now()),
        ),
      );
    } else {
      await db
          .into(db.dealsTable)
          .insert(
            DealsTableCompanion.insert(
              title: title,
              amount: drift.Value(amount),
              stageName: drift.Value(_stageName),
              status: drift.Value(_status),
              contactLocalId: drift.Value(_selectedContactId),
              localUpdatedAt: DateTime.now(),
            ),
          );
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final db = ref.watch(databaseProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
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
          Text(
            widget.deal != null ? 'Edit Deal' : 'Create New Deal',
            style: AppTypography.h3(),
          ),
          const Divider(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  AppTextField(label: 'Deal Title *', controller: _titleCtrl),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'Amount (\$)',
                    controller: _amountCtrl,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  StreamBuilder<List<ContactEntry>>(
                    stream: db.select(db.contactsTable).watch(),
                    builder: (context, snapshot) {
                      final contacts = snapshot.data ?? [];
                      return DropdownButtonFormField<int?>(
                        initialValue: _selectedContactId,
                        decoration: const InputDecoration(
                          labelText: 'Linked Contact',
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('— Unassigned —'),
                          ),
                          ...contacts.map(
                            (c) => DropdownMenuItem(
                              value: c.localId,
                              child: Text('${c.firstName} ${c.lastName ?? ''}'),
                            ),
                          ),
                        ],
                        onChanged: (val) =>
                            setState(() => _selectedContactId = val),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _stageName,
                    decoration: const InputDecoration(labelText: 'Stage'),
                    items:
                        const [
                              'Lead',
                              'Contacted',
                              'Proposal',
                              'Negotiation',
                              'Won',
                              'Lost',
                            ]
                            .map(
                              (s) => DropdownMenuItem(value: s, child: Text(s)),
                            )
                            .toList(),
                    onChanged: (val) => setState(() => _stageName = val!),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _status,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: const [
                      DropdownMenuItem(value: 'open', child: Text('Open')),
                      DropdownMenuItem(value: 'won', child: Text('Won')),
                      DropdownMenuItem(value: 'lost', child: Text('Lost')),
                    ],
                    onChanged: (val) => setState(() => _status = val!),
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    label: 'Save Deal',
                    width: double.infinity,
                    onPressed: _saveDeal,
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
