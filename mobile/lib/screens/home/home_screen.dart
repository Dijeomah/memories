import 'package:flutter/material.dart';
import '../../config/app_routes.dart';
import '../../config/app_theme.dart';
import 'tabs/media_feed_tab.dart';
import 'tabs/events_list_tab.dart';
import 'tabs/subscription_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = const [
    MediaFeedTab(),
    EventsListTab(),
    SubscriptionTab(),
  ];

  final List<String> _titles = const [
    'Memories',
    'My Events',
    'My Plan',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove back button
        title: Text(_titles[_currentIndex]),
        actions: [
          if (_currentIndex < 2) ...[
            IconButton(
              icon: const Icon(Icons.qr_code_scanner),
              onPressed: () => Navigator.pushNamed(context, AppRoutes.scanQR),
            ),
          ],
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      floatingActionButton: _currentIndex == 1
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.createEvent),
              icon: const Icon(Icons.add),
              label: const Text('Create Event'),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.workspace_premium),
            label: 'Plan',
          ),
        ],
      ),
    );
  }
}
