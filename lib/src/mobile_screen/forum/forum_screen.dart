import 'package:event_management/generated/l10n.dart';
import 'package:event_management/src/mobile_screen/forum/create_post.dart';
import 'package:event_management/src/mobile_screen/forum/detail_post_forum.dart';
import 'package:event_management/src/models/info_user.dart';
import 'package:event_management/src/service/forum_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CommunityForumScreen extends StatefulWidget {
  const CommunityForumScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CommunityForumScreenState createState() => _CommunityForumScreenState();
}

class _CommunityForumScreenState extends State<CommunityForumScreen> {
  final router = "/forums";

  List<Map<String, dynamic>> posts = [];
  String selectedFilter = "all";

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    final data = await getPosts();
    if (mounted) {
      setState(() {
        posts = _applyFilter(data);
      });
    }
  }

  List<Map<String, dynamic>> _applyFilter(List<Map<String, dynamic>> data) {
    if (selectedFilter == "popular") {
      data.sort((a, b) => (b['likes'] as int).compareTo(a['likes'] as int));
    } else if (selectedFilter == "latest") {
      data.sort((a, b) => DateTime.parse(b['timepost'])
          .compareTo(DateTime.parse(a['timepost'])));
    }
    return data;
  }

  Future<void> _handleRefresh() async {
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          S.of(context).welcome_forum,
          style: const TextStyle(fontSize: 24),
          softWrap: true,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const CreatePostScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context).guide_forum,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: [
                FilterChip(
                  label: Text(S.of(context).all),
                  selected: selectedFilter == "all",
                  onSelected: (selected) {
                    setState(() {
                      selectedFilter = "all";
                      _fetchData();
                    });
                  },
                ),
                FilterChip(
                  label: Text(S.of(context).popular),
                  selected: selectedFilter == "popular",
                  onSelected: (selected) {
                    setState(() {
                      selectedFilter = "popular";
                      posts = _applyFilter(posts);
                    });
                  },
                ),
                FilterChip(
                  label: Text(S.of(context).latest),
                  selected: selectedFilter == "latest",
                  onSelected: (selected) {
                    setState(() {
                      selectedFilter = "latest";
                      posts = _applyFilter(posts);
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _handleRefresh,
                child: ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return PostItem(
                      id: int.parse(post['id'].toString()),
                      author: InfoUser.fromJson(post['user']),
                      time: DateTime.parse(post['timepost']),
                      title: post['title'].toString(),
                      content: post['description'].toString(),
                      comments:
                          int.tryParse(post['comments_count'].toString()) ?? 0,
                      likes: int.tryParse(post['likes'].toString()) ?? 0,
                      type: post['category'].toString(),
                      image: post['image'].toString(),
                      isLike: post['isLike'],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class PostItem extends StatefulWidget {
  final int id;
  final InfoUser author;
  final DateTime time;
  final String title;
  final String content;
  final int comments;
  int likes;
  final String type;
  final String image;
  bool isLike;

  PostItem({
    super.key,
    required this.id,
    required this.author,
    required this.time,
    required this.title,
    required this.content,
    required this.comments,
    required this.likes,
    required this.type,
    required this.image,
    required this.isLike,
  });

  @override
  State<PostItem> createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> {
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

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ForumPostPage(
                    idPost: widget.id,
                  )),
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
                  InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            // title: Text(author.name),
                            content: SizedBox(
                              width: double.infinity,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        foregroundImage:
                                            NetworkImage(widget.author.avtUrl),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                widget.author.name,
                                                style: const TextStyle(
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text(widget.author.nameFromEmail),
                                              Text(
                                                widget.author.email,
                                                softWrap: true,
                                                overflow: TextOverflow.ellipsis,
                                              )
                                            ]),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(); // Close the dialog
                                },
                                child: const Text('Close'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Row(
                      children: [
                        CircleAvatar(
                          foregroundImage: NetworkImage(widget.author.avtUrl),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.author.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            Text(formatTime(widget.time),
                                style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Chip(label: Text(widget.type)),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                widget.title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(widget.content),
              const SizedBox(height: 10),
              // ignore: unnecessary_null_comparison
              if (widget.image != null && widget.image.isNotEmpty)
                Center(
                    child: Image.network(
                  widget.image,
                  height: 200,
                  width: 200,
                )),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.comment, size: 16),
                      const SizedBox(width: 5),
                      Text('${widget.comments}'),
                    ],
                  ),
                  InkWell(
                    onTap: () async {
                      setState(() {
                        widget.isLike = !widget.isLike;
                        if (widget.isLike) {
                          widget.likes = widget.likes + 1;
                        } else {
                          widget.likes = widget.likes - 1;
                        }
                      });
                      await updateLike(widget.id, widget.isLike);
                    },
                    child: Row(
                      children: [
                        Icon(
                            widget.isLike
                                ? Icons.thumb_up_alt_rounded
                                : Icons.thumb_up_alt_outlined,
                            size: 16),
                        const SizedBox(width: 5),
                        Text('${widget.likes}'),
                      ],
                    ),
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
