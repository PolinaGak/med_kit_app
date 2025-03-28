import 'package:flutter/material.dart';
import 'package:med_kit/screens/home_screen.dart';

void main() {
  runApp(MyApp()); // Запуск приложения
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'МедКит',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(), // Главный экран приложения
    );
  }
}