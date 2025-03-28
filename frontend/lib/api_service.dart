import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer';
import 'models/medkit.dart';


class ApiService {
  static const String baseUrl = 'http://127.0.0.1:5000';

  // Получение всех аптечек
  Future<List<MedKit>> getAllMedKits() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/medkits'));

      if (response.statusCode == 200) {
        Iterable jsonResponse = json.decode(utf8.decode(response.bodyBytes));
        if (jsonResponse.isEmpty) {
          return [];
        }
        return jsonResponse.map((json) => MedKit.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load medkits');
      }
    } catch (e) {
      log('Ошибка в API: $e');
      return [];
    }
  }

  // Получение одной аптечки по ID
  Future<MedKit> getMedKitById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/api/medkits/$id'));

    if (response.statusCode == 200) {
      return MedKit.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to load medkit');
    }
  }
}