// ignore_for_file: library_private_types_in_public_api, avoid_print

import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:event_management/src/service/user_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  static const routeName = '/edit_profile';

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
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
      print('edit_profile: Failed to load user data: $e');
    }
  }

  Future<void> _pickAndUploadImage() async {
    setState(() {
      _isUploading = true;
    });

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      try {
        String imageUrl = await _uploadImageToImageKit(imageFile);

        final updatedImageUrl = _appendUpdatedAtQuery(imageUrl);

        print("Uploading image, URL: $updatedImageUrl");

        setState(() {
          _uploadedImageUrl = updatedImageUrl;
        });

        await currentUser!.updatePhotoURL(updatedImageUrl);

        setState(() {
          currentUser = FirebaseAuth.instance.currentUser;
        });
      } catch (e) {
        print('Failed to upload image: $e');
      } finally {
        setState(() {
          _isUploading = false;
        });
      }
    } else {
      setState(() {
        _isUploading = false;
      });
    }
  }

  String _appendUpdatedAtQuery(String url) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '$url?updatedAt=$timestamp';
  }

  Future<String> _uploadImageToImageKit(File imageFile) async {
    const privateKey = 'private_F801T1Ot8g2c8BCrrN+7+y+Kvdc=';
    final base64EncodedKey = base64Encode(utf8.encode('$privateKey:'));

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://upload.imagekit.io/api/v1/files/upload'),
    );
    request.headers['Authorization'] = 'Basic $base64EncodedKey';
    request.files
        .add(await http.MultipartFile.fromPath('file', imageFile.path));
    request.fields['fileName'] = 'profile_pic_${currentUser!.uid}.jpg';
    request.fields['useUniqueFileName'] = 'false';
    request.fields['folder'] = '/profile_pictures';

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final decodedData = json.decode(responseData);
      final imageUrl = decodedData['url'];

      print("Image uploaded successfully. URL: $imageUrl");

      return imageUrl;
    } else {
      final responseData = await response.stream.bytesToString();
      print('Failed to upload image: ${response.statusCode}, $responseData');
      throw Exception('Failed to upload image ${response.statusCode}');
    }
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
        appBar: AppBar(
          title: const Text('Edit Profile'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
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
                                      (currentUser!.photoURL != null
                                          ? NetworkImage(currentUser!.photoURL!)
                                          : null),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: _pickAndUploadImage,
                                    child: Container(
                                      height: 36,
                                      width: 36,
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
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Full Name',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your full name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email Address',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email address';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _phoneController,
                            decoration: const InputDecoration(
                              labelText: 'Phone Number',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your phone number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {
                              updateUserProfile(
                                  context,
                                  _nameController.text.trim(),
                                  _phoneController.text.trim(),
                                  _uploadedImageUrl);
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
