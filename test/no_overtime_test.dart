import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:no_overtime/no_overtime.dart';

void main() {
  group('NoOvertime.config', () {
    final workStart = const TimeOfDay(hour: 9, minute: 0);
    final workEnd = const TimeOfDay(hour: 17, minute: 0);

    // --- Tests dependent on DateTime.now() ---
    // These tests are sensitive to the actual time they are run.
    // A robust solution requires time mocking.

    test('should throw exception on weekends', () {
      final now = DateTime.now();
      if (now.weekday == DateTime.saturday || now.weekday == DateTime.sunday) {
        expect(
          () => NoOvertime.config(start: workStart, end: workEnd),
          throwsA(isA<StateError>().having(
              (e) => e.toString(), 'message', contains('Today is weekend'))),
        );
      } else {
        print("Skipping weekend test: Today is not a weekend.");
      }
    });

    test('should throw exception if start time is after end time', () {
      final now = DateTime.now();
      // Only run this test on a weekday to avoid interference from the weekend check
      if (now.weekday != DateTime.saturday && now.weekday != DateTime.sunday) {
        expect(
          () => NoOvertime.config(
              start: workEnd, end: workStart), // Reversed times
          throwsA(isA<StateError>().having((e) => e.toString(), 'message',
              contains("You don't need to do any more work"))),
        );
      } else {
        print("Skipping invalid time range test: Today is a weekend.");
      }
    });

    test('should throw exception if current time is before start time', () {
      final now = DateTime.now();
      final start = TimeOfDay(
          hour: now.hour + 1, minute: now.minute); // Start in the future
      final end = TimeOfDay(hour: now.hour + 2, minute: now.minute);

      if (now.weekday != DateTime.saturday && now.weekday != DateTime.sunday) {
        if (start.hour < 24 && end.hour < 24) {
          // Ensure valid TimeOfDay
          expect(
            () => NoOvertime.config(start: start, end: end),
            throwsA(isA<StateError>().having(
                (e) => e.toString(), 'message', contains('No more overtime'))),
          );
        } else {
          print(
              "Skipping 'before start time' test: Cannot set valid future start/end time today.");
        }
      } else {
        print("Skipping 'before start time' test: Today is a weekend.");
      }
    });

    test('should throw exception if current time is at or after end time', () {
      final now = DateTime.now();
      final start = TimeOfDay(hour: now.hour - 2, minute: now.minute);
      final end =
          TimeOfDay(hour: now.hour, minute: now.minute); // End right now

      if (now.weekday != DateTime.saturday && now.weekday != DateTime.sunday) {
        if (start.hour >= 0) {
          // Ensure valid TimeOfDay
          expect(
            () => NoOvertime.config(start: start, end: end),
            throwsA(isA<StateError>().having(
                (e) => e.toString(), 'message', contains('No more overtime'))),
          );
        } else {
          print(
              "Skipping 'after end time' test: Cannot set valid past start time today.");
        }
      } else {
        print("Skipping 'after end time' test: Today is a weekend.");
      }
    });

    test('should run normally if within working hours on a weekday', () {
      final now = DateTime.now();
      final start = TimeOfDay(
          hour: now.hour - 1, minute: now.minute); // Start in the past
      final end = TimeOfDay(
          hour: now.hour + 1, minute: now.minute); // End in the future

      if (now.weekday != DateTime.saturday && now.weekday != DateTime.sunday) {
        if (start.hour >= 0 && end.hour < 24) {
          // Ensure valid TimeOfDay
          expect(
            () => NoOvertime.config(start: start, end: end),
            returnsNormally,
          );
        } else {
          print(
              "Skipping 'within working hours' test: Cannot set valid surrounding start/end time today.");
        }
      } else {
        print("Skipping 'within working hours' test: Today is a weekend.");
      }
    });

    // --- End of time-sensitive tests ---
  });
}
