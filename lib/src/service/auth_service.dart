// ignore_for_file: use_build_context_synchronously, empty_catches

import 'dart:convert';

import 'package:event_management/config.dart';
import 'package:event_management/src/mobile_screen/login.dart';
import 'package:event_management/src/mobile_screen/role_selection_screen.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logging/logging.dart';

String uri = '${Config.baseUrl}/user-services';
final Logger _logger = Logger('MyApp');

Future<void> signInWithFacebook(BuildContext context) async {
  try {
    final LoginResult result = await FacebookAuth.instance.login();

    if (result.status == LoginStatus.success) {
      final OAuthCredential facebookAuthCredential =
          FacebookAuthProvider.credential(result.accessToken!.tokenString);

      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(facebookAuthCredential);

      if (userCredential.user != null) {
        final idToken = await userCredential.user?.getIdToken();

        final response = await http.post(
          Uri.parse('${Config.baseUrl}/user-services/api/Users/register'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'Id': idToken,
            'Email': userCredential.user?.email,
          }),
        );

        if (response.statusCode == 200) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const RoleSelectionScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Error registering user: ${response.body}')));
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Facebook login failed: ${result.message}')));
    }
  } catch (e) {
    rethrow;
  }
}

Future<void> signInWithGoogle(BuildContext context) async {
  try {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser != null) {
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential googleAuthCredential =
          GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(googleAuthCredential);

      if (userCredential.user != null) {
        final idToken = await userCredential.user?.getIdToken();

        final response = await http.get(
          Uri.parse(
              '${Config.baseUrl}/user-services/api/Users/login?firebaseIdToken=$idToken'),
        );

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          if (responseData['success'] == true && responseData['data'] != null) {
            final role = responseData['data']['role'];

            if (role == "None") {
              Navigator.pushReplacementNamed(context, '/role');
            } else {
              Navigator.pushReplacementNamed(context, '/home');
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content:
                    Text('Failed to get role: ${responseData['message']}')));
          }
        } else if (response.statusCode == 500) {
          final Map<String, String> data = {
            'id': idToken ?? '',
            'name': googleUser.displayName ?? 'default',
            'email': googleUser.email,
            'phone': '000000000',
            'role': 'None',
          };

          await _sendDataToBackend(data);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const RoleSelectionScreen(),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${response.statusCode}')));
        }
      }
    }
  } catch (e) {}
}

Future<void> _sendDataToBackend(Map<String, String> data) async {
  final response = await http.post(
    Uri.parse('${Config.baseUrl}/user-services/api/Users/register'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(data),
  );
  if (response.statusCode == 200) {
    _logger.info('Data sent successfully');
  } else {
    _logger.severe('Failed to send data: ${response.body}');
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
