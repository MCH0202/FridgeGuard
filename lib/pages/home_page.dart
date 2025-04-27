import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/temperature_provider.dart';
import 'temperature_trend_page.dart';

// Home page displaying the current fridge temperature
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Retrieve the current temperature from the provider
    final temp = context.watch<TemperatureProvider>().currentTemp;

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
