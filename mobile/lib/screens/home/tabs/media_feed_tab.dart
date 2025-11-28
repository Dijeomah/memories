import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../config/app_theme.dart';
import '../../../providers/event_provider.dart';
import '../../../models/media.dart';
import '../../media/media_viewer_screen.dart';

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
                HugeIcon(
                  icon: HugeIcons.strokeRoundedImage02,
                  size: 100,
                  color: AppTheme.textSecondary,
                ),
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
          child: CustomScrollView(
            slivers: [
              // Slideshow Hero Section
              SliverToBoxAdapter(
                child: _MemoriesSlideshow(media: recentMedia),
              ),
              // Grid of all memories
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final media = recentMedia[index];
                      return _MediaGridItem(media: media, allMedia: recentMedia, initialIndex: index);
                    },
                    childCount: recentMedia.length,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Amazing slideshow widget with fade animations
class _MemoriesSlideshow extends StatefulWidget {
  final List<Media> media;

  const _MemoriesSlideshow({required this.media});

  @override
  State<_MemoriesSlideshow> createState() => _MemoriesSlideshowState();
}

class _MemoriesSlideshowState extends State<_MemoriesSlideshow> {
  int _currentIndex = 0;
  Timer? _timer;
  double _opacity = 1.0;

  @override
  void initState() {
    super.initState();
    _startSlideshow();
  }

  void _startSlideshow() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      setState(() {
        _opacity = 0.0;
      });

      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _currentIndex = (_currentIndex + 1) % widget.media.length;
            _opacity = 1.0;
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentMedia = widget.media[_currentIndex];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MediaViewerScreen(
              mediaList: widget.media,
              initialIndex: _currentIndex,
            ),
          ),
        );
      },
      child: Container(
        height: 400,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image with fade animation
              AnimatedOpacity(
                opacity: _opacity,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                child: Image.network(
                  currentMedia.filePath,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: AppTheme.dividerColor,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppTheme.dividerColor,
                      child: const Center(
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedImageNotFound02,
                          size: 64,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Gradient overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.8),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (currentMedia.event != null)
                        Row(
                          children: [
                            const HugeIcon(
                              icon: HugeIcons.strokeRoundedCalendar03,
                              size: 16,
                              color: Colors.white70,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                currentMedia.event!.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const HugeIcon(
                            icon: HugeIcons.strokeRoundedClock01,
                            size: 14,
                            color: Colors.white70,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _formatDate(currentMedia.createdAt),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const Spacer(),
                          // Page indicators
                          Row(
                            children: List.generate(
                              widget.media.length > 5 ? 5 : widget.media.length,
                              (index) => Container(
                                margin: const EdgeInsets.symmetric(horizontal: 2),
                                width: _currentIndex % widget.media.length == index ? 24 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _currentIndex % widget.media.length == index
                                      ? Colors.white
                                      : Colors.white30,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Video indicator
              if (currentMedia.isVideo)
                const Center(
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedPlayCircle,
                    size: 64,
                    color: Colors.white,
                  ),
                ),
            ],
          ),
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

// Grid item widget
class _MediaGridItem extends StatelessWidget {
  final Media media;
  final List<Media> allMedia;
  final int initialIndex;

  const _MediaGridItem({
    required this.media,
    required this.allMedia,
    required this.initialIndex,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MediaViewerScreen(
              mediaList: allMedia,
              initialIndex: initialIndex,
            ),
          ),
        );
      },
      child: Hero(
        tag: 'media_${media.id}',
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black12, width: 0.5),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  media.thumbnailPath ?? media.filePath,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: AppTheme.dividerColor,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppTheme.dividerColor,
                      child: const Center(
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedImageNotFound02,
                          size: 24,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    );
                  },
                ),
                if (media.isVideo)
                  Container(
                    color: Colors.black26,
                    child: const Center(
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedPlayCircle,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
