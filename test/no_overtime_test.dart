import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:no_overtime/no_overtime.dart';

void main() {
  // Initialize binding for asset loading
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NoOvertime.config', () {
    final workStart = const TimeOfDay(hour: 9, minute: 0);
    final workEnd = const TimeOfDay(hour: 17, minute: 0);

    // --- Tests dependent on DateTime.now() ---
    // These tests are sensitive to the actual time they are run.
    // Consider using a time mocking library (like 'clock') for robust testing.

    test('should throw exception on weekends', () async {
      final now = DateTime.now();
      if (now.weekday == DateTime.saturday || now.weekday == DateTime.sunday) {
        expectLater(
          () async => await NoOvertime.config(start: workStart, end: workEnd),
          throwsA(isA<StateError>().having(
              (e) => e.message, 'message', contains('Today is weekend'))),
        );
      } else {
        print("Skipping weekend test: Today is not a weekend.");
      }
    });

    test('should throw exception if start time is after end time', () async {
      final now = DateTime.now();
      if (now.weekday != DateTime.saturday && now.weekday != DateTime.sunday) {
        expectLater(
          () async => await NoOvertime.config(start: workEnd, end: workStart),
          throwsA(isA<StateError>().having((e) => e.message, 'message',
              contains("You don't need to do any more work"))),
        );
      } else {
        print("Skipping invalid time range test: Today is a weekend.");
      }
    });

    test('should throw exception if current time is before start time',
        () async {
      final now = DateTime.now();
      final start = TimeOfDay(hour: now.hour + 1, minute: now.minute);
      final end = TimeOfDay(hour: now.hour + 2, minute: now.minute);

      if (now.weekday != DateTime.saturday && now.weekday != DateTime.sunday) {
        if (start.hour < 24 && end.hour < 24) {
          expectLater(
            () async => await NoOvertime.config(start: start, end: end),
            throwsA(isA<StateError>().having(
                (e) => e.message, 'message', contains('No more overtime'))),
          );
        } else {
          print(
              "Skipping 'before start time' test: Cannot set valid future start/end time today.");
        }
      } else {
        print("Skipping 'before start time' test: Today is a weekend.");
      }
    });

    test('should throw exception if current time is at or after end time',
        () async {
      final now = DateTime.now();
      final start = TimeOfDay(hour: now.hour - 2, minute: now.minute);
      final end = TimeOfDay(hour: now.hour, minute: now.minute);

      if (now.weekday != DateTime.saturday && now.weekday != DateTime.sunday) {
        if (start.hour >= 0) {
          expectLater(
            () async => await NoOvertime.config(start: start, end: end),
            throwsA(isA<StateError>().having(
                (e) => e.message, 'message', contains('No more overtime'))),
          );
        } else {
          print(
              "Skipping 'after end time' test: Cannot set valid past start time today.");
        }
      } else {
        print("Skipping 'after end time' test: Today is a weekend.");
      }
    });

    test(
        'should run normally if within working hours on a weekday without holidays',
        () async {
      final now = DateTime.now();
      final start = TimeOfDay(hour: now.hour - 1, minute: now.minute);
      final end = TimeOfDay(hour: now.hour + 1, minute: now.minute);

      if (now.weekday != DateTime.saturday && now.weekday != DateTime.sunday) {
        if (start.hour >= 0 && end.hour < 24) {
          expectLater(
            () async => await NoOvertime.config(start: start, end: end),
            completes,
          );
        } else {
          print(
              "Skipping 'within working hours' test: Cannot set valid surrounding start/end time today.");
        }
      } else {
        print("Skipping 'within working hours' test: Today is a weekend.");
      }
    });

    // --- Holiday Tests (Date Dependent) ---
    // These tests depend on the current date matching the holiday dates in vietnam.json

    test('should throw exception on a configured holiday (e.g., Jan 1st)',
        () async {
      final now = DateTime.now();
      if (now.month == 1 && now.day == 1) {
        if (now.weekday != DateTime.saturday &&
            now.weekday != DateTime.sunday) {
          expectLater(
            () async => await NoOvertime.config(
              start: workStart,
              end: workEnd,
              country: ECountry.vietnam,
            ),
            throwsA(isA<StateError>().having(
                (e) => e.message, 'message', contains('Today is a holiday'))),
          );
        } else {
          print("Skipping holiday test: Today is Jan 1st but also a weekend.");
        }
      } else {
        print("Skipping holiday test: Today is not January 1st.");
        if (now.weekday != DateTime.saturday &&
            now.weekday != DateTime.sunday) {}
      }
    });

    test(
        'should throw exception during a configured holiday range (e.g., April 30th)',
        () async {
      final now = DateTime.now();
      final holidayRangeStart = DateTime(now.year, 4, 30);
      final holidayRangeEnd = DateTime(now.year, 5, 2);
      final currentDate = DateTime(now.year, now.month, now.day);

      if (!currentDate.isBefore(holidayRangeStart) &&
          !currentDate.isAfter(holidayRangeEnd)) {
        if (now.weekday != DateTime.saturday &&
            now.weekday != DateTime.sunday) {
          expectLater(
            () async => await NoOvertime.config(
              start: workStart,
              end: workEnd,
              country: ECountry.vietnam,
            ),
            throwsA(isA<StateError>().having(
                (e) => e.message, 'message', contains('Today is a holiday'))),
          );
        } else {
          print(
              "Skipping holiday range test: Today is within Apr 30 - May 2 but also a weekend.");
        }
      } else {
        print(
            "Skipping holiday range test: Today is not within April 30th - May 2nd.");
      }
    });

    test('should run normally on a weekday that is not a holiday', () async {
      final now = DateTime.now();
      if (now.weekday != DateTime.saturday && now.weekday != DateTime.sunday) {
        if (now.month == 1 && now.day == 10) {
          expectLater(
              () async => await NoOvertime.config(
                  start: workStart, end: workEnd, country: ECountry.vietnam),
              completes);
        } else {
          print(
              "Skipping non-holiday test: Not running on assumed non-holiday (Jan 10th) or need explicit holiday check.");
        }
      } else {
        print("Skipping non-holiday test: Today is a weekend.");
      }
    });

    // --- End of tests ---
  });
}
