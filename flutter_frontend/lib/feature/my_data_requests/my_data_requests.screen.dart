import 'package:flutter/material.dart';
import 'package:flutter_frontend/feature/marketplace/data_request.model.dart';
import 'package:flutter_frontend/feature/marketplace/data_request_response.model.dart';
import 'package:flutter_frontend/feature/my_data_requests/my_data_requests.controller.dart';
import 'package:flutter_frontend/feature/my_data_requests/my_data_requests.model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MyDataRequestsScreen extends ConsumerWidget {
  const MyDataRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<MyDataRequestsModel> state = ref.watch(myDataRequestsControllerProvider);
    final controller = ref.read(myDataRequestsControllerProvider.notifier);

    return RefreshIndicator(
      onRefresh: () => controller.refresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.request_page_outlined,
                      size: 48,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Meine Datenanfragen',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Verwalten Sie Ihre erstellten Datenanfragen und die darauf eingegangenen Antworten',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Content
            state.when(
              data: (data) {
                if (data.requests.isEmpty) {
                  return _buildEmptyState(context);
                }
                return _buildRequestsList(context, data.requests, controller);
              },
              loading:
                  () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
              error: (error, stack) => _buildErrorState(context, error.toString(), controller),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Keine Datenanfragen',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sie haben noch keine Datenanfragen erstellt.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error, MyDataRequestsController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Fehler beim Laden',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.red.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.red.shade500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => controller.refresh(),
              icon: const Icon(Icons.refresh),
              label: const Text('Erneut versuchen'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestsList(
    BuildContext context,
    List<DataRequestModel> requests,
    MyDataRequestsController controller,
  ) {
    return Column(
      children: requests.map((request) => _buildRequestCard(context, request, controller)).toList(),
    );
  }

  Widget _buildRequestCard(BuildContext context, DataRequestModel request, MyDataRequestsController controller) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(request.status),
          child: Icon(
            _getStatusIcon(request.status),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          request.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              request.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Chip(
                  label: Text(
                    _getStatusText(request.status),
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: _getStatusColor(request.status).withOpacity(0.2),
                  side: BorderSide(color: _getStatusColor(request.status)),
                ),
                const SizedBox(width: 8),
                Text(
                  request.formattedAge,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const Spacer(),
                if (request.status == 'OPEN' || request.status == 'IN_PROGRESS')
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleRequestAction(context, value, request, controller),
                    itemBuilder:
                        (context) => [
                          const PopupMenuItem(
                            value: 'close_fulfilled',
                            child: Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.green),
                                SizedBox(width: 8),
                                Text('Als erfüllt markieren'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'close_cancelled',
                            child: Row(
                              children: [
                                Icon(Icons.cancel, color: Colors.orange),
                                SizedBox(width: 8),
                                Text('Stornieren'),
                              ],
                            ),
                          ),
                        ],
                    child: const Icon(Icons.more_vert),
                  ),
              ],
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildRequestDetails(context, request, controller),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestDetails(BuildContext context, DataRequestModel request, MyDataRequestsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Request details
        _buildDetailSection('Details der Anfrage', [
          _buildDetailRow('Kategorie', request.category),
          _buildDetailRow('Priorität', request.priority),
          _buildDetailRow('Verwendungszweck', request.intendedUse),
          if (request.preferredFormat.isNotEmpty) _buildDetailRow('Bevorzugtes Format', request.preferredFormat),
          if (request.geographicScope.isNotEmpty) _buildDetailRow('Geografischer Bereich', request.geographicScope),
          if (request.timeScope.isNotEmpty) _buildDetailRow('Zeitraum', request.timeScope),
          _buildDetailRow('Kontakt-E-Mail', request.contactEmail),
        ]),

        const SizedBox(height: 16),

        // Responses section
        FutureBuilder<List<DataRequestResponseModel>>(
          future: controller.getResponsesForRequest(request.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              debugPrint(snapshot.stackTrace.toString());
              return Text('Fehler beim Laden der Antworten: ${snapshot.error}');
            }

            final responses = snapshot.data ?? [];

            if (responses.isEmpty) {
              return _buildDetailSection('Antworten', [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Noch keine Antworten auf diese Anfrage eingegangen.',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
              ]);
            }

            return _buildDetailSection(
              'Antworten (${responses.length})',
              responses.map((response) => _buildResponseCard(context, response, controller)).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildResponseCard(
    BuildContext context,
    DataRequestResponseModel response,
    MyDataRequestsController controller,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Chip(
                  label: Text(
                    _getResponseTypeDisplayName(response.responseType),
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: Colors.blue.shade100,
                ),
                const Spacer(),
                Chip(
                  label: Text(
                    _getResponseStatusDisplayName(response.status),
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: _getResponseStatusColor(response.status).withOpacity(0.2),
                  side: BorderSide(color: _getResponseStatusColor(response.status)),
                ),
                if (response.status == 'PENDING')
                  IconButton(
                    onPressed: () => _acceptResponse(context, response, controller),
                    icon: const Icon(Icons.check_circle, color: Colors.green),
                    tooltip: 'Antwort akzeptieren',
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(response.message),

            // Link to existing datasource if available
            if (response.existingDatasourceId != null) ...[
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  await GoRouter.of(context).push('/datasources/${response.existingDatasourceId}');
                },
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.dataset, color: Colors.blue.shade700, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Verknüpfte Datenquelle ansehen',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.open_in_new, color: Colors.blue.shade700, size: 14),
                    ],
                  ),
                ),
              ),
            ],

            if (response.contactEmail?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.email, size: 16),
                  const SizedBox(width: 4),
                  Text(response.contactEmail!),
                ],
              ),
            ],
            if (response.contactPhone?.isNotEmpty == true) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.phone, size: 16),
                  const SizedBox(width: 4),
                  Text(response.contactPhone!),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _handleRequestAction(
    BuildContext context,
    String action,
    DataRequestModel request,
    MyDataRequestsController controller,
  ) async {
    switch (action) {
      case 'close_fulfilled':
        await _closeRequest(context, request, 'FULFILLED', controller);
        break;
      case 'close_cancelled':
        await _closeRequest(context, request, 'CANCELLED', controller);
        break;
    }
  }

  Future<void> _closeRequest(
    BuildContext context,
    DataRequestModel request,
    String status,
    MyDataRequestsController controller,
  ) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => _buildReasonDialog(context, status),
    );

    if (reason != null && context.mounted) {
      try {
        await controller.closeRequest(request.id, status, reason);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Anfrage erfolgreich ${status == 'FULFILLED' ? 'als erfüllt markiert' : 'storniert'}.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Fehler: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _acceptResponse(
    BuildContext context,
    DataRequestResponseModel response,
    MyDataRequestsController controller,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Antwort akzeptieren'),
            content: const Text(
              'Möchten Sie diese Antwort wirklich akzeptieren? Dies wird Ihre Anfrage als "In Bearbeitung" markieren.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Abbrechen'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Akzeptieren'),
              ),
            ],
          ),
    );

    if (confirm == true && context.mounted) {
      try {
        await controller.acceptResponse(response.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Antwort erfolgreich akzeptiert.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Fehler: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Widget _buildReasonDialog(BuildContext context, String status) {
    final controller = TextEditingController();
    final title = status == 'FULFILLED' ? 'Als erfüllt markieren' : 'Anfrage stornieren';

    return AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Warum möchten Sie diese Anfrage ${status == 'FULFILLED' ? 'als erfüllt markieren' : 'stornieren'}?'),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Grund (optional)',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Abbrechen'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(controller.text.trim()),
          child: Text(status == 'FULFILLED' ? 'Als erfüllt markieren' : 'Stornieren'),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'OPEN':
        return Colors.green;
      case 'IN_PROGRESS':
        return Colors.blue;
      case 'FULFILLED':
        return Colors.purple;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'OPEN':
        return Icons.schedule;
      case 'IN_PROGRESS':
        return Icons.work;
      case 'FULFILLED':
        return Icons.check_circle;
      case 'CANCELLED':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'OPEN':
        return 'Offen';
      case 'IN_PROGRESS':
        return 'In Bearbeitung';
      case 'FULFILLED':
        return 'Erfüllt';
      case 'CANCELLED':
        return 'Storniert';
      default:
        return status;
    }
  }

  Color _getResponseStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return Colors.orange;
      case 'ACCEPTED':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getResponseStatusDisplayName(String status) {
    switch (status) {
      case 'PENDING':
        return 'Ausstehend';
      case 'ACCEPTED':
        return 'Akzeptiert';
      case 'REJECTED':
        return 'Abgelehnt';
      default:
        return status;
    }
  }

  String _getResponseTypeDisplayName(String type) {
    switch (type) {
      case 'EXISTING_DATASOURCE':
        return 'Bestehende Datenquelle';
      case 'NEW_DATASOURCE':
        return 'Neue Datenquelle';
      case 'PARTIAL_MATCH':
        return 'Teilweise passend';
      case 'COLLABORATION':
        return 'Kooperation';
      case 'INFORMATION':
        return 'Information';
      default:
        return type;
    }
  }
}
