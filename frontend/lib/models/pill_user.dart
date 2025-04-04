import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

class PillUser {
  final int idPillUser;
  String name;
  DateTime? expirationDate;
  String? activeSubstance;
  String? category;
  String? intakeType;
  double? quantity;
  String? format;
  String? dosage;
  String? comments;
  String? imageUrl;
  double? lastPrice;

  PillUser({
    required this.idPillUser,
    required this.name,
    this.expirationDate,
    this.activeSubstance,
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
      'expiration_date': expirationDate?.toIso8601String(),
      'active_substance': activeSubstance,
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