import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text("Меню", style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          _buildDrawerItem(Icons.person, "Аккаунт"),
          _buildDrawerItem(Icons.bar_chart, "Статистика"),
          _buildDrawerItem(Icons.book, "Справочник"),
          _buildDrawerItem(Icons.shopping_cart, "Список покупок"),
          _buildDrawerItem(Icons.settings, "Настройки"),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {},
    );
  }
}
