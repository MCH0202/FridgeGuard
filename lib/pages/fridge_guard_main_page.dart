// lib/pages/fridge_guard_main_page.dart

import 'package:flutter/material.dart';
import 'home_page.dart';
import 'food_list_page.dart';
import 'settings_page.dart';

// Main navigation page after login, contains 3 tabs
class FridgeGuardMainPage extends StatefulWidget {
  const FridgeGuardMainPage({super.key});

  @override
  State<FridgeGuardMainPage> createState() => _FridgeGuardMainPageState();
}

class _FridgeGuardMainPageState extends State<FridgeGuardMainPage> {
  int _currentIndex = 0; // Currently selected tab index

  // List of pages associated with each tab
  final List<Widget> _pages = [
    const HomePage(),
    const FoodListPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Display the selected page based on _currentIndex
      body: _pages[_currentIndex],
      
      // Bottom navigation bar for switching between pages
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.thermostat),
            label: 'Temperature',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Food List',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
