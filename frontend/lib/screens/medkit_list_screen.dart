import 'package:flutter/material.dart';
import 'medkit_screen.dart';
import '../api_service.dart';
import '../models/medkit.dart';
import '../enums/medkit_icon.dart';
import 'dart:developer';

class MedKitListScreen extends StatefulWidget {
  @override
  _MedKitListScreenState createState() => _MedKitListScreenState();
}

class _MedKitListScreenState extends State<MedKitListScreen> {
  late Future<List<MedKit>> futureMedKits;

  @override
  void initState() {
    super.initState();
    futureMedKits = ApiService().getAllMedKits();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ваши аптечки"),
      ),
      body: FutureBuilder<List<MedKit>>(
        future: futureMedKits,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print(snapshot.data!);
            log('Ошибка загрузки данных: ${snapshot.error}', name: 'FutureBuilder');
            return Center(child: Text('Ошибка загрузки данных: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            List<MedKit> medKits = snapshot.data!;

            if (medKits.isEmpty) {
              log('Нет данных для отображения', name: 'FutureBuilder');
              return Center(child: Text('Нет данных'));
            }

            log('Получены данные: ${medKits.length} аптечек', name: 'FutureBuilder');

            return ListView.builder(
              itemCount: medKits.length,
              itemBuilder: (context, index) {
                MedKit medKit = medKits[index];

                log('Аптечка #${medKit.idMedKit}: ${medKit.name}', name: 'MedKitList');

                MedKitIcon icon = MedKitIcon.values.firstWhere(
                      (e) => e.toString() == 'MedKitIcon.${medKit.iconName?.toLowerCase()}',
                  orElse: () => MedKitIcon.firstAid,
                );

                Color color = Color(int.parse(medKit.color.replaceFirst('#', '0xff')));

                return ListTile(
                  title: Text(medKit.name),
                  leading: Icon(
                      icon.getIconData(),
                      color: color
                  ),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    log('Переход к деталям аптечки: ${medKit.name}', name: 'MedKitTap');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MedKitScreen(id_med_kit: medKit.idMedKit),
                      ),
                    );
                  },
                  onLongPress: () {
                    _showEditDeleteMenu(context);
                  },
                );
              },
            );
          } else {
            log('Нет данных для отображения', name: 'FutureBuilder');
            return Center(child: Text('Нет данных'));
          }
        },
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () {
              _showCreateMedKitDialog(context);
            },
          ),
        ),
      ),
    );
  }

  void _showEditDeleteMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(leading: Icon(Icons.edit), title: Text("Редактировать"), onTap: () {}),
            ListTile(leading: Icon(Icons.delete), title: Text("Удалить"), onTap: () {}),
          ],
        ),
      ),
    );
  }

  void _showCreateMedKitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Создать новую аптечку"),
        content: TextField(decoration: InputDecoration(hintText: "Название аптечки")),
        actions: [
          TextButton(child: Text("Отмена"), onPressed: () => Navigator.of(context).pop()),
          TextButton(child: Text("Создать"), onPressed: () {}),
        ],
      ),
    );
  }
}
