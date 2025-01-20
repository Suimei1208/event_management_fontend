import 'package:event_management/src/mobile_screen/auth/forgot_password.dart';
import 'package:event_management/src/service/auth_service.dart';
import 'package:event_management/src/service/user_service_web.dart';
import 'package:flutter/material.dart';

class WebLoginScreen extends StatefulWidget {
  const WebLoginScreen({super.key});

  static const routeName = '/login';

  @override
  // ignore: library_private_types_in_public_api
  _WebLoginScreenState createState() => _WebLoginScreenState();
}

class _WebLoginScreenState extends State<WebLoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    Brightness brightness = Theme.of(context).brightness;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.all_inclusive,
                      size: 100, // Adjust icon size for web
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 32, // Larger font size for web
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Use the account below to sign in.',
                      style: TextStyle(
                        fontSize: 18, // Adjust font size for web
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        filled: true,
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
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          await signInWithEmailPassword(
                            context,
                            _emailController.text,
                            _passwordController.text,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: brightness == Brightness.light
                                ? Colors.blue
                                : Theme.of(context).colorScheme.inversePrimary,
                            maximumSize: const Size(double.infinity, 50),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 100, vertical: 20),
                            textStyle: const TextStyle(
                                fontSize: 18, color: Colors.white)),
                        child: const Text(
                          'Sign In',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
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
                      style: TextButton.styleFrom(),
                      child: const Text('Forgot Password'),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Or sign up with',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Column(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () async {
                            await loginWithGoogleWeb(context);
                          },
                          icon: const Icon(Icons.g_mobiledata,
                              color: Colors.white),
                          label: const Text(
                            'Continue with Google',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: brightness == Brightness.light
                                ? Colors.blue
                                : Theme.of(context).colorScheme.inversePrimary,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 100, vertical: 20),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () async {
                            await signInWithFacebookWeb(context);
                          },
                          icon: const Icon(Icons.facebook),
                          label: const Text('Continue with Facebook',
                              style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: brightness == Brightness.light
                                ? Colors.blue
                                : Theme.of(context).colorScheme.inversePrimary,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 100, vertical: 20),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/register');
                          },
                          style: TextButton.styleFrom(),
                          child: const Text(
                            'Don\'t have an account? Register here',
                            style: TextStyle(
                              fontSize: 18,
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
    );
  }
}
