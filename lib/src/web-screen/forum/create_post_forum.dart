// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:event_management/generated/l10n.dart';
import 'package:event_management/src/service/forum_service.dart';
import 'package:event_management/src/web-screen/custom_appbar.dart';
import 'package:flutter/material.dart';

class CreatePostScreenWeb extends StatefulWidget {
  const CreatePostScreenWeb({super.key});

  static const routeName = '/create-post';

  @override
  State<CreatePostScreenWeb> createState() => _CreatePostScreenWebState();
}

class _CreatePostScreenWebState extends State<CreatePostScreenWeb> {
  String? selectedCategory;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  html.File? _imageFile;
  String? _imageUrl;
  bool isLoading = false;
  String? titleError;
  String? descriptionError;
  String? categoryError;

  void _pickImage() async {
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((e) async {
      final files = uploadInput.files;
      if (files?.isEmpty ?? true) return;
      setState(() {
        _imageFile = files!.first;
        // Create an object URL from the file
        final reader = html.FileReader();
        reader.readAsDataUrl(_imageFile!);
        reader.onLoadEnd.listen((e) {
          setState(() {
            _imageUrl = reader.result as String?;
          });
        });
      });
    });
  }

  void _handlePost(BuildContext context) {
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
      if (_imageFile != null) {
        String imageUrl = _imageUrl!;
        createPost(
          _titleController.text,
          _descriptionController.text,
          selectedCategory!,
          imageUrl,
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
          });
        });
        Navigator.of(context).pop();
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
                            onTap: _pickImage,
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
                          if (_imageFile != null) ...[
                            const SizedBox(height: 16.0),
                            // Display the image selected by the user
                            Image.network(
                              _imageUrl!,
                              height: 500,
                              width: 500,
                              fit: BoxFit.cover,
                            ),
                          ],
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
