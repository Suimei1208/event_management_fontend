import 'package:flutter/material.dart';

class CommunityForumScreen extends StatelessWidget {
  CommunityForumScreen({super.key});

  final router = "/forums";

  final List<Map<String, dynamic>> data = [
    {
      'id': '1',
      'title': 'Best practices for getting started with the platform?',
      'type': 'Question',
      'replies': '8',
      'likes': '23',
      'imageUrl': 'https://images.unsplash.com/photo-1592496000931-e50d83df1286?w=500&h=500',
    },
    {
      'id': '2',
      'title': 'Share your success stories using our platform!',
      'type': 'Discussion',
      'replies': '12',
      'likes': '45',
      'imageUrl': 'https://images.unsplash.com/photo-1622570230313-3332b620271c?w=500&h=500',
    },
    {
      'id': '3',
      'title': 'Join us for our upcoming virtual meetup next week!',
      'type': 'Event',
      'replies': '15',
      'likes': '67',
      'imageUrl': 'https://images.unsplash.com/photo-1573484952901-03991c2ece8f?w=500&h=500',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            'Community Forum',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontFamily: 'Inter Tight',
                  letterSpacing: 0.0,
                ),
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.search,
                size: 24.0,
              ),
              onPressed: () {

              },
            ),
          ],
          centerTitle: false,
          elevation: 0.0,
        ),
        body: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Material(
                  elevation: 2.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Start a Discussion',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontFamily: 'Inter Tight',
                                  color: Colors.white,
                                  letterSpacing: 0.0,
                                ),
                          ),
                          const SizedBox(height: 12.0),
                          Text(
                            'Share your thoughts with the community',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontFamily: 'Inter',
                                  color: Colors.white,
                                  letterSpacing: 0.0,
                                ),
                          ),
                          const SizedBox(height: 12.0),
                          ElevatedButton(
                            onPressed: () {
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(MediaQuery.of(context).size.width, 50.0),
                              elevation: 2.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25.0),
                              ),
                            ),
                            child: Text(
                              'Create New Post',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontFamily: 'Inter Tight',
                                    color: Theme.of(context).colorScheme.primary,
                                    letterSpacing: 0.0,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12.0),
                Material(
                  color: Colors.transparent,
                  elevation: 2.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 1.0,
                    decoration: BoxDecoration(
                      color: Theme.of(context).secondaryHeaderColor,
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(20.0, 20.0, 20.0, 20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Popular Topics',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontFamily: 'Inter Tight',
                                  letterSpacing: 0.0,
                                ),
                          ),
                          const SizedBox(height: 16.0),
                          const Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            alignment: WrapAlignment.start,
                            children: [
                              TopicChip(
                                label: 'Announcements',
                                backgroundColor: Color(0xFFE3F2FD),
                                textColor: Color(0xFF1565C0),
                              ),
                              TopicChip(
                                label: 'Questions',
                                backgroundColor: Color(0xFFFFF3E0),
                                textColor: Color(0xFFFF6F00),
                              ),
                              TopicChip(
                                label: 'Discussion',
                                backgroundColor: Color(0xFFE8F5E9),
                                textColor: Color(0xFF2E7D32),
                              ),
                              TopicChip(
                                label: 'Events',
                                backgroundColor: Color(0xFFFCE4EC),
                                textColor: Color(0xFFC2185B),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12.0),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Recent Discussions',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 16.0),
                      // Sử dụng ListView.builder để hiển thị các mục trong data
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          var item = data[index];
                          return Column(
                            children: [
                              DiscussionCard(
                                imageUrl: item['imageUrl'],
                                type: item['type'],
                                title: item['title'],
                                replies: item['replies'],
                                likes: item['likes'],
                                typeColor: getTypeColor(item['type']),
                                textColor: getTypeTextColor(item['type']),
                                navigator: (BuildContext context){
                                },
                              ),
                              const SizedBox(height: 16.0),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color getTypeColor(String type) {
    switch (type) {
      case 'Question':
        return const Color(0xFFE3F2FD);
      case 'Discussion':
        return const Color(0xFFE8F5E9);
      case 'Event':
        return const Color(0xFFFCE4EC);
      default:
        return Colors.white;
    }
  }

  Color getTypeTextColor(String type) {
    switch (type) {
      case 'Question':
        return const Color(0xFF1565C0);
      case 'Discussion':
        return const Color(0xFF2E7D32);
      case 'Event':
        return const Color(0xFFC2185B);
      default:
        return Colors.black;
    }
  }
}

class DiscussionCard extends StatelessWidget {
  const DiscussionCard({
    super.key,
    required this.imageUrl,
    required this.type,
    required this.title,
    required this.replies,
    required this.likes,
    required this.typeColor,
    required this.textColor,
    required this.navigator,
  });

  final String imageUrl;
  final String type;
  final String title;
  final String replies;
  final String likes;
  final Color typeColor;
  final Color textColor;
  final Function(BuildContext) navigator;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        navigator(context);
      },
      child: Material(
        color: Colors.transparent,
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 1.0,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 24.0,
                      backgroundImage: NetworkImage(imageUrl),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.bold,
                            ),
                          ),                   
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Chip(
                      label: Text(
                        type,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 12.0,
                        ),
                      ),
                      backgroundColor: typeColor,
                    ),
                    const SizedBox(width: 8.0),
                    Row(children: [
                      const Icon(Icons.chat_bubble_outline),
                      const SizedBox(width: 8.0),
                      Text("$replies replies")
                    ],),
                    const SizedBox(width: 16.0),
                    Row(children: [
                      const Icon(Icons.favorite_border),
                      const SizedBox(width: 8.0),
                      Text("$likes likes")
                    ],),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TopicChip extends StatelessWidget {
  const TopicChip({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12.0,
        ),
      ),
      backgroundColor: backgroundColor,
    );
  }
}

