import 'package:flutter/material.dart';
import 'package:flutter_frontend/feature/login/login.controller.dart';
import 'package:flutter_frontend/shared/widgets/modern_cards.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends ConsumerWidget {
  LoginScreen({super.key});

  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = MediaQuery.sizeOf(context);
    final theme = Theme.of(context);
    final boxWidth = screenSize.width > 500 ? 450.0 : screenSize.width * 0.9;

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainer,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withOpacity(0.1),
              theme.colorScheme.surfaceContainer,
              theme.colorScheme.secondary.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Hero Section
                  _buildHeroSection(theme),

                  const SizedBox(height: 40),

                  // Login Card
                  GlassmorphismCard(
                    width: boxWidth,
                    padding: const EdgeInsets.all(32),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Welcome text
                          Text(
                            'Willkommen zurück',
                            style: theme.textTheme.displayMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Melden Sie sich in Ihrem Datenraum-Account an',
                            style: theme.textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 32),

                          // Benutzername
                          TextFormField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              labelText: 'Benutzername',
                              hintText: 'Ihr Benutzername',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            validator: (value) => value!.isEmpty ? 'Benutzername erforderlich' : null,
                          ),

                          const SizedBox(height: 20),

                          // Passwort
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              labelText: 'Passwort',
                              hintText: 'Ihr Passwort',
                              prefixIcon: Icon(Icons.lock_outline),
                            ),
                            validator: (value) => value!.length < 4 ? 'Passwort muss min. 4 Zeichen haben' : null,
                            onFieldSubmitted: (_) => _handleLogin(context, ref),
                          ),

                          const SizedBox(height: 32),

                          // Login Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () => _handleLogin(context, ref),
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.login),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Anmelden',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Demo credentials info
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: theme.colorScheme.primary.withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.info_outline, size: 16, color: theme.colorScheme.primary),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Demo-Zugang',
                                      style: theme.textTheme.labelLarge?.copyWith(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Admin: admin / admin123\nUser: testuser / test123',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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

  Widget _buildHeroSection(ThemeData theme) {
    return Column(
      children: [
        // Logo with modern styling
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Image.asset(
            'assets/images/LogoGroßTransparent2.png',
            height: 80,
            semanticLabel: 'Ostfriesland Datenraum Logo',
          ),
        ),

        const SizedBox(height: 24),

        // Title
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: theme.textTheme.displayLarge,
            children: [
              const TextSpan(text: 'Datenraum '),
              TextSpan(
                text: 'Ostfriesland',
                style: TextStyle(color: theme.colorScheme.primary),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Subtitle
        Text(
          'Ihr Zugang zu lokalen Datenquellen aus\nVerwaltung, Wirtschaft und Wissenschaft',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Future<void> _handleLogin(BuildContext context, WidgetRef ref) async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final controller = ref.read(loginControllerProvider.notifier);
        await controller.login(
          _usernameController.text,
          _passwordController.text,
        );
        if (context.mounted) {
          GoRouter.of(context).goNamed('catalog');
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Anmeldung fehlgeschlagen: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }
}
