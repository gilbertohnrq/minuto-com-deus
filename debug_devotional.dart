import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

void main() async {
  // Simulate today's date
  final today = DateTime.now();
  final todayISO = DateFormat('yyyy-MM-dd').format(today);

  print('Today\'s date: $today');
  print('Today ISO format: $todayISO');

  // Load the devotional data
  try {
    final String jsonString =
        await rootBundle.loadString('assets/data/devocionais.json');
    final List<dynamic> jsonList = json.decode(jsonString);

    print('Total devotionals loaded: ${jsonList.length}');

    // Check if today's devotional exists
    final todayDevotional = jsonList.firstWhere(
      (devotional) => devotional['data'] == todayISO,
      orElse: () => null,
    );

    if (todayDevotional != null) {
      print('Found today\'s devotional: ${todayDevotional['versiculo']}');
    } else {
      print('No devotional found for today: $todayISO');
      print('Available dates:');
      for (final devotional in jsonList) {
        print('  - ${devotional['data']}');
      }
    }
  } catch (e) {
    print('Error loading devotionals: $e');
  }
}
