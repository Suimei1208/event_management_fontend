import 'dart:convert';

import 'package:event_management/config.dart';
import 'package:event_management/src/service/logger_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> getCancellationPeriods(int eventid) async {
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

    final response = await http.get(
      Uri.parse('${Config.baseUrl}/ticket-service/feedback/get/$eventid'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $idToken',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load cancellation periods');
    }
  } catch (e) {
    LoggerService.logger.e(e.toString());
    throw Exception('Failed to load cancellation periods');
  }
}

Future<void> createFeedbackCancel(
    int eventid,
    DateTime? startDate,
    DateTime? endDate,
    bool isReasonImgageRequired,
    bool isLinkRequired,
    String? link) async {
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
          '${Config.baseUrl}/ticket-service/tickets/feedback-cancel-event/create'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $idToken',
      },
      body: jsonEncode({
        "id": 0,
        "event_id": eventid,
        // ignore: unnecessary_null_comparison, prefer_null_aware_operators
        "start_date": startDate != null ? startDate.toIso8601String() : null,
        // ignore: unnecessary_null_comparison, prefer_null_aware_operators
        "end_date": endDate != null ? endDate.toIso8601String() : null,
        "is_reason_imgage_required": isReasonImgageRequired,
        "is_link_required": isLinkRequired,
        // ignore: unnecessary_null_comparison, prefer_if_null_operators
        "link": link != null ? link : null,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update cancellation periods');
    } else {
      LoggerService.logger.i('Cancellation periods create successfully');
    }
  } catch (e) {
    LoggerService.logger.e(e.toString());
    throw Exception('Failed to update cancellation periods');
  }
}

Future<void> updateFeedbackCancel(
    int id,
    int eventid,
    DateTime startDate,
    DateTime endDate,
    bool isReasonImgageRequired,
    bool isLinkRequired,
    String? link) async {
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

    final response = await http.put(
      Uri.parse('${Config.baseUrl}/ticket-service/feedback/update'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $idToken',
      },
      body: jsonEncode({
        "id": id,
        "event_id": eventid,
        // ignore: unnecessary_null_comparison, prefer_null_aware_operators
        "start_date": startDate.toIso8601String(),
        // ignore: unnecessary_null_comparison, prefer_null_aware_operators
        "end_date": endDate.toIso8601String(),
        "is_reason_imgage_required": isReasonImgageRequired,
        "is_link_required": isLinkRequired,
        // ignore: unnecessary_null_comparison, prefer_if_null_operators
        "link": link,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update cancellation periods');
    } else {
      LoggerService.logger.i('Cancellation periods update successfully');
    }
  } catch (e) {
    LoggerService.logger.e(e.toString());
    throw Exception('Failed to update cancellation periods');
  }
}
