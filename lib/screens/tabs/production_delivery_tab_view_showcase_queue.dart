part of 'production_delivery_tab.dart';

extension _ProductionDeliveryTabShowcaseQueueView on _ProductionDeliveryTabState {
  Widget _buildShowcaseQueueCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Kitchen Queue: Showcase', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            widget.appData.showcaseRequests.isEmpty
                ? const Text('No requests.')
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.appData.showcaseRequests.length,
                    separatorBuilder: (_, index) => const Divider(),
                    itemBuilder: (context, index) => _buildShowcaseRequestRow(widget.appData.showcaseRequests[index]),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildShowcaseRequestRow(Map<String, dynamic> req) {
    final isPending = req['status'] == 'pending';
    final deliveredQty = (req['delivered_qty'] ?? req['deliveredQty'] ?? 0) as int;
    return ListTile(
      title: Text((req['name'] ?? '').toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      subtitle: Text('Req by ${req['requested_by'] ?? req['requestedBy']} at ${req['time_requested'] ?? req['timeRequested']}'),
      trailing: isPending ? _buildPendingShowcaseActions(req) : _buildDeliveredChip(deliveredQty),
    );
  }
}