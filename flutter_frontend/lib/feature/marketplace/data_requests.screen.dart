import 'package:flutter/material.dart';
import 'package:flutter_frontend/feature/marketplace/data_requests.controller.dart';
import 'package:flutter_frontend/feature/marketplace/data_requests.model.dart';
import 'package:flutter_frontend/feature/marketplace/data_request.model.dart';
import 'package:flutter_frontend/shared/widgets/modern_cards.dart';
import 'package:flutter_frontend/shared/widgets/status_badge.dart';
import 'package:flutter_frontend/shared/widgets/category_chip.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DataRequestsScreen extends ConsumerWidget {
  const DataRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<DataRequestsModel> state = ref.watch(
      dataRequestsControllerProvider,
    );
    final theme = Theme.of(context);

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.shopping_cart_rounded,
                    color: theme.colorScheme.primary,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Datenbedarfe',
                          style: theme.textTheme.displayMedium,
                        ),
                        Text(
                          'Entdecken Sie, welche Daten gesucht werden',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Content
        Expanded(
          child: state.when(
            data: (data) => data.requests.isEmpty ? _buildEmptyState(theme) : _buildKanbanBoard(data.requests, theme),
            error: (err, stack) => _buildErrorState(theme, err.toString()),
            loading: () => _buildLoadingState(theme),
          ),
        ),
      ],
    );
  }

  Widget _buildKanbanBoard(List<DataRequestModel> requests, ThemeData theme) {
    // Group requests by status
    final newRequests = requests.where((r) => r.status == 'Neu').toList();
    final inProgressRequests = requests.where((r) => r.status == 'In Bearbeitung').toList();
    final closedRequests = requests.where((r) => r.status == 'Geschlossen').toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildKanbanColumn(
            title: 'Neue Anfragen',
            requests: newRequests,
            color: theme.colorScheme.secondary,
            icon: Icons.new_releases,
            theme: theme,
          ),
          const SizedBox(width: 16),
          _buildKanbanColumn(
            title: 'In Bearbeitung',
            requests: inProgressRequests,
            color: Colors.orange,
            icon: Icons.work_rounded,
            theme: theme,
          ),
          const SizedBox(width: 16),
          _buildKanbanColumn(
            title: 'Abgeschlossen',
            requests: closedRequests,
            color: theme.colorScheme.tertiary,
            icon: Icons.check_circle,
            theme: theme,
          ),
        ],
      ),
    );
  }

  Widget _buildKanbanColumn({
    required String title,
    required List<DataRequestModel> requests,
    required Color color,
    required IconData icon,
    required ThemeData theme,
  }) {
    return Container(
      width: 350,
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Column Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${requests.length}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Request Cards
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                return _buildRequestCard(requests[index], theme, context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(DataRequestModel request, ThemeData theme, BuildContext context) {
    return ModernCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with priority and category
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CategoryChip(
                label: request.category,
                category: _getCategoryFromString(request.category),
              ),
              StatusBadge(
                status: request.priority,
                type: _getPriorityType(request.priority),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Title
          Text(
            request.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 8),

          // Description
          Text(
            request.description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 12),

          // Metadata
          Row(
            children: [
              Icon(
                Icons.schedule,
                size: 14,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              const SizedBox(width: 4),
              Text(
                request.formattedAge,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const Spacer(),
              if (request.responseCount > 0)
                Row(
                  children: [
                    Icon(
                      Icons.reply,
                      size: 14,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${request.responseCount}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Action button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showRequestDetails(context, request),
              icon: const Icon(Icons.visibility, size: 16),
              label: const Text('Details'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  CategoryType _getCategoryFromString(String category) {
    switch (category.toLowerCase()) {
      case 'verwaltung':
        return CategoryType.administration;
      case 'wirtschaft':
        return CategoryType.business;
      case 'wissenschaft':
        return CategoryType.science;
      case 'umwelt':
        return CategoryType.environment;
      case 'infrastruktur':
        return CategoryType.infrastructure;
      default:
        return CategoryType.citizens;
    }
  }

  StatusType _getPriorityType(String priority) {
    switch (priority.toLowerCase()) {
      case 'hoch':
        return StatusType.rejected;
      case 'mittel':
        return StatusType.pending;
      case 'niedrig':
      default:
        return StatusType.available;
    }
  }

  void _showRequestDetails(BuildContext context, DataRequestModel request) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => _RequestDetailDialog(request: request),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              size: 64,
              color: theme.colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Keine Datenanfragen vorhanden',
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          Text(
            'Hier werden Anfragen nach Daten angezeigt,\ndie andere Nutzer benötigen.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 24),
          Text(
            'Fehler beim Laden',
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          Text(
            error,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: theme.colorScheme.primary),
          const SizedBox(height: 24),
          Text(
            'Lade Datenanfragen...',
            style: theme.textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

class _RequestDetailDialog extends StatelessWidget {
  final DataRequestModel request;

  const _RequestDetailDialog({required this.request});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.description_outlined,
                    color: theme.colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      request.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close,
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status and Priority Row
                  Row(
                    children: [
                      StatusBadge(
                        status: request.status,
                        type: _getStatusFromString(request.status),
                      ),
                      const SizedBox(width: 12),
                      CategoryChip(
                        label: request.category,
                        category: _getCategoryFromString(request.category),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getPriorityColor(request.priority).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _getPriorityColor(request.priority),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.priority_high,
                              size: 16,
                              color: _getPriorityColor(request.priority),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              request.priority.toUpperCase(),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: _getPriorityColor(request.priority),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Description
                  Text(
                    'Beschreibung',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    request.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Stats
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          'Antworten',
                          request.responseCount.toString(),
                          Icons.reply_outlined,
                          theme,
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: theme.colorScheme.outline.withOpacity(0.3),
                        ),
                        _buildStatItem(
                          'Erstellt am',
                          _formatDate(request.createdAt),
                          Icons.calendar_today_outlined,
                          theme,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Schließen'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _showResponseDialogFromDetail(context, request);
                        },
                        icon: const Icon(Icons.reply, size: 18),
                        label: const Text('Antworten'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, ThemeData theme) {
    return Column(
      children: [
        Icon(
          icon,
          color: theme.colorScheme.primary,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  StatusType _getStatusFromString(String status) {
    switch (status.toLowerCase()) {
      case 'aktiv':
        return StatusType.approved;
      case 'in bearbeitung':
        return StatusType.pending;
      case 'geschlossen':
        return StatusType.rejected;
      default:
        return StatusType.available;
    }
  }

  CategoryType _getCategoryFromString(String category) {
    switch (category.toLowerCase()) {
      case 'verwaltung':
        return CategoryType.administration;
      case 'wirtschaft':
        return CategoryType.business;
      case 'wissenschaft':
        return CategoryType.science;
      case 'zivilgesellschaft':
        return CategoryType.citizens;
      default:
        return CategoryType.environment;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'hoch':
        return Colors.red;
      case 'mittel':
        return Colors.orange;
      case 'niedrig':
      default:
        return Colors.green;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}.${date.month}.${date.year}';
    } catch (e) {
      return dateString; // Fallback to original string if parsing fails
    }
  }

  void _showResponseDialogFromDetail(BuildContext context, DataRequestModel request) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Auf Anfrage antworten'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Anfrage: ${request.title}'),
                const SizedBox(height: 16),
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'Ihre Antwort',
                    hintText: 'Beschreiben Sie, wie Sie bei dieser Anfrage helfen können...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Abbrechen'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Hier würde normalerweise die API aufgerufen werden
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Antwort erfolgreich gesendet!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: const Text('Senden'),
              ),
            ],
          ),
    );
  }
}
