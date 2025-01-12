// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:event_management/generated/l10n.dart';
import 'package:event_management/src/service/forum_service.dart';
import 'package:event_management/widget/dialog_widget.dart';
import 'package:flutter/material.dart';

class CreatePostScreenWeb extends StatefulWidget {
  const CreatePostScreenWeb({super.key});

  // static const routeName = 'create-post';

  @override
  State<CreatePostScreenWeb> createState() => _CreatePostScreenWebState();
}

class _CreatePostScreenWebState extends State<CreatePostScreenWeb> {
  String? selectedCategory;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  html.File? _imageFile;
  bool isLoading = false;

  // For web, using file input for image upload
  void _pickImage() async {
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((e) async {
      final files = uploadInput.files;
      if (files?.isEmpty ?? true) return;
      setState(() {
        _imageFile = files!.first;
      });
    });
  }

  void _handlePost() {
    if (selectedCategory == null || selectedCategory!.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const DialogWidget(
            message: 'Vui lòng chọn category trước khi đăng bài',
            title: 'Notification',
          );
        },
      );
    } else {
      setState(() {
        isLoading = true;
      });
      if (_imageFile != null) {
        // Simulate uploading image
        String imageUrl =
            'https://example.com/path/to/uploaded/image.jpg'; // replace with real upload logic
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
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).create_post),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: S.of(context).post_title,
                border: const OutlineInputBorder(),
              ),
              controller: _titleController,
            ),
            const SizedBox(height: 16.0),
            TextField(
              maxLines: 5,
              decoration: InputDecoration(
                labelText: S.of(context).share_thought,
                border: const OutlineInputBorder(),
              ),
              controller: _descriptionController,
            ),
            const SizedBox(height: 16.0),
            Text(
              S.of(context).category,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
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
            const SizedBox(height: 16.0),
            Text(
              S.of(context).attachments,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(),
                borderRadius: BorderRadius.circular(5.0),
              ),
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
                    // Replace this with a way to show an image from a File for web
                    Text(_imageFile!.name),
                  ],
                  const SizedBox(height: 16.0),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            Center(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          _handlePost();
                        },
                  child: isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : Text(S.of(context).post),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label) {
    return ChoiceChip(
      label: Text(label),
      selected: selectedCategory == label,
      onSelected: (bool selected) {
        setState(() {
          selectedCategory = selected ? label : null;
        });
      },
    );
  }
}
