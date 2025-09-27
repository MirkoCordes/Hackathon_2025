import 'package:flutter/material.dart';
import 'package:flutter_frontend/feature/scaffold/app_scaffold.dart';

class ImpressumPage extends StatelessWidget {
  const ImpressumPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Impressum',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Anschrift',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Ostfriesland DataHub\n'
              'Neue Straße 1\n'
              '26789 Leer\n'
              'Deutschland',
            ),
            SizedBox(height: 16),
            Text(
              'Kontakt',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Telefon: +49 (0) xxx xxx xxx xx\n'
              'E-Mail: info@ostfriesland-datahub.de',
            ),
          ],
        ),
      ),
    );
  }
}