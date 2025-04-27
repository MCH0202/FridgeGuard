import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../pages/write_food_page.dart';
import '../widgets/food_card.dart';
import '../pages/scan_page.dart';

class FoodListPage extends StatefulWidget {
  const FoodListPage({super.key});

  @override
  State<FoodListPage> createState() => _FoodListPageState();
}

class _FoodListPageState extends State<FoodListPage> {
  String searchText = '';
  String selectedCategory = 'all';

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Food List')),
      body: Column(
        children: [
          // 搜索框
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search food...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() => searchText = value.toLowerCase());
              },
            ),
          ),
          // 分类筛选
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: selectedCategory == 'all',
                  onSelected: (_) => setState(() => selectedCategory = 'all'),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Fridge'),
                  selected: selectedCategory == 'fridge',
                  onSelected:
                      (_) => setState(() => selectedCategory = 'fridge'),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Freezer'),
                  selected: selectedCategory == 'freezer',
                  onSelected:
                      (_) => setState(() => selectedCategory = 'freezer'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // 列表
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('foods')
                      .where('userId', isEqualTo: userId)
                      .orderBy('createdAt', descending: false)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong.'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs =
                    snapshot.data!.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final name =
                          (data['name'] ?? '').toString().toLowerCase();
                      final storage =
                          (data['storage'] ?? '').toString().toLowerCase();

                      final matchesSearch = name.contains(searchText);
                      final matchesCategory =
                          selectedCategory == 'all' ||
                          storage == selectedCategory;

                      return matchesSearch && matchesCategory;
                    }).toList();

                if (docs.isEmpty) {
                  return const Center(child: Text('No matching items.'));
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final name = data['name'];
                    final expiryDate = data['expiryDate'] as Timestamp?;

                    return FoodCard(
                      name: name ?? 'Unnamed',
                      expiryDate: expiryDate,
                      brightness: brightness,
                      onDelete: () async {
                        await FirebaseFirestore.instance
                            .collection('foods')
                            .doc(doc.id)
                            .delete();
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WriteFoodPage(),
                  ),
                );
              },
              icon: const Icon(Icons.edit),
              label: const Text('Write'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ScanPage()),
                );
              },
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Scan'),
            ),
          ],
        ),
      ),
    );
  }
}
