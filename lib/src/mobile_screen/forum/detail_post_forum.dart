import 'package:event_management/src/models/info_user.dart';
import 'package:event_management/src/service/forum_service.dart';
import 'package:event_management/src/service/logger_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ForumPostPage extends StatefulWidget {
  final int idPost;
  const ForumPostPage({super.key, required this.idPost});

  @override
  // ignore: library_private_types_in_public_api
  _ForumPostPageState createState() => _ForumPostPageState();
}

class _ForumPostPageState extends State<ForumPostPage> {
  Map<String, dynamic> post = {};
  List<Map<String, dynamic>> comments = [];

  final TextEditingController _commentController = TextEditingController();
  User? _hostPost;
  bool? _isLiked;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    // Fetch data from the server
    Map<String, dynamic> data = await getDetailPost(widget.idPost);
    LoggerService.logger.i('Data: $data');
    setState(() {
      post = data['post'];
      comments = List<Map<String, dynamic>>.from(data['comments']);
      if (data['user'] != null) {
        _hostPost = User.fromJson(data['user']);
      }
      _isLiked = data['isLike'];
    });

    // LoggerService.logger.i('Post: $post');
    // LoggerService.logger.i('Comments: $comments');
    // LoggerService.logger.i('Host post: $_hostPost');
  }

  String formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inHours < 24) {
      if (difference.inMinutes < 60) {
        return '${difference.inMinutes} minutes ago';
      } else {
        return '${difference.inHours} hours ago';
      }
    } else {
      return DateFormat('dd/MM/yyyy hh:mm a').format(time);
    }
  }

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
        title: const Text('Detail Post'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_hostPost != null)
                Row(
                  children: [
                    CircleAvatar(
                      foregroundImage: NetworkImage(_hostPost!.avtUrl),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_hostPost!.name,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        if (post['timepost'] != null)
                          Text(formatTime(DateTime.parse(post['timepost'])),
                              style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              const SizedBox(height: 10),
              if (post['title'] != null)
                Text(
                  post['title'],
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
              const SizedBox(height: 10),
              Text(
                post['description'].toString(),
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              if (post['image'] != null && post['image'].isNotEmpty)
                Image.network(
                  post['image'],
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if (_isLiked != null)
                    IconButton(
                      onPressed: () async {
                        setState(() {
                          _isLiked = !_isLiked!;
                          if (_isLiked!) {
                            post['likes'] =
                                (int.parse(post['likes'].toString()) + 1)
                                    .toString();
                          } else {
                            post['likes'] =
                                (int.parse(post['likes'].toString()) - 1)
                                    .toString();
                          }
                        });
                        await updateLike(widget.idPost, _isLiked!);
                      },
                      icon: _isLiked!
                          ? const Icon(Icons.thumb_up, color: Colors.red)
                          : const Icon(Icons.thumb_up_alt_rounded),
                    ),
                  const SizedBox(width: 5),
                  Text(post['likes'].toString()),
                  const SizedBox(width: 20),
                  const Icon(Icons.comment),
                  const SizedBox(width: 5),
                  Text(post['comments_count'].toString()),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Comments',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              comments.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Text('No comments yet'),
                      ),
                    )
                  : SizedBox(
                      height: 400, // Set a fixed height for the ListView
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
                            onReply: (replyContent) =>
                                _addReply(index, replyContent),
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
  bool _isReplying = false;

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
            ],
          ),
          const SizedBox(height: 5),
          Text(widget.content),
          const SizedBox(height: 5),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.thumb_up),
                onPressed: widget.onLike,
              ),
              Text('${widget.likes} Likes'),
              const SizedBox(width: 20),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isReplying = !_isReplying;
                  });
                },
                child: const Text("Reply"),
              ),
            ],
          ),
          if (_isReplying)
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
