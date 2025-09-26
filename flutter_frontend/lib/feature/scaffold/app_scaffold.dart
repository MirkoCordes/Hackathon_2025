import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;

  const AppScaffold({super.key, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hackathon 2025'),
        actions: [
          // User profile icon - navigates to /user
          IconButton(
            tooltip: 'Profil',
            icon: const Icon(Icons.person),
            onPressed: () {
              // Navigate to user profile route
              GoRouter.of(context).go('/user');
            },
          ),
        ],
      ),
      body: body,
    );
  }
}
