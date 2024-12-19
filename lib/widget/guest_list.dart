// ignore_for_file: avoid_print
import 'package:event_management/src/mobile_screen/add_guest.dart';
import 'package:flutter/material.dart';
import 'package:event_management/src/service/logger_service.dart';

class GuestList extends StatefulWidget {
  final String title;
  final List<Map<String, dynamic>>? members;

  const GuestList({super.key, required this.title, required this.members});

  @override
  // ignore: library_private_types_in_public_api
  _GuestListState createState() => _GuestListState();
}

class _GuestListState extends State<GuestList> {
  late List<Map<String, dynamic>> members;

  @override
  void initState() {
    super.initState();
    members = widget.members ?? [];
  }

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
                      onPressed: () async {
                        final selectedUsers = await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                AddMembersPage(name: widget.title),
                          ),
                        );
                        if (selectedUsers != null) {
                          setState(() {
                            members.addAll(
                                selectedUsers); // Cập nhật danh sách thành viên
                          });
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (members.isEmpty)
                  const Center(
                      child: Text(
                          'No members added yet.')) // Thông báo nếu không có thành viên
                else
                  ...members.map((member) => Padding(
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
                                  backgroundImage: member['avtUrl'].isNotEmpty
                                      ? NetworkImage(member['avtUrl'])
                                      : const NetworkImage(
                                          'https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png'),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
