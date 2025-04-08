import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AccountScreen extends StatefulWidget {
  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String _email = '';
  String _name = '';
  bool _isLoading = true;

  Future<void> _getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null) {
      try {
        final response = await http.get(
          Uri.parse('http://127.0.0.1:9000/user'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          setState(() {
            _email = data['email'];
            _name = data['name'];
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        // Обработка ошибки
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Аккаунт'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Имя: $_name', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Email: $_email', style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Навигация на экран редактирования профиля
              },
              child: Text('Редактировать профиль'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Выход из аккаунта
                final prefs = await SharedPreferences.getInstance();
                prefs.remove('token');
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: Text('Выйти'),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
