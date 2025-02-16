import 'package:event_management/generated/l10n.dart';
import 'package:event_management/src/models/info_user.dart';
import 'package:event_management/src/service/forum_service.dart';
import 'package:event_management/src/web-screen/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForumPostPageWeb extends StatefulWidget {
  final int idPost;
  const ForumPostPageWeb({super.key, required this.idPost});

  static const routeName = 'forum/detail-post/';

  @override
  // ignore: library_private_types_in_public_api
  _ForumPostPageWebState createState() => _ForumPostPageWebState();
}

String formatTime(DateTime time, BuildContext context) {
  final now = DateTime.now();
  final difference = now.difference(time);

  if (difference.inHours < 24) {
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} ${S.of(context).minutes_ago}';
    } else {
      return '${difference.inHours} ${S.of(context).hours_ago}';
    }
  } else {
    return DateFormat('dd/MM/yyyy hh:mm a').format(time);
  }
}

class _ForumPostPageWebState extends State<ForumPostPageWeb> {
  Map<String, dynamic> post = {};
  List<Map<String, dynamic>> comments = [];
  bool _isLoading = true;

  final TextEditingController _commentController = TextEditingController();
  InfoUser? _hostPost;
  bool? _isLiked;
  User? user = FirebaseAuth.instance.currentUser;

  @override
  initState() {
    super.initState();
    _fetchData();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    // Fetch data from the server
    Map<String, dynamic> data = await getDetailPost(widget.idPost);
    // LoggerService.logger.i('Data: $data');
    if (!mounted) return;
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      post = data['post'];
      comments = List<Map<String, dynamic>>.from(
          data['comments'].map((commentData) => {
                'comment': commentData['comments'],
                'user': commentData['user'],
                'replies': List<Map<String, dynamic>>.from(
                    commentData['replies'].map((replyData) => {
                          'reply': replyData['reply'],
                          'user': replyData['user'],
                        }))
              }));
      if (data['user'] != null) {
        _hostPost = InfoUser.fromJson(data['user']);
      }
      _isLiked = data['isLike'];
    });
  }

  Future<void> _addComment(String content) async {
    if (user == null) return;

    Map<String, dynamic> comment = {
      'comment': {
        'author': user!.displayName ?? 'You',
        'avtUrl': user!.photoURL ?? '',
        'timepost': DateTime.now().toString(),
        'comment': content,
        'likes': '0',
      },
      'user': {
        'name': user!.displayName ?? 'You',
        'avtUrl': user!.photoURL ?? '',
      },
      'replies': [],
    };

    if (!mounted) return;
    setState(() {
      comments.add(comment);
      _commentController.clear();
    });

    await createComment(content, widget.idPost);
    _fetchData();
  }

  Future<void> _addReply(
      int commentIndex, String replyContent, int idComment) async {
    if (user == null) return;

    Map<String, dynamic> reply = {
      'reply': {
        'timepost': DateTime.now().toString(),
        'comment': replyContent,
      },
      'user': {
        'name': user!.displayName ?? 'You',
        'avtUrl': user!.photoURL ?? '',
      }
    };

    if (!mounted) return;
    setState(() {
      comments[commentIndex]['replies'].add(reply);
    });

    await createReplyComment(replyContent, idComment);
  }

  void _likeComment(int index) {
    if (!mounted) return;
    setState(() {
      comments[index]['comment']['likes'] =
          (int.parse(comments[index]['comment']['likes']) + 1).toString();
    });
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isLoading = true;
    });
    await _fetchData();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _handleRefresh, // Attach the refresh method
              child: Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 700),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_hostPost != null)
                              Row(
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        foregroundImage:
                                            NetworkImage(_hostPost!.avtUrl),
                                      ),
                                      const SizedBox(width: 20),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(_hostPost!.name,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          if (post['timepost'] != null)
                                            Text(
                                                formatTime(
                                                    DateTime.parse(
                                                        post['timepost']),
                                                    context),
                                                style: const TextStyle(
                                                    color: Colors.grey)),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  if (user != null &&
                                      user!.uid == _hostPost!.id)
                                    IconButton(
                                      icon: const Icon(
                                          Icons.more_vert), // Ba chấm dọc
                                      onPressed: () {
                                        showModalBottomSheet(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return Wrap(
                                              children: [
                                                ListTile(
                                                  leading: const Icon(
                                                      Icons.edit,
                                                      color: Colors.blue),
                                                  title: Text(
                                                      S.of(context).edit_post),
                                                  onTap: () {
                                                    // Navigator.push(
                                                    //   context,
                                                    //   MaterialPageRoute(
                                                    //     builder: (context) =>
                                                    //         EditPostScreen(
                                                    //       postId: widget.idPost,
                                                    //       initialTitle:
                                                    //           post['title'],
                                                    //       initialDescription:
                                                    //           post[
                                                    //               'description'],
                                                    //       initialCategory:
                                                    //           post['category'],
                                                    //       initialImageUrl:
                                                    //           post['image'],
                                                    //     ),
                                                    //   ),
                                                    Navigator.pushNamed(
                                                      context,
                                                      '/forum/detail-post/${widget.idPost}/edit',
                                                      arguments: {
                                                        'initialTitle':
                                                            post['title'],
                                                        'initialDescription':
                                                            post['description'],
                                                        'initialCategory':
                                                            post['category'],
                                                        'initialImageUrl':
                                                            post['image'],
                                                      },
                                                    );
                                                  },
                                                ),
                                                ListTile(
                                                  leading: const Icon(
                                                      Icons.delete,
                                                      color: Colors.red),
                                                  title: Text(
                                                      S.of(context).del_post),
                                                  onTap: () async {
                                                    Navigator.pop(context);
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                          title: Text(S
                                                              .of(context)
                                                              .confirm_del),
                                                          content: Text(S
                                                              .of(context)
                                                              .quest_del),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              child: Text(S
                                                                  .of(context)
                                                                  .cancel),
                                                            ),
                                                            TextButton(
                                                              onPressed:
                                                                  () async {
                                                                await deletePost(
                                                                    widget
                                                                        .idPost);
                                                                Navigator.pop(
                                                                    // ignore: use_build_context_synchronously
                                                                    context);
                                                                Navigator.pop(
                                                                    // ignore: use_build_context_synchronously
                                                                    context);
                                                              },
                                                              child: const Text(
                                                                  'Có',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .red)),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
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
                            if (post['image'] != null &&
                                post['image'].isNotEmpty)
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
                                          post['likes'] = (int.parse(
                                                      post['likes']
                                                          .toString()) +
                                                  1)
                                              .toString();
                                        } else {
                                          post['likes'] = (int.parse(
                                                      post['likes']
                                                          .toString()) -
                                                  1)
                                              .toString();
                                        }
                                      });
                                      await updateLike(
                                          widget.idPost, _isLiked!);
                                    },
                                    icon: _isLiked!
                                        ? const Icon(Icons.thumb_up,
                                            color: Colors.red)
                                        : const Icon(
                                            Icons.thumb_up_alt_rounded),
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
                            Text(
                              S.of(context).comment,
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 20),
                            comments.isEmpty
                                ? const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(10.0),
                                      child: Text('No comments yet'),
                                    ),
                                  )
                                : Column(
                                    children: comments.map((comment) {
                                      final commentIndex =
                                          comments.indexOf(comment);
                                      return CommentItem(
                                        author: comment['user']['name'],
                                        avtUrl: comment['user']['avtUrl'],
                                        time: formatTime(
                                            DateTime.parse(
                                                comment['comment']['timepost']),
                                            context),
                                        content: comment['comment']['comment'],
                                        likes: comment['comment']['likes']
                                            .toString(),
                                        replies: comment['replies'],
                                        onReply: (replyContent) => _addReply(
                                            commentIndex,
                                            replyContent,
                                            comment['comment']['id']),
                                        onLike: () =>
                                            _likeComment(commentIndex),
                                      );
                                    }).toList(),
                                  ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: TextField(
                                controller: _commentController,
                                decoration: InputDecoration(
                                  hintText: S.of(context).write_comment,
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
                  ),
                ),
              ),
            ),
    );
  }
}

class CommentItem extends StatefulWidget {
  final String author;
  final String avtUrl;
  final String time;
  final String content;
  final String likes;
  final List<dynamic> replies;
  final Function(String) onReply;
  final Function() onLike;

  const CommentItem({
    super.key,
    required this.author,
    required this.avtUrl,
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
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      foregroundImage: NetworkImage(widget.avtUrl),
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.author,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        Text(widget.time,
                            style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Text(widget.content),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isReplying = !_isReplying;
                        });
                      },
                      child: Text(S.of(context).reply),
                    ),
                  ],
                ),
                if (_isReplying)
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Column(
                      children: [
                        TextField(
                          controller: _replyController,
                          decoration: InputDecoration(
                            hintText: 'Write a reply...',
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.send),
                              onPressed: () {
                                if (_replyController.text.isNotEmpty) {
                                  widget.onReply(_replyController.text);
                                  setState(() {
                                    _replyController.clear();
                                    _isReplying = false;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ...widget.replies.map((reply) {
                  final userName = reply['user']?['name'] ?? 'Unknown';
                  final replyTime = reply['reply']?['timepost'];
                  final replyComment = reply['reply']?['comment'] ?? '';
                  return Container(
                    decoration: BoxDecoration(
                      border: Border(
                          top: BorderSide(
                              color: Theme.of(context).dividerColor)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0, top: 10.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            foregroundImage:
                                NetworkImage(reply['user']?['avtUrl'] ?? ''),
                          ),
                          const SizedBox(width: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(userName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              if (replyTime != null)
                                Text(
                                    formatTime(
                                        DateTime.parse(replyTime), context),
                                    style: const TextStyle(color: Colors.grey)),
                              Text(replyComment),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        )
      ],
    );
  }
}
