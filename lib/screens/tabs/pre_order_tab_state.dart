part of 'pre_order_tab.dart';

extension _PreOrderTabStateHelpers on _PreOrderTabState {
  bool get _canCreateOrder {
    final role = widget.currentUser['role'];
    return role == 'FH' || role == 'Owner';
  }

  bool get _canViewReadyOrders {
    final role = widget.currentUser['role'];
    return role == 'FH' || role == 'Owner';
  }

  void _setSubmitting(bool submitting) {
    _setPreOrderState(() => _isSubmitting = submitting);
  }

  void _setProductAndPrice(String? value) {
    _setPreOrderState(() {
      _poItem = value;
      Map<String, dynamic>? matchedItem;
      for (final item in widget.appData.menuItems) {
        if (item['name'] == value) {
          matchedItem = item;
          break;
        }
      }
      _poPrice = (matchedItem?['price'] as num?)?.toDouble() ?? 0.0;
    });
  }

  void _appendCartItem(Map<String, dynamic> item) {
    _setPreOrderState(() {
      _currentCart.add(item);
      _poItem = null;
      _poQty = 1;
      _poPrice = 0.0;
    });
  }

  void _resetAfterSubmit() {
    _setPreOrderState(() {
      _currentCart.clear();
      _poCustomer = '';
      _poAutoVerify = false;
    });
  }

  void _setAutoVerify(bool value) {
    _setPreOrderState(() => _poAutoVerify = value);
  }

  void _removeCartItemAt(int index) {
    _setPreOrderState(() => _currentCart.removeAt(index));
  }
}
