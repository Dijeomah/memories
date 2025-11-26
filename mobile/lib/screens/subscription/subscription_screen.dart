import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Subscription')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text('Current Plan', style: AppTheme.heading3),
                    const SizedBox(height: 16),
                    const Text('Free Plan', style: AppTheme.heading2),
                    const SizedBox(height: 8),
                    const Text('1 event, 50 guests, 1GB storage', style: AppTheme.bodyMedium),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text('Upgrade Plan'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Usage', style: AppTheme.heading3),
            const SizedBox(height: 16),
            _buildUsageItem('Events', 0, 1),
            _buildUsageItem('Storage', 0, 1024),
          ],
        ),
      ),
    );
  }

  Widget _buildUsageItem(String label, int current, int limit) {
    return Card(
      child: ListTile(
        title: Text(label),
        subtitle: LinearProgressIndicator(
          value: current / limit,
          backgroundColor: AppTheme.dividerColor,
          valueColor: const AlwaysStoppedAnimation(AppTheme.primaryColor),
        ),
        trailing: Text('$current / $limit'),
      ),
    );
  }
}
