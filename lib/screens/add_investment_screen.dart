import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/investment_model.dart';
import '../providers/investment_provider.dart';
import '../widgets/investment_form_fields.dart';

class AddInvestmentScreen extends ConsumerStatefulWidget {
  final Investment? existingInvestment;
  const AddInvestmentScreen({super.key, this.existingInvestment});

  @override
  ConsumerState<AddInvestmentScreen> createState() =>
      _AddInvestmentScreenState();
}

class _AddInvestmentScreenState extends ConsumerState<AddInvestmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  InvestmentType? _selectedType;
  final Map<String, dynamic> _formData = {};
  bool _isLoading = false;
  bool get _isEditing => widget.existingInvestment != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) _populateExistingData();
  }

  void _populateExistingData() {
    final inv = widget.existingInvestment!;
    _nameController.text = inv.name;
    _selectedType = inv.type;
    _formData.clear();
    _formData.addAll(inv.additionalData);
    _formData['amount'] = inv.amount;
    _formData['startDate'] = inv.startDate;
    _formData['maturityDate'] = inv.maturityDate;
    _formData['status'] = inv.status;
  }

  void _onFieldChanged(String key, dynamic value) {
    setState(() {
      _formData[key] = value;
    });
  }

  Future<void> _saveInvestment() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final mode = (_formData['investmentMode'] as String?)?.toUpperCase();
    _formData['investmentMode'] = (mode == 'SIP') ? 'SIP' : 'LUMPSUM';

   /* if (mode == 'SIP') {
      if (_formData['startDate'] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select SIP Start Date'), backgroundColor: Colors.red),
        );
        return;
      }
      final nav = _formData['currentNAV'] as double? ?? 0.0;
      if (nav <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter valid Current NAV'), backgroundColor: Colors.red),
        );
        return;

      
      }
    }*/

    setState(() => _isLoading = true);

    try {
      final amount      = _formData['amount'] as double?       ?? 0.0;
      final DateTime? startDate = _formData['startDate'] as DateTime?; 
      final maturityDate= _formData['maturityDate'] as DateTime?;
      final status      = _formData['status'] as InvestmentStatus;

      final inv = Investment(
        id: _isEditing ? widget.existingInvestment!.id : null,
        name: _nameController.text.trim(),
        amount: amount,
        startDate: startDate ?? DateTime.now(),
        maturityDate: maturityDate,
        status: status,
        type: _selectedType!,
        additionalData: Map.from(_formData)
          ..remove('amount')
          ..remove('startDate')
          //..remove('maturityDate')
          ..remove('status'),
        createdAt: _isEditing ? widget.existingInvestment!.createdAt : null,
      );

      final notifier = ref.read(investmentListProvider.notifier);
      if (_isEditing) {
        await notifier.updateInvestment(inv);
      } else {
        await notifier.addInvestment(inv);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Investment updated' : 'Investment added'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Investment?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(investmentListProvider.notifier)
                .deleteInvestment(widget.existingInvestment!.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Investment deleted'), backgroundColor: Colors.green),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Investment' : 'Add Investment'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: _isEditing
            ? [IconButton(icon: const Icon(Icons.delete), onPressed: _showDeleteConfirmation)]
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Fund Name *', border: OutlineInputBorder()),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<InvestmentType>(
              value: _selectedType,
              decoration: const InputDecoration(labelText: 'Type *', border: OutlineInputBorder()),
              items: InvestmentType.values
                  .map((t) => DropdownMenuItem(value: t, child: Text(t.displayName)))
                  .toList(),
              onChanged: (v) {
                setState(() {
                  if (_selectedType != v) {
                    final preserved = _formData['investmentMode'];
                    _selectedType = v;
                    _formData.clear();
                    if (preserved != null) _formData['investmentMode'] = preserved;
                  }
                });
              },
              validator: (v) => v == null ? 'Select type' : null,
            ),
            const SizedBox(height: 16),
            if (_selectedType != null)
              InvestmentFormFields(
                investmentType: _selectedType!,
                formData: _formData,
                formKey: _formKey,
                onFieldChanged: _onFieldChanged,
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveInvestment,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(_isEditing ? 'Update' : 'Add'),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
