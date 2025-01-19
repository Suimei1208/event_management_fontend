// ignore_for_file: must_be_immutable

import 'package:event_management/generated/l10n.dart';
import 'package:event_management/src/models/info_user.dart';
import 'package:event_management/src/service/forum_service.dart';
import 'package:event_management/src/web-screen/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WebCommunityForumScreen extends StatefulWidget {
  const WebCommunityForumScreen({super.key});
  static const routeName = "/forum";

  @override
  State<WebCommunityForumScreen> createState() => _CommunityForumScreenState();
}

class _CommunityForumScreenState extends State<WebCommunityForumScreen> {
  List<Map<String, dynamic>> posts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final data = await getPosts(); // Fetch posts using API
      if (mounted) {
        setState(() {
          posts = data;
          isLoading = false;
        });
      }
    } catch (error) {
      // Handle API errors (e.g., network issues)
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      debugPrint('Error fetching posts: $error');
    }
  }

  Future<void> _handleRefresh() async {
    setState(() => isLoading = true);
    await _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
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
                          selected: true,
                          onSelected: (selected) {
                            // Filter logic here
                          }),
                      FilterChip(
                          label: Text(S.of(context).popular),
                          selected: false,
                          onSelected: (selected) {
                            // Filter logic here
                          }),
                      FilterChip(
                          label: Text(S.of(context).latest),
                          selected: false,
                          onSelected: (selected) {
                            // Filter logic here
                          }),
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
                          return WebPostItem(
                            id: int.parse(post['id'].toString()),
                            author: InfoUser.fromJson(post['user']),
                            time: DateTime.parse(post['timepost']),
                            title: post['title'].toString(),
                            content: post['description'].toString(),
                            comments: int.tryParse(
                                    post['comments_count'].toString()) ??
                                0,
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

class WebPostItem extends StatefulWidget {
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

  WebPostItem({
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
  State<WebPostItem> createState() => _WebPostItemState();
}

class _WebPostItemState extends State<WebPostItem> {
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
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Post header
            Row(
              children: [
                CircleAvatar(
                  foregroundImage: NetworkImage(widget.author.avtUrl),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.author.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(formatTime(widget.time),
                          style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                Chip(label: Text(widget.type)),
              ],
            ),
            const SizedBox(height: 10),
            // Post content
            Text(
              widget.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(widget.content),
            const SizedBox(height: 10),
            if (widget.image.isNotEmpty)
              Center(
                child: Image.network(
                  widget.image,
                  height: 200 * 16 / 9,
                  width: 200,
                  fit: BoxFit.contain,
                ),
              ),
            const SizedBox(height: 10),
            // Post interactions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.comment, size: 16),
                    const SizedBox(width: 5),
                    Text('${widget.comments} Comments'),
                  ],
                ),
                InkWell(
                  onTap: () async {
                    setState(() {
                      widget.isLike = !widget.isLike;
                      widget.likes += widget.isLike ? 1 : -1;
                    });
                    await updateLike(widget.id, widget.isLike);
                  },
                  child: Row(
                    children: [
                      Icon(
                        widget.isLike
                            ? Icons.thumb_up_alt_rounded
                            : Icons.thumb_up_alt_outlined,
                        size: 16,
                      ),
                      const SizedBox(width: 5),
                      Text('${widget.likes} Likes'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
