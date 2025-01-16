// ignore_for_file: library_private_types_in_public_api, avoid_web_libraries_in_flutter

import 'dart:html' as html;
import 'package:event_management/src/service/user_service_web.dart';
import 'package:event_management/src/web-screen/custom_appbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:event_management/src/service/user_service.dart';

class WebEditProfileScreen extends StatefulWidget {
  const WebEditProfileScreen({super.key});
  static const routeName = "/edit-profile";

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<WebEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  User? currentUser = FirebaseAuth.instance.currentUser;

  bool _isLoading = true;
  bool _isUploading = false;
  String _uploadedImageUrl = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Load user data from your service, and update the form fields
  void _loadUserData() async {
    try {
      final userDetails = await getUserDetails();
      setState(() {
        _nameController.text = userDetails['name'];
        _emailController.text = userDetails['email'];
        _phoneController.text = userDetails['phone'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Handle image picking and uploading
  Future<void> _pickAndUploadImage() async {
    setState(() {
      _isUploading = true;
    });

    // File picker for web
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement()
      ..accept = 'image/*';
    uploadInput.click();

    // Listen for the file selection and upload the image
    uploadInput.onChange.listen((e) async {
      final files = uploadInput.files;
      if (files?.isEmpty ?? true) return;

      final reader = html.FileReader();
      reader.readAsDataUrl(files![0]);

      reader.onLoadEnd.listen((e) async {
        final base64ImageData = reader.result as String;
        try {
          String imageUrl = await uploadImageToImageKitWebVersion(
              base64ImageData, "profile_pictures");
          final updatedImageUrl = _appendUpdatedAtQuery(imageUrl);

          setState(() {
            _uploadedImageUrl = updatedImageUrl;
          });
          await currentUser!.updatePhotoURL(updatedImageUrl);

          setState(() {
            currentUser = FirebaseAuth.instance.currentUser;
          });
        } finally {
          setState(() {
            _isUploading = false;
          });
        }
      });
    });
  }

  // Append a timestamp to the image URL to avoid caching issues
  String _appendUpdatedAtQuery(String url) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '$url?updatedAt=$timestamp';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: const CustomAppBar(),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Center(
                            child: Stack(
                              children: [
                                CircleAvatar(
                                  radius: 60,
                                  backgroundImage:
                                      NetworkImage(currentUser!.photoURL ?? ''),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: _pickAndUploadImage,
                                    child: Container(
                                      height: 48,
                                      width: 48,
                                      decoration: const BoxDecoration(
                                        color: Colors.blue,
                                        shape: BoxShape.circle,
                                      ),
                                      child: _isUploading
                                          ? const CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            )
                                          : const Icon(
                                              Icons.camera_alt,
                                              color: Colors.white,
                                            ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Full Name Field
                          SizedBox(
                            width: 500, // Customize width as needed
                            child: TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Full Name',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 20.0, horizontal: 10.0),
                              ),
                              style: const TextStyle(fontSize: 20),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your full name';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: 500, // Customize width as needed
                            child: TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: 'Email Address',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 20.0,
                                    horizontal: 10.0), // Increased height
                              ),
                              style: const TextStyle(
                                  fontSize: 20), // Increase font size
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email address';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: 500, // Customize width as needed
                            child: TextFormField(
                              controller: _phoneController,
                              decoration: const InputDecoration(
                                labelText: 'Phone Number',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 29.0,
                                    horizontal: 10.0), // Increased height
                              ),
                              style: const TextStyle(
                                  fontSize: 20), // Increase font size
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your phone number';
                                }
                                return null;
                              },
                            ),
                          ),

                          const SizedBox(height: 24),
                          // Update Profile Button
                          ElevatedButton(
                            onPressed: () {
                              // Validate form and update user profile
                              if (_formKey.currentState?.validate() ?? false) {
                                updateUserProfile(
                                  context,
                                  _nameController.text.trim(),
                                  _phoneController.text.trim(),
                                  _uploadedImageUrl,
                                );
                              }
                            },
                            child: const Text('Update Profile'),
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
