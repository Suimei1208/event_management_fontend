// ignore_for_file: use_build_context_synchronously, avoid_web_libraries_in_flutter

import 'dart:html' as html;

import 'package:event_management/generated/l10n.dart';
import 'package:event_management/src/service/forum_service.dart';
import 'package:event_management/src/service/logger_service.dart';
import 'package:event_management/src/service/user_service_web.dart';
import 'package:event_management/src/web-screen/custom_appbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CreatePostScreenWeb extends StatefulWidget {
  const CreatePostScreenWeb({super.key});

  static const routeName = '/create-post';

  @override
  State<CreatePostScreenWeb> createState() => _CreatePostScreenWebState();
}

class _CreatePostScreenWebState extends State<CreatePostScreenWeb> {
  User? user = FirebaseAuth.instance.currentUser;
  String? selectedCategory;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  html.File? uploadedImage;
  String? uploadedImageUrl;
  String _uploadedBase64Data = "";
  bool isLoading = false;
  String? titleError;
  String? descriptionError;
  String? categoryError;

  Future<void> _pickImage() async {
    setState(() {
      isLoading = true;
    });

    html.FileUploadInputElement uploadInput = html.FileUploadInputElement()
      ..accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;
      if (files?.isEmpty ?? true) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      final reader = html.FileReader();
      reader.readAsDataUrl(files![0]);

      reader.onLoadEnd.listen((e) {
        setState(() {
          _uploadedBase64Data = reader.result as String;
          uploadedImageUrl = _uploadedBase64Data;
          isLoading = false;
        });
      });
    });
  }

  Future<void> _uploadImage(uploadedBase64Data) async {
    try {
      setState(() {
        isLoading = true;
      });
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      // ignore: unused_local_variable
      String imgUrl = await uploadDocumentsToImageKitWebVersion(
          _uploadedBase64Data, "forum_images", "${user?.uid}_$timestamp");

      setState(() {
        uploadedImageUrl = imgUrl;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
    }
  }

  Future<void> _handlePost(BuildContext context) async {
    setState(() {
      titleError = _titleController.text.isEmpty ? 'Title is required' : null;
      descriptionError = _descriptionController.text.isEmpty
          ? 'Description is required'
          : null;
      categoryError = selectedCategory == null ? 'Category is required' : null;
    });

    if (titleError == null &&
        descriptionError == null &&
        categoryError == null) {
      setState(() {
        isLoading = true;
      });
      if (_uploadedBase64Data != "") {
        await _uploadImage(_uploadedBase64Data);
      }
      if (uploadedImageUrl != "") {
        LoggerService.logger.i("here !null");
        LoggerService.logger.i(uploadedImageUrl);
        createPost(
          _titleController.text,
          _descriptionController.text,
          selectedCategory!,
          uploadedImageUrl!,
        ).then((_) {
          setState(() {
            isLoading = false;
          });
        });
        Navigator.of(context).pop();
      } else {
        createPost(
          _titleController.text,
          _descriptionController.text,
          selectedCategory!,
          '',
        ).then((_) {
          setState(() {
            isLoading = false;
            Navigator.of(context).pop();
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Brightness brightness = Theme.of(context).brightness;
    return Scaffold(
      appBar: const CustomAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    S.of(context).create_post,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextField(
                    decoration: InputDecoration(
                      labelText: S.of(context).post_title,
                      border: const OutlineInputBorder(),
                      errorText: titleError,
                    ),
                    controller: _titleController,
                  ),
                  const SizedBox(height: 20.0),
                  TextField(
                    maxLines: 5,
                    decoration: InputDecoration(
                      labelText: S.of(context).share_thought,
                      border: const OutlineInputBorder(),
                      errorText: descriptionError,
                    ),
                    controller: _descriptionController,
                  ),
                  const SizedBox(height: 20.0),
                  Text(
                    S.of(context).category,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20.0),
                  Wrap(
                    spacing: 10.0,
                    children: [
                      _buildCategoryChip(
                          "${S.of(context).general} ${S.of(context).discussion}"),
                      _buildCategoryChip(S.of(context).questions),
                      _buildCategoryChip(S.of(context).tips_tricks),
                      _buildCategoryChip(S.of(context).feedback),
                    ],
                  ),
                  if (categoryError != null) ...[
                    const SizedBox(height: 8.0),
                    Text(
                      categoryError!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ],
                  const SizedBox(height: 20.0),
                  Text(
                    S.of(context).attachments,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20.0),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: brightness == Brightness.light
                              ? Colors.grey
                              : Colors.white),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        children: [
                          InkWell(
                            // onTap: _pickImage,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.add_a_photo),
                                  onPressed: _pickImage,
                                ),
                                Text(S.of(context).add_photo),
                              ],
                            ),
                          ),
                          if (uploadedImageUrl != null)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.network(uploadedImageUrl!,
                                  height: 250, width: double.infinity),
                            ),
                          const SizedBox(height: 16.0),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Center(
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: brightness == Brightness.light
                              ? Colors.blue
                              : Theme.of(context).colorScheme.inversePrimary,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 100, vertical: 20),
                        ),
                        onPressed:
                            isLoading ? null : () => _handlePost(context),
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                S.of(context).post,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label) {
    return Column(
      children: [
        ChoiceChip(
          label: Text(
            label,
            style: const TextStyle(fontSize: 18),
          ),
          selected: selectedCategory == label,
          onSelected: (bool selected) {
            setState(() {
              selectedCategory = selected ? label : null;
            });
          },
        ),
        const SizedBox(height: 10.0),
      ],
    );
  }
}
