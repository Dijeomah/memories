import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../config/app_theme.dart';
import '../../providers/event_provider.dart';
import '../../models/event.dart';
import '../media/media_viewer_screen.dart';
import 'create_event_screen.dart';

class EventDetailScreen extends StatefulWidget {
  final int eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadEventData();
  }

  void _loadEventData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<EventProvider>();
      provider.fetchEvent(widget.eventId);
      provider.fetchEventMedia(widget.eventId);
      provider.fetchEventGuests(widget.eventId);
      provider.fetchEventScans(widget.eventId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        actions: [
          IconButton(
            icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedMoreVertical,
              color: Colors.black,
            ),
            onPressed: _showOptionsMenu,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(icon: HugeIcon(icon: HugeIcons.strokeRoundedInformationCircle, color: Colors.black, size: 20), text: 'Info'),
            Tab(icon: HugeIcon(icon: HugeIcons.strokeRoundedImage02, color: Colors.black, size: 20), text: 'Media'),
            Tab(icon: HugeIcon(icon: HugeIcons.strokeRoundedUserMultiple, color: Colors.black, size: 20), text: 'Guests'),
            Tab(icon: HugeIcon(icon: HugeIcons.strokeRoundedAnalytics02, color: Colors.black, size: 20), text: 'Stats'),
          ],
        ),
      ),
      body: Consumer<EventProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.currentEvent == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final event = provider.currentEvent;
          if (event == null) {
            return const Center(child: Text('Event not found'));
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildInfoTab(event),
              _buildMediaTab(provider),
              _buildGuestsTab(provider),
              _buildAnalyticsTab(provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoTab(Event event) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Header
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Event image or icon placeholder
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          gradient: event.eventImage == null ? AppTheme.primaryGradient : null,
                          borderRadius: BorderRadius.circular(12),
                          image: event.eventImage != null
                              ? DecorationImage(
                                  image: NetworkImage(event.eventImage!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: event.eventImage == null
                            ? const HugeIcon(
                                icon: HugeIcons.strokeRoundedCalendar03,
                                color: Colors.white,
                                size: 32,
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(event.title, style: AppTheme.heading2),
                            const SizedBox(height: 4),
                            _buildStatusChip(event.status),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (event.description != null) ...[
                    const Divider(height: 32),
                    Text('Description', style: AppTheme.heading3),
                    const SizedBox(height: 8),
                    Text(event.description!, style: AppTheme.bodyMedium),
                  ],
                  const Divider(height: 32),
                  _buildInfoRow(HugeIcons.strokeRoundedCalendar03, 'Event Date',
                      event.eventDate != null ? _formatDate(event.eventDate!) : 'Not set'),
                  const SizedBox(height: 12),
                  _buildInfoRow(HugeIcons.strokeRoundedLocation01, 'Location', event.location ?? 'Not set'),
                  const SizedBox(height: 12),
                  _buildInfoRow(HugeIcons.strokeRoundedImage02, 'Media',
                      '${event.mediaCount ?? 0} items'),
                  const SizedBox(height: 12),
                  _buildInfoRow(HugeIcons.strokeRoundedUserMultiple, 'Guests',
                      '${event.guestsCount ?? 0} people'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // QR Code Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Event QR Code', style: AppTheme.heading3),
                  const SizedBox(height: 16),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: QrImageView(
                        data: event.qrCodeData,
                        version: QrVersions.auto,
                        size: 200,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Share this QR code with guests',
                    style: AppTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => _shareQRCode(event),
                    icon: const HugeIcon(
                      icon: HugeIcons.strokeRoundedShare08,
                      color: Colors.white,
                      size: 18,
                    ),
                    label: const Text('Share QR Code'),
                  ),
                ],
              ),
            ),
          ),
          if (event.hasGeofence) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: AppTheme.primaryColor),
                        const SizedBox(width: 8),
                        Text('Geofencing Enabled', style: AppTheme.heading3),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Latitude: ${event.geofenceLatitude?.toStringAsFixed(6) ?? "N/A"}',
                      style: AppTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Longitude: ${event.geofenceLongitude?.toStringAsFixed(6) ?? "N/A"}',
                      style: AppTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Radius: ${event.geofenceRadius?.toStringAsFixed(0) ?? "N/A"} meters',
                      style: AppTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMediaTab(EventProvider provider) {
    final media = provider.eventMedia;

    if (media.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_library, size: 100, color: AppTheme.textSecondary),
            const SizedBox(height: 16),
            const Text('No media yet', style: AppTheme.heading3),
            const SizedBox(height: 8),
            const Text('Upload photos and videos', style: AppTheme.bodyMedium),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Upload media
              },
              icon: const Icon(Icons.upload),
              label: const Text('Upload Media'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<EventProvider>().fetchEventMedia(provider.currentEvent!.id);
      },
      child: GridView.builder(
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 0,
          mainAxisSpacing: 0,
          childAspectRatio: 1,
        ),
        itemCount: media.length,
        itemBuilder: (context, index) {
          final item = media[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MediaViewerScreen(
                    mediaList: media,
                    initialIndex: index,
                  ),
                ),
              );
            },
            child: Hero(
              tag: item.id,
              child: Container(
                decoration: const BoxDecoration(
                  border: Border(
                    right: BorderSide(color: Colors.black, width: 0.5),
                    bottom: BorderSide(color: Colors.black, width: 0.5),
                  ),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      item.thumbnailPath ?? item.filePath,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                            strokeWidth: 2,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppTheme.dividerColor,
                          child: const Icon(Icons.broken_image, size: 32),
                        );
                      },
                    ),
                    if (item.isVideo)
                      Container(
                        color: Colors.black26,
                        child: const Center(
                          child: Icon(
                            Icons.play_circle_filled,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGuestsTab(EventProvider provider) {
    final guests = provider.eventGuests;

    if (guests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people, size: 100, color: AppTheme.textSecondary),
            const SizedBox(height: 16),
            const Text('No guests yet', style: AppTheme.heading3),
            const SizedBox(height: 8),
            const Text('Guests will appear here when they scan the QR code',
                style: AppTheme.bodyMedium, textAlign: TextAlign.center),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: guests.length,
      itemBuilder: (context, index) {
        final guest = guests[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.primaryColor,
              child: Text(
                guest.name.substring(0, 1).toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(guest.name),
            subtitle: Text(guest.email),
            trailing: Text(
              guest.role == 'creator' ? 'Creator' : 'Guest',
              style: AppTheme.bodySmall.copyWith(
                color: guest.role == 'creator'
                    ? AppTheme.primaryColor
                    : AppTheme.textSecondary,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnalyticsTab(EventProvider provider) {
    final scans = provider.eventScans;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('QR Code Scans', style: AppTheme.heading3),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildStatCard(
                        'Total Scans',
                        '${scans.length}',
                        HugeIcons.strokeRoundedQrCode,
                        AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        'Unique Users',
                        '${_getUniqueUsers(scans)}',
                        HugeIcons.strokeRoundedUserMultiple,
                        AppTheme.successColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (scans.isNotEmpty) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Recent Scans', style: AppTheme.heading3),
                    const SizedBox(height: 16),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: scans.length > 5 ? 5 : scans.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final scan = scans[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const HugeIcon(
                            icon: HugeIcons.strokeRoundedQrCode,
                            color: AppTheme.primaryColor,
                          ),
                          title: Text(scan.guest?.name ?? 'Unknown User'),
                          subtitle: Text(_formatDateTime(scan.scannedAt)),
                          trailing: scan.latitude != null && scan.longitude != null
                              ? const HugeIcon(
                                  icon: HugeIcons.strokeRoundedLocation01,
                                  size: 16, color: Colors.white,
                                )
                              : null,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        HugeIcon(icon: icon, size: 20, color: AppTheme.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: AppTheme.bodyMedium),
        ),
        Flexible(
          child: Text(
            value,
            style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: HugeIcon(icon: icon, color: color, size: 32),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value, style: AppTheme.heading2.copyWith(color: color)),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTheme.bodySmall,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  int _getUniqueUsers(List scans) {
    final uniqueUserIds = scans.map((scan) => scan.guestId).toSet();
    return uniqueUserIds.length;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showOptionsMenu() {
    final event = context.read<EventProvider>().currentEvent;
    if (event == null) return;

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const HugeIcon(
                icon: HugeIcons.strokeRoundedEdit02,
                color: AppTheme.primaryColor,
              ),
              title: const Text('Edit Event'),
              onTap: () async {
                Navigator.pop(context);
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateEventScreen(event: event),
                  ),
                );
                if (result == true && mounted) {
                  // Reload event data after edit
                  _loadEventData();
                }
              },
            ),
            ListTile(
              leading: const HugeIcon(
                icon: HugeIcons.strokeRoundedShare08,
                color: AppTheme.primaryColor,
              ),
              title: const Text('Share QR Code'),
              onTap: () {
                Navigator.pop(context);
                _shareQRCode(event);
              },
            ),
            ListTile(
              leading: const HugeIcon(
                icon: HugeIcons.strokeRoundedDelete02,
                color: AppTheme.errorColor,
              ),
              title: const Text('Delete Event', style: TextStyle(color: AppTheme.errorColor)),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _shareQRCode(Event event) {
    Share.share(
      'Join my event "${event.title}"!\nScan this QR code: ${event.qrCodeData}',
      subject: 'Event QR Code - ${event.title}',
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: const Text(
            'Are you sure you want to delete this event? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await context.read<EventProvider>().deleteEvent(widget.eventId);
                if (mounted) {
                  Navigator.pop(context);
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete event: $e')),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: AppTheme.errorColor)),
          ),
        ],
      ),
    );
  }
}
