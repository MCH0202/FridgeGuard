import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/temperature_provider.dart';
import 'temperature_trend_page.dart';

// Home page displaying the current fridge temperature
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _hasShownOverheatAlert = false; // Flag to prevent repeated alerts

  @override
  Widget build(BuildContext context) {
    // Retrieve the current temperature from the provider
    final temp = context.watch<TemperatureProvider>().currentTemp;

    // Check if temperature exceeds threshold and alert has not been shown
    if (temp > 8 && !_hasShownOverheatAlert) {
      Future.delayed(Duration.zero, () {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Temperature Warning'),
              content: Text('Fridge temperature is too high! Current: ${temp.toStringAsFixed(1)}°C'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
          _hasShownOverheatAlert = true; // Mark as shown
        }
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text('FridgeGuard')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display the title
            Text('Current Temperature:', style: Theme.of(context).textTheme.titleLarge),
            // Display the current temperature value
            Text('${temp.toInt()} °C', style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 20),
            // Button to navigate to the temperature log page
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TemperatureTrendPage()),
                );
              },
              child: const Text('View Temperature Log'),
            ),
          ],
        ),
      ),
    );
  }
}
