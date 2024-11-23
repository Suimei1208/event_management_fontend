import 'package:flutter/material.dart';

class EditEventScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chỉnh Sửa Sự Kiện")),
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
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Save edited event
                  },
                  child: Text('Lưu sự kiện'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    // Delete event
                  },
                  child: Text('Xóa sự kiện'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
