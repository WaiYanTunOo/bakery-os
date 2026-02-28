part of 'pre_order_tab.dart';

extension _PreOrderTabFormView on _PreOrderTabState {
  Widget _buildFormSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.grey.shade50, border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
      child: Column(children: [_buildProductField(), const SizedBox(height: 8), _buildDateField(), const SizedBox(height: 8), _buildQtyPriceRow()]),
    );
  }

  Widget _buildProductField() {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      itemHeight: null,
      initialValue: _poItem,
      selectedItemBuilder: (_) => widget.appData.menuItems.map((m) => SingleChildScrollView(scrollDirection: Axis.horizontal, child: Align(alignment: Alignment.centerLeft, child: Text(m['name'], maxLines: 1, overflow: TextOverflow.visible)))).toList(),
      decoration: const InputDecoration(labelText: 'Product', border: OutlineInputBorder()),
      items: widget.appData.menuItems.map((m) => DropdownMenuItem(value: m['name'] as String, child: Text(m['name'], softWrap: true))).toList(),
      onChanged: _setProductAndPrice,
    );
  }

  Widget _buildDateField() {
    return TextFormField(initialValue: _poDate, decoration: const InputDecoration(labelText: 'Deliver On (YYYY-MM-DD)', border: OutlineInputBorder()), onChanged: (val) => _poDate = val);
  }

  Widget _buildQtyPriceRow() {
    return Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
      Expanded(child: TextFormField(initialValue: _poQty.toString(), decoration: const InputDecoration(labelText: 'Qty', border: OutlineInputBorder()), keyboardType: TextInputType.number, onChanged: (val) => _poQty = int.tryParse(val) ?? 0)),
      const SizedBox(width: 8),
      Expanded(child: TextFormField(key: ValueKey(_poPrice), initialValue: _poPrice.toStringAsFixed(2), decoration: const InputDecoration(labelText: 'Price', border: OutlineInputBorder()), keyboardType: const TextInputType.numberWithOptions(decimal: true), onChanged: (val) => _poPrice = double.tryParse(val) ?? 0.0)),
      const SizedBox(width: 8),
      IconButton(icon: const Icon(Icons.add_circle, color: Colors.indigo, size: 40), onPressed: _canCreateOrder ? _addItemToCart : null),
    ]);
  }
}