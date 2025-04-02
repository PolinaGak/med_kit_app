class PillUser {
  final int idPillUser;
  final String name;
  final String? activeSubstance;
  final DateTime? expirationDate;
  final String? category;
  final String? intakeType;
  final double? quantity;
  final String? format;
  final String? dosage;
  final String? comments;
  final String? imageUrl;
  final double? lastPrice;

  PillUser({
    required this.idPillUser,
    required this.name,
    this.activeSubstance,
    this.expirationDate,
    this.category,
    this.intakeType,
    this.quantity,
    this.format,
    this.dosage,
    this.comments,
    this.imageUrl,
    this.lastPrice,
  });

  Map<String, dynamic> toJson() {
    return {
      'id_pill_user': idPillUser,
      'name': name,
      'active_substance': activeSubstance,
      'expiration_date': expirationDate?.toIso8601String(),
      'category': category,
      'intake_type': intakeType,
      'quantity': quantity,
      'format': format,
      'dosage': dosage,
      'comments': comments,
      'image_url': imageUrl,
      'last_price': lastPrice,
    };
  }

  factory PillUser.fromJson(Map<String, dynamic> json) {
    return PillUser(
      idPillUser: json['id_pill_user'],
      name: json['name'],
      activeSubstance: json['active_substance'],
      expirationDate: json['expiration_date'] != null
          ? DateTime.parse(json['expiration_date'])
          : null,
      category: json['category'],
      intakeType: json['intake_type'],
      quantity: json['quantity'],
      format: json['format'],
      dosage: json['dosage'],
      comments: json['comments'],
      imageUrl: json['image_url'],
      lastPrice: json['last_price'],
    );
  }

  @override
  String toString() {
    return 'PillUser{idPillUser: $idPillUser, name: $name, expirationDate: $expirationDate, quantity: $quantity}';
  }
}
