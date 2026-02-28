part of 'production_delivery_tab.dart';

extension _ProductionDeliveryTabShowcaseComplete on _ProductionDeliveryTabState {
  Future<void> _completeShowcaseRequest(Map<String, dynamic> req) async {
    if (!_canCompleteShowcase) {
      _showMessage('Only BH or Owner can complete requests.', error: true);
      return;
    }
    final reqId = (req['id'] ?? '').toString();
    final qty = int.tryParse((_bhInputs[reqId] ?? '').trim());
    if (qty == null || qty < 0) {
      _showMessage('Delivered quantity must be a valid number (0 or more).', error: true);
      return;
    }
    final actor = widget.currentUser['name']?.toString() ?? 'Unknown';
    final role = widget.currentUser['role']?.toString() ?? 'Unknown';
    final updates = {
      'status': 'delivered',
      'delivered_qty': qty,
      'time_delivered': AppDateUtils.timeStr(),
      'delivered_by': actor,
    };
    try {
      final ok = await SupabaseService.instance.updateShowcaseRequest(reqId, updates);
      if (!mounted) return;
      if (!ok) return _showMessage('Failed to save delivery update.', error: true);
      req.addAll(updates);
      widget.onStateChanged();
      AuditLogger.action(
        actor: actor,
        role: role,
        action: 'update',
        entity: 'showcase_request',
        entityId: reqId,
        metadata: {'status': 'delivered', 'delivered_qty': qty},
      );
      _showMessage('Request marked as delivered.', error: false);
    } on ValidationError catch (e) {
      if (mounted) _showMessage(e.message, error: true);
    } catch (_) {
      if (mounted) _showMessage('Unexpected error while updating request.', error: true);
    }
  }
}