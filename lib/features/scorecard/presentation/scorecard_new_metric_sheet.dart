import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/components/unified_form.dart';
import 'scorecard_provider.dart';

class ScorecardNewMetricSheet extends ConsumerStatefulWidget {
  final String defaultTimeframe;

  const ScorecardNewMetricSheet({
    super.key,
    this.defaultTimeframe = 'daily',
  });

  static void show(BuildContext context, {String defaultTimeframe = 'daily'}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ScorecardNewMetricSheet(defaultTimeframe: defaultTimeframe),
    );
  }

  @override
  ConsumerState<ScorecardNewMetricSheet> createState() => _ScorecardNewMetricSheetState();
}

class _ScorecardNewMetricSheetState extends ConsumerState<ScorecardNewMetricSheet> {
  final _titleCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _targetValueCtrl = TextEditingController(text: '10');
  final _unitLabelCtrl = TextEditingController(text: 'calls');

  late String _timeframe;
  String _valueType = 'number';
  String _dataSource = 'manual';
  String _targetOperator = 'gte';

  @override
  void initState() {
    super.initState();
    _timeframe = widget.defaultTimeframe;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descriptionCtrl.dispose();
    _targetValueCtrl.dispose();
    _unitLabelCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a metric title')),
      );
      return;
    }

    final data = <String, dynamic>{
      'title': title,
      'description': _descriptionCtrl.text.trim().isNotEmpty ? _descriptionCtrl.text.trim() : null,
      'timeframe': _timeframe,
      'data_source': _dataSource,
      'value_type': _valueType,
      'target_operator': _valueType == 'boolean' ? 'boolean_true' : (_valueType == 'text' ? 'text_any' : _targetOperator),
      'target_value': _valueType == 'boolean' || _valueType == 'text' ? null : _targetValueCtrl.text.trim(),
      'unit_label': _unitLabelCtrl.text.trim().isNotEmpty ? _unitLabelCtrl.text.trim() : null,
    };

    try {
      await ref.read(scorecardProvider.notifier).createMetric(data);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cadence metric created successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return UnifiedFormSheet(
      title: 'New Scorecard Metric',
      subtitle: 'Define a key target & operating cadence KPI',
      submitLabel: 'Create Metric',
      onSubmit: _submit,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UnifiedTextField(
            label: 'Metric Title *',
            controller: _titleCtrl,
            hint: 'e.g. Outbound Discovery Calls',
          ),
          UnifiedTextField(
            label: 'Description / Goal Context',
            controller: _descriptionCtrl,
            hint: 'Optional guidance for team members...',
            maxLines: 2,
          ),
          UnifiedDropdownField<String>(
            label: 'Cadence Timeframe',
            value: _timeframe,
            items: const [
              DropdownMenuItem(value: 'daily', child: Text('Daily (Working Days)')),
              DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
              DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
              DropdownMenuItem(value: 'quarterly', child: Text('Quarterly')),
              DropdownMenuItem(value: 'annually', child: Text('Annually')),
            ],
            onChanged: (val) {
              if (val != null) setState(() => _timeframe = val);
            },
          ),
          UnifiedDropdownField<String>(
            label: 'Data Source',
            value: _dataSource,
            items: const [
              DropdownMenuItem(value: 'manual', child: Text('Manual Entry (Self-Reported)')),
              DropdownMenuItem(value: 'crm_activities', child: Text('⚡ Auto: CRM Activities Logged')),
              DropdownMenuItem(value: 'crm_contacts', child: Text('⚡ Auto: New Contacts / Leads')),
              DropdownMenuItem(value: 'crm_deals', child: Text('⚡ Auto: Deals Pipeline')),
            ],
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _dataSource = val;
                  if (val.startsWith('crm_')) {
                    _valueType = 'number';
                  }
                });
              }
            },
          ),
          if (_dataSource == 'manual')
            UnifiedDropdownField<String>(
              label: 'Value Type',
              value: _valueType,
              items: const [
                DropdownMenuItem(value: 'number', child: Text('Numeric Counter (e.g. 10 calls)')),
                DropdownMenuItem(value: 'boolean', child: Text('Yes / No Toggle (e.g. Did review)')),
                DropdownMenuItem(value: 'currency', child: Text('Currency Amount (e.g. Revenue)')),
                DropdownMenuItem(value: 'text', child: Text('Qualitative Note / Text')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _valueType = val);
              },
            ),
          if (_valueType == 'number' || _valueType == 'currency') ...[
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: UnifiedDropdownField<String>(
                    label: 'Target Goal',
                    value: _targetOperator,
                    items: const [
                      DropdownMenuItem(value: 'gte', child: Text('At least (>=)')),
                      DropdownMenuItem(value: 'lte', child: Text('At most (<=)')),
                      DropdownMenuItem(value: 'eq', child: Text('Exactly (==)')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _targetOperator = val);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: UnifiedTextField(
                    label: 'Target Value',
                    controller: _targetValueCtrl,
                    hint: '10',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            UnifiedTextField(
              label: 'Unit Label',
              controller: _unitLabelCtrl,
              hint: 'calls, demos, deals, USD, etc.',
            ),
          ],
        ],
      ),
    );
  }
}
