part of 'eod_tab.dart';

extension _EodTabView on _EodTabState {
  Widget _buildContent() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 600),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Shift Reconciliation', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              _buildShiftSelector(),
              const SizedBox(height: 16),
              _buildPosReportSection(),
              const SizedBox(height: 16),
              _buildCashCountSection(),
              const SizedBox(height: 16),
              _buildDiscrepancySection(),
              const SizedBox(height: 24),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }
}