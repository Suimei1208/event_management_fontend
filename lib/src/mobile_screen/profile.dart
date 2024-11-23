import 'package:flutter/material.dart';

class UserProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Hồ Sơ Người Dùng")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage("https://www.example.com/avatar.png"),
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Tên'),
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Số điện thoại'),
            ),
            ElevatedButton(
              onPressed: () {
                // Update profile logic goes here
              },
              child: Text('Cập nhật thông tin'),
            ),
          ],
        ),
      ),
    );
  }
}
