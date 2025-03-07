// ignore_for_file: non_constant_identifier_names

import 'package:event_management/config.dart';
import 'package:event_management/src/service/logger_service.dart';
import 'package:event_management/src/service/ticket_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<bool> approveParticipant(
    int eventId, int participantId, String userId) async {
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
          '${Config.baseUrl}/event-service/event/$eventId/participants/$participantId/approve'),
      headers: {
        'Authorization': 'Bearer $idToken',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData['success'] == true) {
        await addTicketForParticipant(eventId, userId, "Approved");
        return true;
      } else {
        throw Exception(
            responseData['message'] ?? 'Failed to approve participant');
      }
    } else {
      LoggerService.logger.w(
          'Failed to approve participant: ${response.statusCode} ${response.body}');
      throw Exception(
          'Failed to approve participant: ${response.statusCode} ${response.body}');
    }
  } catch (e) {
    throw Exception('Failed to approve participant: $e');
  }
}

Future<void> addParticipant(String userId, int eventId, String role) async {
  try {
    // Ensure the user is logged in
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user logged in');
    }

    // Prepare the participant data
    List<Map<String, dynamic>> participants = [];

    String? idToken = await user.getIdToken();

    participants.add({
      "id": 0,
      'userId': userId,
      'eventId': eventId,
      'registration_Date': DateTime.now().toIso8601String(),
      'status': 'Approved',
      'role': role, // Ensure role is passed correctly
    });

    LoggerService.logger.i('Participant Data: $participants');

    // Send a POST request to add the participant
    final response = await http.post(
      Uri.parse('${Config.baseUrl}/event-service/add'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },
      body: jsonEncode(participants),
    );

    // Handle response
    if (response.statusCode == 200) {
      LoggerService.logger.i('Participant added successfully.');
    } else {
      throw Exception(
          'Failed to add participant: ${response.body}, status: ${response.statusCode}');
    }
  } catch (e) {
    // Log any errors that occur during the process
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

Future<void> UserRegisterEvent(int eventid, String status, String role) async {
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
      'status': status,
      'role': role,
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

Future<void> addParticipantToSchedule(int scheduleId, String userId) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user logged in');
    }

    String? idToken = await user.getIdToken();

    final response = await http.post(
      Uri.parse(
          '${Config.baseUrl}/event-service/event/$scheduleId/add-schedule-participant/$userId'),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['success'] == true) {
        LoggerService.logger
            .i('Participant added successfully to the schedule');
      } else {
        LoggerService.logger
            .w('Failed to add participant: ${responseData['message']}');
      }
    } else {
      LoggerService.logger.w(
          'HTTP error: ${response.body}, status: ${response.statusCode}, scheduleId: $scheduleId');
    }
  } catch (error) {
    LoggerService.logger.w('Error: $error');
  }
}

Future<bool> addParticipantsToEventByExcel(
    int eventId, List<String> userIds) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      LoggerService.logger.e("No user logged in");
      throw Exception('No user logged in');
    }
    String? idToken = await user.getIdToken();
    if (idToken == null) {
      LoggerService.logger.e("Failed to retrieve ID token");
      throw Exception('Failed to retrieve ID token');
    }

    final response = await http.post(
      Uri.parse(
          '${Config.baseUrl}/event-service/event/add-participants-excel/$eventId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },
      body: json.encode(userIds),
    );

    if (response.statusCode == 200) {
      LoggerService.logger.i("Participants added successfully.");
      for (var userId in userIds) {
        await addTicketForParticipant(eventId, userId, "Added");
      }
      return true;
    } else {
      LoggerService.logger.e(
          "Failed to add participants, status code: ${response.statusCode}, body: ${response.body}");
      return false;
    }
  } catch (e) {
    LoggerService.logger.e("Error adding participants to event: $e");
    return false;
  }
}

Future<bool> removeParticipant(int eventId, int participantId) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user logged in');
    }

    String? idToken = await user.getIdToken();
    if (idToken == null) {
      throw Exception('Failed to retrieve ID token');
    }

    final response = await http.delete(
      Uri.parse(
          '${Config.baseUrl}/event-service/event/$eventId/participants/$participantId/remove'),
      headers: {
        'Authorization': 'Bearer $idToken',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData['success'] == true) {
        return true;
      } else {
        throw Exception(
            responseData['message'] ?? 'Failed to remove participant');
      }
    } else {
      LoggerService.logger.w(
          'Failed to remove participant: ${response.statusCode} ${response.body}');
      throw Exception(
          'Failed to remove participant: ${response.statusCode} ${response.body}');
    }
  } catch (e) {
    throw Exception('Failed to remove participant: $e');
  }
}

Future<bool> removeScheduleParticipant(int eventId, int participantId) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user logged in');
    }

    String? idToken = await user.getIdToken();
    if (idToken == null) {
      throw Exception('Failed to retrieve ID token');
    }

    final response = await http.delete(
      Uri.parse(
          '${Config.baseUrl}/event-service/event/$eventId/participants/$participantId/remove'),
      headers: {
        'Authorization': 'Bearer $idToken',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData['success'] == true) {
        return true;
      } else {
        throw Exception(
            responseData['message'] ?? 'Failed to remove participant');
      }
    } else {
      LoggerService.logger.w(
          'Failed to remove participant: ${response.statusCode} ${response.body}');
      throw Exception(
          'Failed to remove participant: ${response.statusCode} ${response.body}');
    }
  } catch (e) {
    throw Exception('Failed to remove participant: $e');
  }
}

Future<void> addSpecialParticipant({
  required int eventId,
  required String name,
  required String role,
  required String description,
  required String photoUrl,
}) async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    LoggerService.logger.e('No user logged in');
    throw Exception('No user logged in');
  }

  String? idToken = await user.getIdToken();
  if (idToken == null) {
    LoggerService.logger.e('Failed to retrieve ID token');
    throw Exception('Failed to retrieve ID token');
  }

  final url = Uri.parse(
      '${Config.baseUrl}/event-service/event/$eventId/add-special-participant');
  try {
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'role': role,
        'description': description,
        'photoUrl': photoUrl,
      }),
    );

    if (response.statusCode == 200) {
      LoggerService.logger
          .i('Special participant added successfully: $name, $role');
    } else {
      LoggerService.logger.e(
          'Failed to add special participant: ${response.body}, status: ${response.statusCode}');
      throw Exception(
          'Failed to add special participant: ${response.body}, status: ${response.statusCode}');
    }
  } catch (e) {
    LoggerService.logger.e('Error adding special participant: $e');
    throw Exception('Error adding special participant: $e');
  }
}

Future<void> removeSpecialParticipant(int eventId, int participantId) async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    throw Exception('No user logged in');
  }

  String? idToken = await user.getIdToken();
  if (idToken == null) {
    throw Exception('Failed to retrieve ID token');
  }

  final url = Uri.parse(
      '${Config.baseUrl}/event-service/event/$eventId/remove-special-participant/$participantId');

  try {
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Failed to remove special participant: ${response.body}, status: ${response.statusCode}');
    }
  } catch (error) {
    throw Exception('Error removing special participant: $error');
  }
}

Future<List<Map<String, dynamic>>> fetchSpecialParticipants(int eventId) async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    throw Exception('No user logged in');
  }

  String? idToken = await user.getIdToken();
  if (idToken == null) {
    throw Exception('Failed to retrieve ID token');
  }

  final url = Uri.parse(
      '${Config.baseUrl}/event-service/event/$eventId/special-participants');

  try {
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['success']) {
        return List<Map<String, dynamic>>.from(responseData['data'] ?? []);
      } else {
        throw Exception('Failed to load participants');
      }
    } else {
      throw Exception('Failed to fetch participants: ${response.body}');
    }
  } catch (error) {
    throw Exception('Error fetching participants: $error');
  }
}
