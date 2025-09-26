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
        // Show a close (X) button on the leading side when this route can be popped.
        // That allows pushed routes (like /user) to be closed with an X.
        leading:
            Navigator.of(context).canPop()
                ? IconButton(
                  tooltip: 'Schließen',
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    GoRouter.of(context).pop();
                  },
                )
                : null,
        actions: [
          // User profile icon - navigates to /user using push so it can be popped/closed
          IconButton(
            tooltip: 'Profil',
            icon: const Icon(Icons.person),
            onPressed: () async {
              // Push the user profile route so it can be closed (popped) with an X
              await GoRouter.of(context).push('/user');
            },
          ),
        ],
      ),
      body: body,
    );
  }
}
