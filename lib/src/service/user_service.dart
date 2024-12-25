// ignore_for_file: use_build_context_synchronously, no_leading_underscores_for_local_identifiers

import 'dart:convert';

import 'package:event_management/config.dart';
import 'package:event_management/src/service/logger_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

String uri = '${Config.baseUrl}/user-services';

Future<Map<String, dynamic>> getUserDetails() async {
  try {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String? idToken = await user.getIdToken();
      final response = await http.get(
        Uri.parse(
            '${Config.baseUrl}/user-services/api/Users/ProfileData?id=$idToken'),
        headers: {
          'Authorization': 'Bearer $idToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        return {
          'name': data['name'],
          'email': data['email'],
          'phone': data['phone'],
          'role': data['role'],
        };
      } else {
        throw Exception(
            'Failed to load user data, ${response.statusCode}, id: $idToken');
      }
    } else {
      throw Exception('No user logged in');
    }
  } catch (e) {
    rethrow;
  }
}

// ignore: non_constant_identifier_names
Future<String> GetRoleUser() async {
  try {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String? idToken = await user.getIdToken();
      final response = await http.get(
        Uri.parse(
            '${Config.baseUrl}/user-services/api/Users/ProfileData?id=$idToken'),
        headers: {
          'Authorization': 'Bearer $idToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        return data['role'];
      } else {
        throw Exception(
            'Failed to load user data, ${response.statusCode}, id: $idToken');
      }
    } else {
      throw Exception('No user logged in');
    }
  } catch (e) {
    rethrow;
  }
}

Future<void> updateUserProfile(BuildContext context, String newName,
    String newPhone, String _uploadedImageUrl) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String? idToken = await user.getIdToken();
      await user.updatePhotoURL(_uploadedImageUrl);
      final response = await http.put(
        Uri.parse(
            '${Config.baseUrl}/user-services/api/Users/UpdateProfile?name=$newName&phone=$newPhone'),
        headers: {
          'Authorization': 'Bearer $idToken',
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Faled')),
        );
      }
    } else {
      return;
    }
  } catch (e) {
    rethrow;
  }
}

Future<List<Map<String, dynamic>>> searchUser(String name) async {
  final String apiUrl =
      "${Config.baseUrl}/user-services/api/Users/SearchUser?name=$name";

  try {
    User? user = FirebaseAuth.instance.currentUser;
    String? idToken = await user?.getIdToken();

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $idToken',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      if (jsonData['data'] == null) {
        return [];
      }

      return List<Map<String, dynamic>>.from(
        jsonData['data'].map((item) => {
              'id': item['id'] ?? "",
              'name': item['name'] ?? "Unknown",
              'role': item['role'] ?? "No role",
              'avtUrl': item['avtUrl'] ?? "",
            }),
      );
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  } catch (e) {
    LoggerService.logger.e("Error occurred: $e");
    throw Exception("Error occurred: $e");
  }
}

Future<Map<String, dynamic>> getUserData(String userId) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('No user logged in');
    }

    String? idToken = await user.getIdToken();
    final response = await http.get(
      Uri.parse(
          '${Config.baseUrl}/user-services/api/Users/GetUserById?userId=$userId'),
      headers: {
        'Authorization': 'Bearer $idToken',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (responseData['success'] == true) {
        final Map<String, dynamic> user = responseData['data'];

        return {
          'name': user['name'] ?? 'Unknown',
          'role': user['role'] ?? 'Unknown',
          'photoUrl': user['avtUrl'] ??
              'https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png',
        };
      } else {
        throw Exception(responseData['message'] ?? 'Failed to fetch user data');
      }
    } else {
      LoggerService.logger
          .e('HTTP error: ${response.statusCode} ${response.body}');
      throw Exception('Failed to fetch user data');
    }
  } catch (e) {
    LoggerService.logger.e('Error fetching user data: $e');
    return {
      'name': 'Unknown',
      'role': 'Unknown',
      'photoUrl': 'default-avatar-url',
    };
  }
}
