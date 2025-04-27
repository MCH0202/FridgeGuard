import 'package:flutter/material.dart';

class FoodItem {
  final String name;
  final DateTime addedDate;
  final DateTime expiryDate;

  FoodItem({
    required this.name,
    required this.addedDate,
    required this.expiryDate,
  });
}

class FoodListProvider extends ChangeNotifier {
  final List<FoodItem> foodItems = [];

  void addFood(FoodItem item) {
    foodItems.add(item);
    notifyListeners();
  }

  void removeFood(FoodItem item) {
    foodItems.remove(item);
    notifyListeners();
  }
}
