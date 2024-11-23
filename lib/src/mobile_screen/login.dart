// ignore_for_file: use_build_context_synchronously
import 'package:event_management/generated/l10n.dart';
import 'package:event_management/src/mobile_screen/home_screen.dart';
import 'package:event_management/src/mobile_screen/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> signInwithGoogle() async {
    GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
    AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken, idToken: googleAuth?.idToken);
    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

    if (userCredential.user != null && mounted) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => HomeScreen()));
    }
  }

  Future<void> signInWithFacebook() async {
    final LoginResult result = await FacebookAuth.instance.login();

    if (result.status == LoginStatus.success) {
      final OAuthCredential facebookAuthCredential =
          FacebookAuthProvider.credential(result.accessToken!.tokenString);

      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(facebookAuthCredential);

      if (userCredential.user != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
    } else {
      debugPrint(result.message);
    }
  }

  Future<void> _signInWithEmailPassword(BuildContext context) async {
    try {
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (userCredential.user != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfileWidget()),
        );
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('Error during email/password login: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: ${e.message}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).welcome)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _signInWithEmailPassword(context),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child:  Text(S.of(context).login),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/register',
                );
              },
              child: Text(S.of(context).register_account),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => signInwithGoogle(),
              icon: Image.asset('assets/images/gmail_logo.png', width: 24),
              label:  Text(S.of(context).gmail_sign_in),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => signInWithFacebook(),
              icon: Image.asset('assets/images/facebook_logo.png', width: 24),
              label:  Text(S.of(context).facebook_sign_in),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
