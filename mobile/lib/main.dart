import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'config/app_theme.dart';
import 'config/app_routes.dart';
import 'providers/auth_provider.dart';
import 'providers/event_provider.dart';
import 'providers/subscription_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/events/create_event_screen.dart';
import 'screens/events/event_detail_screen.dart';
import 'screens/qr/scan_qr_screen.dart';
import 'screens/subscription/subscription_screen.dart';
import 'screens/profile/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: '.env');

  runApp(const MemoriesApp());
}

class MemoriesApp extends StatelessWidget {
  const MemoriesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
      ],
      child: MaterialApp(
        title: 'Memories',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.splash,
        routes: {
          AppRoutes.splash: (context) => const SplashScreen(),
          AppRoutes.login: (context) => const LoginScreen(),
          AppRoutes.register: (context) => const RegisterScreen(),
          AppRoutes.home: (context) => const HomeScreen(),
          AppRoutes.createEvent: (context) => const CreateEventScreen(),
          AppRoutes.scanQR: (context) => const ScanQRScreen(),
          AppRoutes.subscription: (context) => const SubscriptionScreen(),
          AppRoutes.profile: (context) => const ProfileScreen(),
        },
        onGenerateRoute: (settings) {
          // Handle routes with parameters
          if (settings.name == AppRoutes.eventDetail) {
            final eventId = settings.arguments as int;
            return MaterialPageRoute(
              builder: (context) => EventDetailScreen(eventId: eventId),
            );
          }

          return null;
        },
      ),
    );
  }
}
