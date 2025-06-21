import 'package:flutter/material.dart';
import 'package:cycle_tracker_app/presentation/screens/home_screen.dart';
import 'package:cycle_tracker_app/presentation/screens/not_found_screen.dart';

/// Route names constants
class Routes {
  static const String home = '/';
  static const String profile = '/profile';
  static const String cycleDetails = '/cycle-details';
  static const String settings = '/settings';
}

/// App route generator
class AppRouter {
  /// Generate routes based on route settings
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );
      case Routes.profile:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Profile Screen - Coming Soon')),
          ),
          settings: settings,
        );
      case Routes.cycleDetails:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Cycle Details Screen - Coming Soon')),
          ),
          settings: settings,
        );
      case Routes.settings:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Settings Screen - Coming Soon')),
          ),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const NotFoundScreen(),
          settings: settings,
        );
    }
  }
}
