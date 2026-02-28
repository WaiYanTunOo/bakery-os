import 'dart:math';

import 'package:flutter/material.dart';

import '../../data/app_data.dart';
import '../../services/supabase_service.dart';
import '../../utils/audit_logger.dart';
import '../../utils/data_utils.dart';

class ProductionDeliveryTab extends StatefulWidget {
  final Map<String, dynamic> currentUser;
  final AppData appData;
  final VoidCallback onStateChanged;

  const ProductionDeliveryTab({
    super.key,
    required this.currentUser,
    required this.appData,
    required this.onStateChanged,
  });

  @override
  State<ProductionDeliveryTab> createState() => _ProductionDeliveryTabState();
}

class _ProductionDeliveryTabState extends State<ProductionDeliveryTab> {
  String _targetDate = '';
  late final TextEditingController _targetDateController;
  String? _fhReqItem;
  final Map<String, String> _bhInputs = {};

  Map<String, int> _verifiedPreOrders = {};
  int _pendingForDate = 0;

  bool get _canRequestShowcase {
    final role = widget.currentUser['role'];
    return role == 'FH' || role == 'Owner';
  }

  bool get _canCompleteShowcase {
    final role = widget.currentUser['role'];
    return role == 'BH' || role == 'Owner';
  }

  @override
  void initState() {
    super.initState();
    _targetDate = AppDateUtils.todayStr();
    _targetDateController = TextEditingController(text: _targetDate);
    _computePreOrders();
  }

  @override
  void dispose() {
    _targetDateController.dispose();
    super.dispose();
  }

  bool _isValidDate(String value) {
    final expression = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!expression.hasMatch(value.trim())) return false;
    return DateTime.tryParse(value.trim()) != null;
  }

  void _computePreOrders() {
    final verified = <String, int>{};
    var pending = 0;

    for (final order in widget.appData.onlineOrders) {
      final status = (order['status'] ?? '').toString();
      final items = order['items'];
      if (items is! List) continue;

      for (final rawItem in items) {
        if (rawItem is! Map) continue;
        final item = Map<String, dynamic>.from(rawItem);
        if ((item['deliveryDate'] ?? '').toString() != _targetDate) continue;

        final qty = (item['qty'] as num?)?.toInt() ?? 0;
        final name = (item['name'] ?? '').toString();
        if (qty <= 0 || name.isEmpty) continue;

        if (status == 'verified') {
          verified[name] = (verified[name] ?? 0) + qty;
        } else if (status == 'pending') {
          pending += qty;
        }
      }
    }

    setState(() {
      _verifiedPreOrders = verified;
      _pendingForDate = pending;
    });
  }

  @override
  void didUpdateWidget(covariant ProductionDeliveryTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.appData.onlineOrders != widget.appData.onlineOrders) {
      _computePreOrders();
    }
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

      if (inserted == null) {
        _showMessage('Failed to save request. Try again.', error: true);
        return;
      }

      widget.appData.showcaseRequests.insert(0, inserted);
      setState(() => _fhReqItem = null);
      widget.onStateChanged();

      AuditLogger.action(
        actor: actor,
        role: role,
        action: 'create',
        entity: 'showcase_request',
        entityId: requestId,
      );
      _showMessage('Request sent to kitchen.', error: false);
    } on ValidationError catch (e) {
      if (!mounted) return;
      _showMessage(e.message, error: true);
    } catch (_) {
      if (!mounted) return;
      _showMessage('Unexpected error while creating request.', error: true);
    }
  }

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
      if (!ok) {
        _showMessage('Failed to save delivery update.', error: true);
        return;
      }

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
      if (!mounted) return;
      _showMessage(e.message, error: true);
    } catch (_) {
      if (!mounted) return;
      _showMessage('Unexpected error while updating request.', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final preOrderTotals = _verifiedPreOrders;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Production & Delivery Book',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        Card(
          color: Colors.blue.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Icon(Icons.arrow_circle_right, color: Colors.blue),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'FH Request: Restock Showcase',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: _fhReqItem,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
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
                    onChanged: _canRequestShowcase
                        ? (val) => setState(() => _fhReqItem = val)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _canRequestShowcase ? _submitShowcaseRequest : null,
                  child: const Text('Send to Kitchen'),
                ),
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
                const Text(
                  'Kitchen Queue: Showcase',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                widget.appData.showcaseRequests.isEmpty
                    ? const Text('No requests.')
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: widget.appData.showcaseRequests.length,
                        separatorBuilder: (_, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final req = widget.appData.showcaseRequests[index];
                          final isPending = req['status'] == 'pending';
                          final deliveredQty =
                              (req['delivered_qty'] ?? req['deliveredQty'] ?? 0)
                                  as int;
                          return ListTile(
                            title: Text(
                              (req['name'] ?? '').toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            subtitle: Text(
                              'Req by ${req['requested_by'] ?? req['requestedBy']} at ${req['time_requested'] ?? req['timeRequested']}',
                            ),
                            trailing: isPending
                                ? (_canCompleteShowcase
                                    ? Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(
                                            width: 70,
                                            child: TextField(
                                              decoration: const InputDecoration(
                                                hintText: 'Qty',
                                                border: OutlineInputBorder(),
                                              ),
                                              keyboardType:
                                                  TextInputType.number,
                                              onChanged: (val) =>
                                                  _bhInputs[(req['id'] ?? '')
                                                      .toString()] = val,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.indigo,
                                              foregroundColor: Colors.white,
                                            ),
                                            onPressed: () =>
                                                _completeShowcaseRequest(req),
                                            child: const Text('Deliver'),
                                          ),
                                        ],
                                      )
                                    : const Chip(
                                        label: Text('Baking...'),
                                        backgroundColor: Colors.amber,
                                      ))
                                : Chip(
                                    label: Text(
                                      deliveredQty == 0
                                          ? 'Out of Stock'
                                          : 'Delivered $deliveredQty',
                                    ),
                                    backgroundColor: deliveredQty == 0
                                        ? Colors.red.shade100
                                        : Colors.green.shade100,
                                  ),
                          );
                        },
                      ),
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
                  children: [
                    const Expanded(
                      child: Text(
                        'Kitchen Queue: Pre-Orders',
                        style:
                            TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      width: 200,
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Bake for Date',
                          border: OutlineInputBorder(),
                        ),
                        controller: _targetDateController,
                        onSubmitted: (val) {
                          if (_isValidDate(val)) {
                            setState(() => _targetDate = val.trim());
                            _computePreOrders();
                          } else {
                            _showMessage(
                              'Date must be in YYYY-MM-DD format.',
                              error: true,
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: 'Refresh queue',
                      onPressed: () {
                        final dateInput = _targetDateController.text.trim();
                        if (_isValidDate(dateInput)) {
                          setState(() => _targetDate = dateInput);
                          _computePreOrders();
                        } else {
                          _showMessage(
                            'Date must be in YYYY-MM-DD format.',
                            error: true,
                          );
                        }
                      },
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Pending pre-order units for this date: $_pendingForDate',
                  style: TextStyle(color: Colors.orange.shade800),
                ),
                const SizedBox(height: 16),
                preOrderTotals.isEmpty
                    ? const Text('No verified pre-orders for this date.')
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Product')),
                            DataColumn(label: Text('Verified Required Qty')),
                          ],
                          rows: preOrderTotals.entries
                              .map(
                                (e) => DataRow(
                                  cells: [
                                    DataCell(
                                      Text(
                                        e.key,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        e.value.toString(),
                                        style: const TextStyle(
                                          fontSize: 20,
                                          color: Colors.pink,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              .toList(),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
