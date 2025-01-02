// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:event_management/config.dart';
import 'package:event_management/src/models/event_with_participants.dart';
import 'package:event_management/src/models/events.dart';
import 'package:event_management/src/models/tickets.dart';
import 'package:event_management/src/service/logger_service.dart';
import 'package:event_management/src/service/participants.dart';
import 'package:event_management/src/service/user_service.dart';
import 'package:event_management/widget/dialog_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<void> createEvent(Event event, BuildContext context) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user logged in');
    }
    String? idToken = await user.getIdToken();
    final response = await http.post(
      Uri.parse('${Config.baseUrl}/event-service/create-event'),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
      body: json.encode(event.toJson()),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Success to create event.'),
        ),
      );
      if (responseData['success'] == true) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Tạo sự kiện thành công'),
              content: const Text('Sự kiện đã được tạo thành công.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create event. Please try again.'),
          ),
        );
      }
    } else {
      LoggerService.logger.w('Failed to create event: ${response.statusCode}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to create event 2. Please try again.'),
        ),
      );
    }
  } catch (e) {
    LoggerService.logger.w('Error: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('An error occurred. Please try again.'),
      ),
    );
  }
}

Future<List<Event>> fetchEvents() async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user logged in');
    }
    String? idToken = await user.getIdToken();
    final response = await http.get(
      Uri.parse('${Config.baseUrl}/event-service/get-event'),
      headers: {
        'Authorization': 'Bearer $idToken',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final List<dynamic> eventsData = responseData['data'] ?? [];

      final List<Event> events = eventsData
          .map((event) => Event.fromJson(event as Map<String, dynamic>))
          .toList();
      return events;
    } else {
      LoggerService.logger.w('Failed to fetch events: ${response.statusCode}');
      return [];
    }
  } catch (e) {
    LoggerService.logger.w('Error: $e');
    return [];
  }
}

Future<void> deleteEvent(int idEvent, BuildContext context) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('No user logged in');
    }

    String? idToken = await user.getIdToken();

    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Event'),
          content: const Text('Are you sure you want to delete this event?'),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirmed != null && confirmed) {
      final response = await http.delete(
        Uri.parse('${Config.baseUrl}/event-service/delete/$idEvent'),
        headers: {
          'Authorization': 'Bearer $idToken',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return const DialogWidget(
                message: 'Delete event successfully!',
                title: 'Notification',
              );
            },
          );
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return const DialogWidget(
                message: 'Failed to delete event!',
                title: 'Notification',
              );
            },
          );
          throw Exception('Failed to delete event');
        }
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const DialogWidget(
              message: 'Failed to delete event!',
              title: 'Notification',
            );
          },
        );
        throw Exception('Failed to delete event');
      }
    }
  } catch (e) {
    LoggerService.logger.w('Error: $e');
    throw Exception('Failed to delete event');
  }
}

Future<String> getIdEvent(String name) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user logged in');
    }
    String? idToken = await user.getIdToken();
    final response = await http.get(
      Uri.parse(
          '${Config.baseUrl}/event-service/getid?idCreate=${user.uid}&name=$name'),
      headers: {
        'Authorization': 'Bearer $idToken',
      },
    );
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return responseData['data'];
    } else {
      throw Exception('Failed to get event id');
    }
  } catch (e) {
    LoggerService.logger.w('Error: $e');
    throw Exception('Failed to get event id');
  }
}

Future<void> updateEvent(Event event, BuildContext context) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user logged in');
    }
    String? idToken = await user.getIdToken();

    final response = await http.put(
      Uri.parse('${Config.baseUrl}/event-service/${event.id}'),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
      body: json.encode(event.toJson()),
    );
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['success'] == true) {
        LoggerService.logger.i('Event updated successfully');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update event.')),
        );
        LoggerService.logger
            .w('Failed to update event: ${responseData['message']}');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update event.')),
      );
      LoggerService.logger.w('HTTP error: ${response.body}');
    }
  } catch (error) {
    LoggerService.logger.w('Error: $error');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('An error occurred. Please try again.')),
    );
  }
}

Future<Event> fetchEventByEventId(int id) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user logged in');
    }

    String? idToken = await user.getIdToken();
    if (idToken == null) {
      throw Exception('Failed to retrieve ID token');
    }

    final response = await http.get(
      Uri.parse('${Config.baseUrl}/event-service/event/$id'),
      headers: {
        'Authorization': 'Bearer $idToken',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData['success'] == true) {
        return Event.fromJson(responseData['data']);
      } else {
        throw Exception(
            responseData['message'] ?? 'Failed to fetch event data');
      }
    } else {
      LoggerService.logger.w(
          'Failed to fetch event by ID: ${response.statusCode} ${response.body}');
      throw Exception('Failed to fetch event by ID');
    }
  } catch (e) {
    throw Exception('Failed to fetch event by ID');
  }
}

Future<List<Event>> fetchEventById(String id) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      LoggerService.logger.e('User is not logged in.');
      throw Exception('No user logged in');
    }

    String? idToken = await user.getIdToken();

    final response = await http.get(
      Uri.parse('${Config.baseUrl}/event-service/get-register-event?uid=$id'),
      headers: {
        'Authorization': 'Bearer $idToken',
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final List<dynamic> eventsData = responseData['data'] ?? [];
      final List<Event> events = eventsData
          .map((event) => Event.fromJson(event as Map<String, dynamic>))
          .toList();
      return events;
    } else {
      throw Exception(
          'Failed to fetch event by ID: ${response.body}, status: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Failed to fetch event by ID: $e');
  }
}

Future<void> addEventToSchedule(
    int eventId, Map<String, dynamic> newEvent) async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    LoggerService.logger.e('No user logged in');
    throw Exception('No user logged in');
  }

  String? idToken = await user.getIdToken();
  try {
    final response = await http.post(
      Uri.parse(
          '${Config.baseUrl}/event-service/event/$eventId/create-schedule'),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
      body: json.encode(newEvent),
    );

    if (response.statusCode != 200) {
      LoggerService.logger.e('Failed to add event: ${response.body}');
      throw Exception('Failed to add event');
    }
  } catch (error, stackTrace) {
    LoggerService.logger.e('Error adding event $error, $stackTrace');
    rethrow;
  }
}

Future<void> updateEventInSchedule(
    int eventId, Map<String, dynamic> updatedEvent) async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    LoggerService.logger.e('No user logged in');
    throw Exception('No user logged in');
  }

  String? idToken = await user.getIdToken();
  try {
    final response = await http.put(
      Uri.parse('${Config.baseUrl}/event-service/event/$eventId/schedules'),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
      body: json.encode(updatedEvent),
    );
    if (response.statusCode != 200) {
      LoggerService.logger
          .e('Failed to update schedule: ${response.statusCode}');
      throw Exception('Failed to update event');
    }
  } catch (error, stackTrace) {
    LoggerService.logger.e('Error adding schedule: $error, $stackTrace');
    rethrow;
  }
}

Future<List<Map<String, dynamic>>> fetchSchedulesForEvent(int eventId) async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    LoggerService.logger.e('No user logged in');
    throw Exception('No user logged in');
  }

  String? idToken = await user.getIdToken();
  try {
    final response = await http.get(
        Uri.parse('${Config.baseUrl}/event-service/event/$eventId/schedules'),
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        });

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = json.decode(response.body);

      if (responseBody['success'] == true) {
        return List<Map<String, dynamic>>.from(responseBody['data']);
      } else {
        throw Exception(responseBody['message'] ?? 'Failed to fetch schedules');
      }
    } else {
      throw Exception('Failed to fetch schedules: ${response.reasonPhrase}');
    }
  } catch (e) {
    throw Exception('Error fetching schedules: $e');
  }
}

Future<void> deleteSchedule(int scheduleId) async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    LoggerService.logger.e('No user logged in');
    throw Exception('No user logged in');
  }

  String? idToken = await user.getIdToken();
  try {
    final response = await http.delete(
      Uri.parse('${Config.baseUrl}/event-service/schedule/$scheduleId'),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      LoggerService.logger
          .e('Failed to delete schedule: ${response.statusCode}');
      throw Exception('Failed to delete schedule');
    }

    LoggerService.logger.i('Schedule deleted successfully');
  } catch (error, stackTrace) {
    LoggerService.logger.e('Error deleting schedule: $error, $stackTrace');
    rethrow;
  }
}

Future<List<Map<String, dynamic>>> fetchEventCanRegister() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    LoggerService.logger.e('No user logged in');
    throw Exception('No user logged in');
  }

  String? idToken = await user.getIdToken();
  try {
    final response = await http.get(
        Uri.parse('${Config.baseUrl}/event-service/event/can-register'),
        headers: {
          'Authorization': 'Bearer $idToken',
        });
    final isRegistered = await fetchStatusEventRegister(user.uid);

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = json.decode(response.body);

      if (responseBody['success'] == true) {
        List<Map<String, dynamic>> data =
            List<Map<String, dynamic>>.from(responseBody['data']);
        for (var i in data) {
          final userData = await getUserData(i['idCreate']);
          i['user'] = {
            'name': userData['name'].toString(),
            'role': userData['role'].toString(),
            'photoUrl': userData['photoUrl'].toString(),
          };
          if (isRegistered.isNotEmpty) {
            for (var user in isRegistered) {
              if (user['id'].toString() == i['id'].toString()) {
                i['isRegistered'] = user['status'];
              }
            }
          }
        }
        return data;
      } else {
        throw Exception(responseBody['message'] ?? 'Failed to fetch schedules');
      }
    } else {
      LoggerService.logger
          .e('Failed to fetch schedules: ${response.reasonPhrase}');
      throw Exception('Failed to fetch : ${response.reasonPhrase}');
    }
  } catch (e) {
    LoggerService.logger.e('Error fetching data: $e');
    throw Exception('$e');
  }
}

Future<void> deleteParticipantsFromEvent(
    int eventId, int participantId, String role) async {
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
          '${Config.baseUrl}/event-service/event/$eventId/participants/$participantId/role/$role'),
      headers: {
        'Authorization': 'Bearer $idToken',
      },
    );

    if (response.statusCode == 200) {
      LoggerService.logger.i('Participant deleted successfully');
    } else {
      LoggerService.logger
          .w('Failed to delete participant: ${response.statusCode}');
      throw Exception('Failed to delete participant');
    }
  } catch (e) {
    LoggerService.logger.e('Error deleting participant: $e');
  }
}

Future<List<Participant>> fetchParticipantsByEventIdAndRole(
    int eventId, String role) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user logged in');
    }

    String? idToken = await user.getIdToken();
    if (idToken == null) {
      throw Exception('Failed to retrieve ID token');
    }

    final response = await http.get(
      Uri.parse(
          '${Config.baseUrl}/event-service/event/$eventId/participants/$role'),
      headers: {
        'Authorization': 'Bearer $idToken',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 404) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData['success'] == true) {
        List<dynamic> participantsJson = responseData['data'];
        List<Participant> participants =
            participantsJson.map((json) => Participant.fromJson(json)).toList();

        for (var participant in participants) {
          final userData = await getUserData(participant.userId);

          participant.name = userData['name'];
          participant.photoUrl = userData['photoUrl'];
        }

        return participants;
      } else {
        throw Exception(
            responseData['message'] ?? 'Failed to fetch participants');
      }
    } else {
      LoggerService.logger.w(
          'Failed to fetch participants: ${response.statusCode} ${response.body}');
      throw Exception('Failed to fetch participants');
    }
  } catch (e) {
    throw Exception('Failed to fetch participants');
  }
}

Future<List<Participant>> getStatusParticipants(int id, String status) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user logged in');
    }

    String? idToken = await user.getIdToken();
    if (idToken == null) {
      throw Exception('Failed to retrieve ID token');
    }

    final response = await http.get(
      Uri.parse(
          '${Config.baseUrl}/event-service/event/$id/participants-status/$status'),
      headers: {
        'Authorization': 'Bearer $idToken',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData['success'] == true) {
        List<dynamic> participantsJson = responseData['data'];
        List<Participant> participants =
            participantsJson.map((json) => Participant.fromJson(json)).toList();

        for (var participant in participants) {
          final userData = await getUserData(participant.userId);

          participant.name = userData['name'];
          participant.photoUrl = userData['photoUrl'];
        }

        return participants;
      } else {
        throw Exception(
            responseData['message'] ?? 'Failed to fetch participants');
      }
    } else {
      LoggerService.logger.w(
          'Failed to fetch participants: ${response.statusCode} ${response.body}');
      throw Exception('Failed to fetch participants');
    }
  } catch (e) {
    throw Exception('Failed to fetch participants');
  }
}

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
        await addTicketForParticipant(eventId, userId);
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

Future<void> updateEventAccess(int eventId, bool newAccess) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user logged in');
    }

    String? idToken = await user.getIdToken();

    final response = await http.put(
      Uri.parse(
          '${Config.baseUrl}/event-service/event/$eventId/access?access=$newAccess'),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['success'] == true) {
        LoggerService.logger.i('Event access updated successfully: $newAccess');
      } else {
        LoggerService.logger
            .w('Failed to update event access: ${responseData['message']}');
      }
    } else {
      LoggerService.logger.w(
          'HTTP error: ${response.body}, status: ${response.statusCode}, eventId: $eventId');
    }
  } catch (error) {
    LoggerService.logger.w('Error: $error');
  }
}

Future<void> updateEventAllow(int eventId, bool newAllow) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user logged in');
    }

    String? idToken = await user.getIdToken();

    final response = await http.put(
      Uri.parse(
          '${Config.baseUrl}/event-service/event/$eventId/allow?allow=$newAllow'),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['success'] == true) {
        LoggerService.logger.i('Event allow updated successfully: $newAllow');
      } else {
        LoggerService.logger
            .w('Failed to update event allow: ${responseData['message']}');
      }
    } else {
      LoggerService.logger.w(
          'HTTP error: ${response.body}, status: ${response.statusCode}, eventId: $eventId');
    }
  } catch (error) {
    LoggerService.logger.w('Error: $error');
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

Future<void> addTicketForParticipant(int eventId, String userId) async {
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
          '${Config.baseUrl}/ticket-service/event/$eventId/add-tickets/$userId'),
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

Future<List<Ticket>> fetchTickets(String userId) async {
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
      Uri.parse('${Config.baseUrl}/ticket-service/tickets/$userId'),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);

      List<Ticket> tickets =
          data.map((ticketJson) => Ticket.fromJson(ticketJson)).toList();

      for (var ticket in tickets) {
        final eventData = await getEventData(ticket.eventId);

        ticket.eventName = eventData['data']['name'] ?? 'Unknown Event';
        ticket.eventBannerUrl =
            eventData['data']['banner'] ?? 'https://placehold.jp/150x150.png';
        ticket.startDate = eventData['data']['startDate'];
        ticket.eventStatus = eventData['data']['status'];
      }

      return tickets;
    } else {
      LoggerService.logger.e(
          'Failed to load tickets, body: ${response.body}, status code: ${response.statusCode}');
      throw Exception('Failed to load tickets');
    }
  } catch (e) {
    LoggerService.logger.e('Error: $e');
    throw Exception('Error fetching ticket data: $e');
  }
}

Future<Map<String, dynamic>> getEventData(int eventId) async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    throw Exception('No user logged in');
  }

  String? idToken = await user.getIdToken();
  if (idToken == null) {
    throw Exception('Failed to retrieve ID token');
  }
  final url = Uri.parse('${Config.baseUrl}/event-service/event/data/$eventId');
  try {
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $idToken',
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    } else {
      throw Exception(
          'Failed to load event data: ${response.body}, status: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error fetching event data: $e');
  }
}

Future<String> uploadImageEventToImageKit(File imageFile, int eventId) async {
  const privateKey = 'private_F801T1Ot8g2c8BCrrN+7+y+Kvdc=';
  final base64EncodedKey = base64Encode(utf8.encode('$privateKey:'));
  User? user = FirebaseAuth.instance.currentUser;

  final request = http.MultipartRequest(
    'POST',
    Uri.parse('https://upload.imagekit.io/api/v1/files/upload'),
  );
  request.headers['Authorization'] = 'Basic $base64EncodedKey';
  request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

  request.fields['fileName'] = 'event_${eventId}_profile_pic_${user!.uid}.jpg';
  request.fields['useUniqueFileName'] = 'false';
  request.fields['folder'] = '/event_images';

  final response = await request.send();

  if (response.statusCode == 200) {
    final responseData = await response.stream.bytesToString();
    final decodedData = json.decode(responseData);
    final imageUrl = decodedData['url'];

    LoggerService.logger.i("Image uploaded successfully. URL: $imageUrl");

    return imageUrl;
  } else {
    final responseData = await response.stream.bytesToString();
    LoggerService.logger
        .e('Failed to upload image: ${response.statusCode}, $responseData');
    throw Exception('Failed to upload image ${response.statusCode}');
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
