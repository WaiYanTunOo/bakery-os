import 'dart:math';

import 'package:flutter/material.dart';

import '../../data/app_data.dart';
import '../../services/supabase_service.dart';
import '../../utils/audit_logger.dart';
import '../../utils/data_utils.dart';

class PreOrderTab extends StatefulWidget {
  final Map<String, dynamic> currentUser;
  final AppData appData;
  final VoidCallback onStateChanged;

  const PreOrderTab({
    super.key,
    required this.currentUser,
    required this.appData,
    required this.onStateChanged,
  });

  @override
  State<PreOrderTab> createState() => _PreOrderTabState();
}

class _PreOrderTabState extends State<PreOrderTab> {
  String _poCustomer = '';
  String? _poItem;
  int _poQty = 1;
  double _poPrice = 0.0;
  String _poDate = '';
  final List<Map<String, dynamic>> _currentCart = [];
  bool _poAutoVerify = false;
  bool _isSubmitting = false;

  bool get _canCreateOrder {
    final role = widget.currentUser['role'];
    return role == 'FH' || role == 'Owner';
  }

  @override
  void initState() {
    super.initState();
    _poDate = AppDateUtils.todayStr();
  }

  bool _isValidDate(String value) {
    final expression = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!expression.hasMatch(value.trim())) return false;
    return DateTime.tryParse(value.trim()) != null;
  }

  void _showMessage(String message, {required bool error}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? Colors.red : Colors.green,
      ),
    );
  }

  void _addItemToCart() {
    if (!_canCreateOrder) {
      _showMessage('Only FH or Owner can create pre-orders.', error: true);
      return;
    }
    if (_poItem == null) {
      _showMessage('Please select a product.', error: true);
      return;
    }
    if (_poQty <= 0) {
      _showMessage('Quantity must be greater than zero.', error: true);
      return;
    }
    if (_poPrice <= 0) {
      _showMessage('Price must be greater than zero.', error: true);
      return;
    }
    if (!_isValidDate(_poDate)) {
      _showMessage('Delivery date must be in YYYY-MM-DD format.', error: true);
      return;
    }

    setState(() {
      _currentCart.add({
        'name': _poItem,
        'deliveryDate': _poDate.trim(),
        'qty': _poQty,
        'price': _poPrice,
      });
      _poItem = null;
      _poQty = 1;
      _poPrice = 0.0;
    });
  }

  Future<void> _submitOrder(double cartTotal) async {
    if (_isSubmitting) return;
    if (!_canCreateOrder) {
      _showMessage('Only FH or Owner can submit pre-orders.', error: true);
      return;
    }
    if (_poCustomer.trim().isEmpty) {
      _showMessage('Customer name is required.', error: true);
      return;
    }
    if (_currentCart.isEmpty) {
      _showMessage('Please add at least one item to the cart.', error: true);
      return;
    }

    setState(() => _isSubmitting = true);

    final orderId =
        'ORD-${Random().nextInt(1000000).toString().padLeft(6, '0')}';
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

      if (inserted == null) {
        _showMessage('Failed to save order. Please try again.', error: true);
        return;
      }

      widget.appData.onlineOrders.insert(0, inserted);
      widget.onStateChanged();

      AuditLogger.action(
        actor: actor,
        role: role,
        action: 'create',
        entity: 'online_order',
        entityId: orderId,
        metadata: {
          'status': order['status'],
          'itemCount': _currentCart.length,
          'total': cartTotal,
        },
      );

      setState(() {
        _currentCart.clear();
        _poCustomer = '';
        _poAutoVerify = false;
      });
      _showMessage('Order submitted successfully.', error: false);
    } on ValidationError catch (e) {
      if (!mounted) return;
      _showMessage(e.message, error: true);
    } catch (_) {
      if (!mounted) return;
      _showMessage('Unexpected error while submitting order.', error: true);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartTotal = _currentCart.fold<double>(
      0.0,
      (sum, item) => sum + ((item['price'] as num) * (item['qty'] as num)),
    );

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 900),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.shopping_cart, color: Colors.indigo),
                  SizedBox(width: 8),
                  Text(
                    'Log Pre-Order Cart',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (!_canCreateOrder)
                Text(
                  'Read-only for your role. Only FH or Owner can create pre-orders.',
                  style: TextStyle(color: Colors.orange.shade800),
                ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Customer Name / Social Handle',
                  border: OutlineInputBorder(),
                ),
                onChanged: (val) => _poCustomer = val,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<String>(
                        initialValue: _poItem,
                        decoration: const InputDecoration(
                          labelText: 'Product',
                          border: OutlineInputBorder(),
                        ),
                        items: widget.appData.menuItems
                            .map(
                              (m) => DropdownMenuItem(
                                value: m['name'] as String,
                                child: Text(m['name']),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            _poItem = val;
                            _poPrice = (widget.appData.menuItems.firstWhere(
                              (m) => m['name'] == val,
                            )['price'] as num)
                                .toDouble();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        initialValue: _poDate,
                        decoration: const InputDecoration(
                          labelText: 'Deliver On (YYYY-MM-DD)',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (val) => _poDate = val,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        initialValue: _poQty.toString(),
                        decoration: const InputDecoration(
                          labelText: 'Qty',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (val) => _poQty = int.tryParse(val) ?? 0,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        key: ValueKey(_poPrice),
                        initialValue: _poPrice.toStringAsFixed(2),
                        decoration: const InputDecoration(
                          labelText: 'Price',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (val) => _poPrice = double.tryParse(val) ?? 0.0,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(
                        Icons.add_circle,
                        color: Colors.indigo,
                        size: 40,
                      ),
                      onPressed: _canCreateOrder ? _addItemToCart : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (_currentCart.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('No items in cart yet.'),
                )
              else ...[
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Item')),
                      DataColumn(label: Text('Date')),
                      DataColumn(label: Text('Qty')),
                      DataColumn(label: Text('Price')),
                      DataColumn(label: Text('Total')),
                      DataColumn(label: Text('Action')),
                    ],
                    rows: _currentCart.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final item = entry.value;
                      final itemTotal =
                          ((item['price'] as num) * (item['qty'] as num)).toDouble();
                      return DataRow(
                        cells: [
                          DataCell(Text(item['name'].toString())),
                          DataCell(Text(item['deliveryDate'].toString())),
                          DataCell(Text(item['qty'].toString())),
                          DataCell(Text('${item['price']} THB')),
                          DataCell(
                            Text(
                              '${itemTotal.toStringAsFixed(2)} THB',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataCell(
                            IconButton(
                              onPressed: () {
                                setState(() => _currentCart.removeAt(idx));
                              },
                              icon: const Icon(Icons.close, color: Colors.red),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                if (widget.currentUser['role'] == 'Owner')
                  Row(
                    children: [
                      Checkbox(
                        value: _poAutoVerify,
                        onChanged: (v) => setState(() => _poAutoVerify = v ?? false),
                      ),
                      const Text('Auto-verify payment (Skip clearing account)'),
                    ],
                  ),
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.grey.shade100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Grand Total:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${cartTotal.toStringAsFixed(2)} THB',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _canCreateOrder ? () => _submitOrder(cartTotal) : null,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Submit Complete Order',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}