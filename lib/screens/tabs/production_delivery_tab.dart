import 'package:flutter/material.dart';
import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/app_data.dart';
import '../../utils/data_utils.dart';

class ProductionDeliveryTab extends StatefulWidget {
  final Map<String, dynamic> currentUser;
  final AppData appData;
  final VoidCallback onStateChanged;

  const ProductionDeliveryTab({super.key, required this.currentUser, required this.appData, required this.onStateChanged});

  @override
  State<ProductionDeliveryTab> createState() => _ProductionDeliveryTabState();
}

class _ProductionDeliveryTabState extends State<ProductionDeliveryTab> {
  String _targetDate = '';
  String? _fhReqItem;
  final Map<String, String> _bhInputs = {};

  @override
  void initState() {
    super.initState();
    _targetDate = AppDateUtils.todayStr();
  }

  @override
  Widget build(BuildContext context) {
    // Aggregate pre-orders
    Map<String, int> preOrderTotals = {};
    for (var order in widget.appData.onlineOrders.where((o) => o['status'] == 'verified')) {
      for (var item in order['items']) {
        if (item['deliveryDate'] == _targetDate) {
          preOrderTotals[item['name']] = (preOrderTotals[item['name']] ?? 0) + (item['qty'] as int);
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Production & Delivery Book', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        
        // FH REQUEST BLOCK
        if (widget.currentUser['role'] == 'FH' || widget.currentUser['role'] == 'Owner')
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(Icons.arrow_circle_right, color: Colors.blue),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'FH Request: Restock Showcase',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: _fhReqItem,
                      decoration: const InputDecoration(filled: true, fillColor: Colors.white, border: OutlineInputBorder()),
                      items: widget.appData.menuItems.map((m) => DropdownMenuItem(value: m['name'] as String, child: Text(m['name']))).toList(),
                      onChanged: (val) => setState(() => _fhReqItem = val),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () async {
                      if (_fhReqItem == null) return;
                      final supabase = Supabase.instance.client;
                      final newReq = {
                        'id': 'REQ-${Random().nextInt(100000)}',
                        'name': _fhReqItem,
                        'status': 'pending',
                        'time_requested': AppDateUtils.timeStr(),
                        'requested_by': widget.currentUser['name'],
                        'time_delivered': null,
                        'delivered_by': null,
                        'delivered_qty': null
                      };
                      debugPrint('Attempting showcase request insert: $newReq');
                      final messenger = ScaffoldMessenger.of(context);
                      try {
                        final resp = await supabase.from('showcase_requests').insert(newReq).select() as List<dynamic>;
                        debugPrint('Insert response data: $resp');
                        if (resp.isNotEmpty) {
                          final inserted = resp.first as Map<String, dynamic>;
                          widget.appData.showcaseRequests.insert(0, inserted);
                        } else {
                          // nothing returned
                          widget.appData.showcaseRequests.insert(0, {
                            'id': 'REQ-${Random().nextInt(1000)}',
                            ...newReq,
                          });
                        }
                        messenger.showSnackBar(
                          const SnackBar(content: Text('Request sent to kitchen'), backgroundColor: Colors.green),
                        );
                      } catch (e) {
                        debugPrint('Failed to persist showcase request: $e');
                        messenger.showSnackBar(
                          SnackBar(content: Text('Error saving request: $e'), backgroundColor: Colors.red),
                        );
                        widget.appData.showcaseRequests.insert(0, {
                          'id': 'REQ-${Random().nextInt(1000)}',
                          ...newReq,
                        });
                      }
                      setState(() => _fhReqItem = null);
                      // refresh entire data to make sure we see server state
                      widget.onStateChanged();
                    },
                    child: const Text('Send to Kitchen'),
                  )
                ],
              ),
            ),
          ),
        
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Kitchen Queue: Showcase', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                widget.appData.showcaseRequests.isEmpty ? const Text('No requests.') : ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.appData.showcaseRequests.length,
                  itemBuilder: (context, index) {
                    var req = widget.appData.showcaseRequests[index];
                    bool isPending = req['status'] == 'pending';
                    return ListTile(
                      title: Text(req['name'] ?? req['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      subtitle: Text('Req by ${req['requested_by'] ?? req['requestedBy']} at ${req['time_requested'] ?? req['timeRequested']}'),
                      trailing: isPending 
                        ? (widget.currentUser['role'] == 'BH' || widget.currentUser['role'] == 'Owner')
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(width: 60, child: TextField(
                                  decoration: const InputDecoration(hintText: 'Qty', border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey))),
                                  onChanged: (val) => _bhInputs[req['id']] = val,
                                )),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                                  onPressed: () async {
                                    int? qty = int.tryParse(_bhInputs[req['id']] ?? '');
                                    if (qty == null) return;
                                    final supabase = Supabase.instance.client;
                                    // Update locally first for immediate UI feedback
                                    req['status'] = 'delivered';
                                    req['delivered_qty'] = qty;
                                    req['time_delivered'] = AppDateUtils.timeStr();
                                    req['delivered_by'] = widget.currentUser['name'];
                                    widget.onStateChanged();
                                    // Attempt to persist update to Supabase; ignore errors but log
                                    try {
                                      if (req['id'] != null) {
                                        await supabase.from('showcase_requests').update({
                                          'status': 'delivered',
                                          'delivered_qty': qty,
                                          'time_delivered': req['time_delivered'],
                                          'delivered_by': req['delivered_by'],
                                        }).eq('id', req['id']);
                                      }
                                    } catch (e) {
                                      debugPrint('Failed to update showcase request: $e');
                                    }
                                  }, 
                                  child: const Text('Deliver')
                                )
                              ],
                            )
                          : const Chip(label: Text('Baking...'), backgroundColor: Colors.amber)
                        : Chip(
                            label: Text((req['delivered_qty'] ?? req['deliveredQty'] ?? 0) == 0 ? 'Out of Stock' : 'Delivered ${(req['delivered_qty'] ?? req['deliveredQty'])}'), 
                            backgroundColor: (req['delivered_qty'] ?? req['deliveredQty'] ?? 0) == 0 ? Colors.red.shade100 : Colors.green.shade100,
                          ),
                    );
                  },
                )
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Kitchen Queue: Pre-Orders', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(width: 200, child: TextField(
                      decoration: const InputDecoration(labelText: 'Bake for Date', border: OutlineInputBorder()),
                      controller: TextEditingController(text: _targetDate),
                      onSubmitted: (val) => setState(() => _targetDate = val),
                    )),
                  ],
                ),
                const SizedBox(height: 16),
                preOrderTotals.isEmpty ? const Text('No pre-orders for this date.') : DataTable(
                  columns: const [DataColumn(label: Text('Product')), DataColumn(label: Text('Total Required'))],
                  rows: preOrderTotals.entries.map((e) => DataRow(cells: [
                    DataCell(Text(e.key, style: const TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text(e.value.toString(), style: const TextStyle(fontSize: 20, color: Colors.pink, fontWeight: FontWeight.bold))),
                  ])).toList(),
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}