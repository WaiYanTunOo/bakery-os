import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/supabase_service.dart';
import '../../data/app_data.dart';

part 'eod_tab_actions.dart';
part 'eod_tab_view.dart';
part 'eod_tab_view_sections.dart';

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

  @override
  Widget build(BuildContext context) {
    return _buildContent();
  }

  void _setEodState(VoidCallback updater) {
    if (!mounted) return;
    setState(updater);
  }

  void _setSubmitting(bool submitting) {
    _setEodState(() => _isSubmitting = submitting);
  }

  void _setShift(String shift) {
    _setEodState(() => _eodShift = shift);
  }
}