import 'package:event_management/src/models/events.dart';
import 'package:event_management/src/service/logger_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class EventDetailsPage extends StatelessWidget {
  final Event event;

  EventDetailsPage({super.key, required this.event});

  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(event.name),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and Date
            Text(
              event.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  "${_formatDate(event.startDate)} - ${_formatDate(event.endDate)}",
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(event.location, style: const TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 16),

            // Description
            Text(
              event.description,
              style: const TextStyle(fontSize: 16),
            ),
            if (event.idCreate == user?.uid) const SizedBox(height: 24),

            // Quick Actions
            _buildQuickActions(),

            const SizedBox(height: 24),

            // Event Stats
            _buildEventStats(),

            const SizedBox(height: 24),

            // Featured Speakers
            _buildFeaturedSpeakers(),

            const SizedBox(height: 24),

            // View Full Schedule Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  LoggerService.logger.i("View Full Schedule pressed");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "View Full Schedule",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget: Quick Actions
  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Text(
            "Quick Actions",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(Icons.person_add, "Add Guest", () {
                LoggerService.logger.i("Add Guest pressed");
              }),
              _buildActionButton(Icons.person, "Add Speaker", () {
                LoggerService.logger.i("Add Speaker pressed");
              }),
              _buildActionButton(Icons.schedule, "Schedule", () {
                LoggerService.logger.i("Schedule pressed");
              }),
            ],
          ),
        ],
      ),
    );
  }

  // Widget: Event Stats
  Widget _buildEventStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Text(
            "Event Stats",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStat("250", "Registered"),
              _buildStat("12", "Speakers"),
              _buildStat("24", "Sessions"),
            ],
          ),
        ],
      ),
    );
  }

  // Widget: Featured Speakers
  Widget _buildFeaturedSpeakers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Featured Speakers",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildSpeaker(
          "Dr. Sarah Chen",
          "AI Research Director, Tech Corp",
          "https://via.placeholder.com/50",
        ),
        const SizedBox(height: 16),
        _buildSpeaker(
          "James Wilson",
          "Blockchain Expert, CryptoFuture",
          "https://via.placeholder.com/50",
        ),
      ],
    );
  }

  // Helper: Action Button
  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey.shade200,
            child: Icon(icon, size: 28, color: Colors.deepPurple),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }

  // Helper: Speaker Widget
  Widget _buildSpeaker(String name, String role, String imageUrl) {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundImage: NetworkImage(imageUrl),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              role,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  // Helper: Format Date
  String _formatDate(DateTime date) {
    return "${date.month}/${date.day}/${date.year}";
  }
}
