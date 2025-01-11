// ignore_for_file: use_build_context_synchronously, empty_catches

import 'dart:convert';

import 'package:event_management/config.dart';
import 'package:event_management/src/mobile_screen/auth/login.dart';
import 'package:event_management/src/service/logger_service.dart';
import 'package:event_management/src/web-screen/login.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

String uri = '${Config.baseUrl}/user-services';

Future<void> loginWithFacebook(BuildContext context) async {
  try {
    final LoginResult result = await FacebookAuth.instance.login();

    if (result.status == LoginStatus.success) {
      final AuthCredential credential =
          FacebookAuthProvider.credential(result.accessToken!.tokenString);

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      String? idToken = await userCredential.user?.getIdToken();

      if (idToken == null) {
        throw Exception("Failed to get ID token.");
      }

      final response = await http.post(
        Uri.parse(
            '${Config.baseUrl}/user-services/api/Users/register-via-social'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'Id': idToken,
          'Name': userCredential.user?.displayName,
          'NameFromEmail': userCredential.user?.email?.split('@')[0],
          'Email': userCredential.user?.email,
          'Phone': userCredential.user?.phoneNumber ?? '',
        }),
      );

      if (response.statusCode == 200) {
        final response = await http.get(
          Uri.parse(
              '${Config.baseUrl}/user-services/api/Users/login?firebaseIdToken=$idToken'),
        );

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          if (responseData['success'] == true && responseData['data'] != null) {
            Navigator.pushReplacementNamed(context, '/home');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Failed to login: ${responseData['message']}')));
          }
        }
      } else {
        LoggerService.logger.e("Error: ${response.body}");
      }
    } else {
      LoggerService.logger.e("Facebook Login failed: ${result.status}");
    }
  } catch (e) {
    LoggerService.logger.e("Facebook Login Error: $e");
  }
}

Future<void> loginWithGoogle(BuildContext context) async {
  try {
    // Trigger the Google Sign-In flow
    final GoogleAuthProvider googleProvider = GoogleAuthProvider();

    // Use Firebase's sign-in method
    final UserCredential userCredential =
        await FirebaseAuth.instance.signInWithPopup(googleProvider);

    // Get ID token to send to your backend
    String? idToken = await userCredential.user?.getIdToken();

    if (idToken == null) {
      throw Exception("Failed to get ID token.");
    }

    // Send the ID token to your backend
    final response = await http.post(
      Uri.parse(
          '${Config.baseUrl}/user-services/api/Users/register-via-social'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'Id': idToken,
        'Name': userCredential.user?.displayName,
        'NameFromEmail': userCredential.user?.email?.split('@')[0],
        'Email': userCredential.user?.email,
        'Phone': userCredential.user?.phoneNumber ?? '',
      }),
    );

    if (response.statusCode == 200) {
      // After registering, login via backend
      final response = await http.get(
        Uri.parse(
            '${Config.baseUrl}/user-services/api/Users/login?firebaseIdToken=$idToken'),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to login: ${responseData['message']}'),
          ));
        }
      }
    } else {
      LoggerService.logger
          .e("Error: ${response.body}, status: ${response.statusCode}");
    }
  } catch (e) {
    LoggerService.logger.e("Google Login Error: $e");
  }
}

Future<void> signInWithEmailPassword(
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
      // final User user = userCredential.user!;

      // Check if the email is verified
      // if (!user.emailVerified) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(
      //       content: Text(
      //           'Your email is not verified. Please verify your email before logging in.'),
      //     ),
      //   );
      //   return;
      // }

      // final idToken = await user.getIdToken();
      // final response = await http.get(
      //   Uri.parse(
      //       '${Config.baseUrl}/user-services/api/Users/login?firebaseIdToken=$idToken'),
      // );

      // if (response.statusCode == 200) {
      //   final responseData = json.decode(response.body);
      //   if (responseData['success'] == true && responseData['data'] != null) {
      //     final role = responseData['data']['role'];

      //     if (role == "None") {
      //       Navigator.pushNamed(context, '/role');
      //     } else {
      Navigator.pushNamed(context, '/home');
    }
    //     } else {
    //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //           content: Text('Failed to get role: ${responseData['message']}')));
    //     }
    //   } else {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //         SnackBar(content: Text('Error: ${response.statusCode}')));
    //   }
    // }
  } on FirebaseAuthException {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Login failed: Check your email and password')));
  }
}

Future<void> selectRole(BuildContext context, String role) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String? idToken = await user.getIdToken();
      final response = await http.post(
        Uri.parse(
            '${Config.baseUrl}/user-services/api/Users/UpdateRole?role=$role'),
        headers: {
          'Authorization': 'Bearer $idToken',
        },
      );

      if (response.statusCode == 200) {
        Navigator.pushNamed(context, '/home');
      } else {
        return;
      }
    } else {
      return;
    }
  } catch (e) {
    rethrow;
  }
}

void resetPassword(String email, BuildContext context) async {
  if (email.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please enter your email!')),
    );
    return;
  }

  try {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Password reset email sent to $email')),
    );
    Future.delayed(const Duration(seconds: 5), () {
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    });
  } on FirebaseAuthException catch (e) {
    String errorMessage;
    if (e.code == 'user-not-found') {
      errorMessage = 'No user found with this email.';
    } else if (e.code == 'invalid-email') {
      errorMessage = 'The email address is not valid.';
    } else {
      errorMessage = 'Something went wrong. Please try again.';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(errorMessage)),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('An unexpected error occurred: $e')),
    );
  }
}

Future<void> logout(BuildContext context) async {
  try {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error during logout: $e')),
    );
  }
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

Future<void> sendEmailVerification(BuildContext context) async {
  final user = FirebaseAuth.instance.currentUser;

  if (user != null && !user.emailVerified) {
    await user.sendEmailVerification();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Verification email sent. Please check your inbox.'),
      ),
    );
  }
}
