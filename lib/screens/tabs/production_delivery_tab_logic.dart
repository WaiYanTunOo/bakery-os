part of 'production_delivery_tab.dart';

extension _ProductionDeliveryTabLogic on _ProductionDeliveryTabState {
  bool _isValidDate(String value) {
    final expression = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!expression.hasMatch(value.trim())) return false;
    return DateTime.tryParse(value.trim()) != null;
  }

  void _showMessage(String message, {required bool error}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: error ? Colors.red : Colors.green),
    );
  }

  List<Map<String, dynamic>> _ordersForDate() {
    return widget.appData.onlineOrders
        .where((order) {
          final items = order['items'];
          if (items is! List) return false;
          return items.any((item) => item is Map && (item['deliveryDate'] ?? '').toString() == _targetDate);
        })
        .map((order) => Map<String, dynamic>.from(order))
        .toList();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'ready':
        return Colors.green;
      case 'in_progress':
        return Colors.blue;
      case 'verified':
        return Colors.indigo;
      default:
        return Colors.orange;
    }
  }
}