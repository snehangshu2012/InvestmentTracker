import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/investment_model.dart';

class InvestmentFormFields extends StatelessWidget {
  final InvestmentType investmentType;
  final Map<String, dynamic> formData;
  final Function(String key, dynamic value) onFieldChanged;
  final GlobalKey<FormState> formKey;

  const InvestmentFormFields({
    super.key,
    required this.investmentType,
    required this.formData,
    required this.onFieldChanged,
    required this.formKey,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      // <-- No nested Form here!
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBasicFields(context),
        const SizedBox(height: 24),
        _buildTypeSpecificFields(context),
      ],
    );
  }

  Widget _buildBasicFields(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Investment Name
        /*TextFormField(
          initialValue: formData['name'] as String?,
          decoration: const InputDecoration(
            labelText: 'Investment Name *',
            hintText: 'Enter investment name',
            prefixIcon: Icon(Icons.title),
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter an investment name';
            }
            return null;
          },
          onSaved: (value) => onFieldChanged('name', value),
          onChanged: (value) => onFieldChanged('name', value),
        ),
        const SizedBox(height: 16),*/

        // Investment Amount
        /*TextFormField(
          initialValue: formData['amount']?.toString(),
          decoration: const InputDecoration(
            labelText: 'Investment Amount (₹) *',
            hintText: 'Enter amount in rupees',
            prefixIcon: Icon(Icons.currency_rupee),
            border: OutlineInputBorder(),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the investment amount';
            }
            final amount = double.tryParse(value);
            if (amount == null || amount <= 0) {
              return 'Please enter a valid amount';
            }
            return null;
          },
          onSaved: (value) {
            final amount = double.tryParse(value ?? '0') ?? 0.0;
            onFieldChanged('amount', amount);
          },
          onChanged: (value) {
            final amount = double.tryParse(value) ?? 0.0;
            onFieldChanged('amount', amount);
          },
        ),
        const SizedBox(height: 16),*/

        // Start Date
        /* InkWell(
          onTap: () => _selectDate(context, 'startDate'),
          child: IgnorePointer(
            child: TextFormField(
              initialValue: formData['startDate'] != null
                  ? _formatDate(formData['startDate'] as DateTime)
                  : null,
              decoration: const InputDecoration(
                labelText: 'Start Date *',
                hintText: 'Select start date',
                prefixIcon: Icon(Icons.calendar_today),
                suffixIcon: Icon(Icons.arrow_drop_down),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a start date';
                }
                return null;
              },
            ),
          ),
        ),
        const SizedBox(height: 16),*/

        // Investment Status
        DropdownButtonFormField<InvestmentStatus>(
          initialValue: formData['status'] as InvestmentStatus?,
          decoration: const InputDecoration(
            labelText: 'Status',
            prefixIcon: Icon(Icons.info),
            border: OutlineInputBorder(),
          ),
          items: InvestmentStatus.values.map((status) {
            return DropdownMenuItem(
              value: status,
              child: Text(status.displayName),
            );
          }).toList(),
          onChanged: (value) => onFieldChanged('status', value),
          onSaved: (value) =>
              onFieldChanged('status', value ?? InvestmentStatus.active),
        ),
      ],
    );
  }

  Widget _buildTypeSpecificFields(BuildContext context) {
    switch (investmentType) {
      case InvestmentType.fixedDeposit:
        return _buildFixedDepositFields(context);
      case InvestmentType.recurringDeposit:
        return _buildRecurringDepositFields(context);
      case InvestmentType.ppf:
        return _buildPPFFields(context);
      case InvestmentType.nps:
        return _buildNPSFields(context);
      case InvestmentType.mutualFundEquity:
      case InvestmentType.mutualFundDebt:
      case InvestmentType.mutualFundHybrid:
        return _buildMutualFundFields(context);
      case InvestmentType.stocks:
        return _buildStocksFields(context);
      case InvestmentType.goldETF:
      case InvestmentType.goldDigital:
      case InvestmentType.goldPhysical:
        return _buildGoldFields(context);
      case InvestmentType.realEstate:
        return _buildRealEstateFields(context);
      case InvestmentType.crypto:
        return _buildCryptoFields(context);
      case InvestmentType.bonds:
        return _buildBondsFields(context);
      case InvestmentType.ulip:
        return _buildULIPFields(context);
      case InvestmentType.epf:
        return _buildEPFFields(context);
      case InvestmentType.other:
        return _buildOtherFields(context);
    }
  }

  Widget _buildFixedDepositFields(BuildContext context) {
    return Column(
      children: [
        // Bank Name
        TextFormField(
          initialValue: formData['bankName'] as String?,
          decoration: const InputDecoration(
            labelText: 'Bank Name *',
            hintText: 'Enter bank name',
            prefixIcon: Icon(Icons.business),
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the bank name';
            }
            return null;
          },
          onSaved: (value) => onFieldChanged('bankName', value),
          onChanged: (value) => onFieldChanged('bankName', value),
        ),
        const SizedBox(height: 16),

        // Invested Amount
        TextFormField(
          initialValue: formData['amount']?.toString(),
          decoration: const InputDecoration(
            labelText: 'Invested Amount (₹) *',
            hintText: 'Enter invested amount',
            prefixIcon: Icon(Icons.currency_rupee),
            border: OutlineInputBorder(),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the invested amount';
            }
            final amount = double.tryParse(value);
            if (amount == null || amount <= 0) {
              return 'Please enter a valid amount greater than 0';
            }
            return null;
          },
          onSaved: (value) {
            final amount = double.tryParse(value ?? '0') ?? 0.0;
            onFieldChanged('amount', amount);
          },
          onChanged: (value) {
            final amount = double.tryParse(value) ?? 0.0;
            onFieldChanged('amount', amount);
          },
        ),
        const SizedBox(height: 16),
        // Interest Rate
        TextFormField(
          initialValue: formData['interestRate']?.toString(),
          decoration: const InputDecoration(
            labelText: 'Interest Rate (%) *',
            hintText: 'Enter interest rate',
            prefixIcon: Icon(Icons.percent),
            border: OutlineInputBorder(),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the interest rate';
            }
            final rate = double.tryParse(value);
            if (rate == null || rate <= 0 || rate > 50) {
              return 'Please enter a valid interest rate (0-50%)';
            }
            return null;
          },
          onSaved: (value) {
            final rate = double.tryParse(value ?? '0') ?? 0.0;
            onFieldChanged('interestRate', rate);
          },
          onChanged: (value) {
            final rate = double.tryParse(value) ?? 0.0;
            onFieldChanged('interestRate', rate);
          },
        ),
        const SizedBox(height: 16),

        // Start Date via StatefulBuilder
        StatefulBuilder(
          builder: (context, setFieldState) {
            final selectedDate = formData['startDate'] as DateTime?;
            return InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate ?? DateTime.now(),
                  firstDate: DateTime(1980),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  onFieldChanged('startDate', picked);
                  setFieldState(() {}); // rebuild this field
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Start Date *',
                  prefixIcon: Icon(Icons.calendar_today),
                  suffixIcon: Icon(Icons.arrow_drop_down),
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  selectedDate != null
                      ? _formatDate(selectedDate)
                      : 'Select start date',
                  style: TextStyle(
                    color: selectedDate != null ? null : Colors.grey,
                  ),
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 16),
        // Maturity Date
// Maturity Date via StatefulBuilder
        StatefulBuilder(
          builder: (context, setFieldState) {
            final maturityDate = formData['maturityDate'] as DateTime?;
            return InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: maturityDate ?? DateTime.now(),
                  firstDate: DateTime.now(), // maturity can’t be before today
                  lastDate: DateTime(2050), // adjust as needed
                );
                if (picked != null) {
                  onFieldChanged('maturityDate', picked);
                  setFieldState(() {}); // rebuild this field
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Maturity Date *',
                  prefixIcon: Icon(Icons.event),
                  suffixIcon: Icon(Icons.arrow_drop_down),
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  maturityDate != null
                      ? _formatDate(maturityDate)
                      : 'Select maturity date',
                  style: TextStyle(
                    color: maturityDate != null ? null : Colors.grey,
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),

        // Compounding Frequency
        DropdownButtonFormField<String>(
          initialValue: formData['compoundingFreq'] as String? ?? 'Quarterly',
          decoration: const InputDecoration(
            labelText: 'Compounding Frequency',
            prefixIcon: Icon(Icons.repeat),
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'Annually', child: Text('Annually')),
            DropdownMenuItem(value: 'Half-yearly', child: Text('Half-yearly')),
            DropdownMenuItem(value: 'Quarterly', child: Text('Quarterly')),
            DropdownMenuItem(value: 'Monthly', child: Text('Monthly')),
          ],
          onChanged: (value) => onFieldChanged('compoundingFreq', value),
          onSaved: (value) =>
              onFieldChanged('compoundingFreq', value ?? 'Quarterly'),
        ),
      ],
    );
  }

  Widget _buildRecurringDepositFields(BuildContext context) {
    return Column(
      children: [
        // Bank Name
        TextFormField(
          initialValue: formData['bankName'] as String?,
          decoration: const InputDecoration(
            labelText: 'Bank Name *',
            hintText: 'Enter bank name',
            prefixIcon: Icon(Icons.business),
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the bank name';
            }
            return null;
          },
          onSaved: (value) => onFieldChanged('bankName', value),
          onChanged: (value) => onFieldChanged('bankName', value),
        ),
        const SizedBox(height: 16),

        // Monthly Amount
        TextFormField(
          initialValue: formData['amount']?.toString(),
          decoration: const InputDecoration(
            labelText: 'Monthly Amount (₹) *',
            hintText: 'Enter monthly contribution',
            prefixIcon: Icon(Icons.currency_rupee),
            border: OutlineInputBorder(),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the monthly amount';
            }
            final amount = double.tryParse(value);
            if (amount == null || amount <= 0) {
              return 'Please enter a valid amount';
            }
            return null;
          },
          onSaved: (value) {
            final amount = double.tryParse(value ?? '0') ?? 0.0;
            onFieldChanged('amount', amount);
          },
          onChanged: (value) {
            final amount = double.tryParse(value) ?? 0.0;
            onFieldChanged('amount', amount);
          },
        ),
        const SizedBox(height: 16),

        // Interest Rate
        TextFormField(
          initialValue: formData['interestRate']?.toString(),
          decoration: const InputDecoration(
            labelText: 'Interest Rate (%) *',
            hintText: 'Enter interest rate',
            prefixIcon: Icon(Icons.percent),
            border: OutlineInputBorder(),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the interest rate';
            }
            final rate = double.tryParse(value);
            if (rate == null || rate <= 0) {
              return 'Please enter a valid interest rate';
            }
            return null;
          },
          onSaved: (value) {
            final rate = double.tryParse(value ?? '0') ?? 0.0;
            onFieldChanged('interestRate', rate);
          },
          onChanged: (value) {
            final rate = double.tryParse(value) ?? 0.0;
            onFieldChanged('interestRate', rate);
            onFieldChanged('investmentMode', 'SIP');
          },
        ),
        const SizedBox(height: 16),

        // Start Date via StatefulBuilder
        StatefulBuilder(
          builder: (context, setFieldState) {
            final selectedDate = formData['startDate'] as DateTime?;
            return InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate ?? DateTime.now(),
                  firstDate: DateTime(1980),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  onFieldChanged('startDate', picked);
                  setFieldState(() {}); // rebuild this field
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Start Date *',
                  prefixIcon: Icon(Icons.calendar_today),
                  suffixIcon: Icon(Icons.arrow_drop_down),
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  selectedDate != null
                      ? _formatDate(selectedDate)
                      : 'Select start date',
                  style: TextStyle(
                    color: selectedDate != null ? null : Colors.grey,
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),

        // Maturity Date via StatefulBuilder
        StatefulBuilder(
          builder: (context, setFieldState) {
            final maturityDate = formData['maturityDate'] as DateTime?;
            return InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: maturityDate ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2050),
                );
                if (picked != null) {
                  onFieldChanged('maturityDate', picked);
                  setFieldState(() {}); // rebuild this field
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Maturity Date *',
                  prefixIcon: Icon(Icons.event),
                  suffixIcon: Icon(Icons.arrow_drop_down),
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  maturityDate != null
                      ? _formatDate(maturityDate)
                      : 'Select maturity date',
                  style: TextStyle(
                    color: maturityDate != null ? null : Colors.grey,
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),

        // Compounding Frequency Dropdown
        DropdownButtonFormField<String>(
          initialValue: formData['compoundingFreq'] as String? ?? 'Quarterly',
          decoration: const InputDecoration(
            labelText: 'Compounding Frequency',
            prefixIcon: Icon(Icons.repeat),
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'Annually', child: Text('Annually')),
            DropdownMenuItem(value: 'Half-yearly', child: Text('Half-yearly')),
            DropdownMenuItem(value: 'Quarterly', child: Text('Quarterly')),
            DropdownMenuItem(value: 'Monthly', child: Text('Monthly')),
          ],
          onChanged: (value) => onFieldChanged('compoundingFreq', value),
          onSaved: (value) =>
              onFieldChanged('compoundingFreq', value ?? 'Quarterly'),
        ),
      ],
    );
  }

  Widget _buildPPFFields(BuildContext context) {
    return Column(
      children: [
        // PPF Account Number
        TextFormField(
          initialValue: formData['accountNumber'] as String?,
          decoration: const InputDecoration(
            labelText: 'PPF Account Number',
            hintText: 'Enter PPF account number',
            prefixIcon: Icon(Icons.account_balance),
            border: OutlineInputBorder(),
          ),
          onSaved: (value) => onFieldChanged('accountNumber', value),
          onChanged: (value) => onFieldChanged('accountNumber', value),
        ),
        const SizedBox(height: 16),

        // Bank/Post Office
        TextFormField(
          initialValue: formData['institution'] as String?,
          decoration: const InputDecoration(
            labelText: 'Bank/Post Office *',
            hintText: 'Enter bank or post office name',
            prefixIcon: Icon(Icons.business),
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the institution name';
            }
            return null;
          },
          onSaved: (value) => onFieldChanged('institution', value),
          onChanged: (value) => onFieldChanged('institution', value),
        ),
        const SizedBox(height: 16),

        // Interest Rate
        TextFormField(
          initialValue: formData['interestRate']?.toString(),
          decoration: const InputDecoration(
            labelText: 'Interest Rate (%)',
            hintText: 'Enter interest rate',
            prefixIcon: Icon(Icons.percent),
            border: OutlineInputBorder(),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onSaved: (value) {
            final rate = double.tryParse(value ?? '0') ?? 0.0;
            onFieldChanged('interestRate', rate);
          },
          onChanged: (value) {
            final rate = double.tryParse(value) ?? 0.0;
            onFieldChanged('interestRate', rate);
          },
        ),
        const SizedBox(height: 16),

        // Annual Contribution
        TextFormField(
          initialValue: formData['amount']?.toString(),
          decoration: const InputDecoration(
            labelText: 'Annual Contribution (₹)',
            hintText: 'Maximum ₹1.5 lakh per year',
            prefixIcon: Icon(Icons.currency_rupee),
            border: OutlineInputBorder(),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onSaved: (value) {
            final contribution = double.tryParse(value ?? '0') ?? 0.0;
            onFieldChanged('amount', contribution);
          },
          onChanged: (value) {
            final contribution = double.tryParse(value) ?? 0.0;
            onFieldChanged('amount', contribution);
          },
        ),
        const SizedBox(height: 16),

        // Start Date via StatefulBuilder
        StatefulBuilder(
          builder: (context, setFieldState) {
            final selectedDate = formData['startDate'] as DateTime?;
            return InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate ?? DateTime.now(),
                  firstDate: DateTime(1980),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  onFieldChanged('startDate', picked);
                  setFieldState(() {}); // rebuild this field
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Start Date',
                  prefixIcon: Icon(Icons.calendar_today),
                  suffixIcon: Icon(Icons.arrow_drop_down),
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  selectedDate != null
                      ? _formatDate(selectedDate)
                      : 'Select start date',
                  style: TextStyle(
                    color: selectedDate != null ? null : Colors.grey,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildNPSFields(BuildContext context) {
    return Column(
      children: [
        // NPS Number
        TextFormField(
          initialValue: formData['npsNumber'] as String?,
          decoration: const InputDecoration(
            labelText: 'NPS Number',
            hintText: 'Enter NPS number',
            prefixIcon: Icon(Icons.account_balance),
            border: OutlineInputBorder(),
          ),
          onSaved: (value) => onFieldChanged('npsNumber', value),
          onChanged: (value) => onFieldChanged('npsNumber', value),
        ),
        const SizedBox(height: 16),

        // Tier
        DropdownButtonFormField<String>(
          initialValue: formData['tier'] as String? ?? 'Tier 1',
          decoration: const InputDecoration(
            labelText: 'NPS Tier',
            prefixIcon: Icon(Icons.layers),
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(
                value: 'Tier 1', child: Text('Tier 1 (Retirement)')),
            DropdownMenuItem(
                value: 'Tier 2', child: Text('Tier 2 (Voluntary)')),
          ],
          onChanged: (value) => onFieldChanged('tier', value),
          onSaved: (value) => onFieldChanged('tier', value ?? 'Tier 1'),
        ),
        const SizedBox(height: 16),

        // Annual Contribution
        TextFormField(
          initialValue: formData['annualContribution']?.toString(),
          decoration: const InputDecoration(
            labelText: 'Annual Contribution (₹)',
            hintText: 'Enter annual contribution',
            prefixIcon: Icon(Icons.currency_rupee),
            border: OutlineInputBorder(),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onSaved: (value) {
            final contribution = double.tryParse(value ?? '0') ?? 0.0;
            onFieldChanged('annualContribution', contribution);
          },
          onChanged: (value) {
            final contribution = double.tryParse(value) ?? 0.0;
            onFieldChanged('annualContribution', contribution);
          },
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: formData['startDate'] ?? DateTime.now(),
              firstDate: DateTime(1990),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              onFieldChanged('startDate', picked);
            }
          },
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Start Date',
              prefixIcon: Icon(Icons.calendar_today),
              border: OutlineInputBorder(),
            ),
            child: Text(formData['startDate'] != null
                ? DateFormat('dd MMM yyyy').format(formData['startDate'])
                : 'Select start date'),
          ),
        ),

        const SizedBox(height: 16),

// Total Invested Amount field
        TextFormField(
          initialValue: formData['amount']?.toString(),
          decoration: const InputDecoration(
            labelText: 'Total Invested Amount (₹) *',
            prefixIcon: Icon(Icons.account_balance_wallet),
            border: OutlineInputBorder(),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onSaved: (value) {
            final total = double.tryParse(value ?? '0') ?? 0.0;
            onFieldChanged('amount', total);
          },
          onChanged: (value) {
            final total = double.tryParse(value) ?? 0.0;
            onFieldChanged('amount', total);
          },
        ),

        const SizedBox(height: 16),

// Lifecycle Fund Type dropdown
        DropdownButtonFormField<String>(
          initialValue: formData['lifecycleFund'] as String? ?? 'LC75',
          decoration: const InputDecoration(
            labelText: 'Lifecycle Fund',
            prefixIcon: Icon(Icons.trending_up),
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'LC75', child: Text('LC75')),
            DropdownMenuItem(value: 'LC50', child: Text('LC50')),
            DropdownMenuItem(value: 'LC25', child: Text('LC25')),
            DropdownMenuItem(
                value: 'CorporateBond', child: Text('Corporate Bond')),
          ],
          onChanged: (value) => onFieldChanged('lifecycleFund', value),
          onSaved: (value) => onFieldChanged('lifecycleFund', value ?? 'LC75'),
        ),
      ],
    );
  }

  Widget _buildMutualFundFields(BuildContext context) {
    final investmentMode = formData['investmentMode'] as String? ?? 'SIP';

    return Column(
      children: [
        // Fund Name
        TextFormField(
          initialValue: formData['fundName'] as String?,
          decoration: const InputDecoration(
            labelText: 'Fund Name *',
            hintText: 'Enter mutual fund name',
            prefixIcon: Icon(Icons.trending_up),
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the fund name';
            }
            return null;
          },
          onSaved: (value) => onFieldChanged('fundName', value),
          onChanged: (value) => onFieldChanged('fundName', value),
        ),
        const SizedBox(height: 16),

        // AMC Name
        TextFormField(
          initialValue: formData['amcName'] as String?,
          decoration: const InputDecoration(
            labelText: 'AMC Name',
            hintText: 'Enter asset management company',
            prefixIcon: Icon(Icons.business),
            border: OutlineInputBorder(),
          ),
          onSaved: (value) => onFieldChanged('amcName', value),
          onChanged: (value) => onFieldChanged('amcName', value),
        ),
        const SizedBox(height: 16),

        // Investment Mode Dropdown
        DropdownButtonFormField<String>(
          initialValue: formData['investmentMode'] as String?,
          decoration: const InputDecoration(
            labelText: 'Investment Mode',
            prefixIcon: Icon(Icons.payment),
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(
                value: 'SIP', child: Text('SIP (Systematic Investment Plan)')),
            DropdownMenuItem(value: 'LUMPSUM', child: Text('Lump Sum')),
          ],
          onChanged: (value) {
            print('Investment mode changed to: $value');
            onFieldChanged('investmentMode', value);
          },
          onSaved: (value) => onFieldChanged('investmentMode', value ?? 'SIP'),
        ),
        const SizedBox(height: 16),

        // Conditional SIP fields
        if (investmentMode.toLowerCase() == 'sip') ...[
          TextFormField(
            initialValue: formData['amount']?.toString(),
            decoration: const InputDecoration(
              labelText: 'Monthly SIP Amount (₹) *',
              hintText: 'Enter monthly SIP amount',
              prefixIcon: Icon(Icons.payment),
              border: OutlineInputBorder(),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              final v = double.tryParse(value ?? '');
              if (v == null || v <= 0) {
                return 'Please enter a valid monthly SIP amount';
              }
              return null;
            },
            onSaved: (value) {
              final amt = double.tryParse(value ?? '0') ?? 0.0;
              onFieldChanged('amount', amt);
            },
            onChanged: (value) {
              final amt = double.tryParse(value) ?? 0.0;
              onFieldChanged('amount', amt);
            },
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () async {
              final selectedDate = await showDatePicker(
                context: context,
                initialDate:
                    formData['startDate'] as DateTime? ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (selectedDate != null) {
                onFieldChanged('startDate', selectedDate);
              }
            },
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'SIP Start Date *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today),
              ),
              child: Text(
                formData['startDate'] != null
                    ? DateFormat('dd MMM yyyy').format(formData['startDate'])
                    : 'Select start date',
                style: TextStyle(
                  color: formData['startDate'] != null ? null : Colors.grey,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: formData['units']?.toString(),
            decoration: const InputDecoration(
              labelText: 'Units',
              hintText: 'Enter number of units',
              prefixIcon: Icon(Icons.pie_chart),
              border: OutlineInputBorder(),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onSaved: (value) {
              final units = double.tryParse(value ?? '0') ?? 0.0;
              onFieldChanged('units', units);
            },
            onChanged: (value) {
              final units = double.tryParse(value) ?? 0.0;
              onFieldChanged('units', units);
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: formData['currentNAV']?.toString(),
            decoration: const InputDecoration(
              labelText: 'Current NAV (₹) *',
              hintText: 'Enter current NAV',
              prefixIcon: Icon(Icons.account_balance_wallet),
              border: OutlineInputBorder(),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              final nav = double.tryParse(value ?? '');
              if (nav == null || nav <= 0) return 'Please enter a valid NAV';
              return null;
            },
            onSaved: (value) {
              final nav = double.tryParse(value ?? '0') ?? 0.0;
              onFieldChanged('currentNAV', nav);
            },
            onChanged: (value) {
              final nav = double.tryParse(value) ?? 0.0;
              onFieldChanged('currentNAV', nav);
            },
          ),
          const SizedBox(height: 16),
        ],
        // Conditional Lump Sum fields
        if (investmentMode.toLowerCase() == 'lumpsum') ...[
          TextFormField(
            initialValue: formData['amount']?.toString(),
            decoration: const InputDecoration(
              labelText: 'Lump Sum Amount (₹) *',
              hintText: 'Enter lump sum amount',
              prefixIcon: Icon(Icons.payment),
              border: OutlineInputBorder(),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              final amt = double.tryParse(value ?? '');
              if (amt == null || amt <= 0) {
                return 'Please enter a valid lump sum amount';
              }
              return null;
            },
            onSaved: (value) {
              final amt = double.tryParse(value ?? '0') ?? 0.0;
              onFieldChanged('amount', amt);
            },
            onChanged: (value) {
              final amt = double.tryParse(value) ?? 0.0;
              onFieldChanged('amount', amt);
            },
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () async {
              final selectedDate = await showDatePicker(
                context: context,
                initialDate:
                    formData['startDate'] as DateTime? ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (selectedDate != null) {
                onFieldChanged('startDate', selectedDate);
              }
            },
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Start Date *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today),
              ),
              child: Text(
                formData['startDate'] != null
                    ? DateFormat('dd MMM yyyy').format(formData['startDate'])
                    : 'Select start date',
                style: TextStyle(
                  color: formData['startDate'] != null ? null : Colors.grey,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: formData['units']?.toString(),
            decoration: const InputDecoration(
              labelText: 'Units',
              hintText: 'Enter number of units',
              prefixIcon: Icon(Icons.pie_chart),
              border: OutlineInputBorder(),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onSaved: (value) {
              final units = double.tryParse(value ?? '0') ?? 0.0;
              onFieldChanged('units', units);
            },
            onChanged: (value) {
              final units = double.tryParse(value) ?? 0.0;
              onFieldChanged('units', units);
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: formData['currentNAV']?.toString(),
            decoration: const InputDecoration(
              labelText: 'NAV (₹)',
              hintText: 'Enter current NAV',
              prefixIcon: Icon(Icons.account_balance_wallet),
              border: OutlineInputBorder(),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onSaved: (value) {
              final nav = double.tryParse(value ?? '0') ?? 0.0;
              onFieldChanged('currentNAV', nav);
            },
            onChanged: (value) {
              final nav = double.tryParse(value) ?? 0.0;
              onFieldChanged('currentNAV', nav);
            },
          ),
        ],
      ],
    );
  }

  Widget _buildStocksFields(BuildContext context) {
    return Column(
      children: [
        // Stock Symbol
        TextFormField(
          initialValue: formData['symbol'] as String?,
          decoration: const InputDecoration(
            labelText: 'Stock Symbol *',
            hintText: 'e.g., RELIANCE, TCS',
            prefixIcon: Icon(Icons.show_chart),
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.characters,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the stock symbol';
            }
            return null;
          },
          onSaved: (value) => onFieldChanged('symbol', value?.toUpperCase()),
          onChanged: (value) => onFieldChanged('symbol', value.toUpperCase()),
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: formData['amount']?.toString(),
          decoration: const InputDecoration(
            labelText: 'Amount (₹) *',
            hintText: 'Enter amount',
            prefixIcon: Icon(Icons.payment),
            border: OutlineInputBorder(),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (value) {
            final v = double.tryParse(value ?? '');
            if (v == null || v <= 0) {
              return 'Please enter a valid amount';
            }
            return null;
          },
          onSaved: (value) {
            final amt = double.tryParse(value ?? '0') ?? 0.0;
            onFieldChanged('amount', amt);
          },
          onChanged: (value) {
            final amt = double.tryParse(value) ?? 0.0;
            onFieldChanged('amount', amt);
          },
        ),
        const SizedBox(height: 16),

        // Exchange
        DropdownButtonFormField<String>(
          initialValue: formData['exchange'] as String? ?? 'NSE',
          decoration: const InputDecoration(
            labelText: 'Exchange',
            prefixIcon: Icon(Icons.business),
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'NSE', child: Text('NSE')),
            DropdownMenuItem(value: 'BSE', child: Text('BSE')),
          ],
          onChanged: (value) => onFieldChanged('exchange', value),
          onSaved: (value) => onFieldChanged('exchange', value ?? 'NSE'),
        ),
        const SizedBox(height: 16),

        TextFormField(
          initialValue: formData['units']?.toString(),
          decoration: const InputDecoration(
            labelText: 'Units',
            hintText: 'Enter number of units',
            prefixIcon: Icon(Icons.pie_chart),
            border: OutlineInputBorder(),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onSaved: (value) {
            final units = double.tryParse(value ?? '0') ?? 0.0;
            onFieldChanged('units', units);
          },
          onChanged: (value) {
            final units = double.tryParse(value) ?? 0.0;
            onFieldChanged('units', units);
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: formData['currentNAV']?.toString(),
          decoration: const InputDecoration(
            labelText: 'Current Price (₹) *',
            hintText: 'Enter current Price',
            prefixIcon: Icon(Icons.account_balance_wallet),
            border: OutlineInputBorder(),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (value) {
            final nav = double.tryParse(value ?? '');
            if (nav == null || nav <= 0) return 'Please enter a valid Price';
            return null;
          },
          onSaved: (value) {
            final nav = double.tryParse(value ?? '0') ?? 0.0;
            onFieldChanged('currentNAV', nav);
          },
          onChanged: (value) {
            final nav = double.tryParse(value) ?? 0.0;
            onFieldChanged('currentNAV', nav);
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildGoldFields(BuildContext context) {
    final isPhysical = investmentType == InvestmentType.goldPhysical;
    final isDigitalOrETF = investmentType == InvestmentType.goldETF ||
        investmentType == InvestmentType.goldDigital;
    final investmentMode = formData['investmentMode'] as String? ?? 'SIP';

    return Column(
      children: [
        if (isPhysical) ...[
          // Purity
          DropdownButtonFormField<String>(
            initialValue: formData['purity'] as String? ?? '22K',
            decoration: const InputDecoration(
              labelText: 'Gold Purity',
              prefixIcon: Icon(Icons.star),
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: '24K', child: Text('24K (99.9%)')),
              DropdownMenuItem(value: '22K', child: Text('22K (91.6%)')),
              DropdownMenuItem(value: '18K', child: Text('18K (75%)')),
            ],
            onChanged: (value) => onFieldChanged('purity', value),
            onSaved: (value) => onFieldChanged('purity', value ?? '22K'),
          ),
          const SizedBox(height: 16),
          // Weight
          TextFormField(
            initialValue: formData['weight']?.toString(),
            decoration: const InputDecoration(
              labelText: 'Weight (grams) *',
              hintText: 'Enter weight in grams',
              prefixIcon: Icon(Icons.balance),
              border: OutlineInputBorder(),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the weight';
              }
              final weight = double.tryParse(value);
              if (weight == null || weight <= 0) {
                return 'Please enter a valid weight';
              }
              return null;
            },
            onSaved: (value) {
              final weight = double.tryParse(value ?? '0') ?? 0.0;
              onFieldChanged('weight', weight);
            },
            onChanged: (value) {
              final weight = double.tryParse(value) ?? 0.0;
              onFieldChanged('weight', weight);
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: formData['amount']?.toString(),
            decoration: const InputDecoration(
              labelText: 'Amount (₹) *',
              hintText: 'Enter amount invested',
              prefixIcon: Icon(Icons.payment),
              border: OutlineInputBorder(),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              final v = double.tryParse(value ?? '');
              if (v == null || v <= 0) {
                return 'Please enter a valid monthly SIP amount';
              }
              return null;
            },
            onSaved: (value) {
              final amt = double.tryParse(value ?? '0') ?? 0.0;
              onFieldChanged('amount', amt);
            },
            onChanged: (value) {
              final amt = double.tryParse(value) ?? 0.0;
              onFieldChanged('amount', amt);
            },
          ),
        ] else if (isDigitalOrETF) ...[
          // Investment Mode Dropdown
          DropdownButtonFormField<String>(
            initialValue: investmentMode,
            decoration: const InputDecoration(
              labelText: 'Investment Mode',
              prefixIcon: Icon(Icons.payment),
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(
                  value: 'SIP',
                  child: Text('SIP (Systematic Investment Plan)')),
              DropdownMenuItem(value: 'LUMPSUM', child: Text('Lump Sum')),
            ],
            onChanged: (value) => onFieldChanged('investmentMode', value),
            onSaved: (value) =>
                onFieldChanged('investmentMode', value ?? 'SIP'),
          ),
          const SizedBox(height: 16),
          if (investmentMode.toLowerCase() == 'sip') ...[
            TextFormField(
              initialValue: formData['amount']?.toString(),
              decoration: const InputDecoration(
                labelText: 'Monthly SIP Amount (₹) *',
                hintText: 'Enter monthly SIP amount',
                prefixIcon: Icon(Icons.payment),
                border: OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                final v = double.tryParse(value ?? '');
                if (v == null || v <= 0) {
                  return 'Please enter a valid monthly SIP amount';
                }
                return null;
              },
              onSaved: (value) {
                final amt = double.tryParse(value ?? '0') ?? 0.0;
                onFieldChanged('amount', amt);
              },
              onChanged: (value) {
                final amt = double.tryParse(value) ?? 0.0;
                onFieldChanged('amount', amt);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: formData['units']?.toString(),
              decoration: const InputDecoration(
                labelText: 'Units',
                hintText: 'Enter number of units',
                prefixIcon: Icon(Icons.pie_chart),
                border: OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              onSaved: (value) {
                final units = double.tryParse(value ?? '0') ?? 0.0;
                onFieldChanged('units', units);
              },
              onChanged: (value) {
                final units = double.tryParse(value) ?? 0.0;
                onFieldChanged('units', units);
              },
            ),
          ] else ...[
            TextFormField(
              initialValue: formData['amount']?.toString(),
              decoration: const InputDecoration(
                labelText: 'Lump Sum Amount (₹) *',
                hintText: 'Enter lump sum amount',
                prefixIcon: Icon(Icons.payment),
                border: OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                final amt = double.tryParse(value ?? '');
                if (amt == null || amt <= 0) {
                  return 'Please enter a valid lump sum amount';
                }
                return null;
              },
              onSaved: (value) {
                final amt = double.tryParse(value ?? '0') ?? 0.0;
                onFieldChanged('amount', amt);
              },
              onChanged: (value) {
                final amt = double.tryParse(value) ?? 0.0;
                onFieldChanged('amount', amt);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: formData['units']?.toString(),
              decoration: const InputDecoration(
                labelText: 'Units *',
                hintText: 'Enter number of units',
                prefixIcon: Icon(Icons.pie_chart),
                border: OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the units';
                }
                final units = double.tryParse(value);
                if (units == null || units <= 0) {
                  return 'Please enter valid units';
                }
                return null;
              },
              onSaved: (value) {
                final units = double.tryParse(value ?? '0') ?? 0.0;
                onFieldChanged('units', units);
              },
              onChanged: (value) {
                final units = double.tryParse(value) ?? 0.0;
                onFieldChanged('units', units);
              },
            ),
          ],
        ],
        const SizedBox(height: 16),
        // Start Date
        InkWell(
          onTap: () async {
            final selectedDate = await showDatePicker(
              context: context,
              initialDate: formData['startDate'] as DateTime? ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
            );
            if (selectedDate != null) {
              onFieldChanged('startDate', selectedDate);
            }
          },
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Start Date *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.calendar_today),
            ),
            child: Text(
              formData['startDate'] != null
                  ? DateFormat('dd MMM yyyy').format(formData['startDate'])
                  : 'Select start date',
              style: TextStyle(
                color: formData['startDate'] != null ? null : Colors.grey,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Current Price/NAV
        TextFormField(
          initialValue: formData['currentNAV']?.toString(),
          decoration: InputDecoration(
            labelText:
                isPhysical ? 'Current Price per gram (₹)' : 'Current NAV (₹)',
            hintText: 'Enter current price',
            prefixIcon: const Icon(Icons.currency_rupee),
            border: const OutlineInputBorder(),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (value) {
            final nav = double.tryParse(value?.trim() ?? '');
            if (nav == null || nav <= 0) {
              return 'Please enter a valid Current NAV';
            }
            return null;
          },
          onSaved: (value) {
            final price = double.tryParse(value?.trim() ?? '0') ?? 0.0;
            onFieldChanged('currentNAV', price);
          },
          onChanged: (value) {
            final price = double.tryParse(value.trim()) ?? 0.0;
            onFieldChanged('currentNAV', price);
          },
        ),
      ],
    );
  }

  Widget _buildRealEstateFields(BuildContext context) {
    return Column(
      children: [
        // Property Type
        DropdownButtonFormField<String>(
          initialValue: formData['propertyType'] as String?,
          decoration: const InputDecoration(
            labelText: 'Property Type *',
            prefixIcon: Icon(Icons.home),
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'Residential', child: Text('Residential')),
            DropdownMenuItem(value: 'Commercial', child: Text('Commercial')),
            DropdownMenuItem(value: 'Plot', child: Text('Plot/Land')),
            DropdownMenuItem(value: 'Industrial', child: Text('Industrial')),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select property type';
            }
            return null;
          },
          onChanged: (value) => onFieldChanged('propertyType', value),
          onSaved: (value) => onFieldChanged('propertyType', value),
        ),
        const SizedBox(height: 16),

        // Location
        TextFormField(
          initialValue: formData['location'] as String?,
          decoration: const InputDecoration(
            labelText: 'Location *',
            hintText: 'Enter property location',
            prefixIcon: Icon(Icons.location_on),
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the location';
            }
            return null;
          },
          onSaved: (value) => onFieldChanged('location', value),
          onChanged: (value) => onFieldChanged('location', value),
        ),
        const SizedBox(height: 16),

        // Area
        TextFormField(
          initialValue: formData['area']?.toString(),
          decoration: const InputDecoration(
            labelText: 'Area (sq ft)',
            hintText: 'Enter area in square feet',
            prefixIcon: Icon(Icons.straighten),
            border: OutlineInputBorder(),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onSaved: (value) {
            final area = double.tryParse(value ?? '0') ?? 0.0;
            onFieldChanged('area', area);
          },
          onChanged: (value) {
            final area = double.tryParse(value) ?? 0.0;
            onFieldChanged('area', area);
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: formData['amount']?.toString(),
          decoration: const InputDecoration(
            labelText: 'Amount (₹) *',
            hintText: 'Enter Invested Amount',
            prefixIcon: Icon(Icons.payment),
            border: OutlineInputBorder(),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (value) {
            final v = double.tryParse(value ?? '');
            if (v == null || v <= 0) {
              return 'Please enter a valid monthly SIP amount';
            }
            return null;
          },
          onSaved: (value) {
            final amt = double.tryParse(value ?? '0') ?? 0.0;
            onFieldChanged('amount', amt);
          },
          onChanged: (value) {
            final amt = double.tryParse(value) ?? 0.0;
            onFieldChanged('amount', amt);
          },
        ),
        const SizedBox(height: 16),

        TextFormField(
          initialValue: formData['currentNAV']?.toString(),
          decoration: const InputDecoration(
            labelText: 'Current Price per SQ Ft (₹)',
            hintText: 'Enter Current Price per Square Ft ',
            prefixIcon: Icon(Icons.account_balance_wallet),
            border: OutlineInputBorder(),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onSaved: (value) {
            final nav = double.tryParse(value ?? '0') ?? 0.0;
            onFieldChanged('currentNAV', nav);
          },
          onChanged: (value) {
            final nav = double.tryParse(value) ?? 0.0;
            onFieldChanged('currentNAV', nav);
          },
        ),
      ],
    );
  }

  Widget _buildCryptoFields(BuildContext context) {
    return Column(
      children: [
        // Cryptocurrency Name
        // Cryptocurrency Name (e.g., Bitcoin)
        TextFormField(
          initialValue: formData['cryptoName'] as String?,
          decoration: const InputDecoration(
            labelText: 'Cryptocurrency *',
            hintText: 'e.g., Bitcoin, Ethereum',
            prefixIcon: Icon(Icons.currency_bitcoin),
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the cryptocurrency name';
            }
            return null;
          },
          onSaved: (value) => onFieldChanged('cryptoName', value),
          onChanged: (value) => onFieldChanged('cryptoName', value),
        ),
        const SizedBox(height: 16),

        // Symbol (e.g., BTC)
        TextFormField(
          initialValue: formData['symbol'] as String?,
          decoration: const InputDecoration(
            labelText: 'Symbol',
            hintText: 'e.g., BTC, ETH',
            prefixIcon: Icon(Icons.code),
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.characters,
          onSaved: (value) => onFieldChanged('symbol', value?.toUpperCase()),
          onChanged: (value) => onFieldChanged('symbol', value.toUpperCase()),
        ),
        const SizedBox(height: 16),

        // Quantity of Crypto Owned
        TextFormField(
          initialValue: formData['quantity']?.toString(),
          decoration: const InputDecoration(
            labelText: 'Quantity *',
            hintText: 'Enter quantity',
            prefixIcon: Icon(Icons.account_balance_wallet),
            border: OutlineInputBorder(),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the quantity';
            }
            final qty = double.tryParse(value);
            if (qty == null || qty <= 0) {
              return 'Please enter a valid quantity';
            }
            return null;
          },
          onSaved: (value) {
            final qty = double.tryParse(value ?? '0') ?? 0.0;
            onFieldChanged('quantity', qty);
          },
          onChanged: (value) {
            final qty = double.tryParse(value) ?? 0.0;
            onFieldChanged('quantity', qty);
          },
        ),
        const SizedBox(height: 16),

        // Invested Amount (amount paid in ₹)
        TextFormField(
          initialValue: formData['amount']?.toString(),
          decoration: const InputDecoration(
            labelText: 'Invested Amount (₹) *',
            hintText: 'Amount invested in INR',
            prefixIcon: Icon(Icons.attach_money),
            border: OutlineInputBorder(),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the invested amount';
            }
            final amt = double.tryParse(value);
            if (amt == null || amt <= 0) {
              return 'Please enter a valid amount';
            }
            return null;
          },
          onSaved: (value) {
            final amt = double.tryParse(value ?? '0') ?? 0.0;
            onFieldChanged('amount', amt);
          },
          onChanged: (value) {
            final amt = double.tryParse(value) ?? 0.0;
            onFieldChanged('amount', amt);
          },
        ),
        const SizedBox(height: 16),

        // Purchase Date (optional but recommended)
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate:
                  formData['purchaseDate'] as DateTime? ?? DateTime.now(),
              firstDate:
                  DateTime(2010), // crypto doesn't exist much before 2010
              lastDate: DateTime.now(),
            );
            if (picked != null) onFieldChanged('purchaseDate', picked);
          },
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Purchase Date',
              prefixIcon: Icon(Icons.calendar_today),
              border: OutlineInputBorder(),
            ),
            child: Text(
              formData['purchaseDate'] != null
                  ? DateFormat('dd MMM yyyy').format(formData['purchaseDate'])
                  : 'Select purchase date',
              style: TextStyle(
                color: formData['purchaseDate'] != null ? null : Colors.grey,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Current Price per Unit (in ₹)
        TextFormField(
          initialValue: formData['currentPrice']?.toString(),
          decoration: const InputDecoration(
            labelText: 'Current Price (₹)',
            hintText: 'Price per crypto unit',
            prefixIcon: Icon(Icons.show_chart),
            border: OutlineInputBorder(),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onSaved: (value) {
            final price = double.tryParse(value ?? '0') ?? 0.0;
            onFieldChanged('currentPrice', price);
          },
          onChanged: (value) {
            final price = double.tryParse(value) ?? 0.0;
            onFieldChanged('currentPrice', price);
          },
        ),
        const SizedBox(height: 16),

        // Exchange / Wallet (optional)
        TextFormField(
          initialValue: formData['exchange'] as String?,
          decoration: const InputDecoration(
            labelText: 'Exchange / Wallet',
            hintText: 'e.g., Binance, Coinbase, Metamask',
            prefixIcon: Icon(Icons.account_balance),
            border: OutlineInputBorder(),
          ),
          onSaved: (value) => onFieldChanged('exchange', value),
          onChanged: (value) => onFieldChanged('exchange', value),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildBondsFields(BuildContext context) {
    return Column(
      children: [
        // Bond Name
        TextFormField(
          initialValue: formData['bondName'] as String?,
          decoration: const InputDecoration(
            labelText: 'Bond Name *',
            hintText: 'Enter bond name or ISIN',
            prefixIcon: Icon(Icons.receipt_long),
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the bond name';
            }
            return null;
          },
          onSaved: (value) => onFieldChanged('bondName', value),
          onChanged: (value) => onFieldChanged('bondName', value),
        ),
        const SizedBox(height: 16),

        // Bond Type
        DropdownButtonFormField<String>(
          initialValue: formData['bondType'] as String?,
          decoration: const InputDecoration(
            labelText: 'Bond Type',
            prefixIcon: Icon(Icons.category),
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(
                value: 'Government', child: Text('Government Bond')),
            DropdownMenuItem(value: 'Corporate', child: Text('Corporate Bond')),
            DropdownMenuItem(value: 'Municipal', child: Text('Municipal Bond')),
            DropdownMenuItem(value: 'Treasury', child: Text('Treasury Bond')),
          ],
          onChanged: (value) => onFieldChanged('bondType', value),
          onSaved: (value) => onFieldChanged('bondType', value),
        ),
        const SizedBox(height: 16),

        // Invested Amount
        TextFormField(
          initialValue: formData['amount']?.toString(),
          decoration: const InputDecoration(
            labelText: 'Invested Amount (₹) *',
            hintText: 'Total cash paid incl. accrued interest',
            prefixIcon: Icon(Icons.account_balance),
            border: OutlineInputBorder(),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (v) {
            final x = double.tryParse(v ?? '');
            if (x == null || x <= 0) return 'Enter a valid invested amount';
            return null;
          },
          onSaved: (v) =>
              onFieldChanged('amount', double.tryParse(v ?? '0') ?? 0.0),
          onChanged: (v) => onFieldChanged('amount', double.tryParse(v) ?? 0.0),
        ),
        const SizedBox(height: 16),
        // Face Value
        TextFormField(
          initialValue: formData['faceValue']?.toString(),
          decoration: const InputDecoration(
            labelText: 'Face Value (₹)',
            hintText: 'Enter face value',
            prefixIcon: Icon(Icons.currency_rupee),
            border: OutlineInputBorder(),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onSaved: (value) {
            final faceValue = double.tryParse(value ?? '0') ?? 0.0;
            onFieldChanged('faceValue', faceValue);
          },
          onChanged: (value) {
            final faceValue = double.tryParse(value) ?? 0.0;
            onFieldChanged('faceValue', faceValue);
          },
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate:
                  formData['purchaseDate'] as DateTime? ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null) onFieldChanged('purchaseDate', picked);
          },
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Purchase Date',
              prefixIcon: Icon(Icons.calendar_today),
              border: OutlineInputBorder(),
            ),
            child: Text(
              formData['purchaseDate'] != null
                  ? DateFormat('dd MMM yyyy').format(formData['purchaseDate'])
                  : 'Select purchase date',
              style: TextStyle(
                color: formData['purchaseDate'] != null ? null : Colors.grey,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Quantity
        TextFormField(
          initialValue: formData['quantity']?.toString(),
          decoration: const InputDecoration(
            labelText: 'Quantity',
            hintText: 'Enter number of bonds',
            prefixIcon: Icon(Icons.format_list_numbered),
            border: OutlineInputBorder(),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: false),
          onSaved: (value) {
            final qty = int.tryParse(value ?? '0') ?? 0;
            onFieldChanged('quantity', qty);
          },
          onChanged: (value) {
            final qty = int.tryParse(value) ?? 0;
            onFieldChanged('quantity', qty);
          },
        ),
        const SizedBox(height: 16),
// Coupon Rate
        TextFormField(
          initialValue: formData['couponRate']?.toString(),
          decoration: const InputDecoration(
            labelText: 'Coupon Rate (%)',
            hintText: 'Enter annual coupon rate',
            prefixIcon: Icon(Icons.percent),
            border: OutlineInputBorder(),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onSaved: (value) {
            final rate = double.tryParse(value ?? '0') ?? 0.0;
            onFieldChanged('couponRate', rate);
          },
          onChanged: (value) {
            final rate = double.tryParse(value) ?? 0.0;
            onFieldChanged('couponRate', rate);
          },
        ),
        const SizedBox(height: 16),
// Maturity Date
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate:
                  formData['maturityDate'] as DateTime? ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null) onFieldChanged('maturityDate', picked);
          },
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Maturity Date',
              prefixIcon: Icon(Icons.calendar_today),
              border: OutlineInputBorder(),
            ),
            child: Text(
              formData['maturityDate'] != null
                  ? DateFormat('dd MMM yyyy').format(formData['maturityDate'])
                  : 'Select maturity date',
              style: TextStyle(
                color: formData['maturityDate'] != null ? null : Colors.grey,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Current Market Price (as % of Face Value)
        TextFormField(
          initialValue: formData['currentMarketPrice']?.toString(),
          decoration: const InputDecoration(
            labelText: 'Current Market Price (%)',
            hintText: 'Enter current market price as % of face value',
            prefixIcon: Icon(Icons.attach_money),
            border: OutlineInputBorder(),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onSaved: (value) {
            final price = double.tryParse(value ?? '0') ?? 0.0;
            onFieldChanged('currentMarketPrice', price);
          },
          onChanged: (value) {
            final price = double.tryParse(value) ?? 0.0;
            onFieldChanged('currentMarketPrice', price);
          },
        ),
        const SizedBox(height: 16),

// Coupon Frequency (optional)
        DropdownButtonFormField<String>(
          initialValue: formData['couponFrequency'] as String? ?? 'Annual',
          decoration: const InputDecoration(
            labelText: 'Coupon Frequency',
            prefixIcon: Icon(Icons.timer),
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'Annual', child: Text('Annual')),
            DropdownMenuItem(value: 'Semi-Annual', child: Text('Semi-Annual')),
            DropdownMenuItem(value: 'Quarterly', child: Text('Quarterly')),
          ],
          onChanged: (value) => onFieldChanged('couponFrequency', value),
          onSaved: (value) => onFieldChanged('couponFrequency', value),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildULIPFields(BuildContext context) {
    return Column(
      children: [
        // Policy Number (already present)
        // Insurance Company (already present)
        // Premium Amount (already present)

        // Policy Start Date
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate:
                  formData['policyStartDate'] as DateTime? ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
            );
            if (picked != null) onFieldChanged('policyStartDate', picked);
          },
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Policy Start Date',
              prefixIcon: Icon(Icons.calendar_today),
              border: OutlineInputBorder(),
            ),
            child: Text(
              formData['policyStartDate'] != null
                  ? DateFormat('dd MMM yyyy')
                      .format(formData['policyStartDate'])
                  : 'Select policy start date',
              style: TextStyle(
                color: formData['policyStartDate'] != null ? null : Colors.grey,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Policy Maturity Date
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate:
                  formData['policyMaturityDate'] as DateTime? ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime(2100),
            );
            if (picked != null) onFieldChanged('policyMaturityDate', picked);
          },
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Policy Maturity Date',
              prefixIcon: Icon(Icons.calendar_today),
              border: OutlineInputBorder(),
            ),
            child: Text(
              formData['policyMaturityDate'] != null
                  ? DateFormat('dd MMM yyyy')
                      .format(formData['policyMaturityDate'])
                  : 'Select policy maturity date',
              style: TextStyle(
                color:
                    formData['policyMaturityDate'] != null ? null : Colors.grey,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
// Invested Amount / Premiums Paid
        TextFormField(
          initialValue: formData['amount']?.toString(),
          decoration: const InputDecoration(
            labelText: 'Invested Amount (₹) *',
            hintText: 'Total premiums paid',
            prefixIcon: Icon(Icons.account_balance_wallet),
            border: OutlineInputBorder(),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the invested amount';
            }
            final amt = double.tryParse(value);
            if (amt == null || amt <= 0) {
              return 'Please enter a valid amount';
            }
            return null;
          },
          onSaved: (value) {
            final amt = double.tryParse(value ?? '0') ?? 0.0;
            onFieldChanged('amount', amt);
          },
          onChanged: (value) {
            final amt = double.tryParse(value) ?? 0.0;
            onFieldChanged('amount', amt);
          },
        ),
        const SizedBox(height: 16),
        // Sum Assured
        TextFormField(
          initialValue: formData['sumAssured']?.toString(),
          decoration: const InputDecoration(
            labelText: 'Sum Assured (₹)',
            hintText: 'Enter sum assured',
            prefixIcon: Icon(Icons.security),
            border: OutlineInputBorder(),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onSaved: (value) {
            final sumAssured = double.tryParse(value ?? '0') ?? 0.0;
            onFieldChanged('sumAssured', sumAssured);
          },
          onChanged: (value) {
            final sumAssured = double.tryParse(value) ?? 0.0;
            onFieldChanged('sumAssured', sumAssured);
          },
        ),
        const SizedBox(height: 16),

        // NAV (Net Asset Value) per unit
        TextFormField(
          initialValue: formData['nav']?.toString(),
          decoration: const InputDecoration(
            labelText: 'NAV (₹)',
            hintText: 'Enter latest NAV',
            prefixIcon: Icon(Icons.show_chart),
            border: OutlineInputBorder(),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onSaved: (value) {
            final nav = double.tryParse(value ?? '0') ?? 0.0;
            onFieldChanged('nav', nav);
          },
          onChanged: (value) {
            final nav = double.tryParse(value) ?? 0.0;
            onFieldChanged('nav', nav);
          },
        ),
        const SizedBox(height: 16),

        // Total Units Held
        TextFormField(
          initialValue: formData['units']?.toString(),
          decoration: const InputDecoration(
            labelText: 'Units Held',
            hintText: 'Enter number of units',
            prefixIcon: Icon(Icons.format_list_numbered),
            border: OutlineInputBorder(),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onSaved: (value) {
            final units = double.tryParse(value ?? '0') ?? 0.0;
            onFieldChanged('units', units);
          },
          onChanged: (value) {
            final units = double.tryParse(value) ?? 0.0;
            onFieldChanged('units', units);
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildEPFFields(BuildContext context) {
    return Column(
      children: [
        // UAN (Universal Account Number) - Most Important
        TextFormField(
          initialValue: formData['uan'] as String?,
          decoration: const InputDecoration(
            labelText: 'UAN (Universal Account Number) *',
            hintText: 'Enter your 12-digit UAN',
            prefixIcon: Icon(Icons.credit_card),
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your UAN';
            }
            if (value.length != 12) {
              return 'UAN must be 12 digits';
            }
            return null;
          },
          keyboardType: TextInputType.number,
          maxLength: 12,
          onSaved: (value) => onFieldChanged('uan', value),
          onChanged: (value) => onFieldChanged('uan', value),
        ),
        const SizedBox(height: 16),

        // EPF Account Number
        TextFormField(
          initialValue: formData['epfNumber'] as String?,
          decoration: const InputDecoration(
            labelText: 'EPF Account Number',
            hintText: 'Enter EPF account number',
            prefixIcon: Icon(Icons.account_balance),
            border: OutlineInputBorder(),
          ),
          onSaved: (value) => onFieldChanged('epfNumber', value),
          onChanged: (value) => onFieldChanged('epfNumber', value),
        ),
        const SizedBox(height: 16),

        // Current Employer Name
        TextFormField(
          initialValue: formData['employerName'] as String?,
          decoration: const InputDecoration(
            labelText: 'Current Employer Name *',
            hintText: 'Enter current employer name',
            prefixIcon: Icon(Icons.business),
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the employer name';
            }
            return null;
          },
          onSaved: (value) => onFieldChanged('employerName', value),
          onChanged: (value) => onFieldChanged('employerName', value),
        ),
        const SizedBox(height: 16),

        // Date of Joining EPF
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate:
                  formData['epfStartDate'] as DateTime? ?? DateTime.now(),
              firstDate: DateTime(1950),
              lastDate: DateTime.now(),
            );
            if (picked != null) onFieldChanged('epfStartDate', picked);
          },
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'EPF Start Date',
              prefixIcon: Icon(Icons.calendar_today),
              border: OutlineInputBorder(),
            ),
            child: Text(
              formData['epfStartDate'] != null
                  ? DateFormat('dd MMM yyyy').format(formData['epfStartDate'])
                  : 'Select EPF start date',
              style: TextStyle(
                color: formData['epfStartDate'] != null ? null : Colors.grey,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Total Invested Amount (All contributions till date)
        TextFormField(
          initialValue: formData['amount']?.toString(),
          decoration: const InputDecoration(
            labelText: 'Total Invested Amount (₹) *',
            hintText: 'Total contributions made till date',
            prefixIcon: Icon(Icons.account_balance_wallet),
            border: OutlineInputBorder(),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the total invested amount';
            }
            final amt = double.tryParse(value);
            if (amt == null || amt <= 0) {
              return 'Please enter a valid amount';
            }
            return null;
          },
          onSaved: (value) {
            final amt = double.tryParse(value ?? '0') ?? 0.0;
            onFieldChanged('amount', amt);
          },
          onChanged: (value) {
            final amt = double.tryParse(value) ?? 0.0;
            onFieldChanged('amount', amt);
          },
        ),
        const SizedBox(height: 16),

        // Monthly Employee Contribution
        TextFormField(
          initialValue: formData['monthlyContribution']?.toString(),
          decoration: const InputDecoration(
            labelText: 'Monthly Employee Contribution (₹)',
            hintText: 'Current monthly contribution',
            prefixIcon: Icon(Icons.person),
            border: OutlineInputBorder(),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onSaved: (value) {
            final contribution = double.tryParse(value ?? '0') ?? 0.0;
            onFieldChanged('monthlyContribution', contribution);
          },
          onChanged: (value) {
            final contribution = double.tryParse(value) ?? 0.0;
            onFieldChanged('monthlyContribution', contribution);
          },
        ),
        const SizedBox(height: 16),

        // Current EPF Balance
        TextFormField(
          initialValue: formData['currentBalance']?.toString(),
          decoration: const InputDecoration(
            labelText: 'Current EPF Balance (₹)',
            hintText: 'Latest EPF balance from passbook',
            prefixIcon: Icon(Icons.account_balance),
            border: OutlineInputBorder(),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onSaved: (value) {
            final balance = double.tryParse(value ?? '0') ?? 0.0;
            onFieldChanged('currentBalance', balance);
          },
          onChanged: (value) {
            final balance = double.tryParse(value) ?? 0.0;
            onFieldChanged('currentBalance', balance);
          },
        ),
        const SizedBox(height: 16),

        // EPF Interest Rate (Current year)
        TextFormField(
          initialValue: formData['interestRate']?.toString(),
          decoration: const InputDecoration(
            labelText: 'Interest Rate (%)',
            hintText: 'Current EPF interest rate',
            prefixIcon: Icon(Icons.percent),
            border: OutlineInputBorder(),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onSaved: (value) {
            final rate =
                double.tryParse(value ?? '0') ?? 8.25; // Default EPF rate
            onFieldChanged('interestRate', rate);
          },
          onChanged: (value) {
            final rate = double.tryParse(value) ?? 8.25;
            onFieldChanged('interestRate', rate);
          },
        ),
        const SizedBox(height: 16),

        // Last Updated Date (when balance was checked)
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate:
                  formData['lastUpdated'] as DateTime? ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
            );
            if (picked != null) onFieldChanged('lastUpdated', picked);
          },
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Balance Last Updated',
              prefixIcon: Icon(Icons.update),
              border: OutlineInputBorder(),
            ),
            child: Text(
              formData['lastUpdated'] != null
                  ? DateFormat('dd MMM yyyy').format(formData['lastUpdated'])
                  : 'Select last update date',
              style: TextStyle(
                color: formData['lastUpdated'] != null ? null : Colors.grey,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildOtherFields(BuildContext context) {
    return Column(
      children: [
        // Description
        TextFormField(
          initialValue: formData['description'] as String?,
          decoration: const InputDecoration(
            labelText: 'Description *',
            hintText: 'Enter investment description',
            prefixIcon: Icon(Icons.description),
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a description';
            }
            return null;
          },
          onSaved: (value) => onFieldChanged('description', value),
          onChanged: (value) => onFieldChanged('description', value),
        ),
        const SizedBox(height: 16),

        // Category
        TextFormField(
          initialValue: formData['category'] as String?,
          decoration: const InputDecoration(
            labelText: 'Category',
            hintText: 'Enter investment category',
            prefixIcon: Icon(Icons.category),
            border: OutlineInputBorder(),
          ),
          onSaved: (value) => onFieldChanged('category', value),
          onChanged: (value) => onFieldChanged('category', value),
        ),
        const SizedBox(height: 16),

        // Invested Amount (Total amount put in)
        TextFormField(
          initialValue: formData['amount']?.toString(),
          decoration: const InputDecoration(
            labelText: 'Invested Amount (₹) *',
            hintText: 'Total amount invested',
            prefixIcon: Icon(Icons.account_balance_wallet),
            border: OutlineInputBorder(),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the invested amount';
            }
            final amt = double.tryParse(value);
            if (amt == null || amt <= 0) {
              return 'Please enter a valid amount';
            }
            return null;
          },
          onSaved: (value) {
            final amt = double.tryParse(value ?? '0') ?? 0.0;
            onFieldChanged('amount', amt);
          },
          onChanged: (value) {
            final amt = double.tryParse(value) ?? 0.0;
            onFieldChanged('amount', amt);
          },
        ),
        const SizedBox(height: 16),

        // Current Value
        TextFormField(
          initialValue: formData['currentValue']?.toString(),
          decoration: const InputDecoration(
            labelText: 'Current Value (₹)',
            hintText: 'Enter current market value',
            prefixIcon: Icon(Icons.currency_rupee),
            border: OutlineInputBorder(),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onSaved: (value) {
            final currentValue = double.tryParse(value ?? '0') ?? 0.0;
            onFieldChanged('currentValue', currentValue);
          },
          onChanged: (value) {
            final currentValue = double.tryParse(value) ?? 0.0;
            onFieldChanged('currentValue', currentValue);
          },
        ),
        const SizedBox(height: 16),

        // Investment Date (optional but useful)
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate:
                  formData['investmentDate'] as DateTime? ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
            );
            if (picked != null) onFieldChanged('investmentDate', picked);
          },
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Investment Date',
              prefixIcon: Icon(Icons.calendar_today),
              border: OutlineInputBorder(),
            ),
            child: Text(
              formData['investmentDate'] != null
                  ? DateFormat('dd MMM yyyy').format(formData['investmentDate'])
                  : 'Select investment date',
              style: TextStyle(
                color: formData['investmentDate'] != null ? null : Colors.grey,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // Helper method to format dates
  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  Future<void> _selectDate(BuildContext context, String field) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: formData[field] as DateTime? ?? DateTime.now(),
      firstDate: field == 'maturityDate' ? DateTime.now() : DateTime(1980),
      lastDate: field == 'startDate' ? DateTime.now() : DateTime(2050),
    );

    if (picked != null) {
      onFieldChanged(field, picked);
    }
  }
}
