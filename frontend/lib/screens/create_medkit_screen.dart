import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../enums/medkit_icon.dart';
import '../models/medkit.dart';
import '../api_service.dart';

class CreateMedKitScreen extends StatefulWidget {
  @override
  _CreateMedKitScreenState createState() => _CreateMedKitScreenState();
}

class _CreateMedKitScreenState extends State<CreateMedKitScreen> {
  final _nameController = TextEditingController();
  MedKitIcon selectedIcon = MedKitIcon.firstAid;
  Color selectedColor = Color(0xFFFFB6C1);
  String? comment;

  List<Color> colorOptions = [
    Color(0xFFFFB6C1),
    Color(0xFFFFD700),
    Color(0xFF87CEFA),
    Color(0xFFB0E0E6),
    Color(0xFFFFA07A),
    Color(0xFFF4A460),
    Color(0xFFDDA0DD),
    Color(0xFFBA55D3),
    Color(0xFF98FB98),
    Color(0xFFFF7F50),
    Color(0xFF66CDAA),
    Color(0xFFFFDEAD),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Создание аптечки"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: selectedColor,
                  child: Icon(
                    selectedIcon.getIconData(),
                    color: Colors.white,
                  ),
                  radius: 24,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Введите название',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Divider(
              thickness: 1,
              color: Colors.grey[400],
            ),
            SizedBox(height: 32),
            GridView.count(
              crossAxisCount: 6,
              shrinkWrap: true,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              children: List.generate(
                MedKitIcon.values.length,
                    (index) {
                  bool isSelected = selectedIcon == MedKitIcon.values[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIcon = MedKitIcon.values[index];
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: isSelected
                            ? Border.all(color: Colors.blue, width: 2)
                            : null,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.grey[200],
                        child: Icon(
                          MedKitIcon.values[index].getIconData(),
                          size: 24,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Divider(
              thickness: 1,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: colorOptions.length,
              itemBuilder: (context, index) {
                bool isSelected = selectedColor == colorOptions[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedColor = colorOptions[index];
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: isSelected
                          ? Border.all(color: Colors.blue, width: 2)
                          : null,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: CircleAvatar(
                      backgroundColor: colorOptions[index],
                      radius: 24,
                    ),
                  ),
                );
              },
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _openColorPicker(),
                child: Text("Другой цвет"),
              ),
            ),
            SizedBox(height: 32),
            Divider(
              thickness: 1,
              color: Colors.grey[400],
              indent: 0,
              endIndent: 0,
            ),
            TextField(
              onChanged: (value) {
                setState(() {
                  comment = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Комментарий (не обязателен)',
                border: OutlineInputBorder(),
              ),
              maxLength: 50,
            ),
            SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: _saveMedKit,
                child: Text("Сохранить"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openColorPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Выберите цвет"),
          content: SingleChildScrollView(
            child: HueRingPicker(
              pickerColor: selectedColor,
              onColorChanged: (color) {
                setState(() {
                  selectedColor = color;
                });
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Сохранить"),
            ),
          ],
        );
      },
    );
  }

  void _saveMedKit() async {
    final response = await ApiService().createMedKit(
      _nameController.text,
      '#${selectedColor.value.toRadixString(16).padLeft(6, '0').toUpperCase()}',
      selectedIcon.toString().split('.').last,
      comment,
    );

    if (response != null) {
      Navigator.pop(context, response);
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Ошибка"),
          content: Text("Не удалось создать аптечку."),
          actions: [
            TextButton(child: Text("OK"), onPressed: () => Navigator.pop(context)),
          ],
        ),
      );
    }
  }
}