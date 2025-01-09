import 'dart:convert';

import 'package:event_management/config.dart';
import 'package:event_management/src/service/logger_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

Future<void> createPost(
    String title, String description, String category, String image) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }
    String? idToken = await user.getIdToken();
    final response = await http.post(
      Uri.parse('${Config.baseUrl}/forum-service/forum/create-post'),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'id': 0,
        'title': title,
        'description': description,
        'category': category,
        'uid': user.uid,
        'timePost': DateTime.now().toIso8601String(),
        'likes': 0,
        'commentsCount': 0,
        'image': image,
      }),
    );
    if (response.statusCode == 200) {
      LoggerService.logger.i('Create post request successful');
    } else {
      LoggerService.logger.e('Failed to create post: ${response.body}');
    }
  } catch (e) {
    LoggerService.logger.e('Failed to create post: $e');
  }
}

Future<List<Map<String, dynamic>>> getPosts() async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }
    String? idToken = await user.getIdToken();
    final response = await http.get(
      Uri.parse('${Config.baseUrl}/forum-service/forum/get-post/${user.uid}'),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      LoggerService.logger.i('Get posts request successful');
      Map<String, dynamic> posts = jsonDecode(response.body);

      List<Map<String, dynamic>> postList =
          List<Map<String, dynamic>>.from(posts['data']);

      return postList;
    } else {
      LoggerService.logger.e('Failed to get posts: ${response.body}');
      return [];
    }
  } catch (e) {
    LoggerService.logger.e('Failed to get posts: $e');
    return [];
  }
}

Future<void> updateLike(int id, bool isLike) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }
    String? idToken = await user.getIdToken();
    final response = await http.put(
      Uri.parse(
          '${Config.baseUrl}/forum-service/forum/update-like/$id/$isLike'),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      LoggerService.logger.i('Update like successful');
    } else {
      LoggerService.logger.e('Failed to update: ${response.body}');
    }
  } catch (e) {
    LoggerService.logger.e('Failed to update: $e');
  }
}

Future<Map<String, dynamic>> getDetailPost(int id) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }
    String? idToken = await user.getIdToken();
    final response = await http.get(
      Uri.parse(
          '${Config.baseUrl}/forum-service/forum/detail-post/$id/${user.uid}'),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      LoggerService.logger.i('Get detail post request successful');
      Map<String, dynamic> post = jsonDecode(response.body);
      return post['data'];
    } else {
      LoggerService.logger.e('Failed to get detail post: ${response.body}');
      return {};
    }
  } catch (e) {
    LoggerService.logger.e('Failed to get detail post: $e');
    return {};
  }
}
