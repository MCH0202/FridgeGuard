import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/temperature_provider.dart';
import 'temperature_trend_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final temp = context.watch<TemperatureProvider>().currentTemp;

    return Scaffold(
      appBar: AppBar(title: const Text('FridgeGuard')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Current Temperature:', style: Theme.of(context).textTheme.titleLarge),
            Text('${temp.toInt()} °C', style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 20),
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
