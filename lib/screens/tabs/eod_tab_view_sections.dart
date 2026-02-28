part of 'eod_tab.dart';

extension _EodTabViewSections on _EodTabState {
  List<TextInputFormatter> _amountInputFormatters() => [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')), LengthLimitingTextInputFormatter(12)];

  Widget _buildShiftSelector() {
    return DropdownButtonFormField(
      initialValue: _eodShift,
      decoration: const InputDecoration(labelText: 'Shift', border: OutlineInputBorder()),
      items: const [DropdownMenuItem(value: '3:30 PM', child: Text('3:30 PM')), DropdownMenuItem(value: '5:30 PM', child: Text('5:30 PM')), DropdownMenuItem(value: '8:00 PM', child: Text('8:00 PM'))],
      onChanged: (val) => _setShift(val.toString()),
    );
  }

  Widget _buildPosReportSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.blue.shade50,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('1. Copy from POS Z-Report', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
        const SizedBox(height: 16),
        Row(children: [Expanded(child: TextField(controller: _eodGross, keyboardType: const TextInputType.numberWithOptions(decimal: true), inputFormatters: _amountInputFormatters(), decoration: const InputDecoration(labelText: 'Gross', filled: true, fillColor: Colors.white, helperText: 'Max: 999,999.99'))), const SizedBox(width: 8), Expanded(child: TextField(controller: _eodPrompt, keyboardType: const TextInputType.numberWithOptions(decimal: true), inputFormatters: _amountInputFormatters(), decoration: const InputDecoration(labelText: 'PromptPay', filled: true, fillColor: Colors.white, helperText: 'Max: 999,999.99')))]),
        const SizedBox(height: 8),
        Row(children: [Expanded(child: TextField(controller: _eodCard, keyboardType: const TextInputType.numberWithOptions(decimal: true), inputFormatters: _amountInputFormatters(), decoration: const InputDecoration(labelText: 'Card', filled: true, fillColor: Colors.white, helperText: 'Max: 999,999.99'))), const SizedBox(width: 8), Expanded(child: TextField(controller: _eodExp, keyboardType: const TextInputType.numberWithOptions(decimal: true), inputFormatters: _amountInputFormatters(), decoration: const InputDecoration(labelText: 'Expected Cash', filled: true, fillColor: Colors.white, helperText: 'Max: 999,999.99')))]),
      ]),
    );
  }

  Widget _buildCashCountSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.amber.shade50,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('2. Physical Cash Count', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
        const SizedBox(height: 16),
        TextField(controller: _eodAct, keyboardType: const TextInputType.numberWithOptions(decimal: true), inputFormatters: _amountInputFormatters(), decoration: const InputDecoration(labelText: 'Actual Cash', filled: true, fillColor: Colors.white, helperText: 'Max: 999,999.99')),
      ]),
    );
  }

  Widget _buildDiscrepancySection() {
    return ValueListenableBuilder<double>(
      valueListenable: _discrepancy,
      builder: (context, disc, _) {
        if (_eodExp.text.isEmpty || _eodAct.text.isEmpty) return const SizedBox.shrink();
        return Column(children: [
          Container(padding: const EdgeInsets.all(16), color: disc == 0 ? Colors.green.shade50 : Colors.red.shade50, child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Discrepancy:', style: TextStyle(fontWeight: FontWeight.bold)), Text('${disc > 0 ? '+' : ''}${disc.toStringAsFixed(2)} THB', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: disc == 0 ? Colors.green : Colors.red))])),
          const SizedBox(height: 16),
          if (disc != 0) TextField(controller: _eodNote, maxLength: 500, maxLines: 3, inputFormatters: [LengthLimitingTextInputFormatter(500)], decoration: const InputDecoration(labelText: 'Explanation Required', border: OutlineInputBorder(), helperText: 'Max 500 characters', counterText: '')),
        ]);
      },
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        key: const Key('eod_submit'),
        onPressed: _canSubmit() ? () => _submitReport(_discrepancy.value) : null,
        child: _isSubmitting ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Submit Report'),
      ),
    );
  }
}