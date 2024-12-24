// ignore_for_file: unnecessary_null_comparison

import 'package:event_management/src/mobile_screen/user_event.dart';
import 'package:event_management/src/models/events.dart';
import 'package:event_management/src/service/event_service.dart';
import 'package:event_management/src/service/logger_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:event_management/src/mobile_screen/profile.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  late String userName;
  late String userProfileUrl;
  late List<Event> events = [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    userName = user?.displayName ?? "User";
    userProfileUrl = user?.photoURL ?? "";
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    List<Event> listEvents = await fetchEventById(user!.uid);
    setState(() {
      events = listEvents;
    });
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

    final List<Widget> screens = [
      // Home Screen
      SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Next Event",
                          style: TextStyle(
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
              const Text("Next Scheduled",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Column(
                children: events.map((event) => buildEventCard(event)).toList(),
              )
            ],
          ),
        ),
      ),
      const UserEvents(),
      const ProfileWidget(),
      const ProfileWidget(),
    ];

    return Scaffold(
      appBar: _currentIndex == 0
          ? AppBar(
              elevation: 0,
              centerTitle: false,
              title: const Text("Welcome Back"),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Row(
                    children: [
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
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: "Events"),
          BottomNavigationBarItem(icon: Icon(Icons.forum), label: "Forum"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
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

  Widget buildEventCard(Event event) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            LoggerService.logger.i("Event clicked ${event.id}");
          },
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${DateFormat.jm().format(event.startDate)} - ${event.startDate.day}/${event.startDate.month}/${event.startDate.year}",
                          style: const TextStyle(
                              fontSize: 16, color: Colors.purple),
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
                        Row(
                          children: [
                            const Icon(Icons.location_on),
                            Text(
                              event.location,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios,
                      size: 16, color: Colors.grey),
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
