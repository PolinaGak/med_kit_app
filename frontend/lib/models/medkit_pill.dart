import 'medkit.dart';
import 'pill_user.dart';

class MedKitPill {
  final int id;
  final int idMedKit;
  final int idPillUser;
  final MedKit medKit;
  final PillUser pill;

  MedKitPill({
    required this.id,
    required this.idMedKit,
    required this.idPillUser,
    required this.medKit,
    required this.pill,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_med_kit': idMedKit,
      'id_pill_user': idPillUser,
      'med_kit': medKit.toJson(),
      'pill': pill.toJson(),
    };
  }

  factory MedKitPill.fromJson(Map<String, dynamic> json) {
    return MedKitPill(
      id: json['id'],
      idMedKit: json['id_med_kit'],
      idPillUser: json['id_pill_user'],
      medKit: MedKit.fromJson(json['med_kit']),
      pill: PillUser.fromJson(json['pill']),
    );
  }

  @override
  String toString() {
    return 'MedKitPill{id: $id, idMedKit: $idMedKit, idPillUser: $idPillUser}';
  }
}
