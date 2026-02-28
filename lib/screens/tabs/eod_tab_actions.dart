part of 'eod_tab.dart';

extension _EodTabActions on _EodTabState {
  bool _canSubmit() => !_isSubmitting && _eodExp.text.isNotEmpty && _eodAct.text.isNotEmpty;

  Future<void> _submitReport(double disc) async {
    _setSubmitting(true);
    try {
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
      widget.appData.eodReports.add({'shift': _eodShift, 'disc': disc});
      _eodGross.clear();
      _eodPrompt.clear();
      _eodCard.clear();
      _eodExp.clear();
      _eodAct.clear();
      _eodNote.clear();
      widget.onStateChanged();
      widget.onTabChanged('home');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Shift Closed and saved to Supabase!'), backgroundColor: Colors.green));
      }
    } on ValidationError catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Validation Error: ${e.message}'), backgroundColor: Colors.orange, duration: const Duration(seconds: 4)));
      }
    } catch (e, st) {
      debugPrint('EOD submit error: $e');
      debugPrint('$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error saving report. Please try again.'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) _setSubmitting(false);
    }
  }
}