import 'package:event_management/src/mobile_screen/forum/detil_post_forum.dart';
import 'package:flutter/material.dart';

class CommunityForumScreen extends StatelessWidget {
  final router = "/forums";
  final List<Map<String, dynamic>> posts = [
    {
      'author': 'Sarah Johnson',
      'time': '2 hours ago',
      'title': 'Best practices for mobile app development?',
      'content':
          'I\'m starting a new mobile app project and would love to hear about best practices for architecture, state management, and testing...',
      'comments': 24,
      'likes': 18,
      'type': 'Discussion',
    },
    {
      'author': 'David Chen',
      'time': '5 hours ago',
      'title': 'How to implement authentication in Flutter?',
      'content':
          'Looking for recommendations on implementing secure authentication in a Flutter app. What are the best packages and approaches?',
      'comments': 15,
      'likes': 12,
      'type': 'Question',
    },
    {
      'author': 'Emily Wilson',
      'time': '8 hours ago',
      'title': 'Complete guide to state management',
      'content':
          'In this tutorial, I\'ll cover different state management solutions in Flutter and when to use each one...',
      'comments': 42,
      'likes': 28,
      'type': 'Tutorial',
    },
  ];

  CommunityForumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forum'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome to the Community',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Join discussions, share knowledge, and connect with others',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8.0, // Khoảng cách ngang giữa các FilterChip
              runSpacing:
                  4.0, // Khoảng cách dọc giữa các FilterChip nếu xuống dòng
              children: [
                FilterChip(
                    label: const Text('All Topics'),
                    selected: true,
                    onSelected: (selected) {}),
                FilterChip(
                    label: const Text('Popular'),
                    selected: false,
                    onSelected: (selected) {}),
                FilterChip(
                    label: const Text('Latest'),
                    selected: false,
                    onSelected: (selected) {}),
                FilterChip(
                    label: const Text('Unanswered'),
                    selected: false,
                    onSelected: (selected) {}),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return PostItem(
                    author: post['author'],
                    time: post['time'],
                    title: post['title'],
                    content: post['content'],
                    comments: post['comments'],
                    likes: post['likes'],
                    type: post['type'],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PostItem extends StatelessWidget {
  final String author;
  final String time;
  final String title;
  final String content;
  final int comments;
  final int likes;
  final String type;

  const PostItem({
    super.key,
    required this.author,
    required this.time,
    required this.title,
    required this.content,
    required this.comments,
    required this.likes,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ForumPostPage()),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(child: Text(author[0])),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(author,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(time, style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const Spacer(),
                  Chip(label: Text(type)),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(content),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.comment, size: 16),
                      const SizedBox(width: 5),
                      Text('$comments'),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.thumb_up, size: 16),
                      const SizedBox(width: 5),
                      Text('$likes'),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
