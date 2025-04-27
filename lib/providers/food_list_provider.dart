import 'package:flutter/material.dart';

// Model representing a food item with name, added date, and expiry date
class FoodItem {
  final String name; // Name of the food item
  final DateTime addedDate; // Date when the item was added
  final DateTime expiryDate; // Expiration date of the item

  FoodItem({
    required this.name,
    required this.addedDate,
    required this.expiryDate,
  });
}

// Provider class to manage a list of food items
class FoodListProvider extends ChangeNotifier {
  final List<FoodItem> foodItems = []; // List of current food items

  // Add a new food item and notify listeners
  void addFood(FoodItem item) {
    foodItems.add(item);
    notifyListeners();
  }

  // Remove a food item and notify listeners
  void removeFood(FoodItem item) {
    foodItems.remove(item);
    notifyListeners();
  }
}
