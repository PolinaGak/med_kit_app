import 'package:flutter/material.dart';
import 'medkit_screen.dart';
import '../api_service.dart';
import '../models/medkit.dart';
import '../enums/medkit_icon.dart';
import 'dart:developer';
import 'create_medkit_screen.dart';

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

  void _refreshMedKits() {
    setState(() {
      futureMedKits = ApiService().getAllMedKits();
    });
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
                      (e) => e.toString().split('.').last.toLowerCase() == medKit.iconName?.toLowerCase(),
                  orElse: () => MedKitIcon.firstAid,
                );

                Color color = Color(int.parse(medKit.color.replaceFirst('#', '0xff')));

                return ListTile(
                  title: Text(medKit.name),
                  leading: Icon(
                    icon.getIconData(),
                    color: color,
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
                    _showEditDeleteMenu(context, medKit.idMedKit);
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

  void _showEditDeleteMenu(BuildContext context, int medKitId) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(leading: Icon(Icons.edit), title: Text("Редактировать"), onTap: () {}),
            ListTile(
              leading: Icon(Icons.delete),
              title: Text("Удалить"),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmationDialog(context, medKitId);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, int medKitId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text("Вы действительно хотите удалить эту аптечку?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Отмена"),
            ),
            TextButton(
              onPressed: () async
                try {
                  await ApiService().deleteMedKit(medKitId);
                  log('Аптечка с ID $medKitId успешно удалена', name: 'MedKitList');
                  _refreshMedKits();
                  Navigator.of(context).pop();
                } catch (e) {
                  log('Ошибка удаления аптечки: $e', name: 'MedKitList');
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text("Ошибка"),
                      content: Text("Не удалось удалить аптечку."),
                      actions: [
                        TextButton(child: Text("OK"), onPressed: () => Navigator.pop(context)),
                      ],
                    ),
                  );
                }
              },
              child: Text("Удалить"),
            ),
          ],
        );
      },
    );
  }

  void _showCreateMedKitDialog(BuildContext context) async {
    final newMedKit = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateMedKitScreen()),
    );

    if (newMedKit != null) {
      _refreshMedKits();
    }
  }
}
