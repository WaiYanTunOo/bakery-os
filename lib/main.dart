import 'package:flutter/material.dart';
import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';

const supabaseUrl = 'YOUR_SUPABASE_URL';
const supabaseKey = 'YOUR_SUPABASE_ANON_KEY';

final supabase = Supabase.instance.client;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: "https://kqagriqzwhwnbukevgtx.supabase.co",
    anonKey: "sb_publishable_6cFAI5c3ayXLCURLI65F2g_jxN_ezQi",
  );

  runApp(const BakeryOSApp());
}


class BakeryOSApp extends StatelessWidget {
  const BakeryOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BakeryOS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: const RoleSelectionScreen(),
    );
  }
}

// --- MOCK DATA ---
final List<Map<String, dynamic>> initialStaff = [
  {'id': 's1', 'name': 'Khun Jane', 'role': 'FH', 'can_manage_products': false},
  {'id': 's2', 'name': 'Khun A', 'role': 'BH', 'can_manage_products': false},
  {'id': 's3', 'name': 'Khun Boy', 'role': 'FH', 'can_manage_products': true},
  {'id': 'owner', 'name': 'Bakery Owner', 'role': 'Owner', 'can_manage_products': true},
];

final List<Map<String, dynamic>> initialMenuItems = [
  {'id': 1, 'name': 'Coconut Cake', 'price': 95.0},
  {'id': 2, 'name': 'Mango Mini', 'price': 95.0},
  {'id': 3, 'name': 'Rich Chocolate', 'price': 95.0},
  {'id': 4, 'name': 'Matcha Raspberry', 'price': 95.0},
  {'id': 5, 'name': 'Applepresso', 'price': 120.0},
];

// --- SCREEN 1: LOGIN ---
class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Center(
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.storefront, size: 64, color: Colors.indigo),
              const SizedBox(height: 16),
              const Text('BakeryOS', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const Text('Select a user to simulate login', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 32),
              ...initialStaff.map((staff) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: staff['role'] == 'Owner' ? Colors.indigo.shade100 : 
                                     staff['role'] == 'FH' ? Colors.blue.shade100 : Colors.orange.shade100,
                    child: Icon(
                      staff['role'] == 'Owner' ? Icons.trending_up : 
                      staff['role'] == 'FH' ? Icons.point_of_sale : Icons.kitchen,
                      color: staff['role'] == 'Owner' ? Colors.indigo : 
                             staff['role'] == 'FH' ? Colors.blue : Colors.orange,
                    ),
                  ),
                  title: Text(staff['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Role: ${staff['role']}'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => DashboardScreen(currentUser: staff)),
                    );
                  },
                ),
              )).toList(),
            ],
          ),
        ),
      ),
    );
  }
}

// --- SCREEN 2: MAIN DASHBOARD ---
class DashboardScreen extends StatefulWidget {
  final Map<String, dynamic> currentUser;
  const DashboardScreen({super.key, required this.currentUser});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _activeTab = 'home';
  
  // App State (Simulating Database)
  List<Map<String, dynamic>> _menuItems = List.from(initialMenuItems);
  List<Map<String, dynamic>> _staffDirectory = List.from(initialStaff);
  List<Map<String, dynamic>> _eodReports = [];
  List<Map<String, dynamic>> _onlineOrders = [];
  List<Map<String, dynamic>> _expenses = [];
  List<Map<String, dynamic>> _showcaseRequests = [];

  // Helper to format date
  String _todayStr() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')}";
  }
  
  String _timeStr() {
    final now = DateTime.now();
    return "${now.hour.toString().padLeft(2,'0')}:${now.minute.toString().padLeft(2,'0')}";
  }

  // --- NAVIGATION LOGIC ---
  List<Map<String, dynamic>> _getNavItems() {
    String role = widget.currentUser['role'];
    bool canManage = widget.currentUser['can_manage_products'];
    
    List<Map<String, dynamic>> items = [
      {'id': 'home', 'icon': Icons.home, 'label': 'Home'},
      {'id': 'production', 'icon': Icons.inventory, 'label': 'Prod & Delivery'},
    ];

    if (role == 'FH' || role == 'Owner') {
      items.add({'id': 'preorder', 'icon': Icons.shopping_cart, 'label': 'Pre-Orders'});
      items.add({'id': 'eod', 'icon': Icons.attach_money, 'label': 'Shift Reconcile'});
    }

    if (role != 'Owner') {
      items.add({'id': 'expense', 'icon': Icons.receipt, 'label': 'Log Expense'});
    }

    if (canManage) {
      items.add({'id': 'catalog', 'icon': Icons.local_offer, 'label': 'Manage Catalog'});
    }

    if (role == 'Owner') {
      items.add({'id': 'expense_book', 'icon': Icons.account_balance_wallet, 'label': 'Expense Book'});
      items.add({'id': 'ledger', 'icon': Icons.book, 'label': 'Verified Ledger'});
      items.add({'id': 'staff', 'icon': Icons.people, 'label': 'Staff Manager'});
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final navItems = _getNavItems();
    final selectedIndex = navItems.indexWhere((item) => item['id'] == _activeTab);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          children: [
            const Icon(Icons.storefront, color: Colors.indigo),
            const SizedBox(width: 8),
            const Text('BakeryOS', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.indigo.shade50, borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.indigo),
                  const SizedBox(width: 8),
                  Text(
                    '${widget.currentUser['name']} (${widget.currentUser['role']})',
                    style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Switch User',
              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RoleSelectionScreen())),
            )
          ],
        ),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sidebar Navigation
          Container(
            width: 250,
            color: Colors.white,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: navItems.map((item) {
                bool isSelected = _activeTab == item['id'];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: ListTile(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    selected: isSelected,
                    selectedTileColor: Colors.indigo.shade50,
                    leading: Icon(item['icon'], color: isSelected ? Colors.indigo : Colors.grey.shade600),
                    title: Text(item['label'], style: TextStyle(
                      color: isSelected ? Colors.indigo : Colors.grey.shade800,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
                    )),
                    onTap: () => setState(() => _activeTab = item['id']),
                  ),
                );
              }).toList(),
            ),
          ),
          const VerticalDivider(width: 1, thickness: 1),
          // Main Content Area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: SingleChildScrollView(
                child: _buildActiveTabContent(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveTabContent() {
    switch (_activeTab) {
      case 'home': return _buildHome();
      case 'production': return _buildProductionDelivery();
      case 'preorder': return _buildPreOrder();
      case 'eod': return _buildEOD();
      case 'expense': return _buildExpense();
      case 'expense_book': return _buildExpenseLedger();
      case 'ledger': return _buildVerifiedLedger();
      case 'catalog': return _buildCatalog();
      case 'staff': return _buildStaffManager();
      default: return const Center(child: Text('Work in progress'));
    }
  }

  // --- TAB: HOME DASHBOARD ---
  Widget _buildHome() {
    if (widget.currentUser['role'] != 'Owner') {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 100),
            Icon(Icons.coffee, size: 80, color: Colors.indigo.shade200),
            const SizedBox(height: 16),
            Text('Welcome, ${widget.currentUser['name']}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const Text('Use the menu on the left to begin your shift.', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    int pendingCount = _onlineOrders.where((o) => o['status'] == 'pending').length;
    double verifiedRev = _onlineOrders.where((o) => o['status'] == 'verified').fold(0.0, (sum, o) => sum + o['total']);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Owner Dashboard', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        Row(
          children: [
            _buildStatCard('Pending Transfers', pendingCount.toString(), Icons.pending_actions, Colors.orange),
            const SizedBox(width: 16),
            _buildStatCard('Verified Revenue', '$verifiedRev THB', Icons.check_circle, Colors.green),
            const SizedBox(width: 16),
            _buildStatCard('Pending Shift Reviews', _eodReports.length.toString(), Icons.assignment, Colors.indigo),
          ],
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Clearing Account (Needs Verification)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _onlineOrders.where((o) => o['status'] == 'pending').isEmpty 
                  ? const Text('No pending orders.')
                  : ListView(
                      shrinkWrap: true,
                      children: _onlineOrders.where((o) => o['status'] == 'pending').map((order) {
                        return ListTile(
                          title: Text(order['customer'], style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${order['items'].length} items | Logged by ${order['loggedBy']}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('${order['total']} THB', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.indigo)),
                              const SizedBox(width: 16),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                                onPressed: () {
                                  setState(() => order['status'] = 'verified');
                                },
                                child: const Text('Verify'),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    )
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 20),
                  const SizedBox(width: 8),
                  Text(title, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ),
      ),
    );
  }

  // --- TAB: EXPENSE FORM ---
  final TextEditingController _expDescCtrl = TextEditingController();
  final TextEditingController _expQtyCtrl = TextEditingController(text: '1');
  final TextEditingController _expPriceCtrl = TextEditingController();
  final TextEditingController _expRemarkCtrl = TextEditingController();
  String _expSource = 'Petty Cash (Register)';

  Widget _buildExpense() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 600),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.receipt, color: Colors.pink),
                  SizedBox(width: 8),
                  Text('Log Daily Expense', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                child: const Text('Record ALL expenses here for detailed tracking. Use Qashier POS "Pay Out" for register cash.', style: TextStyle(color: Colors.blue)),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _expDescCtrl,
                decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: TextField(controller: _expQtyCtrl, decoration: const InputDecoration(labelText: 'Qty', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                  const SizedBox(width: 16),
                  Expanded(child: TextField(controller: _expPriceCtrl, decoration: const InputDecoration(labelText: 'Unit Price (THB)', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _expSource,
                decoration: const InputDecoration(labelText: 'Payment Source', border: OutlineInputBorder()),
                items: [
                  if (widget.currentUser['role'] != 'BH') const DropdownMenuItem(value: 'Petty Cash (Register)', child: Text('Cash Register (Petty Cash)')),
                  const DropdownMenuItem(value: 'Staff Pocket', child: Text('Staff Paid Out of Pocket')),
                  if (widget.currentUser['role'] == 'Owner') const DropdownMenuItem(value: 'Owner Transfer', child: Text('Owner Transferred directly')),
                ],
                onChanged: (val) => setState(() => _expSource = val!),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _expRemarkCtrl,
                decoration: const InputDecoration(labelText: 'Remarks (Optional)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.pink, foregroundColor: Colors.white),
                  onPressed: () {
                    if (_expDescCtrl.text.isEmpty || _expPriceCtrl.text.isEmpty) return;
                    double price = double.tryParse(_expPriceCtrl.text) ?? 0;
                    int qty = int.tryParse(_expQtyCtrl.text) ?? 1;
                    setState(() {
                      _expenses.insert(0, {
                        'id': 'EXP-${Random().nextInt(1000)}',
                        'date': _todayStr(),
                        'time': _timeStr(),
                        'description': _expDescCtrl.text,
                        'qty': qty,
                        'unitPrice': price,
                        'total': price * qty,
                        'paidFrom': _expSource,
                        'remark': _expRemarkCtrl.text,
                        'loggedBy': widget.currentUser['name']
                      });
                      _expDescCtrl.clear();
                      _expPriceCtrl.clear();
                      _expRemarkCtrl.clear();
                      _expQtyCtrl.text = '1';
                    });
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Expense Logged!')));
                  },
                  child: const Text('Submit Expense', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // --- TAB: EXPENSE LEDGER (Owner) ---
  Widget _buildExpenseLedger() {
    double total = _expenses.fold(0.0, (sum, e) => sum + e['total']);
    double staffOwed = _expenses.where((e) => e['paidFrom'] == 'Staff Pocket').fold(0.0, (sum, e) => sum + e['total']);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Expense Book Ledger', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildStatCard('Total Expenses', '$total THB', Icons.receipt_long, Colors.pink),
            const SizedBox(width: 16),
            _buildStatCard('Owed to Staff', '$staffOwed THB', Icons.warning, Colors.red),
          ],
        ),
        const SizedBox(height: 24),
        Card(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Date & Time')),
                DataColumn(label: Text('Description')),
                DataColumn(label: Text('Source')),
                DataColumn(label: Text('Total')),
                DataColumn(label: Text('Logged By')),
              ],
              rows: _expenses.map((e) => DataRow(cells: [
                DataCell(Text('${e['date']} ${e['time']}')),
                DataCell(Text(e['description'])),
                DataCell(Text(e['paidFrom'])),
                DataCell(Text('${e['total']} THB', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.pink))),
                DataCell(Text(e['loggedBy'])),
              ])).toList(),
            ),
          ),
        )
      ],
    );
  }

  // --- TAB: PRE-ORDER (Cart System) ---
  String _poCustomer = '';
  String? _poItem;
  int _poQty = 1;
  double _poPrice = 0.0;
  String _poDate = '';
  List<Map<String, dynamic>> _currentCart = [];
  bool _poAutoVerify = false;

  Widget _buildPreOrder() {
    if (_poDate.isEmpty) _poDate = _todayStr(); // default

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
                        value: _poItem,
                        decoration: const InputDecoration(labelText: 'Product', border: OutlineInputBorder()),
                        items: _menuItems.map((m) => DropdownMenuItem(value: m['name'] as String, child: Text(m['name']))).toList(),
                        onChanged: (val) {
                          setState(() {
                            _poItem = val;
                            _poPrice = _menuItems.firstWhere((m) => m['name'] == val)['price'];
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
                        key: ValueKey(_poPrice), // Force update when dropdown changes
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
                      setState(() {
                        _onlineOrders.insert(0, {
                          'id': 'ORD-${Random().nextInt(1000)}',
                          'customer': _poCustomer,
                          'items': List.from(_currentCart),
                          'total': cartTotal,
                          'status': _poAutoVerify ? 'verified' : 'pending',
                          'date': _todayStr(),
                          'loggedBy': widget.currentUser['name']
                        });
                        _currentCart.clear();
                        _poCustomer = '';
                      });
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

  // --- TAB: PRODUCTION & DELIVERY (FH & BH) ---
  String _targetDate = '';
  String? _fhReqItem;
  Map<String, String> _bhInputs = {};

  Widget _buildProductionDelivery() {
    if (_targetDate.isEmpty) _targetDate = _todayStr();

    // Aggregate pre-orders
    Map<String, int> preOrderTotals = {};
    for (var order in _onlineOrders.where((o) => o['status'] == 'verified')) {
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
                  const Text('FH Request: Restock Showcase', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _fhReqItem,
                      decoration: const InputDecoration(filled: true, fillColor: Colors.white, border: OutlineInputBorder()),
                      items: _menuItems.map((m) => DropdownMenuItem(value: m['name'] as String, child: Text(m['name']))).toList(),
                      onChanged: (val) => setState(() => _fhReqItem = val),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (_fhReqItem == null) return;
                      setState(() {
                        _showcaseRequests.insert(0, {
                          'id': 'REQ-${Random().nextInt(1000)}',
                          'name': _fhReqItem,
                          'status': 'pending',
                          'timeRequested': _timeStr(),
                          'requestedBy': widget.currentUser['name'],
                          'timeDelivered': null,
                          'deliveredBy': null,
                          'deliveredQty': null
                        });
                        _fhReqItem = null;
                      });
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
                _showcaseRequests.isEmpty ? const Text('No requests.') : ListView.builder(
                  shrinkWrap: true,
                  itemCount: _showcaseRequests.length,
                  itemBuilder: (context, index) {
                    var req = _showcaseRequests[index];
                    bool isPending = req['status'] == 'pending';
                    return ListTile(
                      title: Text(req['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      subtitle: Text('Req by ${req['requestedBy']} at ${req['timeRequested']}'),
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
                                  onPressed: () {
                                    int? qty = int.tryParse(_bhInputs[req['id']] ?? '');
                                    if (qty == null) return;
                                    setState(() {
                                      req['status'] = 'delivered';
                                      req['deliveredQty'] = qty;
                                      req['timeDelivered'] = _timeStr();
                                      req['deliveredBy'] = widget.currentUser['name'];
                                    });
                                  }, 
                                  child: const Text('Deliver')
                                )
                              ],
                            )
                          : const Chip(label: Text('Baking...'), backgroundColor: Colors.amber)
                        : Chip(
                            label: Text(req['deliveredQty'] == 0 ? 'Out of Stock' : 'Delivered ${req['deliveredQty']}'), 
                            backgroundColor: req['deliveredQty'] == 0 ? Colors.red.shade100 : Colors.green.shade100,
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

  // --- TAB: MANAGE CATALOG (Owner/Manager) ---
  final TextEditingController _catNameCtrl = TextEditingController();
  final TextEditingController _catPriceCtrl = TextEditingController();

  Widget _buildCatalog() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Master Product Catalog', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Add Product', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      TextField(controller: _catNameCtrl, decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder())),
                      const SizedBox(height: 16),
                      TextField(controller: _catPriceCtrl, decoration: const InputDecoration(labelText: 'Price', border: OutlineInputBorder()), keyboardType: TextInputType.number),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          if (_catNameCtrl.text.isEmpty) return;
                          setState(() {
                            _menuItems.add({'id': DateTime.now().millisecondsSinceEpoch, 'name': _catNameCtrl.text, 'price': double.tryParse(_catPriceCtrl.text) ?? 0.0});
                            _catNameCtrl.clear(); _catPriceCtrl.clear();
                          });
                        },
                        child: const Text('Save to Menu'),
                      )
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: Card(
                child: DataTable(
                  columns: const [DataColumn(label: Text('Name')), DataColumn(label: Text('Price')), DataColumn(label: Text('Action'))],
                  rows: _menuItems.map((m) => DataRow(cells: [
                    DataCell(Text(m['name'])),
                    DataCell(Text('${m['price']} THB')),
                    DataCell(IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => setState(() => _menuItems.remove(m)))),
                  ])).toList(),
                ),
              ),
            )
          ],
        )
      ],
    );
  }

  // --- TAB: STAFF MANAGER (Owner) ---
  final TextEditingController _stfNameCtrl = TextEditingController();
  String _stfRole = 'FH';
  bool _stfPerm = false;

  Widget _buildStaffManager() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Staff & Permissions Directory', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Add Staff', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      TextField(controller: _stfNameCtrl, decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder())),
                      const SizedBox(height: 16),
                      DropdownButtonFormField(
                        value: _stfRole,
                        decoration: const InputDecoration(labelText: 'Role', border: OutlineInputBorder()),
                        items: const [DropdownMenuItem(value:'FH',child:Text('FH')), DropdownMenuItem(value:'BH',child:Text('BH'))],
                        onChanged: (val) => setState(() => _stfRole = val.toString()),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Checkbox(value: _stfPerm, onChanged: (val) => setState(() => _stfPerm = val!)),
                          const Text('Can Manage Menu?'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          if (_stfNameCtrl.text.isEmpty) return;
                          setState(() {
                            _staffDirectory.add({'id': 's${Random().nextInt(1000)}', 'name': _stfNameCtrl.text, 'role': _stfRole, 'can_manage_products': _stfPerm});
                            _stfNameCtrl.clear();
                          });
                        },
                        child: const Text('Add Staff'),
                      )
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: Card(
                child: DataTable(
                  columns: const [DataColumn(label: Text('Name')), DataColumn(label: Text('Role')), DataColumn(label: Text('Menu Perm'))],
                  rows: _staffDirectory.where((s) => s['id'] != 'owner').map((s) => DataRow(cells: [
                    DataCell(Text(s['name'], style: const TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Chip(label: Text(s['role']))),
                    DataCell(Checkbox(value: s['can_manage_products'], onChanged: (val) => setState(() => s['can_manage_products'] = val!))),
                  ])).toList(),
                ),
              ),
            )
          ],
        )
      ],
    );
  }

  // --- TAB: VERIFIED LEDGER (Owner) ---
  Widget _buildVerifiedLedger() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Verified Sales Ledger', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        Card(
          child: DataTable(
            columns: const [DataColumn(label: Text('ID')), DataColumn(label: Text('Customer')), DataColumn(label: Text('Items')), DataColumn(label: Text('Total'))],
            rows: _onlineOrders.where((o) => o['status'] == 'verified').map((o) => DataRow(cells: [
              DataCell(Text(o['id'])),
              DataCell(Text(o['customer'])),
              DataCell(Text('${o['items'].length} item(s)')),
              DataCell(Text('${o['total']} THB', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
            ])).toList(),
          ),
        )
      ],
    );
  }

  // --- TAB: EOD FORM (FH) ---
  final TextEditingController _eodGross = TextEditingController();
  final TextEditingController _eodPrompt = TextEditingController();
  final TextEditingController _eodCard = TextEditingController();
  final TextEditingController _eodExp = TextEditingController();
  final TextEditingController _eodAct = TextEditingController();
  final TextEditingController _eodNote = TextEditingController();
  String _eodShift = '3:30 PM';

  Widget _buildEOD() {
    double exp = double.tryParse(_eodExp.text) ?? 0;
    double act = double.tryParse(_eodAct.text) ?? 0;
    double disc = act - exp;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 600),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Shift Reconciliation', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              DropdownButtonFormField(
                value: _eodShift,
                decoration: const InputDecoration(labelText: 'Shift', border: OutlineInputBorder()),
                items: const [DropdownMenuItem(value:'3:30 PM',child:Text('3:30 PM')), DropdownMenuItem(value:'5:30 PM',child:Text('5:30 PM')), DropdownMenuItem(value:'8:00 PM',child:Text('8:00 PM'))],
                onChanged: (val) => setState(() => _eodShift = val.toString()),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.blue.shade50,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('1. Copy from POS Z-Report', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: _eodGross, decoration: const InputDecoration(labelText: 'Gross', filled: true, fillColor: Colors.white))),
                        const SizedBox(width: 8),
                        Expanded(child: TextField(controller: _eodPrompt, decoration: const InputDecoration(labelText: 'PromptPay', filled: true, fillColor: Colors.white))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: _eodCard, decoration: const InputDecoration(labelText: 'Card', filled: true, fillColor: Colors.white))),
                        const SizedBox(width: 8),
                        Expanded(child: TextField(controller: _eodExp, onChanged: (v)=>setState((){}), decoration: const InputDecoration(labelText: 'Expected Cash', filled: true, fillColor: Colors.white))),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.amber.shade50,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('2. Physical Cash Count', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
                    const SizedBox(height: 16),
                    TextField(controller: _eodAct, onChanged: (v)=>setState((){}), decoration: const InputDecoration(labelText: 'Actual Cash', filled: true, fillColor: Colors.white)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (_eodExp.text.isNotEmpty && _eodAct.text.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  color: disc == 0 ? Colors.green.shade50 : Colors.red.shade50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Discrepancy:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('${disc > 0 ? '+' : ''}${disc.toStringAsFixed(2)} THB', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: disc == 0 ? Colors.green : Colors.red)),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              if (disc != 0)
                TextField(controller: _eodNote, decoration: const InputDecoration(labelText: 'Explanation Required', border: OutlineInputBorder())),
              const SizedBox(height: 24),
              SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: () {
                setState(() {
                  _eodReports.add({'shift': _eodShift, 'disc': disc});
                  _eodGross.clear(); _eodPrompt.clear(); _eodCard.clear(); _eodExp.clear(); _eodAct.clear(); _eodNote.clear();
                  _activeTab = 'home';
                });
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Shift Closed!')));
              }, child: const Text('Submit Report')))
            ],
          ),
        ),
      ),
    );
  }
}