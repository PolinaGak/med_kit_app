class MedKit {
  final int idMedKit;
  final String name;
  final DateTime creationDate;
  final String? comment;
  final String color;
  final String? iconName;

  MedKit({
    required this.idMedKit,
    required this.name,
    required this.creationDate,
    this.comment,
    required this.color,
    this.iconName,
  });

  Map<String, dynamic> toJson() {
    return {
      'id_med_kit': idMedKit,
      'name': name,
      'creation_date': creationDate.toIso8601String(),
      'comment': comment,
      'color': color,
      'icon_name': iconName,
    };
  }

  factory MedKit.fromJson(Map<String, dynamic> json) {
    return MedKit(
      idMedKit: json['id_med_kit'],
      name: json['name'],
      creationDate: DateTime.parse(json['creation_date']),
      comment: json['comment'],
      color: json['color'],
      iconName: json['icon_name'],
    );
  }

  @override
  String toString() {
    return 'MedKit{idMedKit: $idMedKit, name: $name, creationDate: ${creationDate.toIso8601String()}}';
  }
}
