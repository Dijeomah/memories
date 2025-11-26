import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../config/app_theme.dart';
import '../../providers/event_provider.dart';
import '../../models/event.dart';

class GuestEventScreen extends StatefulWidget {
  final Event event;
  final Map<String, dynamic> guestInfo;

  const GuestEventScreen({
    super.key,
    required this.event,
    required this.guestInfo,
  });

  @override
  State<GuestEventScreen> createState() => _GuestEventScreenState();
}

class _GuestEventScreenState extends State<GuestEventScreen> {
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadEventMedia();
  }

  void _loadEventMedia() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventProvider>().fetchEventMedia(widget.event.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showEventInfo,
          ),
        ],
      ),
      body: Consumer<EventProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.eventMedia.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final media = provider.eventMedia;

          if (media.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.photo_library, size: 100, color: AppTheme.textSecondary),
                  const SizedBox(height: 16),
                  const Text('No photos yet', style: AppTheme.heading3),
                  const SizedBox(height: 8),
                  const Text(
                    'Be the first to upload!',
                    style: AppTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await context.read<EventProvider>().fetchEventMedia(widget.event.id);
            },
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemCount: media.length,
              itemBuilder: (context, index) {
                final item = media[index];
                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      // TODO: Show full screen image viewer
                    },
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          item.thumbnailPath ?? item.filePath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppTheme.dividerColor,
                              child: const Icon(Icons.broken_image),
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
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Camera Button
          FloatingActionButton(
            heroTag: 'camera',
            onPressed: () => _pickMedia(ImageSource.camera),
            backgroundColor: AppTheme.primaryColor,
            child: const Icon(Icons.camera_alt),
          ),
          const SizedBox(height: 12),
          // Gallery Button
          FloatingActionButton(
            heroTag: 'gallery',
            onPressed: () => _pickMedia(ImageSource.gallery),
            backgroundColor: AppTheme.secondaryColor,
            child: const Icon(Icons.photo_library),
          ),
        ],
      ),
    );
  }

  void _pickMedia(ImageSource source) async {
    try {
      // Show option to choose photo or video
      final mediaType = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Choose media type'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo, color: AppTheme.primaryColor),
                title: const Text('Photo'),
                onTap: () => Navigator.pop(context, 'photo'),
              ),
              ListTile(
                leading: const Icon(Icons.videocam, color: AppTheme.secondaryColor),
                title: const Text('Video'),
                onTap: () => Navigator.pop(context, 'video'),
              ),
            ],
          ),
        ),
      );

      if (mediaType == null) return;

      XFile? file;
      if (mediaType == 'photo') {
        file = await _picker.pickImage(
          source: source,
          maxWidth: 1920,
          maxHeight: 1080,
          imageQuality: 85,
        );
      } else {
        file = await _picker.pickVideo(
          source: source,
          maxDuration: const Duration(minutes: 2),
        );
      }

      if (file != null) {
        _uploadMedia(File(file.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick media: $e')),
        );
      }
    }
  }

  void _uploadMedia(File file) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Uploading...'),
          ],
        ),
      ),
    );

    try {
      await context.read<EventProvider>().uploadMedia(
            eventId: widget.event.id,
            file: file,
          );

      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Media uploaded successfully!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    }
  }

  void _showEventInfo() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Event Information', style: AppTheme.heading3),
            const Divider(height: 32),
            if (widget.event.description != null) ...[
              Text('Description', style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              )),
              const SizedBox(height: 8),
              Text(widget.event.description!, style: AppTheme.bodyMedium),
              const SizedBox(height: 16),
            ],
            if (widget.event.eventDate != null) ...[
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: AppTheme.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    _formatDate(widget.event.eventDate!),
                    style: AppTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            if (widget.event.location != null) ...[
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: AppTheme.textSecondary),
                  const SizedBox(width: 8),
                  Text(widget.event.location!, style: AppTheme.bodyMedium),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
