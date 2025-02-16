// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:event_management/generated/l10n.dart';
import 'package:event_management/src/service/forum_service.dart';
import 'package:event_management/src/service/user_service_web.dart';
import 'package:event_management/src/web-screen/custom_appbar.dart';
import 'package:event_management/widget/dialog_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;

class EditPostScreenWeb extends StatefulWidget {
  final int postId;
  final String initialTitle;
  final String initialDescription;
  final String initialCategory;
  final String? initialImageUrl;

  const EditPostScreenWeb({
    super.key,
    required this.postId,
    required this.initialTitle,
    required this.initialDescription,
    required this.initialCategory,
    this.initialImageUrl,
  });

  static const routeName = "forum/detail-post/edit/";

  @override
  State<EditPostScreenWeb> createState() => _EditPostScreenWebState();
}

class _EditPostScreenWebState extends State<EditPostScreenWeb> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late String selectedCategory;
  File? _imageFile;
  bool isLoading = false;
  html.File? uploadedImage;
  String? uploadedImageUrl;
  String _uploadedBase64Data = "";
  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _descriptionController =
        TextEditingController(text: widget.initialDescription);
    selectedCategory = widget.initialCategory;
  }

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
      String imgUrl = await uploadImageToImageKitWebVersion(uploadedBase64Data!,
          "forum_images/${user?.uid}_${_titleController.text}");
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

  void _handleUpdate(BuildContext context) async {
    setState(() {
      isLoading = true;
    });

    try {
      if (_uploadedBase64Data != "") {
        await _uploadImage(_uploadedBase64Data);
      }
      if (uploadedImageUrl != "") {
        await editPost(
          widget.postId,
          _titleController.text,
          _descriptionController.text,
          selectedCategory,
          "$uploadedImageUrl?updatedAt=${DateTime.now().millisecondsSinceEpoch}",
        );
      } else {
        await editPost(
          widget.postId,
          _titleController.text,
          _descriptionController.text,
          selectedCategory,
          widget.initialImageUrl,
        );
      }
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return DialogWidget(
            message: S.of(context).edit_post_ans,
            title: S.of(context).notification,
          );
        },
      );
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (error) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const DialogWidget(
              message: 'Failed to update post.',
              title: 'Error',
            );
          },
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 600, right: 600, top: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: S.of(context).post_title,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: S.of(context).share_thought,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              Text(
                S.of(context).category,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              InputDecorator(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(8.0),
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
                    if (_imageFile != null ||
                        (widget.initialImageUrl != null &&
                            widget.initialImageUrl!.isNotEmpty)) ...[
                      const SizedBox(height: 16.0),
                      uploadedImageUrl != null
                          ? Image.network(uploadedImageUrl!,
                              height: 250, width: double.infinity)
                          : Image.network(
                              widget.initialImageUrl!,
                              height: 150,
                              width: 150,
                              fit: BoxFit.cover,
                            ),
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.inversePrimary,
                    ),
                    onPressed: isLoading ? null : () => _handleUpdate(context),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(S.of(context).edit_post),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label) {
    return ChoiceChip(
      label: Text(label),
      selected: selectedCategory == label,
      onSelected: (bool selected) {
        if (mounted) {
          setState(() {
            selectedCategory = selected ? label : selectedCategory;
          });
        }
      },
    );
  }
}
