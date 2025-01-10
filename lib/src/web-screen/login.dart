import 'package:event_management/src/mobile_screen/auth/forgot_password.dart';
import 'package:event_management/src/service/auth_service.dart';
import 'package:flutter/material.dart';

class LoginScreenWeb extends StatefulWidget {
  const LoginScreenWeb({super.key});

  static const routeName = '/login';

  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenWebState createState() => _LoginScreenWebState();
}

class _LoginScreenWebState extends State<LoginScreenWeb> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Theme.of(context).colorScheme.primary, // Fixed color property
        child: SafeArea(
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.all_inclusive,
                        size: 100, // Adjust icon size for web
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Sign In',
                        style: TextStyle(
                          fontSize: 32, // Larger font size for web
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Use the account below to sign in.',
                        style: TextStyle(
                          fontSize: 18, // Adjust font size for web
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          await signInWithEmailPassword(
                            context,
                            _emailController.text,
                            _passwordController.text,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          maximumSize: const Size(double.infinity, 50),
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 100, vertical: 20),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                        child: const Text('Sign In'),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const ForgotPasswordScreen()),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimary,
                        ),
                        child: const Text('Forgot Password'),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Or sign up with',
                        style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Column(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () async {
                              await loginWithGoogle(context);
                            },
                            icon: const Icon(Icons.g_mobiledata),
                            label: const Text('Continue with Google'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 100, vertical: 20),
                              foregroundColor:
                                  Theme.of(context).colorScheme.onSurface,
                              backgroundColor:
                                  Theme.of(context).colorScheme.surface,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () async {
                              await loginWithFacebook(context);
                            },
                            icon: const Icon(Icons.facebook),
                            label: const Text('Continue with Facebook'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 100, vertical: 20),
                              foregroundColor:
                                  Theme.of(context).colorScheme.onSurface,
                              backgroundColor:
                                  Theme.of(context).colorScheme.surface,
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/register');
                            },
                            style: TextButton.styleFrom(
                              foregroundColor:
                                  Theme.of(context).colorScheme.onPrimary,
                            ),
                            child: Text(
                              'Don\'t have an account? Register here',
                              style: TextStyle(
                                fontSize: 18,
                                color: Theme.of(context).colorScheme.onPrimary,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
