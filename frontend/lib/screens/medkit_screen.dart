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

  void _deletePill(int pillId) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text('Вы действительно хотите удалить это лекарство?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Отмена'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Удалить'),
            ),
          ],
        );
      },
    );

    if (confirmDelete) {
      bool success = await ApiService().deletePill(widget.id_med_kit, pillId);

      if (success) {
        _refreshPills();

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Лекарство удалено')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка при удалении')));
      }
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  Color _getDateColor(DateTime? expirationDate) {
    if (expirationDate == null) return Colors.black;
    return expirationDate.isBefore(DateTime.now()) ? Colors.red : Colors.black;
  }

  void _showPillInfo(PillUser pill) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            pill.name,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Категория: ${pill.category ?? '-'}'),
              Text('Активное вещество: ${pill.activeSubstance ?? '-'}'),
              Text('Тип приёма: ${pill.intakeType ?? '-'}'),
              Text('Дозировка: ${pill.dosage ?? '-'}'),
              Text('Количество: ${pill.quantity?.toString() ?? '-'}'),
              Text('Комментарии: ${pill.comments ?? '-'}'),
              Text(
                'Годен до: ${_formatDate(pill.expirationDate)}',
                style: TextStyle(
                  color: _getDateColor(pill.expirationDate),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('ОК'),
            ),
          ],
        );
      },
    );
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
                        color: Colors.yellow[100],
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        medKit.comment!,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  SizedBox(height: 16),
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
                        Map<String, List<PillUser>> categorizedPills = {};
                        for (var pill in pills) {
                          categorizedPills.putIfAbsent(pill.category ?? 'Без категории', () => []).add(pill);
                        }
                        return Expanded(
                          child: ListView.builder(
                            itemCount: categorizedPills.keys.length,
                            itemBuilder: (context, categoryIndex) {
                              String category = categorizedPills.keys.elementAt(categoryIndex);
                              List<PillUser> categoryPills = categorizedPills[category]!;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    category,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                  Divider(),
                                  ...categoryPills.map((pill) {
                                    return Column(
                                      children: [
                                        ListTile(
                                          title: Text(
                                            pill.name,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Годен до: ${_formatDate(pill.expirationDate)}',
                                                style: TextStyle(
                                                  color: _getDateColor(pill.expirationDate),
                                                ),
                                              ),
                                            ],
                                          ),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: Icon(Icons.info),
                                                onPressed: () => _showPillInfo(pill),
                                              ),
                                              IconButton(
                                                icon: Icon(Icons.edit),
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => CreatePillScreen(
                                                        idMedKit: widget.id_med_kit,
                                                        pillId: pill.idPillUser,
                                                      ),
                                                    ),
                                                  ).then((_) {
                                                    _refreshPills();
                                                  });
                                                },
                                              ),
                                              IconButton(
                                                icon: Icon(Icons.delete),
                                                onPressed: () => _deletePill(pill.idPillUser),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Divider(),
                                      ],
                                    );
                                  }).toList(),
                                ],
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
