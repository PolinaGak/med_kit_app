class User {
  final int idUser;
  final String name;
  final String email;
  final String hashPassword;

  User({
    required this.idUser,
    required this.name,
    required this.email,
    required this.hashPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'id_user': idUser,
      'name': name,
      'email': email,
      'hash_password': hashPassword,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      idUser: json['id_user'],
      name: json['name'],
      email: json['email'],
      hashPassword: json['hash_password'],
    );
  }

  @override
  String toString() {
    return 'User{idUser: $idUser, name: $name, email: $email}';
  }
}
