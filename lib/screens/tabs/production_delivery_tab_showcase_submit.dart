part of 'production_delivery_tab.dart';

extension _ProductionDeliveryTabShowcaseSubmit on _ProductionDeliveryTabState {
  Future<void> _submitShowcaseRequest() async {
    if (!_canRequestShowcase) {
      _showMessage('Only FH or Owner can request showcase restock.', error: true);
      return;
    }
    if (_fhReqItem == null || _fhReqItem!.trim().isEmpty) {
      _showMessage('Please select a product first.', error: true);
      return;
    }
    final actor = widget.currentUser['name']?.toString() ?? 'Unknown';
    final role = widget.currentUser['role']?.toString() ?? 'Unknown';
    final requestId = 'REQ-${Random().nextInt(1000000).toString().padLeft(6, '0')}';
    final payload = {
      'id': requestId,
      'name': _fhReqItem,
      'status': 'pending',
      'time_requested': AppDateUtils.timeStr(),
      'requested_by': actor,
      'time_delivered': null,
      'delivered_by': null,
      'delivered_qty': null,
    };
    try {
      final inserted = await SupabaseService.instance.insertShowcaseRequest(payload);
      if (!mounted) return;
      if (inserted == null) return _showMessage('Failed to save request. Try again.', error: true);
      widget.appData.showcaseRequests.insert(0, inserted);
      _setSelectedShowcaseItem(null);
      widget.onStateChanged();
      AuditLogger.action(actor: actor, role: role, action: 'create', entity: 'showcase_request', entityId: requestId);
      _showMessage('Request sent to kitchen.', error: false);
    } on ValidationError catch (e) {
      if (mounted) _showMessage(e.message, error: true);
    } catch (_) {
      if (mounted) _showMessage('Unexpected error while creating request.', error: true);
    }
  }
}