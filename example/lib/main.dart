import 'package:flutter/material.dart';
import 'package:no_overtime/no_overtime.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NoOvertime.config(
    country: ECountry.vietnam,
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Hello World!'),
        ),
      ),
    );
  }
}
