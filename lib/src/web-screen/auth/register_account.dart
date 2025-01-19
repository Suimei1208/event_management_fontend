// ignore_for_file: use_build_context_synchronously
import 'dart:convert';
import 'package:event_management/config.dart';
import 'package:event_management/src/service/logger_service.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreenWeb extends StatefulWidget {
  const RegisterScreenWeb({super.key});

  static const routeName = '/register';

  @override
  State<RegisterScreenWeb> createState() => _RegisterScreenWebState();
}

class _RegisterScreenWebState extends State<RegisterScreenWeb> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  String _emailError = '';
  String _passwordError = '';
  String _confirmPasswordError = '';
  String _phoneError = '';
  String _nameError = '';

  Future<void> _registerWithEmailPassword(BuildContext context) async {
    setState(() {
      _emailError = '';
      _passwordError = '';
      _confirmPasswordError = '';
      _phoneError = '';
      _nameError = '';
    });

    if (_nameController.text.trim().isEmpty) {
      setState(() {
        _nameError = 'Full name cannot be empty';
      });
      return;
    }

    if (_emailController.text.trim().isEmpty) {
      setState(() {
        _emailError = 'Email cannot be empty';
      });
      return;
    } else if (!_emailController.text.trim().contains('@') ||
        !_emailController.text.trim().contains('.') ||
        !_emailController.text.trim().contains('com') ||
        _emailController.text.trim().contains(' ')) {
      setState(() {
        _emailError = 'Invalid email format';
      });
      return;
    }

    if (_phoneController.text.trim().isEmpty) {
      setState(() {
        _phoneError = 'Phone number cannot be empty';
      });
      return;
    } else if (_phoneController.text.trim().length != 10) {
      setState(() {
        _phoneError = 'Phone number should be 10 digits';
      });
      return;
    }

    if (_passwordController.text.trim().isEmpty) {
      setState(() {
        _passwordError = 'Password cannot be empty';
      });
      return;
    } else if (_passwordController.text.trim().length < 6) {
      setState(() {
        _passwordError = 'Password should be at least 6 characters';
      });
      return;
    }

    if (_passwordController.text.trim() !=
        _passwordConfirmController.text.trim()) {
      setState(() {
        _confirmPasswordError = 'Passwords do not match';
      });
      return;
    }

    try {
      final UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      const String avatarUrl =
          'https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png';
      await userCredential.user?.updatePhotoURL(avatarUrl);
      await userCredential.user?.updateDisplayName(_nameController.text.trim());

      final idToken = await userCredential.user?.getIdToken();

      final Map<String, String> data = {
        'id': idToken ?? '',
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'nameFromEmail': '',
      };

      LoggerService.logger.e(data);

      await _sendDataToBackend(data);

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      debugPrint('Error during registration: $e');
      setState(() {
        _emailError = 'Registration failed: ${e.message}';
      });
    }
  }

  Future<void> _sendDataToBackend(Map<String, String> data) async {
    final response = await http.post(
      Uri.parse('${Config.baseUrl}/user-services/api/Users/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      LoggerService.logger.w('Data sent successfully');
    } else {
      LoggerService.logger.w('Failed to send data: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    Brightness brightness = Theme.of(context).brightness;
    return Scaffold(
      body: Center(
        child: Container(
          alignment: Alignment.center,
          height: double.infinity,
          constraints: const BoxConstraints(maxWidth: 600),
          // decoration: BoxDecoration(
          //   border: Border.all(
          //     color: brightness == Brightness.light
          //         ? Colors.grey[300]!
          //         : Colors.grey[700]!,
          //   ),
          //   borderRadius: BorderRadius.circular(8),
          // ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.all_inclusive,
                size: 80,
              ),
              const SizedBox(height: 20),
              const Text(
                'Register',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'Create a new account.',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              if (_nameError.isNotEmpty)
                Text(
                  _nameError,
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 15),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              if (_emailError.isNotEmpty)
                Text(
                  _emailError,
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 15),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              if (_phoneError.isNotEmpty)
                Text(
                  _phoneError,
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 15),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              if (_passwordError.isNotEmpty)
                Text(
                  _passwordError,
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 15),
              TextField(
                controller: _passwordConfirmController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
              ),
              if (_confirmPasswordError.isNotEmpty)
                Text(
                  _confirmPasswordError,
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brightness == Brightness.light
                        ? Colors.blue
                        : Theme.of(context).colorScheme.inversePrimary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 60, vertical: 30),
                    textStyle: const TextStyle(fontSize: 20),
                  ),
                  onPressed: () async {
                    await _registerWithEmailPassword(
                      context,
                    );
                  },
                  child: const Text(
                    'Register',
                    style: TextStyle(fontSize: 15, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Already have an account? Sign in here',
                  style:
                      TextStyle(decoration: TextDecoration.none, fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
