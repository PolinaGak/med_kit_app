import 'package:flutter/material.dart';
import '../api_service.dart';
import '../models/pill_user.dart';

class SearchScreen extends StatefulWidget {
  final int userId;

  SearchScreen({required this.userId});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<PillUser> _allPills = [];
  List<PillUser> _filteredPills = [];
  String _query = '';
  String _filter = 'Название';
  bool _sortByExpiry = false;

  @override
  void initState() {
    super.initState();
    _loadPills();
  }

  void _loadPills() async {
    List<PillUser> pills = await ApiService().getAllPills(userId: widget.userId);
    setState(() {
      _allPills = pills;
      _applyFilters();
    });
  }

  void _applyFilters() {
    List<PillUser> filtered = _allPills.where((pill) {
      final query = _query.toLowerCase();
      switch (_filter) {
        case 'Название':
          return pill.name.toLowerCase().contains(query);
        case 'Действующее вещество':
          return (pill.activeSubstance ?? '').toLowerCase().contains(query);
        case 'Группа':
          return (pill.category ?? '').toLowerCase().contains(query);
        default:
          return true;
      }
    }).toList();

    if (_sortByExpiry) {
      filtered.sort((a, b) {
        if (a.expirationDate == null) return 1;
        if (b.expirationDate == null) return -1;
        return a.expirationDate!.compareTo(b.expirationDate!);
      });
    } else {
      filtered.sort((a, b) => a.name.compareTo(b.name));
    }

    setState(() {
      _filteredPills = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Поиск лекарства',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    _query = value;
                    _applyFilters();
                  },
                ),
              ),
              SizedBox(width: 10),
              DropdownButton<String>(
                value: _filter,
                items: ['Название', 'Действующее вещество', 'Группа']
                    .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _filter = value!;
                    _applyFilters();
                  });
                },
              ),
              SizedBox(width: 10),
              IconButton(
                icon: Icon(_sortByExpiry ? Icons.timer : Icons.sort_by_alpha),
                onPressed: () {
                  setState(() {
                    _sortByExpiry = !_sortByExpiry;
                    _applyFilters();
                  });
                },
              )
            ],
          ),
          SizedBox(height: 16),
          Expanded(
            child: _filteredPills.isEmpty
                ? Center(child: Text('Нет результатов'))
                : ListView.builder(
              itemCount: _filteredPills.length,
              itemBuilder: (context, index) {
                final pill = _filteredPills[index];
                return Card(
                  child: ListTile(
                    title: Text(pill.name),
                    subtitle: Text(
                        'Группа: ${pill.category ?? "-"}, Срок годн.: ${pill.expirationDate?.toLocal().toString().split(" ")[0] ?? "-"}'),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
