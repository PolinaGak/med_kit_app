import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_service.dart';
import 'edit_profile_screen.dart';

class AccountScreen extends StatefulWidget {
  final int userId;

  AccountScreen({required this.userId});

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String _email = '';
  String _name = '';
  bool _isLoading = true;

  // Метод для получения данных пользователя
  Future<void> _getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token != null) {
      try {
        final response = await ApiService().getUserProfile(token);

        if (response != null) {
          setState(() {
            _email = response['email'];
            _name = response['name'];
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

  // Метод для обновления данных, вызываемый после редактирования
  void _updateUserData(String name, String email) {
    setState(() {
      _name = name;
      _email = email;
    });
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
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfileScreen(userId: widget.userId),
                  ),
                );
                if (result != null) {
                  // Обновляем данные на экране AccountScreen, если они изменились
                  _updateUserData(result['name'], result['email']);
                }
              },
              child: Text('Редактировать профиль'),
            ),
            ElevatedButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                prefs.remove('token');
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: Text(
                'Выйти',
                style: TextStyle(color: Colors.red),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                elevation: 0,
                side: BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
