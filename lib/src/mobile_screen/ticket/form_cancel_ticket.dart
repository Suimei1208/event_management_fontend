// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:event_management/src/service/event_service.dart';
import 'package:event_management/src/service/logger_service.dart';
import 'package:event_management/src/service/ticket_service.dart';
import 'package:event_management/widget/dialog_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TicketCancellationForm extends StatefulWidget {
  final int eventId;
  const TicketCancellationForm({super.key, required this.eventId});

  @override
  // ignore: library_private_types_in_public_api
  _TicketCancellationFormState createState() => _TicketCancellationFormState();
}

class _TicketCancellationFormState extends State<TicketCancellationForm> {
  final _formKey = GlobalKey<FormState>();
  String? _cancellationReason;
  File? _selectedImage;
  User? user = FirebaseAuth.instance.currentUser;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      LoggerService.logger.e("Error picking image: $e");
    }
  }

  Future<void> _submitRequest(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      String? imageUrl;
      if (_selectedImage != null) {
        try {
          imageUrl = await uploadImageEventToImageKit(
            _selectedImage!,
            widget.eventId,
            'ticket_cancellation_${user?.uid}_${widget.eventId}',widget.eventId.toString()
          );
        } catch (e) {
          LoggerService.logger.e("Image upload failed: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to upload image")),
          );
          return;
        }
      }

      LoggerService.logger.e('Cancellation Reason: $_cancellationReason');
      await createTicketCancellationRequest(
        widget.eventId,
        _cancellationReason!,
        imageUrl ?? '',
      );

      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const DialogWidget(
              message: 'Hủy bỏ vé thành công!',
              title: 'Success',
            );
          },
        ).then((_) {
          if (mounted) {
            Navigator.pop(context); // Go back to the previous screen
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ticket Cancellation Request'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                'Please provide details for your cancellation',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              TextFormField(
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Reason for Cancellation',
                  hintText: 'Please explain why you need to cancel...',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a reason for cancellation';
                  }
                  return null;
                },
                onChanged: (value) {
                  _cancellationReason = value;
                },
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _selectedImage != null
                      ? Image.file(_selectedImage!, fit: BoxFit.cover)
                      : const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo, color: Colors.grey),
                              SizedBox(height: 8),
                              Text('Upload Images'),
                              Text('Tap to add proof images'),
                            ],
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _submitRequest(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                ),
                child: const Text('Submit Request'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
