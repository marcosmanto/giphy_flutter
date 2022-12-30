import 'package:flutter/material.dart';
import 'package:giphy_flutter/pages/home_page.dart';

void main() {
  runApp(const GiphtApp());
}

class GiphtApp extends StatelessWidget {
  const GiphtApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}
