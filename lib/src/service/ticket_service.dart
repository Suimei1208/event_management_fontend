import 'dart:convert';

import 'package:event_management/config.dart';
import 'package:event_management/src/models/tickets.dart';
import 'package:event_management/src/service/event_service.dart';
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

Future<void> addTicketForParticipant(
    int eventId, String userId, String status) async {
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
          '${Config.baseUrl}/ticket-service/event/$eventId/add-tickets/$userId?status=$status'),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Failed to add ticket for participant: ${response.body}, status code: ${response.statusCode}');
    }

    final responseData = json.decode(response.body);
    if (responseData['success'] == true) {
      LoggerService.logger.i('Ticket confirmed successfully');
    } else {
      throw Exception('Failed to confirm ticket: ${response.body}');
    }
  } catch (e) {
    throw Exception('Failed to add ticket for participant: $e');
  }
}

Future<List<Ticket>> fetchTickets() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    LoggerService.logger.e('Error: No user logged in');
    throw Exception('No user logged in');
  }

  String? idToken = await user.getIdToken();
  if (idToken == null) {
    LoggerService.logger.e('Error: Failed to retrieve ID token');
    throw Exception('Failed to retrieve ID token');
  }

  try {
    final response = await http.get(
      Uri.parse('${Config.baseUrl}/ticket-service/tickets/${user.uid}'),
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
      // LoggerService.logger.e('Data: $data');
      List<Ticket> tickets = (data['data'] as List<dynamic>)
          .map((ticketJson) =>
              Ticket.fromJson(ticketJson as Map<String, dynamic>))
          .toList();

      for (var ticket in tickets) {
        final eventData = await getEventData(ticket.eventId);

        ticket.eventName = eventData['data']['name'] ?? 'Unknown Event';
        ticket.eventBannerUrl =
            eventData['data']['banner'] ?? 'https://placehold.jp/150x150.png';
        ticket.startDate = eventData['data']['startDate'];
        ticket.eventStatus = eventData['data']['status'];

        //fetch feedback Cancel
        try {
          final responseCancel = await http.get(
            Uri.parse(
                '${Config.baseUrl}/ticket-service/feedback/get/${ticket.eventId}'),
            headers: {
              'Authorization': 'Bearer $idToken',
              'Content-Type': 'application/json',
            },
          );
          if (responseCancel.statusCode == 200) {
            Map<String, dynamic> dataCancel = json.decode(responseCancel.body);
            // LoggerService.logger.e('Data Cancel: $dataCancel');
            if (dataCancel['success'] == true) {
              if (dataCancel['data'] != null) {
                ticket.cancellationStartDate =
                    DateTime.parse(dataCancel['data']['start_date']);
                ticket.cancellationEndDate =
                    DateTime.parse(dataCancel['data']['end_date']);
                ticket.isReasonImageRequired =
                    dataCancel['data']['is_reason_image_required'];
                ticket.isLinkRequired = dataCancel['data']['is_link_required'];
                ticket.cancellationLink = dataCancel['data']['link'] ?? "";
              } else {
                ticket.isReasonImageRequired = false;
                ticket.isLinkRequired = false;
              }

              final responseCancel = await http.get(
                Uri.parse(
                    '${Config.baseUrl}/ticket-service/feedback/user-cancel/get/status?eventid=${ticket.eventId}&uid=${user.uid}'),
                headers: {
                  'Authorization': 'Bearer $idToken',
                  'Content-Type': 'application/json',
                },
              );
              if (responseCancel.statusCode == 200) {
                Map<String, dynamic> dataCancel =
                    json.decode(responseCancel.body);
                if (dataCancel['success'] == true) {
                  ticket.cancel_status = dataCancel['data'] ?? "None";
                }
              }
            }
          }
        } catch (e) {
          LoggerService.logger.e('Error: $e');
          throw Exception('Error fetching ticket data: $e');
        }
      }

      return tickets;
    } else {
      return [];
    }
  } catch (e) {
    LoggerService.logger.e('Error: $e');
    throw Exception('Error fetching ticket data: $e');
  }
}

Future<void> updateCancelTicketStatus(List<String> uid, String status) async {
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
    final response = await http.put(
      Uri.parse(
          '${Config.baseUrl}/ticket-service/feedback/user-cancel/put/list-user/$status'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(uid),
    );

    if (response.statusCode == 200) {
      LoggerService.logger
          .i('Ticket cancellation request updated successfully');
    } else {
      LoggerService.logger.e('Failed to update ticket cancellation request');
    }
  } catch (e) {
    LoggerService.logger.e('Error: $e');
  }
}

Future<Map<String, dynamic>> getQrTicket(int eventid) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      LoggerService.logger.e('User not logged in');
      throw Exception('User not logged in');
    }
    String? token = await user.getIdToken();
    if (token == null) {
      LoggerService.logger.e('Token not found');
      throw Exception('Token not found');
    }
    final response = await http.get(
      Uri.parse(
          '${Config.baseUrl}/ticket-service/tickets/${user.uid}/qr/$eventid'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      return data['data'];
    } else {
      LoggerService.logger.e('Failed to fetch QR ticket');
      throw Exception(
          'Failed to fetch QR ticket. ${response.body}. ${response.statusCode}');
    }
  } catch (e) {
    LoggerService.logger.e('Error: $e');
    throw Exception('Error: $e');
  }
}
