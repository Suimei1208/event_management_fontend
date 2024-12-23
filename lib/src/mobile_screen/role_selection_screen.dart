import 'package:event_management/src/service/auth_service.dart';
import 'package:flutter/material.dart';

class RoleSelectionScreen extends StatefulWidget {
  static const routeName = '/role';

  const RoleSelectionScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RoleSelectionScreenState createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Your Role'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RoleCard(
                icon: Icons.school,
                title: 'Student',
                description:
                    'Access course materials, submit assignments, and track your academic progress.',
                buttonText: 'Continue as Student',
                onPressed: () {
                  selectRole(context, 'Student');
                },
              ),
              const SizedBox(height: 20),
              RoleCard(
                icon: Icons.person,
                title: 'Lecturer',
                description:
                    'Manage courses, create assignments, and engage with your students.',
                buttonText: 'Continue as Lecturer',
                onPressed: () {
                  selectRole(context, 'Lecturer');
                },
              ),
              const SizedBox(height: 20),
              RoleCard(
                icon: Icons.event,
                title: 'Organizer',
                description:
                    'Plan events, manage registrations, and coordinate with participants.',
                buttonText: 'Continue as Organizer',
                onPressed: () {
                  selectRole(context, 'Organizer');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String buttonText;
  final VoidCallback onPressed;

  const RoleCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(
              icon,
              size: 60,
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              child: Text(
                buttonText,
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
