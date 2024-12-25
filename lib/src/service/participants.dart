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

Future<List<Map<String, dynamic>>> fetchParticipants(int eventId) async {
  try {
    final response = await http.get(
      Uri.parse('${Config.baseUrl}/event-service/$eventId'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      // Parse the response body to get participants
      final responseData = json.decode(response.body);
      List<Map<String, dynamic>> participants =
          List<Map<String, dynamic>>.from(responseData['data']['participants']);
      LoggerService.logger.i('Fetched participants: $participants');
      return participants; // Return the list of participants
    } else {
      throw Exception('Failed to fetch participants: ${response.body}');
    }
  } catch (e) {
    // Log the error and return an empty list in case of failure
    LoggerService.logger.w('Failed to fetch participants: $e');
    return [];
  }
}

// ignore: non_constant_identifier_names
Future<void> UserRegisterEvent(String eventid) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user logged in');
    }

    String? idToken = await user.getIdToken();
    var participant = {
      "id": 0,
      'userId': user.uid,
      'eventId': eventid,
      'registration_Date': DateTime.now().toIso8601String(),
      'status': 'Pending',
      'role': 'Participant',
    };
    List<Map<String, dynamic>> participants = [];
    participants.add(participant);
    final response = await http.post(
      Uri.parse('${Config.baseUrl}/event-service/add'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },
      body: jsonEncode(participants),
    );

    if (response.statusCode == 200) {
      LoggerService.logger.i('User registered successfully.');
      // const DialogWidget(
      //   message: "Notification",
      //   title: "Registered successfully",
      // );
    } else {
      throw Exception('Failed to register user: ${response.body}');
    }
  } catch (e) {
    // Log lỗi nếu có
    LoggerService.logger.w('Failed to register user: $e');
  }
}

Future<List<Map<String, dynamic>>> fetchStatusEventRegister(String uid) async {
  try {
    // Check if the user is logged in
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user logged in');
    }

    String? idToken = await user.getIdToken();

    final response = await http.get(
      Uri.parse(
          '${Config.baseUrl}/event-service/get-event-register-pending?uid=$uid'),
      headers: {
        'Authorization': 'Bearer $idToken',
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      List<Map<String, dynamic>> status =
          List<Map<String, dynamic>>.from(responseData['data']);
      return status;
    } else {
      throw Exception('Failed to fetch status: ${response.body}');
    }
  } catch (e) {
    LoggerService.logger.w('Failed to fetch status: $e');
    return [];
  }
}

Future<void> unregisterEvent(String eventId) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user logged in');
    }


    final response = await http.delete(
      Uri.parse(
          '${Config.baseUrl}/event-service/participants/unregister?uid=${user.uid}&eventid=$eventId'),
    );

    if (response.statusCode == 200) {
      LoggerService.logger.i('Unregistered successfully.');
    } else {
      throw Exception('Failed to unregister: ${response.body}');
    }
  } catch (e) {
    LoggerService.logger.w('Failed to unregister: $e');
  }
}
