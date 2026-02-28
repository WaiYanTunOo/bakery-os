part of 'pre_order_tab.dart';

extension _PreOrderTabSubmit on _PreOrderTabState {
  Future<void> _submitOrder(double cartTotal) async {
    if (_isSubmitting) return;
    if (!_canCreateOrder) return _showMessage('Only FH or Owner can submit pre-orders.', error: true);
    if (_poCustomer.trim().isEmpty) return _showMessage('Customer name is required.', error: true);
    if (_currentCart.isEmpty) return _showMessage('Please add at least one item to the cart.', error: true);
    _setSubmitting(true);
    final orderId = 'ORD-${Random().nextInt(1000000).toString().padLeft(6, '0')}';
    final actor = widget.currentUser['name']?.toString() ?? 'Unknown';
    final role = widget.currentUser['role']?.toString() ?? 'Unknown';
    final order = {
      'id': orderId,
      'customer': _poCustomer.trim(),
      'items': List<Map<String, dynamic>>.from(_currentCart),
      'total': cartTotal,
      'status': _poAutoVerify ? 'verified' : 'pending',
      'date': AppDateUtils.todayStr(),
      'logged_by': actor,
      'loggedBy': actor,
    };
    try {
      final inserted = await SupabaseService.instance.insertOnlineOrder(order);
      if (!mounted) return;
      if (inserted == null) return _showMessage('Failed to save order. Please try again.', error: true);
      widget.appData.onlineOrders.insert(0, inserted);
      widget.onStateChanged();
      AuditLogger.action(actor: actor, role: role, action: 'create', entity: 'online_order', entityId: orderId, metadata: {'status': order['status'], 'itemCount': _currentCart.length, 'total': cartTotal});
      _resetAfterSubmit();
      _showMessage('Order submitted successfully.', error: false);
    } on ValidationError catch (e) {
      if (mounted) _showMessage(e.message, error: true);
    } catch (_) {
      if (mounted) _showMessage('Unexpected error while submitting order.', error: true);
    } finally {
      if (mounted) _setSubmitting(false);
    }
  }
}