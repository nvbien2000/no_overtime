# No Overtime

No more overtime. Go home early & enjoy your life!

## Features

*   Throws a `StateError` if in the weekend (Saturday or Sunday).
*   Throws a `StateError` if outside your working hours.
*   Throws a `StateError` if start time >= end time (haha, troll).
*   **Only active in DEBUG mode (`kDebugMode == true`). Does nothing in release builds.**

## Getting started

```yaml
dev_dependencies:
  no_overtime:
  flutter_test:
    sdk: flutter
```

## Usage

```dart
import 'package:flutter/material.dart';
import 'package:no_overtime/no_overtime.dart';

void main() {
  NoOvertime.config(
    start: TimeOfDay(hour: 9, minute: 0),  // Optional. Default: 9:00
    end: TimeOfDay(hour: 17, minute: 30), // Optional. Default: 18:00
  );

  runApp(MyApp());
}
```

# Rest, my bros! Enjoy our life!
