import 'package:flutter/material.dart';
import '../api_service.dart';
import '../models/medkit.dart';
import '../enums/medkit_icon.dart';

class MedKitScreen extends StatefulWidget {
  final int id_med_kit;
  MedKitScreen({required this.id_med_kit});

  @override
  _MedKitScreenState createState() => _MedKitScreenState();
}

class _MedKitScreenState extends State<MedKitScreen> {
  late Future<MedKit> futureMedKit;

  @override
  void initState() {
    super.initState();
    futureMedKit = ApiService().getMedKitById(widget.id_med_kit);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<MedKit>(
          future: futureMedKit,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text('Загрузка...');
            } else if (snapshot.hasError) {
              return Text('Ошибка');
            } else if (snapshot.hasData) {
              return Row(
                children: [
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      snapshot.data!.name,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    MedKitIcon.values.firstWhere(
                          (e) => e.toString().split('.').last.toLowerCase() == snapshot.data!.iconName?.toLowerCase(),
                      orElse: () => MedKitIcon.firstAid,
                    ).getIconData(),
                    size: 24,
                  ),
                ],
              );
            } else {
              return Text('Нет данных');
            }
          },
        ),
      ),
      body: FutureBuilder<MedKit>(
        future: futureMedKit,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Ошибка загрузки данных'));
          } else if (snapshot.hasData) {
            MedKit medKit = snapshot.data!;

            Color color = Color(int.parse(medKit.color.replaceFirst('#', '0xff')));

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (medKit.comment != null && medKit.comment!.isNotEmpty)
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.yellow[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        medKit.comment!,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),

                  SizedBox(height: 16),

                  Text(
                    'Список лекарств',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),

                  Expanded(
                    child: ListView.builder(
                      itemCount: 15,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text('Лекарство ${index + 1}'),
                          trailing: Icon(Icons.medical_services),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Center(child: Text('Нет данных'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          _showCreatePillDialog(context);
        },
      ),
    );
  }

  void _showCreatePillDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Создать новое лекарство'),
          content: TextField(
            decoration: InputDecoration(hintText: 'Введите название лекарства'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Отмена'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Создать'),
              onPressed: () {
                // Логика создания лекарства
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
