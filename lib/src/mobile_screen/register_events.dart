import 'package:flutter/material.dart';

// Giao diện danh sách sự kiện
class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  // ignore: non_constant_identifier_names
  final Route = "/register_events";

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  // Dữ liệu mẫu
  final List<Map<String, dynamic>> events = [
    {
      "id": 1,
      "name": "AI & Machine Learning Conference",
      "description": "Conference about AI and ML",
      "startDate": DateTime(2024, 3, 15),
      "endDate": DateTime(2024, 3, 17),
      "location": "Location A",
      "status": "Approved", // Approved, Pending, Available
      "user": {
        "id": 101,
        "name": "John Doe",
        "avatar":
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ25ltiIj_X-v_Td2kdh0MMm7UH-GMwo00Q-g&s",
      },
    },
    {
      "id": 2,
      "name": "Web Development Workshop",
      "description": "Learn modern web development",
      "startDate": DateTime(2024, 3, 20),
      "endDate": DateTime(2024, 3, 20),
      "location": "Location B",
      "status": "Available", // Approved, Pending, Available
      "user": {
        "id": 102,
        "name": "Jane Smith",
        "avatar":
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ25ltiIj_X-v_Td2kdh0MMm7UH-GMwo00Q-g&s",
      },
    },
    {
      "id": 3,
      "name": "Flutter Development Bootcamp",
      "description": "Learn to build mobile apps with Flutter",
      "startDate": DateTime(2024, 4, 10),
      "endDate": DateTime(2024, 4, 12),
      "location": "Location C",
      "status": "Pending",
      "user": {
        "id": 103,
        "name": "Alice Johnson",
        "avatar":
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ25ltiIj_X-v_Td2kdh0MMm7UH-GMwo00Q-g&s",
      },
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Events"),
      ),
      body: ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          final user = event["user"];

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
                    // Tên sự kiện và trạng thái sự kiện
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
                            color: event["status"] == "Approved"
                                ? Colors.green[100]
                                : event["status"] == "Pending"
                                    ? Colors.orange[100]
                                    : Colors.blue[100],
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Text(
                            event["status"],
                            style: TextStyle(
                              color: event["status"] == "Approved"
                                  ? Colors.green
                                  : event["status"] == "Pending"
                                      ? Colors.orange
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
                          backgroundImage: NetworkImage(user["avatar"]),
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
                          "${event["startDate"].toLocal().toString().split(' ')[0]} to ${event["endDate"].toLocal().toString().split(' ')[0]}",
                          style: const TextStyle(fontSize: 14.0),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),

                    // Nút hành động
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
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: const Text("Register"),
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
}
