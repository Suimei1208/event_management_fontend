import 'package:flutter/material.dart';

class CreateEventScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tạo Sự Kiện")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Tên sự kiện'),
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Lịch trình'),
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Địa điểm'),
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Mục tiêu sự kiện'),
            ),
            ElevatedButton(
              onPressed: () {
                // Event creation logic goes here
              },
              child: Text('Tạo sự kiện'),
            ),
          ],
        ),
      ),
    );
  }
}
