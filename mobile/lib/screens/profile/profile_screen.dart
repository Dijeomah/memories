import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_routes.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppTheme.primaryColor,
                  child: Text(
                    user?['name']?.substring(0, 1).toUpperCase() ?? 'U',
                    style: const TextStyle(fontSize: 40, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                Text(user?['name'] ?? 'User', style: AppTheme.heading2),
                const SizedBox(height: 8),
                Text(user?['email'] ?? '', style: AppTheme.bodyMedium),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildMenuItem(
            icon: Icons.subscriptions,
            title: 'Subscription',
            onTap: () => Navigator.pushNamed(context, AppRoutes.subscription),
          ),
          _buildMenuItem(
            icon: Icons.settings,
            title: 'Settings',
            onTap: () {},
          ),
          _buildMenuItem(
            icon: Icons.help,
            title: 'Help & Support',
            onTap: () {},
          ),
          const Divider(height: 32),
          _buildMenuItem(
            icon: Icons.logout,
            title: 'Logout',
            textColor: AppTheme.errorColor,
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: textColor ?? AppTheme.primaryColor),
        title: Text(title, style: TextStyle(color: textColor)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  void _logout(BuildContext context) async {
    await context.read<AuthProvider>().logout();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
    }
  }
}
