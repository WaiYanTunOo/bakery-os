import 'package:flutter/material.dart';
import 'dart:math';
import '../../data/app_data.dart';
import '../../utils/data_utils.dart';

class PreOrderTab extends StatefulWidget {
  final Map<String, dynamic> currentUser;
  final AppData appData;
  final VoidCallback onStateChanged;

  const PreOrderTab({super.key, required this.currentUser, required this.appData, required this.onStateChanged});

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

  @override
  void initState() {
    super.initState();
    _poDate = AppDateUtils.todayStr();
  }

  @override
  Widget build(BuildContext context) {
    double cartTotal = _currentCart.fold(0.0, (sum, item) => sum + (item['price'] * item['qty']));

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 800),
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
                  Text('Log Pre-Order Cart', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                decoration: const InputDecoration(labelText: 'Customer Name / Social Handle', border: OutlineInputBorder()),
                onChanged: (val) => _poCustomer = val,
              ),
              const SizedBox(height: 24),
              // Add Item Form
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.grey.shade50, border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<String>(
                        initialValue: _poItem,
                        decoration: const InputDecoration(labelText: 'Product', border: OutlineInputBorder()),
                        items: widget.appData.menuItems.map((m) => DropdownMenuItem(value: m['name'] as String, child: Text(m['name']))).toList(),
                        onChanged: (val) {
                          setState(() {
                            _poItem = val;
                            _poPrice = widget.appData.menuItems.firstWhere((m) => m['name'] == val)['price'];
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        initialValue: _poDate,
                        decoration: const InputDecoration(labelText: 'Deliver On (YYYY-MM-DD)', border: OutlineInputBorder()),
                        onChanged: (val) => _poDate = val,
                      )
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        initialValue: _poQty.toString(),
                        decoration: const InputDecoration(labelText: 'Qty', border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                        onChanged: (val) => _poQty = int.tryParse(val) ?? 1,
                      )
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        key: ValueKey(_poPrice),
                        initialValue: _poPrice.toString(),
                        decoration: const InputDecoration(labelText: 'Price', border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                        onChanged: (val) => _poPrice = double.tryParse(val) ?? 0.0,
                      )
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: Colors.indigo, size: 40),
                      onPressed: () {
                        if (_poItem == null) return;
                        setState(() {
                          _currentCart.add({'name': _poItem, 'deliveryDate': _poDate, 'qty': _poQty, 'price': _poPrice});
                          _poItem = null;
                        });
                      },
                    )
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Cart Table
              if (_currentCart.isNotEmpty) ...[
                Table(
                  border: TableBorder.all(color: Colors.grey.shade300),
                  children: [
                    TableRow(
                      decoration: BoxDecoration(color: Colors.indigo.shade50),
                      children: const [
                        Padding(padding: EdgeInsets.all(8.0), child: Text('Item', style: TextStyle(fontWeight: FontWeight.bold))),
                        Padding(padding: EdgeInsets.all(8.0), child: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
                        Padding(padding: EdgeInsets.all(8.0), child: Text('Qty', style: TextStyle(fontWeight: FontWeight.bold))),
                        Padding(padding: EdgeInsets.all(8.0), child: Text('Total', style: TextStyle(fontWeight: FontWeight.bold))),
                        Padding(padding: EdgeInsets.all(8.0), child: Text('')),
                      ]
                    ),
                    ..._currentCart.asMap().entries.map((entry) {
                      int idx = entry.key;
                      Map item = entry.value;
                      return TableRow(
                        children: [
                          Padding(padding: const EdgeInsets.all(8.0), child: Text(item['name'])),
                          Padding(padding: const EdgeInsets.all(8.0), child: Text(item['deliveryDate'], style: const TextStyle(color: Colors.pink))),
                          Padding(padding: const EdgeInsets.all(8.0), child: Text(item['qty'].toString())),
                          Padding(padding: const EdgeInsets.all(8.0), child: Text('${item['price'] * item['qty']}', style: const TextStyle(fontWeight: FontWeight.bold))),
                          IconButton(icon: const Icon(Icons.close, color: Colors.red, size: 16), onPressed: () => setState(() => _currentCart.removeAt(idx)))
                        ]
                      );
                    })
                  ],
                ),
                const SizedBox(height: 16),
                if (widget.currentUser['role'] == 'Owner')
                   Row(
                     children: [
                       Checkbox(value: _poAutoVerify, onChanged: (v) => setState(() => _poAutoVerify = v!)),
                       const Text('Auto-verify payment (Skip clearing account)'),
                     ],
                   ),
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.grey.shade100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Grand Total:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('$cartTotal THB', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.indigo)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity, height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                    onPressed: () {
                      if (_poCustomer.isEmpty) return;
                      
                      widget.appData.onlineOrders.insert(0, {
                        'id': 'ORD-${Random().nextInt(1000)}',
                        'customer': _poCustomer,
                        'items': List.from(_currentCart),
                        'total': cartTotal,
                        'status': _poAutoVerify ? 'verified' : 'pending',
                        'date': AppDateUtils.todayStr(),
                        'loggedBy': widget.currentUser['name']
                      });
                      
                      setState(() {
                        _currentCart.clear();
                        _poCustomer = '';
                      });
                      
                      widget.onStateChanged();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order Submitted!')));
                    },
                    child: const Text('Submit Complete Order', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                )
              ]
            ],
          ),
        ),
      ),
    );
  }
}