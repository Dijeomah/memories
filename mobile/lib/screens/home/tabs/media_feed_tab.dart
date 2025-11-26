import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/app_theme.dart';
import '../../../providers/event_provider.dart';
import '../../../models/media.dart';

class MediaFeedTab extends StatefulWidget {
  const MediaFeedTab({super.key});

  @override
  State<MediaFeedTab> createState() => _MediaFeedTabState();
}

class _MediaFeedTabState extends State<MediaFeedTab> {
  @override
  void initState() {
    super.initState();
    _loadRecentMedia();
  }

  void _loadRecentMedia() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load recent media across all events
      context.read<EventProvider>().fetchRecentMedia();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EventProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final recentMedia = provider.recentMedia;

        if (recentMedia.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.photo_library, size: 100, color: AppTheme.textSecondary),
                const SizedBox(height: 16),
                const Text('No memories yet', style: AppTheme.heading3),
                const SizedBox(height: 8),
                const Text(
                  'Upload photos and videos to your events',
                  style: AppTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await context.read<EventProvider>().fetchRecentMedia();
          },
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemCount: recentMedia.length,
            itemBuilder: (context, index) {
              final media = recentMedia[index];
              return _MediaCard(media: media);
            },
          ),
        );
      },
    );
  }
}

class _MediaCard extends StatelessWidget {
  final Media media;

  const _MediaCard({required this.media});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // TODO: Show full screen media viewer
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Thumbnail
                  Image.network(
                    media.thumbnailPath ?? media.filePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppTheme.dividerColor,
                        child: const Icon(Icons.broken_image, size: 50),
                      );
                    },
                  ),
                  // Video indicator
                  if (media.isVideo)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (media.event != null)
                    Text(
                      media.event!.title,
                      style: AppTheme.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(media.createdAt),
                    style: AppTheme.caption,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
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
}
