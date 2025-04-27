import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/temperature_provider.dart';

class TemperatureTrendPage extends StatelessWidget {
  const TemperatureTrendPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tempProvider = context.watch<TemperatureProvider>();
    final List<TempRecord> temps = tempProvider.lastFiveTemps;

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final chartWidth = screenWidth * 0.9;
    final chartHeight = screenHeight * 0.3;

    final List<FlSpot> spots = [
      for (int i = 0; i < temps.length; i++) FlSpot(i.toDouble(), temps[i].value),
    ];

    final List<String> times = [
      for (int i = 0; i < temps.length; i++)
        '${temps[i].time.hour}:${temps[i].time.minute.toString().padLeft(2, '0')}',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Temperature Log')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            const Text(
              'Recent Temperature Trend',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (spots.isEmpty)
              const Text('No temperature data yet...')
            else
              Center(
                child: SizedBox(
                  width: chartWidth,
                  height: chartHeight,
                  child: LineChart(
                    LineChartData(
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            interval: 5,
                            getTitlesWidget: (value, meta) {
                              return Text('${value.toInt()}°');
                            },
                          ),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 36,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              if (value % 1 != 0) return const Text('');
                              int index = value.toInt();
                              if (index >= 0 && index < times.length) {
                                return Text(times[index]);
                              } else {
                                return const Text('');
                              }
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      minX: -0.5,
                      maxX: 4.5,
                      minY: -5,
                      maxY: 20,
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: const Color.fromARGB(255, 52, 122, 243),
                          barWidth: 3,
                          belowBarData: BarAreaData(
                            show: true,
                            color: const Color.fromARGB(255, 52, 122, 243)
                                .withAlpha((0.4 * 255).toInt()),
                          ),
                          dotData: FlDotData(show: true),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
