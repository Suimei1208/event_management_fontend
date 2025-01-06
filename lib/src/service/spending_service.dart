import 'dart:convert';

import 'package:event_management/config.dart';
import 'package:event_management/src/service/logger_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

Future<void> addSpending(
    int eventId, String category, double amount, String type) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user logged in');
    }

    String? idToken = await user.getIdToken();
    if (idToken == null) {
      throw Exception('Failed to retrieve ID token');
    }

    final response = await http.post(
      Uri.parse(
          '${Config.baseUrl}/event-finance-service/event/$eventId/spending/add'),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'eventId': eventId,
        'category': category,
        'amount': amount,
        'type': type,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Failed to add spending: ${response.body}, status code: ${response.statusCode}');
    }

    final responseData = json.decode(response.body);
    if (responseData['success'] == true) {
      LoggerService.logger.i('Spending added successfully');
    } else {
      throw Exception('Failed to add spending: ${response.body}');
    }
  } catch (e) {
    LoggerService.logger.e('Failed to add spending: $e');
  }
}

Future<List<Map<String, dynamic>>> fetchSpendings(int eventId) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      LoggerService.logger.e('User not logged in');
      return [];
    }

    String? idToken = await user.getIdToken();
    if (idToken == null) {
      LoggerService.logger.e('Token not found');
      return [];
    }

    final response = await http.get(
      Uri.parse(
          '${Config.baseUrl}/event-finance-service/event/$eventId/spending'),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      if (data['success'] == false) {
        return [];
      }
      List<Map<String, dynamic>> spendings = [];
      for (var item in data['data']) {
        spendings.add(item);
      }
      return spendings;
    } else {
      return [];
    }
  } catch (e) {
    LoggerService.logger.e('Error fetching spendings: $e');
    return [];
  }
}

Future<Map<String, double>> fetchSpendingData(int eventId) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    String? token = await user.getIdToken();
    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.get(
      Uri.parse(
          '${Config.baseUrl}/event-finance-service/event/$eventId/spending'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      Map<String, double> spendingData = {};

      for (var item in data['data']) {
        String category = item['category'];
        double amount = (item['amount'] is int)
            ? (item['amount'] as int).toDouble()
            : item['amount'];
        spendingData[category] = amount;
      }

      return spendingData;
    } else {
      throw Exception(
          'Failed to load spending data. Status: ${response.statusCode}. Body: ${response.body}');
    }
  } catch (e) {
    throw Exception('Error: $e');
  }
}

Future<void> updateSpending(
    int eventId, int spendingId, String category, double amount) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user logged in');
    }

    String? idToken = await user.getIdToken();
    if (idToken == null) {
      throw Exception('Failed to retrieve ID token');
    }

    final response = await http.put(
      Uri.parse(
          '${Config.baseUrl}/event-finance-service/event/$eventId/spending/update/$spendingId'),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'category': category,
        'amount': amount,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update spending: ${response.body}');
    }

    final responseData = json.decode(response.body);
    if (responseData['success'] == true) {
      LoggerService.logger.i('Spending updated successfully');
    } else {
      throw Exception('Failed to update spending: ${response.body}');
    }
  } catch (e) {
    LoggerService.logger.e('Failed to update spending: $e');
  }
}

Future<void> deleteSpending(int eventId, int id) async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    LoggerService.logger.e('No user logged in');
    throw Exception('No user logged in');
  }

  String? idToken = await user.getIdToken();
  try {
    final response = await http.delete(
      Uri.parse(
          '${Config.baseUrl}/event-finance-service/event/$eventId/spending/delete/$id'),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      LoggerService.logger.e('Failed to delete spending: ${response.body}');
      throw Exception(
          'Failed to delete $id spending. ${response.body}. ${response.statusCode}');
    }
  } catch (error, stackTrace) {
    LoggerService.logger.e('Error deleting spending: $error, $stackTrace');
    rethrow;
  }
}
