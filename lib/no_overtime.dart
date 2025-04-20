import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'enum_countries.dart';
export 'enum_countries.dart';

class NoOvertime {
  static Future<void> config({
    TimeOfDay start = const TimeOfDay(hour: 8, minute: 0),
    TimeOfDay end = const TimeOfDay(hour: 18, minute: 0),
    ECountry? country,
  }) async {
    if (!kDebugMode) {
      return;
    }

    if (_isWeekend()) {
      throw StateError("Today is weekend, not a working day.");
    }

    // if start time >= end time. Haha, you troll me!
    if (start.hour > end.hour ||
        (start.hour == end.hour && start.minute >= end.minute)) {
      throw StateError("Haha. You don't need to do any more work.");
    }

    if (_isOutsideWorkingHours(start, end)) {
      throw StateError("No more overtime, go home early & enjoy your life!");
    }

    if (country != null) {
      if (await _isHoliday(country)) {
        throw StateError("Today is a holiday, not a working day.");
      }
    }
  }
}

bool _isWeekend() {
  final now = DateTime.now();
  return now.weekday == DateTime.saturday || now.weekday == DateTime.sunday;
}

bool _isOutsideWorkingHours(TimeOfDay start, TimeOfDay end) {
  final now = DateTime.now();

  final nowInMinutes = now.hour * 60 + now.minute;
  final startInMinutes = start.hour * 60 + start.minute;
  final endInMinutes = end.hour * 60 + end.minute;

  return nowInMinutes < startInMinutes || nowInMinutes >= endInMinutes;
}

Future<bool> _isHoliday(ECountry c) async {
  final now = DateTime.now();
  final fileName = c.jsonFile;
  final filePath = 'packages/no_overtime/assets/holidays/$fileName';

  try {
    final data = await rootBundle.loadString(filePath);
    final holidaysRaw = jsonDecode(data) as List;
    final holidays = holidaysRaw.map((e) {
      // Remove all spaces
      return e.toString().trim().replaceAll(" ", "");
    }).toList();

    for (final holiday in holidays) {
      if (holiday.contains('-')) {
        // Date range format: DD/MM-DD/MM
        final parts = holiday.split('-');
        final startParts = parts[0].split('/');
        final endParts = parts[1].split('/');

        final startDay = int.parse(startParts[0]);
        final startMonth = int.parse(startParts[1]);
        final endDay = int.parse(endParts[0]);
        final endMonth = int.parse(endParts[1]);

        final startDate = DateTime(now.year, startMonth, startDay);
        final endDate = DateTime(now.year, endMonth, endDay);
        final currentDate = DateTime(now.year, now.month, now.day);

        // Check if current date is within the range (inclusive)
        if (!currentDate.isBefore(startDate) && !currentDate.isAfter(endDate)) {
          return true;
        }
      } else {
        // Single date format: DD/MM
        final parts = holiday.split('/');

        final holidayDay = int.parse(parts[0]);
        final holidayMonth = int.parse(parts[1]);

        if (now.day == holidayDay && now.month == holidayMonth) {
          return true;
        }
      }
    }
  } catch (e) {
    debugPrint("Error processing holidays from $fileName: $e");
    return false;
  }

  return false;
}
