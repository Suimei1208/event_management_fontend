import 'package:event_management/src/service/logger_service.dart';
import 'package:event_management/src/service/ticket_service.dart';
import 'package:event_management/widget/dialog_widget.dart';
import 'package:flutter/material.dart';

class TicketCancellationForm extends StatefulWidget {
  final int eventId;
  const TicketCancellationForm({super.key, required this.eventId});

  @override
  _TicketCancellationFormState createState() => _TicketCancellationFormState();
}

class _TicketCancellationFormState extends State<TicketCancellationForm> {
  final _formKey = GlobalKey<FormState>();
  String? _cancellationReason;

  void _submitRequest(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      // Handle form submission logic here
      LoggerService.logger.e('Cancellation Reason: $_cancellationReason');
      // You can also implement image upload functionality here
      await createTicketCancellationRequest(
              widget.eventId,
              _cancellationReason!,
              'https://upload-os-bbs.hoyolab.com/upload/2024/10/01/427373429/617690b2c1bd3807e719d4b27eab2b5b_4733504345886202071.jpg?x-oss-process=image%2Fresize%2Cs_1000%2Fauto-orient%2C0%2Finterlace%2C1%2Fformat%2Cwebp%2Fquality%2Cq_70')
          .then((result) {
        // Ensure the widget is still mounted before using BuildContext
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
            Navigator.pop(context); // Go back to the previous screen
          });
        }
      });
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
                onTap: () {
                  // Implement image upload functionality here
                  LoggerService.logger.i('Upload images');
                },
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
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
