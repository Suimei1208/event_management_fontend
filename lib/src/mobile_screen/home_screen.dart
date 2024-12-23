import 'package:event_management/src/models/events.dart';
import 'package:event_management/src/service/event_service.dart';
import 'package:event_management/src/service/logger_service.dart';
// import 'package:event_management/src/service/logger_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

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

  void _onItemTapped(int index) {
    String routeName1 = '/home';
    switch (index) {
      case 0:
        routeName1 = '/home';
        break;
      case 1:
        // routeName = '/events'; // Trang Events
        break;
      case 2:
        routeName1 = '/forum'; // Trang Forum
        break;
      case 3:
        routeName1 = '/profile'; // Trang Profile
        break;
      default:
        routeName1 = '/home';
    }
    Navigator.pushReplacementNamed(context, routeName1);
  }

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
    // LoggerService.logger.e(events.length);

    // for (var event in events) {
    //   LoggerService.logger.e(event);
    // }
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

    return Scaffold(
      // backgroundColor: Colors.grey[200],
      appBar: AppBar(
        // backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          "Welcome Back",
        ),
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
                CircleAvatar(
                  backgroundImage: NetworkImage(userProfileUrl),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text(userName,
              //     style: const TextStyle(
              //         fontSize: 20,
              //         fontWeight: FontWeight.bold,
              //         color: Colors.blue)),
              // const SizedBox(height: 20),
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
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: "Events"),
          BottomNavigationBarItem(icon: Icon(Icons.forum), label: "Forum"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          _onItemTapped(index);
        },
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
