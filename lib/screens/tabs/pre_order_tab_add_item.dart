part of 'pre_order_tab.dart';

extension _PreOrderTabAddItem on _PreOrderTabState {
  void _addItemToCart() {
    if (!_canCreateOrder) return _showMessage('Only FH or Owner can create pre-orders.', error: true);
    if (_poItem == null) return _showMessage('Please select a product.', error: true);
    if (_poQty <= 0) return _showMessage('Quantity must be greater than zero.', error: true);
    if (_poPrice <= 0) return _showMessage('Price must be greater than zero.', error: true);
    if (!_isValidDate(_poDate)) {
      return _showMessage('Delivery date must be in YYYY-MM-DD format.', error: true);
    }
    _appendCartItem({'name': _poItem, 'deliveryDate': _poDate.trim(), 'qty': _poQty, 'price': _poPrice});
  }
}