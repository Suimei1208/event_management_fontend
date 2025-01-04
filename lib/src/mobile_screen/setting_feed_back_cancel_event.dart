import 'package:event_management/src/service/cancellationperiods_service.dart';
import 'package:event_management/src/service/logger_service.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class SettingCancelEvent extends StatefulWidget {
  String eventId;
  SettingCancelEvent({super.key, required this.eventId});

  @override
  // ignore: library_private_types_in_public_api
  _SettingCancelEventState createState() => _SettingCancelEventState();
}

class _SettingCancelEventState extends State<SettingCancelEvent> {
  bool selectReason = false;
  bool addExternalLink = false;
  TextEditingController externalLinkController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;
  Map<String, dynamic> feedbackData = {};

  // Function to show date picker
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    DateTime initialDate = isStartDate
        ? (startDate ?? DateTime.now())
        : (endDate ?? DateTime.now());
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (selectedDate != null) {
      setState(() {
        if (isStartDate) {
          startDate = selectedDate;
        } else {
          endDate = selectedDate;
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchFeedbackData();
  }

  void _fetchFeedbackData() async {
    final data = await getCancellationPeriods(int.parse(widget.eventId));
    // Update the state synchronously
    setState(() {
      feedbackData = data;
      if (feedbackData['data'] != null) {
        startDate = DateTime.parse(feedbackData['data']['start_date']);
        endDate = DateTime.parse(feedbackData['data']['end_date']);
        selectReason = feedbackData['data']['is_reason_imgage_required'];
        addExternalLink = feedbackData['data']['is_link_required'];
        externalLinkController.text = feedbackData['data']['link'] ?? "";
      } else {
        feedbackData = {};
      }
    });
    LoggerService.logger.i(feedbackData);
  }

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
                  addExternalLink = false;
                });
              },
            ),
            const SizedBox(height: 10),

            // Add Image Evidence
            SwitchListTile(
              title: const Text('Add Image Evidence'),
              value: selectReason,
              onChanged: (value) {
                setState(() {
                  selectReason = value;
                  addExternalLink = false;
                });
              },
            ),
            const SizedBox(height: 10),

            // Show date pickers if selectReason is true
            // if (selectReason)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Select start date'),
                    TextButton(
                      onPressed: () => _selectDate(context, true),
                      child: Text(
                        startDate != null
                            ? '${startDate!.toLocal()}'.split(' ')[0]
                            : 'Pick a date',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Select end date'),
                    TextButton(
                      onPressed: () => _selectDate(context, false),
                      child: Text(
                        endDate != null
                            ? '${endDate!.toLocal()}'.split(' ')[0]
                            : 'Pick a date',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),

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
                      selectReason = false;
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
                  setState(() {
                    // ignore: unnecessary_null_comparison
                    if (feedbackData.isEmpty) {
                      if (addExternalLink) {
                        if (externalLinkController.text.isNotEmpty) {
                          createFeedbackCancel(
                            int.parse(widget.eventId),
                            startDate,
                            startDate,
                            false,
                            addExternalLink,
                            externalLinkController.text,
                          );
                        }
                      } else {
                        createFeedbackCancel(
                          int.parse(widget.eventId),
                          startDate!,
                          endDate!,
                          selectReason,
                          false,
                          null,
                        );
                      }
                      Navigator.pop(context);
                    } else if (feedbackData.isNotEmpty) {
                      if (addExternalLink) {
                        // if (externalLinkController.text.isNotEmpty) {
                        updateFeedbackCancel(
                            feedbackData['data']['id'],
                            int.parse(widget.eventId),
                            startDate!,
                            endDate!,
                            false,
                            addExternalLink,
                            externalLinkController.text);
                        LoggerService.logger.i(feedbackData['data']['id']);
                        // }
                      } else {
                        // LoggerService.logger.i('Feedback updated');
                        updateFeedbackCancel(
                            feedbackData['data']['id'],
                            int.parse(widget.eventId),
                            startDate!,
                            endDate!,
                            true,
                            false,
                            "");
                      }
                    }
                    Navigator.pop(context);
                  });
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
