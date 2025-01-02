import 'package:event_management/src/service/logger_service.dart';
import 'package:flutter/material.dart';

class SettingCancelEvent extends StatefulWidget {
  const SettingCancelEvent({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SettingCancelEventState createState() => _SettingCancelEventState();
}

class _SettingCancelEventState extends State<SettingCancelEvent> {
  bool selectReason = false;
  bool addImageEvidence = false;
  bool addExternalLink = false;
  TextEditingController externalLinkController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Setting Feedback'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Select Reason
            SwitchListTile(
              title: const Text('Select Reason'),
              value: selectReason,
              onChanged: (value) {
                setState(() {
                  selectReason = value;
                });
              },
            ),
            const SizedBox(height: 10),

            // Add Image Evidence
            SwitchListTile(
              title: const Text('Add Image Evidence'),
              value: addImageEvidence,
              onChanged: (value) {
                setState(() {
                  addImageEvidence = value;
                });
              },
            ),
            const SizedBox(height: 10),

            // Add External Link
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Thêm SwitchListTile
                SwitchListTile(
                  title: const Text('Add External Link'),
                  value: addExternalLink,
                  onChanged: (value) {
                    setState(() {
                      addExternalLink = value;
                    });
                  },
                ),
                // Nếu addExternalLink bật, hiển thị ô nhập liên kết
                if (addExternalLink)
                  TextField(
                    controller: externalLinkController,
                    decoration: const InputDecoration(
                      labelText: 'Enter External Link',
                      border: OutlineInputBorder(),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 20),

            // Submit Feedback Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Submit feedback logic here
                  LoggerService.logger.i('Feedback submitted');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Button color
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
