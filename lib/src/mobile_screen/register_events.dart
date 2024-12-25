import 'package:event_management/src/service/participants.dart';
import 'package:flutter/material.dart';
import 'package:event_management/src/service/event_service.dart';

class EventRegisterScreen extends StatefulWidget {
  const EventRegisterScreen({super.key});

  static const routeName = "/register_events";

  @override
  State<EventRegisterScreen> createState() => _EventRegisterScreenState();
}

class _EventRegisterScreenState extends State<EventRegisterScreen> {
  late final List<Map<String, dynamic>> events = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() {
    fetchEventCanRegister().then((data) {
      if (mounted) {
        setState(() {
          events.addAll(data);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register Events"),
      ),
      body: ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          final user = event["user"];
          String? isRegistered =
              event["isRegistered"]; // Get registration state per event

          return Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            event["name"],
                            style: const TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                            maxLines: 2,
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                          decoration: BoxDecoration(
                            color: event["status"] == "Upcoming"
                                ? Colors.green[100]
                                : Colors.blue[100],
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Text(
                            event["status"],
                            style: TextStyle(
                              color: event["status"] == "Upcoming"
                                  ? Colors.green
                                  : Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),

                    // Người dùng và avatar
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(user["photoUrl"]),
                          radius: 16.0,
                        ),
                        const SizedBox(width: 8.0),
                        Text(
                          user["name"],
                          style: const TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),

                    // Ngày bắt đầu và kết thúc
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16.0),
                        const SizedBox(width: 4.0),
                        Text(
                          "${_parseDate(event["startDate"])} to ${_parseDate(event["endDate"])}",
                          style: const TextStyle(fontSize: 14.0),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),

                    // Nút hành động (Register/Unregister)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            // Xử lý logic View Details
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    "Viewing details for ${event["name"]}"),
                              ),
                            );
                          },
                          child: const Text("View Details"),
                        ),
                        ElevatedButton(
                          onPressed: isRegistered == "Approved"
                              ? null // Vô hiệu hóa nút nếu trạng thái là "Approved"
                              : () async {
                                  if (isRegistered == null) {
                                    await UserRegisterEvent(
                                        event["id"].toString());
                                  } else if (isRegistered == "Pending") {
                                    await unregisterEvent(
                                        event["id"].toString());
                                  }
                                  setState(() {
                                    if (isRegistered == "Pending") {
                                      event["isRegistered"] = null;
                                    } else if (isRegistered == "Rejected") {
                                    } else {
                                      event["isRegistered"] = "Pending";
                                    }
                                  });
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isRegistered == "Approved"
                                ? Colors
                                    .grey // Màu xám nếu trạng thái là "Approved" (disabled)
                                : (isRegistered == "Pending"
                                    ? Colors.green
                                    : Colors.blue),
                          ),
                          child: Text(
                            isRegistered == "Approved"
                                ? "Approved" // Nút hiển thị "Approved" và bị disable
                                : (isRegistered == "Pending"
                                    ? "Hủy đăng ký"
                                    : "Đăng ký"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Helper function to parse date and return formatted date string
  String _parseDate(String date) {
    try {
      DateTime parsedDate = DateTime.parse(date);
      return parsedDate
          .toLocal()
          .toString()
          .split(' ')[0]; // returns the date in YYYY-MM-DD format
    } catch (e) {
      return "Invalid Date"; // Handle invalid date format
    }
  }
}
