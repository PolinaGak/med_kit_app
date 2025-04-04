import 'package:flutter/material.dart';
import '../api_service.dart';
import '../models/pill_user.dart';
import '../models/medkit.dart';
import '../enums/medkit_icon.dart';
import 'create_pill_screen.dart';

class MedKitScreen extends StatefulWidget {
  final int id_med_kit;
  MedKitScreen({required this.id_med_kit});

  @override
  _MedKitScreenState createState() => _MedKitScreenState();
}

class _MedKitScreenState extends State<MedKitScreen> {
  late Future<List<PillUser>> futurePills;
  late Future<MedKit> futureMedKit;

  @override
  void initState() {
    super.initState();
    futurePills = ApiService().getPillsByMedKitId(widget.id_med_kit);
    futureMedKit = ApiService().getMedKitById(widget.id_med_kit);
  }

  void _refreshPills() {
    setState(() {
      futurePills = ApiService().getPillsByMedKitId(widget.id_med_kit);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: FutureBuilder<MedKit>(
          future: futureMedKit,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text('Загрузка...');
            } else if (snapshot.hasError) {
              return Text('Ошибка');
            } else if (snapshot.hasData) {
              MedKit medKit = snapshot.data!;

              Color iconColor = Color(int.parse(medKit.color.replaceFirst('#', '0xff')));

              return Row(
                children: [
                  SizedBox(width: 8),
                  Icon(
                    MedKitIcon.values.firstWhere(
                          (e) => e.toString().split('.').last.toLowerCase() == medKit.iconName?.toLowerCase(),
                      orElse: () => MedKitIcon.firstAid,
                    ).getIconData(),
                    size: 24,
                    color: iconColor,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      medKit.name,
                      overflow: TextOverflow.ellipsis,
                    ),
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
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (medKit.comment != null && medKit.comment!.isNotEmpty)
                    Container(
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.yellow[100], // Жёлтый фон
                        borderRadius: BorderRadius.circular(8.0),
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
                  FutureBuilder<List<PillUser>>(
                    future: futurePills,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Ошибка загрузки данных'));
                      } else if (snapshot.hasData) {
                        List<PillUser> pills = snapshot.data!;
                        if (pills.isEmpty) {
                          return Center(child: Text('Нет лекарств в аптечке'));
                        }
                        return Expanded(
                          child: ListView.builder(
                            itemCount: pills.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(pills[index].name),
                                subtitle: Text('Категория: ${pills[index].category ?? 'Не указана'}'),
                                trailing: Icon(Icons.medical_services),
                              );
                            },
                          ),
                        );
                      } else {
                        return Center(child: Text('Нет данных'));
                      }
                    },
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
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreatePillScreen(idMedKit: widget.id_med_kit),
            ),
          );
          _refreshPills();
        },
      ),
    );
  }
}
