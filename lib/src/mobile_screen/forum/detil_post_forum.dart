import 'package:flutter/material.dart';

class ForumPostPage extends StatefulWidget {
  const ForumPostPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ForumPostPageState createState() => _ForumPostPageState();
}

class _ForumPostPageState extends State<ForumPostPage> {
  List<Map<String, dynamic>> comments = [
    {
      'author': 'Michael Chen',
      'time': '1 hour ago',
      'content':
          'These are great tips! I especially like the point about taking regular breaks. It really helps maintain focus.',
      'likes': '24',
      'replies': []
    },
    {
      'author': 'Emily Wilson',
      'time': '45 minutes ago',
      'content':
          'Could you share more details about your note-taking method? It sounds interesting!',
      'likes': '12',
      'replies': []
    },
  ];

  final TextEditingController _commentController = TextEditingController();

  void _addComment(String content) {
    setState(() {
      comments.add({
        'author': 'You',
        'time': 'Just now',
        'content': content,
        'likes': '0',
        'replies': [],
      });
      _commentController.clear();
    });
  }

  void _addReply(int commentIndex, String replyContent) {
    setState(() {
      comments[commentIndex]['replies'].add({
        'author': 'You',
        'time': 'Just now',
        'content': replyContent,
        'likes': '0',
      });
    });
  }

  void _likeComment(int index) {
    setState(() {
      comments[index]['likes'] =
          (int.parse(comments[index]['likes']) + 1).toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forum Post'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tips for Improving Your Study Habits',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'I wanted to share some effective study techniques that have helped me maintain good grades while balancing other activities. Here are my top recommendations for productive study sessions...',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.favorite, color: Colors.red),
                SizedBox(width: 5),
                Text('248'),
                SizedBox(width: 20),
                Icon(Icons.comment),
                SizedBox(width: 5),
                Text('42'),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Comments',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  final comment = comments[index];
                  return CommentItem(
                    author: comment['author']!,
                    time: comment['time']!,
                    content: comment['content']!,
                    likes: comment['likes']!,
                    replies: comment['replies'],
                    onReply: (replyContent) => _addReply(index, replyContent),
                    onLike: () => _likeComment(index),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: 'Write a comment...',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      if (_commentController.text.isNotEmpty) {
                        _addComment(_commentController.text);
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CommentItem extends StatefulWidget {
  final String author;
  final String time;
  final String content;
  final String likes;
  final List<dynamic> replies;
  final Function(String) onReply;
  final Function() onLike;

  const CommentItem({
    super.key,
    required this.author,
    required this.time,
    required this.content,
    required this.likes,
    required this.replies,
    required this.onReply,
    required this.onLike,
  });

  @override
  // ignore: library_private_types_in_public_api
  _CommentItemState createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem> {
  final TextEditingController _replyController = TextEditingController();
  bool _isReplying = false; // Flag to show the reply box

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(child: Text(widget.author[0])),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.author,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(widget.time, style: const TextStyle(color: Colors.grey)),
                ],
              ),
              // const Spacer(),
              // Text('${widget.likes} Likes'),
              // IconButton(
              //   icon: const Icon(Icons.thumb_up),
              //   onPressed: widget.onLike,
              // ),
            ],
          ),
          const SizedBox(height: 5),
          Text(widget.content),
          const SizedBox(height: 5),
          Row(
            children: [
              // "Like" button on the same row
              IconButton(
                icon: const Icon(Icons.thumb_up),
                onPressed: widget.onLike,
              ),
              Text('${widget.likes} Likes'),
              const SizedBox(width: 20),
              // "Reply" button
              TextButton(
                onPressed: () {
                  setState(() {
                    _isReplying = !_isReplying; // Toggle reply box visibility
                  });
                },
                child: const Text("Reply"),
              ),
            ],
          ),
          if (_isReplying) // Show the reply input field if _isReplying is true
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: TextField(
                controller: _replyController,
                decoration: InputDecoration(
                  hintText: 'Reply...',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      if (_replyController.text.isNotEmpty) {
                        widget.onReply(_replyController.text);
                        _replyController.clear();
                      }
                    },
                  ),
                ),
              ),
            ),
          const SizedBox(height: 10),
          if (widget.replies.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Column(
                children: widget.replies.map<Widget>((reply) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(child: Text(reply['author'][0])),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(reply['author'],
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          Text(reply['content']),
                        ],
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
