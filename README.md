# No Overtime

No more overtime. Go home early & enjoy your life!

## Features

* Saturday or Sunday? Throws a `StateError`.
* Outside your working hours? Throws a `StateError`.
* In your holidays? Throws a `StateError`.
* **Only active in DEBUG mode. Does nothing in release builds.**

## Getting started

```yaml
dependencies:
  flutter:
    sdk: flutter
  no_overtime:
```

## Usage

```dart
import 'package:flutter/material.dart';
import 'package:no_overtime/no_overtime.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NoOvertime.config(
    start: TimeOfDay(hour: 9, minute: 0),  // Optional. Default: 9:00
    end: TimeOfDay(hour: 17, minute: 30), // Optional. Default: 18:00
    country: ECountry.vietnam, // Optional. Default: null
  );

  runApp(MyApp());
}
```

> Holidays now is only available for Vietnam. Please feels free to create a Pull Request with your country! 
- Step 1: Create a JSON file with `D/M` for a specific day, or `D/M-D/M` for a range of days. See [vietnam.json](assets/holidays/vietnam.json) for more details.
- Step 2: Add your country to this enum file: [enum_countries.dart](lib/enum_countries.dart).

# Rest, my bros! Enjoy our life!
