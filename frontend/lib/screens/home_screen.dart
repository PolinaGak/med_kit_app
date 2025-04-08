import 'package:flutter/material.dart';
import 'medkit_list_screen.dart';
import 'schedule_screen.dart';
import 'search_screen.dart';
import 'app_drawer.dart';

class HomeScreen extends StatefulWidget {
  final int userId;

  HomeScreen({required this.userId});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages.add(MedKitListScreen(userId: widget.userId));
    _pages.add(ScheduleScreen());
    _pages.add(SearchScreen());
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Med_kit")),
      drawer: AppDrawer(), // Боковое меню
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.medical_services), label: 'Аптечка'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'График'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Поиск'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
