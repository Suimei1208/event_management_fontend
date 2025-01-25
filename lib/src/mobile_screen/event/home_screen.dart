// ignore_for_file: unnecessary_null_comparison, use_build_context_synchronously

import 'package:event_management/src/mobile_screen/event/detail_event.dart';
import 'package:event_management/src/mobile_screen/forum/forum_screen.dart';
import 'package:event_management/src/mobile_screen/event/register_events.dart';
import 'package:event_management/src/mobile_screen/event/user_event.dart';
import 'package:event_management/src/models/events.dart';
import 'package:event_management/src/service/calendar_service.dart';
import 'package:event_management/src/service/event_service.dart';
import 'package:event_management/src/service/logger_service.dart';
import 'package:event_management/src/service/ticket_service.dart';
import 'package:event_management/src/service/user_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:event_management/src/mobile_screen/user/profile.dart';
import 'package:event_management/generated/l10n.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home-mobile';

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

  @override
  void initState() {
    super.initState();
    userProfileUrl = user?.photoURL ?? "";
    fetchEvents();
    _fetchUserName(context);
  }

  Future<void> _fetchUserName(BuildContext context) async {
    try {
      userName = await GetNameUser(context);
    } catch (e) {
      LoggerService.logger.e("Failed to fetch user name: $e");
    }
  }

  Future<void> _addEventToCalendarInMobile(
      BuildContext context, Event event) async {
    final hasPermission = await requestPermissionsCalendar();
    if (!hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Không có quyền truy cập lịch")),
      );
      return;
    }

    final calendars = await getCalendars();
    if (calendars.isNotEmpty) {
      await addEventWithCheck(
        context,
        calendars.first.id!,
        event.name,
        event.description,
        event.startDate,
        event.endDate,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Không tìm thấy lịch nào!")),
      );
    }
  }

  Future<void> fetchEvents() async {
    List<Event> listEvents = await fetchEventById(user!.uid);
    List<Event> toRemove = [];

    for (var event in listEvents) {
      final ticket = await getQrTicket(event.id);
      if (ticket['statusTicket'] == "Cancelled") {
        toRemove.add(event);
      }
    }

    if (mounted) {
      setState(() {
        events = listEvents..removeWhere((event) => toRemove.contains(event));
      });
    }

    LoggerService.logger.i(events);
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final filteredEvents =
        events.where((event) => event.startDate.isAfter(now));
    final nextEvent = filteredEvents.isNotEmpty ? filteredEvents.first : null;
    LoggerService.logger.i("$filteredEvents");
    final Duration timeUntilNextEvent =
        nextEvent != null ? nextEvent.startDate.difference(now) : Duration.zero;
    Event? ongoingEvents;
    if (events.isNotEmpty) {
      for (var event in events) {
        if (event.status == "Ongoing") {
          ongoingEvents = event;
          break;
        }
      }
    }

    Future<void> handleRefresh() async {
      try {
        await fetchEvents();
        await _fetchUserName(context);
        setState(() {});
      } catch (e) {
        LoggerService.logger.e("Failed to refresh events: $e");
      }
    }

    final List<Widget> screens = [
      RefreshIndicator(
        onRefresh: handleRefresh,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ongoingEvents != null
                    ? Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(S.of(context).ongoing_event,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                  Chip(
                                    label: Text(S.of(context).Ongoing,
                                        style: const TextStyle(
                                            color: Colors.white)),
                                    backgroundColor:
                                        const Color.fromARGB(255, 245, 203, 18),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      "${DateFormat.jm().format(ongoingEvents.startDate)} - ${ongoingEvents.location}",
                                      style:
                                          const TextStyle(color: Colors.grey),
                                      softWrap: true,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  user?.uid == ongoingEvents.idCreate
                                      ? const Text("")
                                      : ElevatedButton(
                                          style: Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.purple)
                                              : null,
                                          onPressed: () async {
                                            Map<String, dynamic> qrCode =
                                                await getQrTicket(
                                                    ongoingEvents!.id);
                                            _viewQRCode(context, qrCode['qr']);
                                          },
                                          child: const Text('View your ticket'))
                                ],
                              ),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
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
                                nextEvent?.name ??
                                    S.of(context).no_upcoming_event,
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
                      .where((event) => event != ongoingEvents)
                      .map((event) => buildEventCard(event))
                      .toList(),
                )
              ],
            ),
          ),
        ),
      ),
      const EventRegisterScreen(),
      const CommunityForumScreen(),
      const UserEvents(),
      const ProfileWidget(),
    ];

    return Scaffold(
      appBar: _currentIndex == 0
          ? AppBar(
              automaticallyImplyLeading: false,
              elevation: 0,
              centerTitle: false,
              title: Text(S.of(context).welcome_back),
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
      bottomNavigationBar: ConvexAppBar(
        style: TabStyle.react,
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[900]
            : Colors.white,
        activeColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.tealAccent
            : Colors.blue,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey
            : Colors.black54,
        items: [
          TabItem(icon: Icons.home, title: S.of(context).home),
          TabItem(icon: Icons.event, title: S.of(context).register_event),
          TabItem(icon: Icons.forum, title: S.of(context).forum),
          TabItem(icon: Icons.edit_calendar, title: S.of(context).manage_event),
          TabItem(icon: Icons.person, title: S.of(context).profile),
        ],
        initialActiveIndex: _currentIndex,
        onTap: _onItemTapped,
        // height: 0,
      ),
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
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        style: Theme.of(context).brightness == Brightness.dark
                            ? ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple)
                            : null,
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return SizedBox(
                                height: 100,
                                child: Wrap(
                                  children: [
                                    ListTile(
                                      leading: const Icon(Icons.phone_android),
                                      title:
                                          const Text('Add to phone calendar'),
                                      onTap: () async {
                                        Navigator.pop(context);
                                        await _addEventToCalendarInMobile(
                                            context, event);
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.calendar_today),
                                      title:
                                          const Text('Add to Google Calendar'),
                                      onTap: () async {
                                        Navigator.pop(context);
                                        // await addGoogleCalendarEvent(
                                        //     event.name,
                                        //     event.description,
                                        //     event.startDate,
                                        //     event.endDate,
                                        //     context);
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        child: const Row(
                          children: [
                            Icon(Icons.add_card_outlined),
                            Text('Add to calendar'),
                          ],
                        ),
                      ),
                      event.idCreate == user?.uid
                          ? const Text("Event của bạn")
                          : ElevatedButton(
                              style: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? ElevatedButton.styleFrom(
                                      backgroundColor: Colors.purple)
                                  : null,
                              onPressed: () async {
                                Map<String, dynamic> qrCode =
                                    await getQrTicket(event.id);
                                _viewQRCode(context, qrCode['qr']);
                              },
                              child: const Text('View your ticket'),
                            )
                    ],
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

  void _viewQRCode(BuildContext context, String qrCode) {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final trimmedTimestamp = timestamp.length > 8
        ? timestamp.substring(timestamp.length - 8)
        : timestamp;
    final dynamicQrData = '$qrCode-$trimmedTimestamp';

    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Your QR Code',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              const SizedBox(height: 16),
              Center(
                child: QrImageView(
                  data: dynamicQrData,
                  version: QrVersions.auto,
                  size: 200.0,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Close',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
