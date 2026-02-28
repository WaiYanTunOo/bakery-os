import 'package:flutter/material.dart';
import '../../data/app_data.dart';

class CatalogTab extends StatefulWidget {
  final AppData appData;
  final VoidCallback onStateChanged;

  const CatalogTab({super.key, required this.appData, required this.onStateChanged});

  @override
  State<CatalogTab> createState() => _CatalogTabState();
}

class _CatalogTabState extends State<CatalogTab> {
  final TextEditingController _catNameCtrl = TextEditingController();
  final TextEditingController _catPriceCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
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
                          widget.appData.menuItems.add({
                            'id': DateTime.now().millisecondsSinceEpoch, 
                            'name': _catNameCtrl.text, 
                            'price': double.tryParse(_catPriceCtrl.text) ?? 0.0
                          });
                          _catNameCtrl.clear(); 
                          _catPriceCtrl.clear();
                          widget.onStateChanged();
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
                  rows: widget.appData.menuItems.map((m) => DataRow(cells: [
                    DataCell(Text(m['name'])),
                    DataCell(Text('${m['price']} THB')),
                    DataCell(IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () {
                      widget.appData.menuItems.remove(m);
                      widget.onStateChanged();
                    })),
                  ])).toList(),
                ),
              ),
            )
          ],
        )
      ],
    );
  }
}