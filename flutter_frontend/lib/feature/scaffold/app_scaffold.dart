import 'package:flutter/material.dart';
import 'package:flutter_frontend/feature/logout/logout.controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';


class AppScaffold extends ConsumerWidget {
  final Widget body;

  const AppScaffold({super.key, required this.body});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

  final LogoutController logoutController = ref.read(
    logoutControllerProvider.notifier,
  );

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
          IconButton(
            tooltip: 'Log Out',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await logoutController.logout();
              if(context.mounted){
                GoRouter.of(context).go('/');
              }
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
        // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Image.asset('assets/images/LogoGroßTransparent2.png'),
            ),
            ListTile(
              title: const Text('Item 1'),
              onTap: () {
                // Update the state of the app.
                // ...
              },
            ),
            ListTile(
              title: const Text('Item 2'),
              onTap: () {
                // Update the state of the app.
                // ...
              },
            ),
          ],
        ),
      ),
      body: body,
    );
  }
}
