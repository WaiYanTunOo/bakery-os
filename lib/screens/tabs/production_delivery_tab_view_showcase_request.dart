part of 'production_delivery_tab.dart';

extension _ProductionDeliveryTabShowcaseRequestView on _ProductionDeliveryTabState {
  Widget _buildShowcaseRequestCard() {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.arrow_circle_right, color: Colors.blue),
            const SizedBox(width: 8),
            const Expanded(child: Text('FH Request: Restock Showcase', style: TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
            Expanded(
              flex: 2,
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: _fhReqItem,
                decoration: const InputDecoration(filled: true, fillColor: Colors.white, border: OutlineInputBorder()),
                items: widget.appData.menuItems.map((m) => DropdownMenuItem(value: m['name'] as String, child: Text(m['name']))).toList(),
                onChanged: _canRequestShowcase ? _setSelectedShowcaseItem : null,
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(onPressed: _canRequestShowcase ? _submitShowcaseRequest : null, child: const Text('Send to Kitchen')),
          ],
        ),
      ),
    );
  }
}