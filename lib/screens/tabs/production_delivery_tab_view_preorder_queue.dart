part of 'production_delivery_tab.dart';

extension _ProductionDeliveryTabPreorderQueueView on _ProductionDeliveryTabState {
  Widget _buildPreorderQueueCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildPreorderHeader(), _buildPreorderTotals(), _buildReadinessActions()]),
      ),
    );
  }

  Widget _buildPreorderHeader() {
    return Row(children: [
      const Expanded(child: Text('Kitchen Queue: Pre-Orders', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
      SizedBox(
        width: 200,
        child: TextField(
          controller: _targetDateController,
          decoration: const InputDecoration(labelText: 'Bake for Date', border: OutlineInputBorder()),
          onSubmitted: (_) => _refreshQueueDate(),
        ),
      ),
      const SizedBox(width: 8),
      IconButton(tooltip: 'Refresh queue', onPressed: _refreshQueueDate, icon: const Icon(Icons.refresh)),
    ]);
  }

  void _refreshQueueDate() {
    final dateInput = _targetDateController.text.trim();
    if (!_isValidDate(dateInput)) return _showMessage('Date must be in YYYY-MM-DD format.', error: true);
    _setTargetDate(dateInput);
    _computePreOrders();
  }

  Widget _buildPreorderTotals() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 8),
      Text('Pending pre-order units for this date: $_pendingForDate', style: TextStyle(color: Colors.orange.shade800)),
      const SizedBox(height: 4),
      Text('In progress: $_inProgressForDate | Ready: $_readyForDate', style: TextStyle(color: Colors.blue.shade800)),
      const SizedBox(height: 16),
      _verifiedPreOrders.isEmpty ? const Text('No active pre-orders for this date.') : _buildPreorderTable(),
      const SizedBox(height: 20),
      const Divider(),
      const SizedBox(height: 8),
      const Text('BH Readiness Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
    ]);
  }

  Widget _buildPreorderTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [DataColumn(label: Text('Product')), DataColumn(label: Text('Required Qty'))],
        rows: _verifiedPreOrders.entries
            .map((e) => DataRow(cells: [DataCell(Text(e.key, style: const TextStyle(fontWeight: FontWeight.bold))), DataCell(Text(e.value.toString(), style: const TextStyle(fontSize: 20, color: Colors.pink, fontWeight: FontWeight.bold)))]))
            .toList(),
      ),
    );
  }
}