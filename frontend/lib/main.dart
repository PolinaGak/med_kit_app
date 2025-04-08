import 'package:flutter/material.dart';
import 'package:med_kit/screens/home_screen.dart';
import 'package:med_kit/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Обеспечиваем инициализацию перед запуском
  int? userId = await getUserId(); // Получаем userId из SharedPreferences
  bool isLoggedIn = userId != null; // Проверяем, если userId существует, то пользователь авторизован
  runApp(MyApp(isLoggedIn: isLoggedIn, userId: userId)); // Передаем статус авторизации и userId
}

Future<int?> getUserId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getInt('userId'); // Получаем userId из SharedPreferences
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final int? userId;

  MyApp({required this.isLoggedIn, this.userId});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'МедКит',
      initialRoute: isLoggedIn ? '/home' : '/login', // Если пользователь авторизован, открываем HomeScreen, иначе LoginScreen
      routes: {
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(userId: userId!),
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}
