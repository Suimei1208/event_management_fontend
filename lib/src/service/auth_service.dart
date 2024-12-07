import 'dart:convert';

import 'package:event_management/config.dart';
import 'package:event_management/src/mobile_screen/home_screen.dart';
import 'package:event_management/src/mobile_screen/login.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

String uri = '${Config.baseUrl}/user-services';
Future<void> signInWithGoogle(BuildContext context) async {
  try {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser != null) {
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential googleAuthCredential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(googleAuthCredential);

      if (userCredential.user != null) {
        Navigator.pushReplacement(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
    }
  } catch (e) {
    rethrow;
  }
}

Future<void> signInWithFacebook(BuildContext context) async {
  final LoginResult result = await FacebookAuth.instance.login();

  if (result.status == LoginStatus.success) {
    final OAuthCredential facebookAuthCredential = FacebookAuthProvider.credential(result.accessToken!.tokenString);

    final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);

    if (userCredential.user != null) {
      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    }
  } else {
  }
}

Future<void> signInWithEmailPassword(BuildContext context, String email, String password) async {
  try {
    final UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (userCredential.user != null) {
      final idToken = await userCredential.user?.getIdToken();
      final response = await http.get(
        Uri.parse('${Config.baseUrl}/user-services/api/Users/login?firebaseIdToken=$idToken'),      
      );
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          final role = responseData['data']['role'];
          
          if (role == "None") {
            // ignore: use_build_context_synchronously
            Navigator.pushNamed(context, '/role');
          } else {
            // ignore: use_build_context_synchronously
            Navigator.pushNamed(context, '/profile');
          }
        } else {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to get role: ${responseData['message']}'))
          );
        }
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.statusCode}'))
        );
      }
    }
  } on FirebaseAuthException catch (e) {
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Login failed: ${e.message}'))
    );
  }
}

Future<void> selectRole(BuildContext context, String role) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String? idToken = await user.getIdToken();
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/user-services/api/Users/UpdateRole?role=$role'),    
        headers: {
            'Authorization': '$idToken',
          },    
      );

      if (response.statusCode == 200) {
        // ignore: use_build_context_synchronously
        Navigator.pushNamed(context, '/profile');
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

    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Password reset email sent to $email')),
    );
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      ); 
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

    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(errorMessage)),
    );
  } catch (e) {
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('An unexpected error occurred: $e')),
    );
  }
}