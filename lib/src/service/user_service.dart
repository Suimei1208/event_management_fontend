// ignore_for_file: use_build_context_synchronously, no_leading_underscores_for_local_identifiers, non_constant_identifier_names

import 'dart:convert';
import 'dart:io';

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

Future<String> GetNameUser() async {
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
        return data['name'];
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

Future<String> GetIdUser() async {
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
        return data['id'];
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
      'photoUrl':
          'https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png',
    };
  }
}

Future<String> uploadImageToImageKit(File imageFile) async {
  const privateKey = 'private_F801T1Ot8g2c8BCrrN+7+y+Kvdc=';
  final base64EncodedKey = base64Encode(utf8.encode('$privateKey:'));
  User? user = FirebaseAuth.instance.currentUser;

  final request = http.MultipartRequest(
    'POST',
    Uri.parse('https://upload.imagekit.io/api/v1/files/upload'),
  );
  request.headers['Authorization'] = 'Basic $base64EncodedKey';
  request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
  request.fields['fileName'] = 'profile_pic_${user!.uid}.jpg';
  request.fields['useUniqueFileName'] = 'false';
  request.fields['folder'] = '/profile_pictures';

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
