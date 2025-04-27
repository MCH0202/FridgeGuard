
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/scanned_product.dart';

// Page for editing a scanned product's details
class ScanEditPage extends StatefulWidget {
  final ScannedProduct product;

  const ScanEditPage({super.key, required this.product});

  @override
  State<ScanEditPage> createState() => _ScanEditPageState();
}

class _ScanEditPageState extends State<ScanEditPage> {
  final nameController = TextEditingController();
  late String selectedStorage;
  late String selectedExpiry;

  // Predefined options for fridge and freezer storage durations
  final fridgeOptions = ['+3 days', '+14 days', 'Custom'];
  final freezerOptions = ['+1 month', '+6 months', 'Custom'];

  // Return storage options based on selected storage type
  List<String> get currentOptions =>
      selectedStorage == 'freezer' ? freezerOptions : fridgeOptions;

  @override
  void initState() {
    super.initState();
    nameController.text = widget.product.name;
    selectedStorage = widget.product.storage ?? '';
    selectedExpiry = widget.product.expiryDate != null
        ? DateFormat('yyyy.MM.dd').format(widget.product.expiryDate!)
        : '';
  }

  @override
  Widget build(BuildContext context) {
    final nonCustomOptions =
        currentOptions.where((o) => o != 'Custom').toList();
    final isCustomSelected = selectedExpiry.isNotEmpty &&
        !fridgeOptions.contains(selectedExpiry) &&
        !freezerOptions.contains(selectedExpiry);
    final customLabel = isCustomSelected ? selectedExpiry : 'Custom';

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Scanned Product')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Input for product name
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Storage type selection
            const Text('Select Storage'),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: ['freezer', 'fridge'].map((type) {
                final isSelected = selectedStorage == type;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: ChoiceChip(
                    label: Text('My $type'),
                    selected: isSelected,
                    onSelected: (_) => setState(() => selectedStorage = type),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),

            // Expiration date selection
            const Text('Select Expiration'),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: nonCustomOptions.map((option) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: ChoiceChip(
                    label: Text(option),
                    selected: selectedExpiry == option,
                    onSelected: (_) => setState(() => selectedExpiry = option),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Custom expiration date picker
            ChoiceChip(
              label: Text(customLabel),
              selected: isCustomSelected || selectedExpiry == 'Custom',
              onSelected: (_) async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: widget.product.expiryDate ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
                );
                if (picked != null) {
                  setState(() {
                    selectedExpiry =
                        DateFormat('yyyy.MM.dd').format(picked);
                  });
                }
              },
            ),
            const SizedBox(height: 40),

            // Action buttons (Cancel / Save)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final name = nameController.text.trim();
                      if (name.isEmpty ||
                          selectedStorage.isEmpty ||
                          selectedExpiry.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Please complete all fields')),
                        );
                        return;
                      }

                      // Calculate expiration date
                      DateTime expiryDate;
                      if (selectedExpiry.startsWith('+')) {
                        final parts = selectedExpiry.split(' ');
                        final value =
                            int.tryParse(parts[0].substring(1)) ?? 0;
                        final unit = parts[1];
                        expiryDate = DateTime.now().add(unit.contains('month')
                            ? Duration(days: value * 30)
                            : Duration(days: value));
                      } else {
                        expiryDate =
                            DateFormat('yyyy.MM.dd').parse(selectedExpiry);
                      }

                      // Return updated product data
                      final result = ScannedProduct(
                        barcode: widget.product.barcode,
                        name: name,
                        storage: selectedStorage,
                        expiryDate: expiryDate,
                      );

                      Navigator.pop(context, result);
                    },
                    child: const Text('Save'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
