import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

class EventDetailScreen extends StatelessWidget {
  final int eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Event Details')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.event, size: 100, color: AppTheme.primaryColor),
            const SizedBox(height: 16),
            Text('Event ID: $eventId', style: AppTheme.heading3),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.qr_code),
              label: const Text('View QR Code'),
            ),
          ],
        ),
      ),
    );
  }
}
