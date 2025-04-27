import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Page for manually adding new food items
class WriteFoodPage extends StatefulWidget {
  const WriteFoodPage({super.key});

  @override
  State<WriteFoodPage> createState() => _WriteFoodPageState();
}

class _WriteFoodPageState extends State<WriteFoodPage> {
  String selectedStorage = ''; // Selected storage type: fridge or freezer
  String selectedExpiry = ''; // Selected expiration option

  // Predefined options for fridge and freezer storage
  final fridgeOptions = ['+3 days', '+14 days', 'Custom'];
  final freezerOptions = ['+1 month', '+6 months', 'Custom'];

  // Dynamically select options based on current selected storage
  List<String> get currentOptions =>
      selectedStorage == 'freezer' ? freezerOptions : fridgeOptions;

  final nameController = TextEditingController(); // Controller for food name input

  // Format custom picked date
  String get formattedCustomDate =>
      selectedExpiry.contains('.') ? selectedExpiry : '';

  // Show a missing information warning dialog
  void showMissingDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nonCustomOptions = currentOptions.where((o) => o != 'Custom').toList();
    final isCustomSelected =
        selectedExpiry != '' &&
        !fridgeOptions.contains(selectedExpiry) &&
        !freezerOptions.contains(selectedExpiry);
    final customLabel = isCustomSelected ? selectedExpiry : 'Custom';

    return Scaffold(
      appBar: AppBar(title: const Text('Add Food Item')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Input field for food name
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 28),

            // Storage type selection (Fridge or Freezer)
            const Text('Add to', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: ['freezer', 'fridge'].map((type) {
                final isSelected = selectedStorage == type;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: ChoiceChip(
                    showCheckmark: false,
                    label: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Text('My $type'),
                    ),
                    selected: isSelected,
                    onSelected: (_) => setState(() => selectedStorage = type),
                    shape: const StadiumBorder(),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),

            // Expiration date selection
            const Text('Select an expiration date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Predefined expiration options
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: nonCustomOptions.map((option) {
                    final isSelected = selectedExpiry == option;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ChoiceChip(
                        showCheckmark: false,
                        label: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: Text(option),
                        ),
                        selected: isSelected,
                        onSelected: (_) => setState(() => selectedExpiry = option),
                        shape: const StadiumBorder(),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Custom expiration date picker
                Center(
                  child: ChoiceChip(
                    showCheckmark: false,
                    label: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Text(customLabel),
                    ),
                    selected: currentOptions.contains('Custom') &&
                        (selectedExpiry == 'Custom' || isCustomSelected),
                    onSelected: (_) async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
                      );
                      if (picked != null) {
                        setState(() {
                          selectedExpiry = DateFormat('yyyy.MM.dd').format(picked);
                        });
                      }
                    },
                    shape: const StadiumBorder(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Add food item button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add item', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                ),
                onPressed: () async {
                  // Validation checks
                  if (selectedStorage.isEmpty) {
                    showMissingDialog(context, 'Missing inventory', 'Please select an inventory to add the food item to.');
                    return;
                  }
                  if (selectedExpiry.isEmpty) {
                    showMissingDialog(context, 'Missing expiration', 'Please select an expiration date.');
                    return;
                  }
                  if (nameController.text.trim().isEmpty) {
                    showMissingDialog(context, 'Missing name', 'Please enter a food name.');
                    return;
                  }

                  final name = nameController.text.trim();

                  // Calculate expiration date based on selection
                  DateTime expiryDate;
                  if (selectedExpiry.startsWith('+')) {
                    final parts = selectedExpiry.split(' ');
                    final numStr = parts[0].substring(1);
                    final unit = parts[1];
                    final value = int.tryParse(numStr) ?? 0;
                    if (unit.startsWith('day')) {
                      expiryDate = DateTime.now().add(Duration(days: value));
                    } else if (unit.startsWith('month')) {
                      expiryDate = DateTime.now().add(Duration(days: value * 30));
                    } else {
                      expiryDate = DateTime.now();
                    }
                  } else {
                    expiryDate = DateFormat('yyyy.MM.dd').parse(selectedExpiry);
                  }

                  final uid = FirebaseAuth.instance.currentUser?.uid;

                  try {
                    // Add food item to Firestore
                    await FirebaseFirestore.instance.collection('foods').add({
                      'name': name,
                      'storage': selectedStorage,
                      'expiry': selectedExpiry,
                      'expiryDate': Timestamp.fromDate(expiryDate),
                      'createdAt': Timestamp.now(),
                      'userId': uid,
                    });
                    if (!context.mounted) return;
                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Item "$name" added to $selectedStorage.')),
                    );

                    // Reset form fields
                    setState(() {
                      nameController.clear();
                      selectedStorage = '';
                      selectedExpiry = '';
                    });
                  } catch (e) {
                    if (!context.mounted) return;
                    // Show failure message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to add item: $e')),
                    );
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
