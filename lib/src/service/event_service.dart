// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:event_management/config.dart';
import 'package:event_management/src/models/event_with_participants.dart';
import 'package:event_management/src/models/events.dart';
import 'package:event_management/src/service/logger_service.dart';
import 'package:event_management/src/service/participants.dart';
import 'package:event_management/src/service/user_service.dart';
import 'package:event_management/widget/dialog_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<int> createEvent(Event event, BuildContext context) async {
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
        // Assuming the backend returns the generated event ID
        int generatedEventId = responseData['data']['id'];

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

        // Return the generated event ID
        return generatedEventId;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create event. Please try again.'),
          ),
        );
        return 0;
      }
    } else {
      LoggerService.logger.w('Failed to create event: ${response.statusCode}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to create event 2. Please try again.'),
        ),
      );
      return 0;
    }
  } catch (e) {
    LoggerService.logger.w('Error: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('An error occurred. Please try again.'),
      ),
    );
    return 0;
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
            // 'role': userData['role'].toString(),
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

Future<List<Map<String, dynamic>>> fetchEventCompleted() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    LoggerService.logger.e('No user logged in');
    throw Exception('No user logged in');
  }

  String? idToken = await user.getIdToken();
  try {
    final response = await http.get(
        Uri.parse(
            '${Config.baseUrl}/event-service/review/get-event?uid=${user.uid}'),
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
            // 'role': userData['role'].toString(),
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

Future<Participant?> fetchParticipantRoleByUserIdAndEventId(int eventId) async {
  try {
    // Get the current user and their ID token
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
          '${Config.baseUrl}/event-service/participant/get-role?userId=${user.uid}&eventId=$eventId'),
      headers: {
        'Authorization': 'Bearer $idToken',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData['success'] == true) {
        final participantData = responseData['data'];
        LoggerService.logger.i(participantData);
        if (participantData != null) {
          Participant participant = Participant.fromJson(participantData);
          return participant;
        }
      } else {
        throw Exception(
            responseData['message'] ?? 'Failed to fetch participant role');
      }
    } else {
      LoggerService.logger.w(
          'Failed to fetch participant role: ${response.statusCode} ${response.body}');
      throw Exception('Failed to fetch participant role');
    }
  } catch (e) {
    LoggerService.logger.w('Error fetching participant role: $e');
    throw Exception('Failed to fetch participant role');
  }
  return null;
}

Future<List<Participant>> getParticipants(
    int id, String status, String role) async {
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
          '${Config.baseUrl}/event-service/event/$id/participants-status/$status/role/$role'),
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

Future<String> uploadImageEventToImageKit(
    File imageFile, int eventId, String fileName) async {
  const privateKey = 'private_F801T1Ot8g2c8BCrrN+7+y+Kvdc=';
  final base64EncodedKey = base64Encode(utf8.encode('$privateKey:'));

  final request = http.MultipartRequest(
    'POST',
    Uri.parse('https://upload.imagekit.io/api/v1/files/upload'),
  );
  request.headers['Authorization'] = 'Basic $base64EncodedKey';
  request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

  request.fields['fileName'] = fileName;
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

Future<Map<String, dynamic>> getStats(int eventId) async {
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
      Uri.parse('${Config.baseUrl}/event-service/event/data/$eventId/stats'),
      headers: {
        'Authorization': 'Bearer $idToken',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData['success'] == true) {
        // LoggerService.logger.i(responseData['data']);
        return responseData['data'];
      } else {
        throw Exception(
            responseData['message'] ?? 'Failed to fetch stats data');
      }
    } else {
      LoggerService.logger.w(
          'Failed to fetch stats data: ${response.statusCode} ${response.body}');
      throw Exception('Failed to fetch stats data');
    }
  } catch (e) {
    throw Exception('Failed to fetch stats data: $e');
  }
}

Future<void> cancelEvent(int eventId, BuildContext context) async {
  try {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hủy Event'),
          content: const Text('Bạn có muốn hủy Event này không?'),
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
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

      String? idToken = await user.getIdToken();
      if (idToken == null) {
        throw Exception('Failed to retrieve ID token');
      }

      final response = await http.put(
        Uri.parse('${Config.baseUrl}/event-service/event/$eventId/cancel'),
        headers: {
          'Authorization': 'Bearer $idToken',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return const DialogWidget(
                message: 'Sự kiện đã được hủy.',
                title: 'Notification',
              );
            },
          );
        } else {
          throw Exception(responseData['message'] ?? 'Không thể hủy sự kiện');
        }
      } else {
        LoggerService.logger.w(
            'Failed to cancel event: ${response.statusCode} ${response.body}');
        throw Exception(
            'Không thể hủy sự kiện: ${response.statusCode} ${response.body}');
      }
    } else {
      // Người dùng hủy hành động
      LoggerService.logger.e("Người dùng đã hủy việc hủy sự kiện");
    }
  } catch (e) {
    // Hiển thị lỗi
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Lỗi khi hủy sự kiện: $e')));
  }
}

Future<void> resetEvent(int eventId, BuildContext context) async {
  try {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Mở lại Event'),
          content: const Text('Bạn có muốn mở lại Event này không?'),
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
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

      String? idToken = await user.getIdToken();
      if (idToken == null) {
        throw Exception('Failed to retrieve ID token');
      }

      final response = await http.put(
        Uri.parse('${Config.baseUrl}/event-service/event/$eventId/reset'),
        headers: {
          'Authorization': 'Bearer $idToken',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return const DialogWidget(
                message: 'Sự kiện đã được mở lại.',
                title: 'Notification',
              );
            },
          );
        } else {
          throw Exception(responseData['message'] ?? 'Không thể mở sự kiện');
        }
      } else {
        LoggerService.logger.w(
            'Failed to reset event: ${response.statusCode} ${response.body}');
        throw Exception(
            'Không thể mở sự kiện: ${response.statusCode} ${response.body}');
      }
    } else {
      // Người dùng hủy hành động
      LoggerService.logger.e("Người dùng đã hủy việc mở sự kiện");
    }
  } catch (e) {
    // Hiển thị lỗi
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Lỗi khi hủy sự kiện: $e')));
  }
}

Future<Map<String, dynamic>> checkIn(int eventId, String qrCode) async {
  LoggerService.logger.i(
      'Entering checkIn function with eventId: $eventId and qrCode: $qrCode');

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

  final url =
      Uri.parse('${Config.baseUrl}/event-service/event/$eventId/checkin');
  LoggerService.logger.i('Making POST request to URL: $url');

  try {
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'QRCode': qrCode,
      }),
    );

    LoggerService.logger
        .i('Received response: ${response.statusCode} - ${response.body}');

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      LoggerService.logger.i('Response data: $responseData');
      if (responseData['success']) {
        return responseData;
      } else {
        throw Exception('Check-in failed: ${responseData['message']}');
      }
    } else {
      throw Exception('Failed to check in: ${response.body}');
    }
  } catch (error) {
    LoggerService.logger.e('Error during check-in: $error', error: error);
    throw Exception('Error during check-in: $error');
  }
}

Future<Map<String, dynamic>> checkOut(int eventId, String qrCode) async {
  LoggerService.logger.i(
      'Entering checkOut function with eventId: $eventId and qrCode: $qrCode');

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

  final url =
      Uri.parse('${Config.baseUrl}/event-service/event/$eventId/checkout');
  LoggerService.logger.i('Making POST request to URL: $url');

  try {
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
      body: json.encode({'qrCode': qrCode}),
    );

    LoggerService.logger
        .i('Received response: ${response.statusCode} - ${response.body}');

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      LoggerService.logger.i('Response data: $responseData');
      if (responseData['success']) {
        return responseData;
      } else {
        throw Exception('Check-out failed: ${responseData['message']}');
      }
    } else {
      throw Exception('Failed to check out: ${response.body}');
    }
  } catch (error) {
    LoggerService.logger.e('Error during check-out: $error', error: error);
    throw Exception('Error during check-out: $error');
  }
}

Future<void> addReview(int eventid, String content, int rating) async {
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
      Uri.parse('${Config.baseUrl}/event-service/review/add'),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'id':0,
        'eventid': eventid,
        'uid': user.uid,
        'rate': rating,
        'review': content,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['success'] == true) {
        LoggerService.logger.i('Review added successfully');
      } else {
        LoggerService.logger
            .w('Failed to add review: ${responseData['message']}');
        throw Exception('Failed to add review');
      }
    } else {
      LoggerService.logger.w(
          'HTTP error: ${response.body}, status: ${response.statusCode}');
      throw Exception('Failed to add review');
    }
  } catch (error) {
    LoggerService.logger.w('Error: $error');
    throw Exception('Failed to add review');
  }
}