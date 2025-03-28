import 'user.dart';
import 'medkit.dart';

class UserMedKit {
  final int id;
  final int idUser;
  final int idMedKit;
  final User user;
  final MedKit medKit;

  UserMedKit({
    required this.id,
    required this.idUser,
    required this.idMedKit,
    required this.user,
    required this.medKit,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_user': idUser,
      'id_med_kit': idMedKit,
      'user': user.toJson(),
      'med_kit': medKit.toJson(),
    };
  }

  factory UserMedKit.fromJson(Map<String, dynamic> json) {
    return UserMedKit(
      id: json['id'],
      idUser: json['id_user'],
      idMedKit: json['id_med_kit'],
      user: User.fromJson(json['user']),
      medKit: MedKit.fromJson(json['med_kit']),
    );
  }

  @override
  String toString() {
    return 'UserMedicineKit{id: $id, idUser: $idUser, idMedKit: $idMedKit}';
  }
}
