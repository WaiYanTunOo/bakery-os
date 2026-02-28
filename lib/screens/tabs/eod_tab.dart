import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/supabase_service.dart';
import '../../data/app_data.dart';

class EodTab extends StatefulWidget {
  final AppData appData;
  final VoidCallback onStateChanged;
  final Function(String) onTabChanged;

  const EodTab({
    super.key,
    required this.appData,
    required this.onStateChanged,
    required this.onTabChanged,
  });

  @override
  State<EodTab> createState() => _EodTabState();
}

class _EodTabState extends State<EodTab> {
  final TextEditingController _eodGross = TextEditingController();
  final TextEditingController _eodPrompt = TextEditingController();
  final TextEditingController _eodCard = TextEditingController();
  final TextEditingController _eodExp = TextEditingController();
  final TextEditingController _eodAct = TextEditingController();
  final TextEditingController _eodNote = TextEditingController();
  String _eodShift = '3:30 PM';
  
  bool _isSubmitting = false; // Added to prevent double-submissions

  // Track discrepancy separately so we don't rebuild entire form on every keypress
  final ValueNotifier<double> _discrepancy = ValueNotifier(0);

  Future<void> _submitReport(double disc) async {
    setState(() => _isSubmitting = true);

    try {
      // Use Supabase service wrapper to perform insert with sanitization and validation
      final success = await SupabaseService.instance.insertEodReport(
        shift: _eodShift,
        grossSales: double.tryParse(_eodGross.text) ?? 0.0,
        promptpay: double.tryParse(_eodPrompt.text) ?? 0.0,
        card: double.tryParse(_eodCard.text) ?? 0.0,
        expectedCash: double.tryParse(_eodExp.text) ?? 0.0,
        actualCash: double.tryParse(_eodAct.text) ?? 0.0,
        discrepancy: disc,
        note: _eodNote.text,
      );

      if (!success) throw Exception('failed to persist');

      // Also add to local state if you still want it to show up instantly without fetching
      widget.appData.eodReports.add({'shift': _eodShift, 'disc': disc});
      
      // Clear fields
      _eodGross.clear(); 
      _eodPrompt.clear(); 
      _eodCard.clear(); 
      _eodExp.clear(); 
      _eodAct.clear(); 
      _eodNote.clear();
      
      widget.onStateChanged();
      widget.onTabChanged('home');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Shift Closed and saved to Supabase!'), backgroundColor: Colors.green),
        );
      }
    } on ValidationError catch (e) {
      // Handle validation errors with specific message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Validation Error: ${e.message}'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e, st) {
      debugPrint('EOD submit error: $e');
      debugPrint('$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error saving report. Please try again.'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // listen for changes and recalc discrepancy without rebuilding whole widget
    void calc() {
      double exp = double.tryParse(_eodExp.text) ?? 0;
      double act = double.tryParse(_eodAct.text) ?? 0;
      _discrepancy.value = act - exp;
    }
    _eodExp.addListener(calc);
    _eodAct.addListener(calc);
  }

  @override
  void dispose() {
    _eodGross.dispose();
    _eodPrompt.dispose();
    _eodCard.dispose();
    _eodExp.dispose();
    _eodAct.dispose();
    _eodNote.dispose();
    _discrepancy.dispose();
    super.dispose();
  }

  bool _canSubmit() {
    return !_isSubmitting &&
        _eodExp.text.isNotEmpty &&
        _eodAct.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    // we rely on _discrepancy notifier for calculations

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 600),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Shift Reconciliation', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              DropdownButtonFormField(
                initialValue: _eodShift,
                decoration: const InputDecoration(labelText: 'Shift', border: OutlineInputBorder()),
                items: const [DropdownMenuItem(value:'3:30 PM',child:Text('3:30 PM')), DropdownMenuItem(value:'5:30 PM',child:Text('5:30 PM')), DropdownMenuItem(value:'8:00 PM',child:Text('8:00 PM'))],
                onChanged: (val) => setState(() => _eodShift = val.toString()),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.blue.shade50,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('1. Copy from POS Z-Report', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _eodGross,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                              LengthLimitingTextInputFormatter(12), // max 999999.99
                            ],
                            decoration: const InputDecoration(labelText: 'Gross', filled: true, fillColor: Colors.white, helperText: 'Max: 999,999.99'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _eodPrompt,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                              LengthLimitingTextInputFormatter(12), // max 999999.99
                            ],
                            decoration: const InputDecoration(labelText: 'PromptPay', filled: true, fillColor: Colors.white, helperText: 'Max: 999,999.99'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _eodCard,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                              LengthLimitingTextInputFormatter(12), // max 999999.99
                            ],
                            decoration: const InputDecoration(labelText: 'Card', filled: true, fillColor: Colors.white, helperText: 'Max: 999,999.99'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _eodExp,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                              LengthLimitingTextInputFormatter(12), // max 999999.99
                            ],
                            onChanged: (v){/*recalculates via listener*/},
                            decoration: const InputDecoration(labelText: 'Expected Cash', filled: true, fillColor: Colors.white, helperText: 'Max: 999,999.99'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.amber.shade50,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('2. Physical Cash Count', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _eodAct,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                        LengthLimitingTextInputFormatter(12), // max 999999.99
                      ],
                      onChanged: (v)=>setState((){}),
                      decoration: const InputDecoration(
                        labelText: 'Actual Cash',
                        filled: true,
                        fillColor: Colors.white,
                        helperText: 'Max: 999,999.99',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder<double>(
                valueListenable: _discrepancy,
                builder: (context, disc, _) {
                  if (_eodExp.text.isEmpty || _eodAct.text.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        color: disc == 0 ? Colors.green.shade50 : Colors.red.shade50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Discrepancy:', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('${disc > 0 ? '+' : ''}${disc.toStringAsFixed(2)} THB', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: disc == 0 ? Colors.green : Colors.red)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (disc != 0)
                        TextField(
                          controller: _eodNote,
                          maxLength: 500,
                          maxLines: 3,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(500),
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Explanation Required',
                            border: OutlineInputBorder(),
                            helperText: 'Max 500 characters',
                            counterText: '',  // Remove counter to reduce clutter
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity, 
                height: 50, 
                child: ElevatedButton(
                  key: const Key('eod_submit'),
                  onPressed: _canSubmit() ? () => _submitReport(_discrepancy.value) : null, 
                  child: _isSubmitting 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Submit Report'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}