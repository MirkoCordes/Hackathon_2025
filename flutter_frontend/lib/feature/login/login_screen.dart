// login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_frontend/feature/login/login.controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends ConsumerWidget {
  LoginScreen({super.key});

  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;

    // 2. Maximale Breite für die Login-Box definieren
    // Nimm 80% der Bildschirmbreite, aber nicht mehr als 450 Pixel.
    final boxWidth = screenWidth > 450 ? 450.0 : screenWidth * 0.8;

    final LoginController controller = ref.read(
      loginControllerProvider.notifier,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: SizedBox(
            width: boxWidth,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // E-Mail/Benutzername
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Benutzername',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator:
                        (value) =>
                            value!.isEmpty
                                ? 'Benutzername erforderlich.'
                                : null,

                    // Fehler beim Tippen zurücksetzen
                  ),
                  const SizedBox(height: 16),

                  // Passwort
                    TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: 'Passwort',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                    validator: (value) =>
                      value!.length < 4
                        ? 'Passwort muss min. 4 Zeichen haben.'
                        : null,
                    // Fehler beim Tippen zurücksetzen
                    onFieldSubmitted: (_) async {
                      await controller.login(
                      _usernameController.text,
                      _passwordController.text,
                      );
                      if (context.mounted) {
                      GoRouter.of(context).goNamed('catalog');
                      }
                    },
                    ),
                  const SizedBox(height: 24),

                  const SizedBox(height: 12),

                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        await controller.login(
                          _usernameController.text,
                          _passwordController.text,
                        );
                        if (context.mounted) {
                          GoRouter.of(context).goNamed('catalog');
                        }
                      },
                      child: const Text(
                        'Anmelden',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
