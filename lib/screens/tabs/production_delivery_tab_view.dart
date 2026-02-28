part of 'production_delivery_tab.dart';

extension _ProductionDeliveryTabView on _ProductionDeliveryTabState {
  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Production & Delivery Book', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        _buildShowcaseRequestCard(),
        const SizedBox(height: 24),
        _buildShowcaseQueueCard(),
        const SizedBox(height: 24),
        _buildPreorderQueueCard(),
      ],
    );
  }
}