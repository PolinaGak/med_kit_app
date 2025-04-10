import 'package:flutter/material.dart';
import 'edit_profile_screen.dart';
import 'account_screen.dart';
import 'settings_screen.dart';

class AppDrawer extends StatelessWidget {
  final int userId;

  AppDrawer({required this.userId});

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
          _buildDrawerItem(Icons.person, "Аккаунт", context),
          _buildDrawerItem(Icons.settings, "Настройки", context),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        if (title == "Аккаунт") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AccountScreen(userId: userId),
            ),
          );
        } else if (title == "Настройки") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SettingsScreen(),
            ),
          );
        } else {
          Navigator.pop(context);
        }
      },
    );
  }
}