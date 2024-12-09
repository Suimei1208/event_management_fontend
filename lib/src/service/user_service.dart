// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:event_management/config.dart';
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
