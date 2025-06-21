import 'package:cycle_tracker_app/dependencies.dart';
import 'package:cycle_tracker_app/presentation/screens/home_screen.dart';
import 'package:cycle_tracker_app/core/constants/app_constants.dart';

void main() {
  runApp(const ProviderScope(child: CycleTrackerApp()));
}

class CycleTrackerApp extends StatelessWidget {
  const CycleTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.pink,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
