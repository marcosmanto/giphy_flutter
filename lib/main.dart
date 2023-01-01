import 'package:flutter/material.dart';
import 'package:giphy_flutter/pages/home_page.dart';

void main() {
  runApp(const GiphyApp());
}

class GiphyApp extends StatelessWidget {
  const GiphyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ThemeData();
    return MaterialApp(
      title: 'Flutter Demo',
      theme: theme.copyWith(
        colorScheme: theme.colorScheme.copyWith(
          primary: Colors.black,
          secondary: Color(0xFF0ef598),
          tertiary: Colors.grey[800],
        ),
        inputDecorationTheme: InputDecorationTheme(
          floatingLabelStyle: TextStyle(color: Color(0xFF00cafb)),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF0ef598)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF00cafb), width: 2),
          ),
          hintStyle: TextStyle(color: Colors.amber),
          labelStyle: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      home: HomePage(),
    );
  }
}
