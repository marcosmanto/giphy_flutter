import 'package:flutter/material.dart';
import 'package:giphy_flutter/pages/home_page.dart';

void main() {
  runApp(const GiphtApp());
}

class GiphtApp extends StatelessWidget {
  const GiphtApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ThemeData();
    return MaterialApp(
      title: 'Flutter Demo',
      theme: theme.copyWith(
          colorScheme: theme.colorScheme.copyWith(
              primary: Colors.black, secondary: Colors.purple.shade300)),
      home: HomePage(),
    );
  }
}
