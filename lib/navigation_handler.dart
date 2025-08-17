import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/intro/intro_screen_1.dart';
import 'screens/detox_home_screen.dart';
import 'screens/timer_setup_screen.dart';

class NavigationHandler extends StatefulWidget {
  const NavigationHandler({super.key});

  @override
  State<NavigationHandler> createState() => _NavigationHandlerState();
}

class _NavigationHandlerState extends State<NavigationHandler> {
  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Check if this is the first launch
    final isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
    final isOnboardingComplete = prefs.getBool('isOnboardingComplete') ?? false;
    final isDetoxActive = prefs.getBool('isDetoxActive') ?? false;

    if (!mounted) return;

    // Navigate based on app state
    if (isFirstLaunch || !isOnboardingComplete) {
      // Show intro screens for first-time users
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const IntroScreen1()),
      );
    } else if (isDetoxActive) {
      // User has an active detox session
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const DetoxHomeScreen()),
      );
    } else {
      // User is logged in but no active session
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const TimerSetupScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while checking status
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF6366f1),
              Color(0xFF8b5cf6),
            ],
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}