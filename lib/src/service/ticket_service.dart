import 'dart:convert';

import 'package:event_management/config.dart';
import 'package:event_management/src/service/logger_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

Future<void> createTicketCancellationRequest(
    int eventId, String cancellationReason, String linkUrl) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      LoggerService.logger.e('User not logged in');
      return;
    }
    String? token = await user.getIdToken();
    if (token == null) {
      LoggerService.logger.e('Token not found');
      return;
    }
    final response = await http.post(
      Uri.parse('${Config.baseUrl}/ticket-service/feedback/user-cancel/create'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{
        'id': 0,
        'event_id': eventId,
        'uid': user.uid,
        'send_at': DateTime.now().toIso8601String(),
        'reason': cancellationReason,
        'link_image': linkUrl,
        'status': 'Pending',
      }),
    );

    if (response.statusCode == 200) {
      LoggerService.logger
          .i('Ticket cancellation request submitted successfully');
    } else {
      LoggerService.logger.e('Failed to submit ticket cancellation request');
    }
  } catch (e) {
    LoggerService.logger.e('Error: $e');
  }
}

Future<List<Map<String, dynamic>>> fetchCancelledUsers(
    int eventId, String status) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      LoggerService.logger.e('User not logged in');
      return [];
    }
    String? token = await user.getIdToken();
    if (token == null) {
      LoggerService.logger.e('Token not found');
      return [];
    }
    final response = await http.get(
      Uri.parse(
          '${Config.baseUrl}/ticket-service/feedback/user-cancel/get/list-user/pending?eventId=$eventId&status=$status'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      List<Map<String, dynamic>> cancelledUsers = [];
      for (var user in data['data'] as List) {
        cancelledUsers.add({
          'id': user['id'],
          'event_id': user['event_id'],
          'uid': user['uid'],
          'name': user['user']['name'],
          'nameFromEmail': user['user']['nameFromEmail'],
          'email': user['user']['email'],
          'avtUrl': user['user']['avtUrl'],
          'link_image': user['link_image'],
          'send_at': user['send_at'],
          'reason': user['reason'],
          'status': user['status'],
        });
      }
      return cancelledUsers;
    } else {
      LoggerService.logger.e('Failed to fetch cancelled users');
      return [];
    }
  } catch (e) {
    LoggerService.logger.e('Error: $e');
    return [];
  }
}
