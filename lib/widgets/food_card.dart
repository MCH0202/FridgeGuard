import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class FoodCard extends StatelessWidget {
  final String name;
  final Timestamp? expiryDate;
  final VoidCallback onDelete;
  final Brightness brightness;

  const FoodCard({
    super.key,
    required this.name,
    required this.expiryDate,
    required this.onDelete,
    required this.brightness,
  });

  String formatExpiry(Timestamp? expiryTimestamp) {
    if (expiryTimestamp == null) return 'No expiry date';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = expiryTimestamp.toDate();
    final expiryDay = DateTime(expiry.year, expiry.month, expiry.day);
    final diff = expiryDay.difference(today).inDays;

    if (diff < 0) {
      return 'Expired ${-diff} days ago';
    } else if (diff == 0) {
      return 'Expires today';
    } else if (diff <= 3) {
      return 'Expires in $diff days';
    } else {
      return 'Expires on ${DateFormat('yyyy.MM.dd').format(expiryDay)}';
    }
  }

List<Color> getGradientColors(int diff) {
  final isDark = brightness == Brightness.dark;
  final base = isDark ? Colors.black : Colors.white;

  if (diff < 0) {
    return [base, Colors.red.withAlpha((0.4 * 255).toInt())];
  } else if (diff <= 2) {
    return [base, Colors.orange.withAlpha((0.4 * 255).toInt())];
  } else {
    return [base, Colors.green.withAlpha((0.4 * 255).toInt())];
  }
}

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = expiryDate?.toDate();
    final diff = expiry != null
        ? DateTime(expiry.year, expiry.month, expiry.day)
            .difference(today)
            .inDays
        : 999;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: getGradientColors(diff),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(name),
        subtitle: Text(formatExpiry(expiryDate)),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
