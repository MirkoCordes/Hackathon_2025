import 'package:flutter/material.dart';
import 'package:flutter_frontend/feature/catalog/dataset.dart';
import 'package:flutter_frontend/shared/widgets/category_chip.dart';
import 'package:flutter_frontend/shared/widgets/status_badge.dart';
import 'package:flutter_frontend/shared/widgets/modern_cards.dart';
import 'package:go_router/go_router.dart';

class DatasetListWidget extends StatelessWidget {
  const DatasetListWidget({super.key, required this.datasets});

  final List<Dataset> datasets;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    // Responsive grid columns
    int crossAxisCount = 1;
    if (screenWidth > 1200) {
      crossAxisCount = 3;
    } else if (screenWidth > 800) {
      crossAxisCount = 2;
    }

    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2, // Make cards more square
      ),
      itemCount: datasets.length,
      itemBuilder: (context, index) {
        final dataset = datasets[index];
        return _DatasetCard(dataset: dataset);
      },
    );
  }
}

class _DatasetCard extends StatelessWidget {
  const _DatasetCard({required this.dataset});

  final Dataset dataset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasAccess = dataset.hasAccess ?? false;

    return ModernCard(
      onTap: hasAccess ? () => _navigateToDetail(context) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with category and access status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CategoryChip(
                label: _DatasetCard._getDatasetCategoryLabel(dataset),
                category: _DatasetCard._getDatasetCategoryType(dataset),
              ),
              StatusBadge(
                status: hasAccess ? 'Verfügbar' : 'Zugang erforderlich',
                type: hasAccess ? StatusType.available : StatusType.restricted,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Title
          Text(
            dataset.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 8),

          // Description
          Expanded(
            child: Text(
              dataset.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(height: 16),

          // Action button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: hasAccess ? () => _navigateToDetail(context) : () => _showAccessDialog(context),
              icon: Icon(hasAccess ? Icons.visibility : Icons.key),
              label: Text(hasAccess ? 'Anzeigen' : 'Zugang beantragen'),
              style: ElevatedButton.styleFrom(
                backgroundColor: hasAccess ? theme.colorScheme.primary : theme.colorScheme.secondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static CategoryType _getDatasetCategoryType(Dataset dataset) {
    // Map dataset properties to category types
    final title = dataset.title.toLowerCase();
    if (title.contains('verwaltung') || title.contains('amtlich')) {
      return CategoryType.administration;
    } else if (title.contains('umwelt') || title.contains('wetter')) {
      return CategoryType.environment;
    } else if (title.contains('wirtschaft') || title.contains('unternehmen')) {
      return CategoryType.business;
    } else if (title.contains('forschung') || title.contains('wissenschaft')) {
      return CategoryType.science;
    } else if (title.contains('bürger') || title.contains('sozial')) {
      return CategoryType.citizens;
    } else if (title.contains('infrastruktur') || title.contains('verkehr')) {
      return CategoryType.infrastructure;
    }
    return CategoryType.administration; // Default
  }

  static String _getDatasetCategoryLabel(Dataset dataset) {
    final categoryType = _getDatasetCategoryType(dataset);
    switch (categoryType) {
      case CategoryType.administration:
        return 'Verwaltung';
      case CategoryType.business:
        return 'Wirtschaft';
      case CategoryType.science:
        return 'Wissenschaft';
      case CategoryType.citizens:
        return 'Bürgerdaten';
      case CategoryType.environment:
        return 'Umwelt';
      case CategoryType.infrastructure:
        return 'Infrastruktur';
    }
  }

  void _navigateToDetail(BuildContext context) {
    GoRouter.of(context).pushNamed(
      'datasources',
      pathParameters: {'id': dataset.id.toString()},
    );
  }

  void _showAccessDialog(BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Icon(Icons.security, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                const Text('Zugang beantragen'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Für den Datensatz "${dataset.title}" benötigen Sie eine Zugangs­berechtigung.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Laden Sie entsprechende Zertifikate über Ihr Profil hoch.',
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Abbrechen'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  GoRouter.of(context).push('/user');
                },
                icon: const Icon(Icons.upload_file),
                label: const Text('Zertifikat hochladen'),
              ),
            ],
          ),
    );
  }
}
