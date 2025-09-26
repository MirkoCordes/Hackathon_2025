import 'package:flutter/material.dart';
import 'package:flutter_frontend/feature/user/user.entity.dart';

/// Simple User Profile page that shows the fields of [User].
///
/// This page intentionally does not perform any network calls. It
/// will try to read a `User` instance from `ModalRoute.of(context)?.settings.arguments`
/// or display a placeholder/empty view when none is provided.
class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Try to get a User passed via route extra (GoRouter state.extra) or arguments
    final maybeUser = ModalRoute.of(context)?.settings.arguments;
    User? user;
    if (maybeUser is User) {
      user = maybeUser;
    }

    // If no user provided, use a placeholder user for UI layout purposes
    final displayUser = user ?? const User(
      id: 0,
      username: 'anonymous',
      email: 'anonymous@example.com',
      role: UserRole.user,
      enabled: false,
      firstName: null,
      lastName: null,
      organization: null,
      jobTitle: null,
      activeCertificatesCount: 0,
      totalCertificatesCount: 0,
      accessRequestsCount: 0,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 32,
                child: Icon(Icons.person, size: 36),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(displayUser.displayName, style: Theme.of(context).textTheme.titleLarge),
                  Text(displayUser.email, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          ListTile(
            title: const Text('Benutzername'),
            subtitle: Text(displayUser.username),
          ),
          ListTile(
            title: const Text('Vorname'),
            subtitle: Text(displayUser.firstName ?? '-'),
          ),
          ListTile(
            title: const Text('Nachname'),
            subtitle: Text(displayUser.lastName ?? '-'),
          ),
          ListTile(
            title: const Text('Organisation'),
            subtitle: Text(displayUser.organization ?? '-'),
          ),
          ListTile(
            title: const Text('Funktion/Titel'),
            subtitle: Text(displayUser.jobTitle ?? '-'),
          ),
          ListTile(
            title: const Text('Rolle'),
            subtitle: Text(displayUser.role.displayName),
          ),
          ListTile(
            title: const Text('Aktive Zertifikate'),
            subtitle: Text('${displayUser.activeCertificatesCount}'),
          ),
          ListTile(
            title: const Text('Zertifikate insgesamt'),
            subtitle: Text('${displayUser.totalCertificatesCount}'),
          ),
          ListTile(
            title: const Text('Zugriffsanfragen'),
            subtitle: Text('${displayUser.accessRequestsCount}'),
          ),
        ],
      ),
    );
  }
}
