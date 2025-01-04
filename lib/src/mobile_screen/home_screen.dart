// ignore_for_file: unnecessary_null_comparison
import 'package:event_management/src/mobile_screen/detail_event.dart';
import 'package:event_management/src/mobile_screen/forum_screen.dart';
import 'package:event_management/src/mobile_screen/register_events.dart';
import 'package:event_management/src/mobile_screen/user_event.dart';
import 'package:event_management/src/models/events.dart';
import 'package:event_management/src/service/event_service.dart';
import 'package:event_management/src/service/logger_service.dart';
import 'package:event_management/src/service/user_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:event_management/src/mobile_screen/profile.dart';
import 'package:event_management/generated/l10n.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  late String userProfileUrl;
  late List<Event> events = [];
  int _currentIndex = 0;
  String userName = "";
  List<String> notifications = [];

  @override
  void initState() {
    super.initState();
    userProfileUrl = user?.photoURL ?? "";
    fetchEvents();
    _fetchUserName();
    _configureFCM();
  }

  void _configureFCM() {
    FirebaseMessaging.instance.subscribeToTopic('event-updates');
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        setState(() {
          notifications.add(message.notification!.body!);
        });
      }
    });
  }

  Future<void> _fetchUserName() async {
    try {
      userName = await GetNameUser();
    } catch (e) {
      LoggerService.logger.e("Failed to fetch user name: $e");
    }
  }

  Future<void> fetchEvents() async {
    List<Event> listEvents = await fetchEventById(user!.uid);
    if (mounted) {
      setState(() {
        events = listEvents;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final nextEvent = events.isNotEmpty
        ? events.firstWhere((event) => event.startDate.isAfter(now),
            orElse: () => events.first)
        : null;
    final Duration timeUntilNextEvent =
        nextEvent != null ? nextEvent.startDate.difference(now) : Duration.zero;
    final ongoingEvents = events.isNotEmpty
        ? events.firstWhere((event) => event.status == "Ongoing")
        : null;

    final List<Widget> screens = [
      SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (ongoingEvents != null)
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("On-going Event",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                ongoingEvents.name,
                                style: const TextStyle(fontSize: 16),
                                softWrap: true,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            const Chip(
                              label: Text("Ongoing",
                                  style: TextStyle(color: Colors.white)),
                              backgroundColor:
                                  Color.fromARGB(255, 245, 203, 18),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                "${DateFormat.jm().format(ongoingEvents.startDate)} - ${ongoingEvents.location}",
                                style: const TextStyle(color: Colors.grey),
                                softWrap: true,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            ElevatedButton(
                                style: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? ElevatedButton.styleFrom(
                                        backgroundColor: Colors.purple)
                                    : null,
                                onPressed: () {
                                  setState(() {
                                    LoggerService.logger.i(
                                        "Event clicked ticket ${ongoingEvents.id}");
                                  });
                                },
                                child: const Text('View your ticket'))
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(S.of(context).next_event,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              nextEvent?.name ?? "No upcoming event",
                              style: const TextStyle(fontSize: 16),
                              softWrap: true,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Chip(
                            label: Text(
                                "In ${timeUntilNextEvent.inHours} hours",
                                style: const TextStyle(color: Colors.white)),
                            backgroundColor: Colors.green,
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "${DateFormat.jm().format(nextEvent?.startDate ?? now)} - ${nextEvent?.location ?? "N/A"}",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(S.of(context).next_events,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Column(
                children: events
                    .where((event) =>
                        ongoingEvents != null && event != ongoingEvents)
                    .map((event) => buildEventCard(event))
                    .toList(),
              )
            ],
          ),
        ),
      ),
      const EventRegisterScreen(),
      CommunityForumScreen(),
      const UserEvents(),
      const ProfileWidget(),
    ];

    return Scaffold(
      appBar: _currentIndex == 0
          ? AppBar(
              elevation: 0,
              centerTitle: false,
              title: Text(S.of(context).welcome_back),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications),
                        onPressed: () {
                          _showNotificationsDialog(context);
                        },
                      ),
                      Text(
                        userName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 10),
                      StreamBuilder<User?>(
                        stream: FirebaseAuth.instance.userChanges(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.active) {
                            final user = snapshot.data;
                            final photoURL = user?.photoURL;
                            return CircleAvatar(
                              radius: 20,
                              backgroundImage: (photoURL != null)
                                  ? NetworkImage(photoURL)
                                  : null,
                              child: (photoURL == null)
                                  ? const Icon(Icons.person, size: 20)
                                  : null,
                            );
                          }
                          return const Center(
                              child: CircularProgressIndicator());
                        },
                      ),
                      const SizedBox(width: 10),
                    ],
                  ),
                ),
              ],
            )
          : null,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              icon: const Icon(Icons.home), label: S.of(context).home),
          BottomNavigationBarItem(
              icon: const Icon(Icons.event),
              label: S.of(context).register_event),
          BottomNavigationBarItem(
              icon: const Icon(Icons.forum), label: S.of(context).forum),
          BottomNavigationBarItem(
              icon: const Icon(Icons.edit_calendar),
              label: S.of(context).manage_event),
          BottomNavigationBarItem(
              icon: const Icon(Icons.person), label: S.of(context).profile),
        ],
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[900]
            : Colors.white,
        selectedItemColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.tealAccent
            : Colors.blue,
        unselectedItemColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey
            : Colors.black54,
      ),
    );
  }

  void _showNotificationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Notifications"),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: notifications.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(notifications[index]),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget buildEventCard(Event event) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            LoggerService.logger.i("Event clicked ${event.id}");
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EventDetailsPage(event: event),
              ),
            );
          },
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${DateFormat.jm().format(event.startDate)} - ${event.startDate.day}/${event.startDate.month}/${event.startDate.year}",
                        style:
                            const TextStyle(fontSize: 16, color: Colors.purple),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        event.name,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        softWrap: true,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        event.description,
                        style: const TextStyle(color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.location_on),
                              Text(
                                event.location,
                                style: const TextStyle(color: Colors.grey),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  // const Icon(Icons.arrow_forward_ios,
                  //     size: 16, color: Colors.grey),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    style: Theme.of(context).brightness == Brightness.dark
                        ? ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple)
                        : null,
                    onPressed: () {
                      setState(() {
                        LoggerService.logger
                            .i("Event clicked ticket ${event.id}");
                      });
                    },
                    child: const Text('View your ticket'),
                  )
                ],
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 3,
        )
      ],
    );
  }
}
