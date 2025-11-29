import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../config/app_routes.dart';
import '../config/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  void _navigate() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.guestWelcome);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // add this svg: 'assets/illustrations/scanners.svg' below instead of the Icon
              SvgPicture.asset('assets/illustrations/scanners.svg'),
              // const Icon(Icons.photo_library, size: 100, color: Colors.white),
              // const SizedBox(height: 20),
              const Text(
                'Memories',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Share Your Moments',
                style: TextStyle(fontSize: 18, color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
