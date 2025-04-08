import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer';
import 'models/medkit.dart';
import 'models/medkit_pill.dart';
import 'models/pill_user.dart';
import 'models/user.dart';


class ApiService {
  static const String baseUrl = 'http://127.0.0.1:5000';


  Future<Map<String, dynamic>> registerUser(String email, String password, String name) async {
    final url = Uri.parse('$baseUrl/register/');
    final body = json.encode({
      'email': email,
      'password': password,
      'name': name,
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final userId = responseData['user_id'];

        return {'message': 'User registered successfully', 'user_id': userId};
      } else {
        return {'error': 'Registration failed: ${response.body}'};
      }
    } catch (e) {
      log('Ошибка при регистрации: $e');
      return {'error': 'Registration failed: $e'};
    }
  }



  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    final url = Uri.parse('$baseUrl/login/');
    final body = json.encode({
      'email': email,
      'password': password,
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return {
          'access_token': responseData['access_token'],
          'refresh_token': responseData['refresh_token'],
          'user_id': responseData['user_id'],
        };
      } else {
        return {'error': 'Login failed: ${response.body}'};
      }
    } catch (e) {
      log('Ошибка при входе: $e');
      return {'error': 'Login failed: $e'};
    }
  }


  Future<Map<String, dynamic>> refreshAccessToken(String refreshToken) async {
    final url = Uri.parse('$baseUrl/refresh-token/');
    final body = json.encode({
      'refresh_token': refreshToken,
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return {
          'access_token': responseData['access_token'],
          'token_type': responseData['token_type'],
        };
      } else {
        return {'error': 'Failed to refresh access token: ${response.body}'};
      }
    } catch (e) {
      log('Ошибка при обновлении токена: $e');
      return {'error': 'Failed to refresh access token: $e'};
    }
  }


  Future<Map<String, dynamic>> forgotPassword(String email) async {
    final url = Uri.parse('$baseUrl/forgot-password/');
    final body = json.encode({
      'email': email,
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        return {'message': 'Password reset email sent successfully'};
      } else {
        return {'error': 'Failed to send password reset email: ${response.body}'};
      }
    } catch (e) {
      log('Ошибка при сбросе пароля: $e');
      return {'error': 'Failed to send password reset email: $e'};
    }
  }


  Future<Map<String, dynamic>> resetPassword(String token, String newPassword) async {
    final url = Uri.parse('$baseUrl/reset-password/');
    final body = json.encode({
      'token': token,
      'new_password': newPassword,
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        return {'message': 'Password reset successfully'};
      } else {
        return {'error': 'Failed to reset password: ${response.body}'};
      }
    } catch (e) {
      log('Ошибка при сбросе пароля: $e');
      return {'error': 'Failed to reset password: $e'};
    }
  }


  Future<List<MedKit>> getAllMedKitsByUserId(int userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/medkits/user/$userId'));

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

  // Получение всех лекарств по ID аптечки
  Future<List<PillUser>> getPillsByMedKitId(int id) async {
    try {
      final response = await http.get(
          Uri.parse('$baseUrl/api/medkits/$id/pills'));

      if (response.statusCode == 200) {
        Iterable jsonResponse = json.decode(utf8.decode(response.bodyBytes));

        return jsonResponse.map((json) => PillUser.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load pills');
      }
    } catch (e) {
      log('Ошибка в API: $e');
      return [];
    }
  }


  //Сохранение новой аптечки
  Future<MedKit?> createMedKit(String name,
      String color,
      String iconName,
      String? comment,
      int userId) async {
    final url = Uri.parse('$baseUrl/api/medkits/$userId');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        'name': name,
        'color': color,
        'icon_name': iconName,
        'comment': comment ?? '',
        'creation_date': DateTime.now().toIso8601String(),
      }),
    );

    if (response.statusCode == 200) {
      return MedKit.fromJson(json.decode(response.body));
    } else {
      return null;
    }
  }

  // Метод для удаления аптечки по ID
  Future<void> deleteMedKit(int id) async {
    final url = Uri.parse('$baseUrl/api/medkits/$id');
    final response = await http.delete(url);

    if (response.statusCode != 200) {
      throw Exception('Не удалось удалить аптечку');
    }
  }

  // Метод для обновления аптечки
  Future<void> updateMedKit(int id,
      String name,
      String color,
      String iconName,
      String? comment) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/medkits/$id'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'name': name,
        'color': color,
        'icon_name': iconName,
        'comment': comment,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Не удалось обновить аптечку');
    }
  }

  Future<bool> createPill(String name,
      DateTime? expirationDate,
      String? activeSubstance,
      String? category,
      String? intakeType,
      double? quantity,
      String? format,
      String? dosage,
      String? comments,
      String? imageUrl,
      double? lastPrice,
      int medKitId) async {
    final pillData = {
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

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/medkits/$medKitId/pills'),
        headers: {"Content-Type": "application/json"},
        body: json.encode(pillData),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Не удалось создать лекарство');
      }
    } catch (e) {
      log('Ошибка в API: $e');
      return false;
    }
  }


  Future<bool> deletePill(int medkitId, int pillId) async {
    final url = Uri.parse('$baseUrl/api/medkits/$medkitId/pills/$pillId');
    final response = await http.delete(url);

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      return true;
    } else {
      return false;
    }
  }


  // Метод для обновления лекарства в аптечке
  Future<bool> updatePill(int medkitId,
      int pillId,
      String name,
      DateTime? expirationDate,
      String? activeSubstance,
      String? category,
      String? intakeType,
      double? quantity,
      String? format,
      String? dosage,
      String? comments,
      String? imageUrl,
      double? lastPrice,) async {
    final pillData = {
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

    final response = await http.put(
      Uri.parse('$baseUrl/api/medkits/$medkitId/pills/$pillId'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(pillData),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<PillUser> getPillById(int pillId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/pills/$pillId'));

      if (response.statusCode == 200) {
        return PillUser.fromJson(json.decode(utf8.decode(response.bodyBytes)));
      } else {
        throw Exception('Failed to load pill');
      }
    } catch (e) {
      log('Ошибка в API: $e');
      rethrow;
    }
  }
}