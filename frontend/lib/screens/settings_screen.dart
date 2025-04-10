import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Настройки'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Если у вас возникнут вопросы или предложения по доработке приложения, вы можете связаться с разработчиком через следующие каналы:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 20),
            _buildContactItem(
              Icons.phone,
              'Номер телефона: +7 (902) 614-16-75',
            ),
            _buildContactItem(
              Icons.message,
              'Telegram: @alisasavvina',
            ),
            _buildContactItem(
              Icons.email,
              'Email: polinagakgak@yandex.ru',
            ),
            SizedBox(height: 20),
            Text(
              'Мы всегда рады обратной связи и постараемся ответить на все ваши вопросы.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String contactInfo) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 30, color: Colors.blue),
          SizedBox(width: 10),
          Flexible(
            child: Text(
              contactInfo,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
