import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/app_routes.dart';
import '../../../config/app_theme.dart';
import '../../../providers/event_provider.dart';

class EventsListTab extends StatefulWidget {
  const EventsListTab({super.key});

  @override
  State<EventsListTab> createState() => _EventsListTabState();
}

class _EventsListTabState extends State<EventsListTab> {
  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  void _loadEvents() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventProvider>().fetchEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EventProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.events.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event, size: 100, color: AppTheme.textSecondary),
                const SizedBox(height: 16),
                const Text('No events yet', style: AppTheme.heading3),
                const SizedBox(height: 8),
                const Text('Create your first event', style: AppTheme.bodyMedium),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await context.read<EventProvider>().fetchEvents();
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.events.length,
            itemBuilder: (context, index) {
              final event = provider.events[index];
              return Card(
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.eventDetail,
                      arguments: event.id,
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.event,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    event.title,
                                    style: AppTheme.heading3,
                                  ),
                                  const SizedBox(height: 4),
                                  if (event.description != null)
                                    Text(
                                      event.description!,
                                      style: AppTheme.bodySmall,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _buildStatChip(
                              Icons.photo_library,
                              '${event.mediaCount ?? 0}',
                              'Media',
                            ),
                            const SizedBox(width: 8),
                            _buildStatChip(
                              Icons.people,
                              '${event.guestsCount ?? 0}',
                              'Guests',
                            ),
                            const SizedBox(width: 8),
                            _buildStatusChip(event.status),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildStatChip(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.textSecondary),
          const SizedBox(width: 4),
          Text(
            value,
            style: AppTheme.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;

    switch (status) {
      case 'active':
        color = AppTheme.successColor;
        label = 'Active';
        break;
      case 'draft':
        color = AppTheme.warningColor;
        label = 'Draft';
        break;
      case 'expired':
        color = AppTheme.textSecondary;
        label = 'Expired';
        break;
      default:
        color = AppTheme.textSecondary;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: AppTheme.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
