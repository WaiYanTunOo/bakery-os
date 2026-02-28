part of 'pre_order_tab.dart';

extension _PreOrderTabLogic on _PreOrderTabState {
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

  List<Map<String, dynamic>> _readyOrders() {
    return widget.appData.onlineOrders
        .where((order) => (order['status'] ?? '').toString() == 'ready')
        .map((order) => Map<String, dynamic>.from(order))
        .toList();
  }

  String _itemNames(Map<String, dynamic> order) {
    final items = order['items'];
    if (items is! List) return '-';
    final names = <String>[];
    for (final rawItem in items) {
      if (rawItem is! Map) continue;
      final name = (Map<String, dynamic>.from(rawItem)['name'] ?? '').toString().trim();
      if (name.isNotEmpty) names.add(name);
    }
    return names.isEmpty ? '-' : names.join(', ');
  }
}