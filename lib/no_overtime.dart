import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// No more overtime, go home early & enjoy your life. This function is only available in debug mode.
///
/// Example:
/// ```dart
/// void main() {
///   NoOvertime.config(
///     start: TimeOfDay(hour: 8, minute: 0), // Default is 8:00
///     end: TimeOfDay(hour: 18, minute: 0), // Default is 18:00
///   );
///
///   ... some code ...
/// }
/// ```
class NoOvertime {
  static void config({
    TimeOfDay start = const TimeOfDay(hour: 8, minute: 0),
    TimeOfDay end = const TimeOfDay(hour: 18, minute: 0),
  }) {
    if (!kDebugMode) {
      return; // Only available in debug mode
    }

    final now = DateTime.now();

    // check if today is weekend
    if (now.weekday == 6 || now.weekday == 7) {
      throw StateError("Today is weekend, not a working day.");
    }

    // if start time >= end time. Haha, you troll me!
    if (start.hour > end.hour ||
        (start.hour == end.hour && start.minute >= end.minute)) {
      throw StateError("Haha. You don't need to do any more work.");
    }

    // if current time is between start and end
    final nowInMinutes = now.hour * 60 + now.minute;
    final startInMinutes = start.hour * 60 + start.minute;
    final endInMinutes = end.hour * 60 + end.minute;

    if (nowInMinutes < startInMinutes || nowInMinutes >= endInMinutes) {
      throw StateError("No more overtime, go home early & enjoy your life!");
    }
  }
}
