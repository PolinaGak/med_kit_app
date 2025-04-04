import 'package:flutter/material.dart';
import 'package:med_kit/models/pill_user.dart';
import 'package:intl/intl.dart';
import '../api_service.dart';

class CreatePillScreen extends StatefulWidget {
  final int idMedKit;
  CreatePillScreen({required this.idMedKit});

  @override
  _CreatePillScreenState createState() => _CreatePillScreenState();
}

class _CreatePillScreenState extends State<CreatePillScreen> {
  final _nameController = TextEditingController();
  final _activeSubstanceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _dosageController = TextEditingController();
  final _commentsController = TextEditingController();
  final _lastPriceController = TextEditingController();

  DateTime? _selectedDate;

  String? _category = 'Жаропонижающие и обезболивающие';
  String? _intakeType = 'До еды';
  String? _format = 'таблетки';

  final List<String> categories = [
    'Жаропонижающие и обезболивающие',
    'Противовоспалительные',
    'Антибиотики',
    'Антигистамины',
    'Противодиабетические препараты',
    'Бронхолитики',
    'Препараты для сердца',
    'Противосудорожные средства',
    'Кортикостероиды',
    'Другое',
    'Антипаразитарные средства',
    'Противогрибковые препараты',
    'Противовирусные препараты',
    'Препараты для желудочно-кишечного тракта',
    'Препараты для нервной системы',
    'Иммуностимуляторы',
    'Противораковые препараты',
    'Нозальные препараты',
    'Вакцины'
  ];


  final List<String> formats = [
    'граммы',
    'миллилитры',
    'таблетки',
    'ампулы',
    'суппозитории',
    'другое',
    'капли',
    'растворы',
    'пастилки',
    'мазь',
    'крем',
    'гели',
    'пластыри',
    'ингаляторы',
    'суспензии',
    'порошки',
    'шприцы',
    'сиропы'
  ];

  final List<String> intakeTypes = [
    'До еды',
    'После еды',
    'Во время еды',
    'Нет ограничений',
    'Перед сном',
    'После пробуждения'
    'По мере необходимости',
    'Утром',
    'Днём',
    'Вечером',
    'Перед или после еды',
  ];

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _activeSubstanceController.dispose();
    _quantityController.dispose();
    _dosageController.dispose();
    _commentsController.dispose();
    _lastPriceController.dispose();
  }

  Future<void> _savePill() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Поле "Название лекарства" обязательно!')));
      return;
    }

    if (_quantityController.text.isNotEmpty && double.tryParse(_quantityController.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('В поле "Остаток лекарства" должно быть числом!')));
      return;
    }

    if (_lastPriceController.text.isNotEmpty && double.tryParse(_lastPriceController.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('В поле "Последняя цена" должно быть числом!')));
      return;
    }

    final isSuccess = await ApiService().createPill(
      _nameController.text,
      _selectedDate ?? DateTime.now(),
      _activeSubstanceController.text,
      _category,
      _intakeType,
      double.tryParse(_quantityController.text),
      _format,
      _dosageController.text,
      _commentsController.text,
      null,
      double.tryParse(_lastPriceController.text),
      widget.idMedKit,
    );

    if (isSuccess) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Не удалось сохранить лекарство')));
    }
  }


  Widget _buildTextField(
      TextEditingController controller,
      String label, {
        TextInputType? keyboardType,
      }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade600),
        border: OutlineInputBorder(),
      ),
      keyboardType: keyboardType,
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = (await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    ))!;

    if (picked != null && picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Добавить новое лекарство'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTextField(_nameController, 'Название лекарства'),
              SizedBox(height: 16),
              InkWell(
                onTap: () => _selectDate(context),
                child: IgnorePointer(
                  child: TextField(
                    controller: TextEditingController(text: _selectedDate != null ? DateFormat('dd.MM.yyyy').format(_selectedDate!) : ''),
                    decoration: InputDecoration(
                      labelText: 'Дата',
                      labelStyle: TextStyle(color: Colors.grey.shade600),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: InputDecoration(
                  labelText: 'Категория лекарства',
                  labelStyle: TextStyle(color: Colors.grey.shade600),
                  border: OutlineInputBorder(),
                ),
                isExpanded: true,
                items: categories
                    .map((category) => DropdownMenuItem<String>(value: category, child: Text(category)))
                    .toList(),
                onChanged: (newValue) {
                  setState(() {
                    _category = newValue;
                  });
                },
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _intakeType,
                      decoration: InputDecoration(
                        labelText: 'Тип приёма',
                        labelStyle: TextStyle(color: Colors.grey.shade600),
                        border: OutlineInputBorder(),
                      ),
                      items: intakeTypes
                          .map((type) => DropdownMenuItem<String>(value: type, child: Text(type)))
                          .toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _intakeType = newValue;
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      _quantityController,
                      'Остаток лекарства',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _format,
                      decoration: InputDecoration(
                        labelText: 'Формат',
                        labelStyle: TextStyle(color: Colors.grey.shade600),
                        border: OutlineInputBorder(),
                      ),
                      items: formats
                          .map((format) => DropdownMenuItem<String>(value: format, child: Text(format)))
                          .toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _format = newValue;
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              _buildTextField(_activeSubstanceController, 'Действующее вещество'),
              SizedBox(height: 16),
              _buildTextField(_commentsController, 'Комментарии'),
              SizedBox(height: 16),
              _buildTextField(_lastPriceController, 'Последняя цена'),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: _savePill,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1F7AB2),
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Сохранить',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
