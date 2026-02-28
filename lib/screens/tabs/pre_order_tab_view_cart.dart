part of 'pre_order_tab.dart';

extension _PreOrderTabCartView on _PreOrderTabState {
  Widget _buildCartSection() {
    if (_currentCart.isEmpty) {
      return Container(width: double.infinity, padding: const EdgeInsets.all(20), decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)), child: const Text('No items in cart yet.'));
    }
    final cartTotal = _currentCart.fold<double>(0.0, (sum, item) => sum + ((item['price'] as num) * (item['qty'] as num)));
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SingleChildScrollView(scrollDirection: Axis.horizontal, child: DataTable(columns: const [DataColumn(label: Text('Item')), DataColumn(label: Text('Date')), DataColumn(label: Text('Qty')), DataColumn(label: Text('Price')), DataColumn(label: Text('Total')), DataColumn(label: Text('Action'))], rows: _currentCart.asMap().entries.map(_buildCartRow).toList())),
      const SizedBox(height: 16),
      if (widget.currentUser['role'] == 'Owner') Row(children: [Checkbox(value: _poAutoVerify, onChanged: (v) => _setAutoVerify(v ?? false)), const Text('Auto-verify payment (Skip clearing account)')]),
      Container(
        padding: const EdgeInsets.all(16),
        color: Colors.grey.shade100,
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Grand Total:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), Text('${cartTotal.toStringAsFixed(2)} THB', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.indigo))]),
      ),
      const SizedBox(height: 16),
      SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
          onPressed: _canCreateOrder ? () => _submitOrder(cartTotal) : null,
          child: _isSubmitting ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Submit Complete Order', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    ]);
  }

  DataRow _buildCartRow(MapEntry<int, Map<String, dynamic>> entry) {
    final idx = entry.key;
    final item = entry.value;
    final itemTotal = ((item['price'] as num) * (item['qty'] as num)).toDouble();
    return DataRow(cells: [
      DataCell(Text(item['name'].toString())),
      DataCell(Text(item['deliveryDate'].toString())),
      DataCell(Text(item['qty'].toString())),
      DataCell(Text('${item['price']} THB')),
      DataCell(Text('${itemTotal.toStringAsFixed(2)} THB', style: const TextStyle(fontWeight: FontWeight.bold))),
      DataCell(IconButton(onPressed: () => _removeCartItemAt(idx), icon: const Icon(Icons.close, color: Colors.red))),
    ]);
  }
}