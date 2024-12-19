import 'package:event_management/config.dart';
import 'package:event_management/src/service/logger_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> addParticipant(
    List<Map<String, dynamic>> members, int eventId, String role) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user logged in');
    }

    List<Map<String, dynamic>> participants = [];

    String? idToken = await user.getIdToken();

    for (var member in members) {
      participants.add({
        "id": 0,
        'userId': member['id'],
        'eventId': eventId,
        'registration_Date': DateTime.now().toIso8601String(),
        'status': 'Approved',
        'role': role,
      });
    }
    LoggerService.logger.i(participants);
    final response = await http.post(
      Uri.parse('${Config.baseUrl}/event-service/add'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },
      body: jsonEncode(participants),
    );

    if (response.statusCode == 200) {
      LoggerService.logger.i('Participant added successfully.');
    } else {
      throw Exception('Failed to add participant: ${response.body}');
    }
  } catch (e) {
    // Log lỗi nếu có
    LoggerService.logger.w('Failed to add participant: $e');
  }
}
