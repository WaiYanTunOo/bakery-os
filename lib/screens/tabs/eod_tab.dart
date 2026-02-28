import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

  Future<void> _submitReport(double disc) async {
    setState(() => _isSubmitting = true);

    try {
      // Get the Supabase client instance
      final supabase = Supabase.instance.client;

      // Insert data into Supabase (Adjust table name 'eod_reports' and columns as needed)
      await supabase.from('eod_reports').insert({
        'shift': _eodShift,
        'gross_sales': double.tryParse(_eodGross.text) ?? 0.0,
        'promptpay': double.tryParse(_eodPrompt.text) ?? 0.0,
        'card': double.tryParse(_eodCard.text) ?? 0.0,
        'expected_cash': double.tryParse(_eodExp.text) ?? 0.0,
        'actual_cash': double.tryParse(_eodAct.text) ?? 0.0,
        'discrepancy': disc,
        'note': _eodNote.text,
        'created_at': DateTime.now().toIso8601String(),
      });

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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving to Supabase: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double exp = double.tryParse(_eodExp.text) ?? 0;
    double act = double.tryParse(_eodAct.text) ?? 0;
    double disc = act - exp;

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
                        Expanded(child: TextField(controller: _eodGross, decoration: const InputDecoration(labelText: 'Gross', filled: true, fillColor: Colors.white))),
                        const SizedBox(width: 8),
                        Expanded(child: TextField(controller: _eodPrompt, decoration: const InputDecoration(labelText: 'PromptPay', filled: true, fillColor: Colors.white))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: _eodCard, decoration: const InputDecoration(labelText: 'Card', filled: true, fillColor: Colors.white))),
                        const SizedBox(width: 8),
                        Expanded(child: TextField(controller: _eodExp, onChanged: (v)=>setState((){}), decoration: const InputDecoration(labelText: 'Expected Cash', filled: true, fillColor: Colors.white))),
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
                    TextField(controller: _eodAct, onChanged: (v)=>setState((){}), decoration: const InputDecoration(labelText: 'Actual Cash', filled: true, fillColor: Colors.white)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (_eodExp.text.isNotEmpty && _eodAct.text.isNotEmpty)
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
                TextField(controller: _eodNote, decoration: const InputDecoration(labelText: 'Explanation Required', border: OutlineInputBorder())),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity, 
                height: 50, 
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : () => _submitReport(disc), 
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