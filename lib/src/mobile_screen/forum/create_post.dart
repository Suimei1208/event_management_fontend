// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:event_management/generated/l10n.dart';
import 'package:event_management/src/service/forum_service.dart';
import 'package:event_management/widget/dialog_widget.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  String? selectedCategory;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _imageFile;
  bool isLoading = false;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
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
        uploadImageForumToImageKit(_imageFile!, _titleController.text)
            .then((imageUrl) {
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
        }).catchError((error) {
          setState(() {
            isLoading = false;
          });
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return const DialogWidget(
                message: 'Failed to upload image.',
                title: 'Error',
              );
            },
          );
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.add_a_photo),
                  onPressed: _pickImage,
                ),
                Text(S.of(context).add_photo),
              ],
            ),
            if (_imageFile != null) ...[
              const SizedBox(height: 16.0),
              Image.file(
                _imageFile!,
                height: 150,
                width: 150,
                fit: BoxFit.cover,
              ),
            ],
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
