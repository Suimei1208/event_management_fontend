// ignore_for_file: avoid_print
import 'package:event_management/src/mobile_screen/add_guest.dart';
import 'package:flutter/material.dart';
import 'package:event_management/src/service/logger_service.dart';

class GuestList extends StatefulWidget {
  final String title;
  final List<Map<String, String>> members;

  const GuestList({super.key, required this.title, required this.members});

  @override
  // ignore: library_private_types_in_public_api
  _GuestListState createState() => _GuestListState();
}

class _GuestListState extends State<GuestList> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).dividerColor,
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            fontSize: 30,
                          ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.add,
                        color: Theme.of(context).colorScheme.primary,
                        size: 24,
                      ),
                      onPressed: () {
                        LoggerService.logger.e('Add member button pressed');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AddMembersPage()),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...widget.members.map((member) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundImage:
                                    NetworkImage(member['avtUrl']!),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      member['name']!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            fontFamily: 'Inter',
                                          ),
                                    ),
                                    Text(
                                      member['role']!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontFamily: 'Inter',
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.color,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.close,
                                  color: Theme.of(context).colorScheme.error,
                                  size: 20,
                                ),
                                onPressed: () {
                                  LoggerService.logger
                                      .e('Remove member button pressed');
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    )),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
