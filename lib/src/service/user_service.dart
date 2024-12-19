// ignore_for_file: use_build_context_synchronously

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

Future<void> updateUserProfile(
    BuildContext context, String newName, String newPhone) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String? idToken = await user.getIdToken();

      const String avtarUrl =
          'https://s3.getstickerpack.com/storage/uploads/sticker-pack/honkai-star-rail-hsr-then-wake-to-weep/sticker_2.png?d0ec19664277d77e2c85423a8d8f781d&d=200x200';
      await user.updatePhotoURL(avtarUrl);

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
          const SnackBar(content: Text('Faile')),
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
        LoggerService.logger.e('No data available');
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
