// ignore_for_file: avoid_web_libraries_in_flutter, use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
// import 'dart:convert';
import 'dart:js_util' as js_util;
import 'package:event_management/config.dart';
import 'package:event_management/src/web-screen/auth/login.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:event_management/src/service/logger_service.dart';
import 'package:http/http.dart' as http;
import 'package:event_management/src/service/logger_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Future<String> uploadImageToImageKitWebVersion(
    String base64ImageData, String folderName) async {
  const privateKey = 'private_F801T1Ot8g2c8BCrrN+7+y+Kvdc=';
  final base64EncodedKey = base64Encode(utf8.encode('$privateKey:'));
  User? user = FirebaseAuth.instance.currentUser;

  // Remove the base64 prefix if it exists (data:image/jpeg;base64,)
  String imageData = base64ImageData.replaceFirst(
      RegExp(r"^data:image\/[a-zA-Z]+;base64,"), "");

  // Create a FormData object to upload the image as multipart form data
  final request = html.FormData();

  // Convert the cleaned base64 image data to Blob
  final imageBlob = html.Blob([base64Decode(imageData)]);

  // Append the file and other fields to the request
  request.appendBlob('file', imageBlob, 'profile_pic_${user!.uid}.jpg');
  request.append('fileName', 'profile_pic_${user.uid}.jpg');
  request.append('useUniqueFileName', 'false');
  request.append('folder', "/$folderName");

  // Create an XMLHttpRequest to send the form data
  final xhr = html.HttpRequest();
  final uri = Uri.parse('https://upload.imagekit.io/api/v1/files/upload');
  xhr.open('POST', uri.toString());
  xhr.setRequestHeader('Authorization', 'Basic $base64EncodedKey');

  // Send the request and handle the response
  final completer = Completer<String>();
  xhr.onLoadEnd.listen((e) {
    if (xhr.status == 200) {
      final response = json.decode(xhr.responseText!);
      final imageUrl = response['url'];
      LoggerService.logger.i("Image uploaded successfully. URL: $imageUrl");
      completer.complete(imageUrl);
    } else {
      LoggerService.logger
          .e('Failed to upload image: ${xhr.status}, ${xhr.responseText}');
      completer.completeError('Failed to upload image');
    }
  });

  xhr.send(request);

  return completer.future;
}

Future<String> uploadDocumentsToImageKitWebVersion(
    String base64ImageData, String folder, String fileName) async {
  const privateKey = 'private_F801T1Ot8g2c8BCrrN+7+y+Kvdc=';
  final base64EncodedKey = base64Encode(utf8.encode('$privateKey:'));

  // Remove the base64 prefix if it exists (e.g., data:image/jpeg;base64,)
  String imageData = base64ImageData.replaceFirst(
      RegExp(r"^data:image\/[a-zA-Z]+;base64,"), "");

  // Create a FormData object to upload the image as multipart form data
  final request = html.FormData();

  // Convert the cleaned base64 image data to Blob
  final imageBlob = html.Blob([base64Decode(imageData)]);

  // Append the file and other fields to the request
  request.appendBlob('file', imageBlob, fileName);
  request.append('fileName', fileName);
  request.append('useUniqueFileName', 'false');
  request.append('folder', folder);

  // Create an XMLHttpRequest to send the form data
  final xhr = html.HttpRequest();
  final uri = Uri.parse('https://upload.imagekit.io/api/v1/files/upload');
  xhr.open('POST', uri.toString());
  xhr.setRequestHeader('Authorization', 'Basic $base64EncodedKey');

  // Send the request and handle the response
  final completer = Completer<String>();
  xhr.onLoadEnd.listen((e) {
    if (xhr.status == 200) {
      final response = json.decode(xhr.responseText!);
      final imageUrl = response['url'];
      LoggerService.logger.i("Image uploaded successfully. URL: $imageUrl");
      completer.complete(imageUrl);
    } else {
      LoggerService.logger
          .e('Failed to upload image: ${xhr.status}, ${xhr.responseText}');
      completer.completeError('Failed to upload image');
    }
  });

  xhr.send(request);

  return completer.future;
}

Future<void> logoutWeb(BuildContext context) async {
  try {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const WebLoginScreen()),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error during logout: $e')),
    );
  }
}

//login web

Future<void> loginWithGoogleWeb(BuildContext context) async {
  try {
    await FirebaseAuth.instance.signOut();

    final GoogleAuthProvider googleProvider = GoogleAuthProvider();

    final UserCredential userCredential =
        await FirebaseAuth.instance.signInWithPopup(googleProvider);

    if (userCredential.user == null) {
      throw Exception("User not authenticated with Google.");
    }

    String? idToken = await userCredential.user?.getIdToken();

    if (idToken == null) {
      throw Exception("Failed to get ID token from Firebase.");
    }

    final Map<String, String> userData = {
      'Id': idToken,
      'Name': userCredential.user?.displayName ?? 'No Name',
      'NameFromEmail':
          userCredential.user?.email?.split('@')[0] ?? 'No Name From Email',
      'Email': userCredential.user?.email ?? 'No Email',
      'Phone': userCredential.user?.phoneNumber ?? 'No Phone',
    };

    final response = await http.post(
      Uri.parse(
          '${Config.baseUrl}/user-services/api/Users/register-via-social'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(userData),
    );

    if (response.statusCode != 200) {
      LoggerService.logger.e("Error registering user: ${response.body}");
      throw Exception("Registration failed, please try again.");
    }

    final loginResponse = await http.get(
      Uri.parse(
          '${Config.baseUrl}/user-services/api/Users/login?firebaseIdToken=$idToken'),
    );

    if (loginResponse.statusCode == 200) {
      final responseData = json.decode(loginResponse.body);
      if (responseData['success'] == true && responseData['data'] != null) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to login: ${responseData['message']}')));
      }
    } else {
      throw Exception("Backend login request failed: ${loginResponse.body}");
    }
  } catch (e) {
    LoggerService.logger.e("Google Login Error: $e");
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred during Google login: $e')));
  }
}

Future<void> signInWithFacebookWeb(BuildContext context) async {
  try {
    // Wait until the Facebook SDK is loaded
    while (!(js_util.hasProperty(js_util.globalThis, 'FB') &&
        js_util.getProperty(js_util.globalThis, 'FB') != null)) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    // Get the Facebook SDK object
    final fb = js_util.getProperty(js_util.globalThis, 'FB');

    // Call the Facebook Login function with allowInterop
    js_util.callMethod(fb, 'login', [
      js_util.allowInterop((response) async {
        if (js_util.getProperty(response, 'status') == 'connected') {
          final authResponse = js_util.getProperty(response, 'authResponse');
          final accessToken = js_util.getProperty(authResponse, 'accessToken');
          LoggerService.logger
              .i('Facebook Login Success. Access Token: $accessToken');

          // Use the access token with Firebase Authentication
          final idToken = await _signInWithFirebase(accessToken);

          // Send the ID token to your backend
          if (idToken != null) {
            await _sendIdTokenToBackend(context, idToken);
          }
        } else {
          LoggerService.logger.e('Facebook login canceled or failed.');
        }
      }),
      {'scope': 'email'} // Request additional permissions as needed
    ]);
  } catch (e) {
    LoggerService.logger.e('Facebook Login Failed: $e');
  }
}

Future<String?> _signInWithFirebase(String accessToken) async {
  try {
    // Create a Facebook Auth credential using the access token
    final OAuthCredential credential =
        FacebookAuthProvider.credential(accessToken);

    // Sign in to Firebase with the credential
    final UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

    LoggerService.logger
        .i('Firebase login successful for user: ${userCredential.user?.email}');

    // Get the ID token
    return await userCredential.user?.getIdToken();
  } catch (e) {
    LoggerService.logger.e('Firebase login failed: $e');
    return null;
  }
}

Future<void> _sendIdTokenToBackend(BuildContext context, String idToken) async {
  try {
    final response = await http.post(
      Uri.parse(
          '${Config.baseUrl}/user-services/api/Users/register-via-social'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'Id': idToken,
        'Name': FirebaseAuth.instance.currentUser?.displayName,
        'NameFromEmail':
            FirebaseAuth.instance.currentUser?.email?.split('@')[0],
        'Email': FirebaseAuth.instance.currentUser?.email,
        'Phone': FirebaseAuth.instance.currentUser?.phoneNumber ?? '',
      }),
    );

    if (response.statusCode == 200) {
      final loginResponse = await http.get(
        Uri.parse(
            '${Config.baseUrl}/user-services/api/Users/login?firebaseIdToken=$idToken'),
      );

      if (loginResponse.statusCode == 200) {
        final responseData = json.decode(loginResponse.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                  'Failed to login: ${responseData['message'] ?? 'Unknown error'}')));
        }
      } else {
        LoggerService.logger.e('Login request failed: ${loginResponse.body}');
      }
    } else {
      LoggerService.logger.e('Registration request failed: ${response.body}');
    }
  } catch (e) {
    LoggerService.logger.e('Error sending ID token to backend: $e');
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('An error occurred while communicating with the server.'),
    ));
  }
}

Future<void> signInWithEmailPasswordWed(
    BuildContext context, String email, String password) async {
  try {
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email and password!')),
      );
      return;
    } else if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Password must be at least 6 characters!')),
      );
      return;
    } else if (!email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email!')),
      );
      return;
    }

    final UserCredential userCredential =
        await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (userCredential.user != null) {
      Navigator.pushNamed(context, '/home');
    }

  } on FirebaseAuthException {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Login failed: Check your email and password')));
  }
}