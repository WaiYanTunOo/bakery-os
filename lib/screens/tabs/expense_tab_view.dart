part of 'expense_tab.dart';

extension _ExpenseTabView on _ExpenseTabState {
  Widget _buildExpenseCard(BuildContext context) {
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
                  Expanded(
                    child: TextField(
                      controller: _expQtyCtrl,
                      decoration: const InputDecoration(labelText: 'Qty', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _expPriceCtrl,
                      decoration: const InputDecoration(labelText: 'Unit Price (THB)', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _expSource,
                decoration: const InputDecoration(labelText: 'Payment Source', border: OutlineInputBorder()),
                items: _paymentSourceItems(),
                onChanged: (val) {
                  if (val != null) _setExpenseSource(val);
                },
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
                  onPressed: () => _submitExpense(context),
                  child: const Text('Submit Expense', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
