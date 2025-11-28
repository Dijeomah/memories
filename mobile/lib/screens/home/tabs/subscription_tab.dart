import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import '../../../config/app_routes.dart';
import '../../../config/app_theme.dart';
import '../../../providers/subscription_provider.dart';

class SubscriptionTab extends StatefulWidget {
  const SubscriptionTab({super.key});

  @override
  State<SubscriptionTab> createState() => _SubscriptionTabState();
}

class _SubscriptionTabState extends State<SubscriptionTab> {
  @override
  void initState() {
    super.initState();
    _loadSubscription();
  }

  void _loadSubscription() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SubscriptionProvider>().fetchCurrentSubscription();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final subscription = provider.currentSubscription;
        final plan = subscription?.plan;

        return RefreshIndicator(
          onRefresh: () async {
            await context.read<SubscriptionProvider>().fetchCurrentSubscription();
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Current Plan Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const HugeIcon(
                              icon: HugeIcons.strokeRoundedCrown,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  plan?.name ?? 'No Plan',
                                  style: AppTheme.heading2,
                                ),
                                const SizedBox(height: 4),
                                if (subscription != null)
                                  Text(
                                    subscription.isActive
                                        ? 'Active'
                                        : 'Inactive',
                                    style: AppTheme.bodyMedium.copyWith(
                                      color: subscription.isActive
                                          ? AppTheme.successColor
                                          : AppTheme.errorColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 32),
                      if (plan != null) ...[
                        _buildLimitRow(
                          'Events',
                          plan.hasUnlimitedEvents
                              ? 'Unlimited'
                              : '${plan.maxEvents}',
                          Icons.event,
                        ),
                        const SizedBox(height: 12),
                        _buildLimitRow(
                          'Storage',
                          plan.storageLimitDisplay,
                          Icons.cloud_upload,
                        ),
                        const SizedBox(height: 12),
                        _buildLimitRow(
                          'Guests per Event',
                          plan.hasUnlimitedGuests
                              ? 'Unlimited'
                              : '${plan.maxGuestsPerEvent}',
                          Icons.people,
                        ),
                        const SizedBox(height: 12),
                        _buildFeatureRow(
                          'QR Code Sharing',
                          plan.features.contains('qr_code_sharing'),
                        ),
                        const SizedBox(height: 12),
                        _buildFeatureRow(
                          'Geofencing',
                          plan.features.contains('geofencing'),
                        ),
                        const SizedBox(height: 12),
                        _buildFeatureRow(
                          'Media Moderation',
                          plan.features.contains('media_moderation'),
                        ),
                      ],
                      if (subscription != null && subscription.endsAt != null) ...[
                        const Divider(height: 32),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: AppTheme.textSecondary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Renews on ${_formatDate(subscription.endsAt!)}',
                              style: AppTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Upgrade Button
              if (plan != null && plan.isFree)
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.subscription);
                  },
                  child: const Text('Upgrade Plan'),
                ),
              const SizedBox(height: 8),
              // Manage Subscription Button
              if (subscription != null && !plan!.isFree)
                OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.subscription);
                  },
                  child: const Text('Manage Subscription'),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLimitRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: AppTheme.bodyMedium),
        ),
        Text(
          value,
          style: AppTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureRow(String label, bool enabled) {
    return Row(
      children: [
        Icon(
          enabled ? Icons.check_circle : Icons.cancel,
          size: 20,
          color: enabled ? AppTheme.successColor : AppTheme.textSecondary,
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: AppTheme.bodyMedium.copyWith(
            color: enabled ? AppTheme.textPrimary : AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
