import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:email_validator/email_validator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import '../api_service.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordAgainController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  bool _isLoading = false;
  String _errorMessage = '';

  bool isValidPassword(String password) {
    final passwordRegExp = RegExp(
      r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>])[A-Za-z\d!@#$%^&*(),.?":{}|<>]{8,}$',
    );
    return passwordRegExp.hasMatch(password);
  }

  Future<void> _saveUserId(int userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', userId);
  }

  Future<void> _register() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _passwordAgainController.text.trim();
    final name = _nameController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Пожалуйста, заполните все поля.';
      });
      return;
    }

    if (!EmailValidator.validate(email)) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Пожалуйста, введите корректный email.';
      });
      return;
    }

    if (!isValidPassword(password)) {
      setState(() {
        _isLoading = false;
        _errorMessage =
        'Пароль должен содержать хотя бы 8 символов, включать заглавные и строчные буквы, цифры и специальные символы.';
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Пароли не совпадают.';
      });
      return;
    }

    try {
      final result = await ApiService().registerUser(email, password, name);

      if (result.containsKey('message')) {
        final userId = result['user_id'];

        await _saveUserId(userId);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(userId: userId),
          ),
        );
      } else if (result.containsKey('error')) {
        setState(() {
          _isLoading = false;
          _errorMessage = result['error'];
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Произошла ошибка. Попробуйте снова.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Регистрация'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Пароль'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _passwordAgainController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Повторите пароль'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Имя'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _register,
              child: _isLoading
                  ? CircularProgressIndicator()
                  : Text('Зарегистрироваться'),
            ),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
