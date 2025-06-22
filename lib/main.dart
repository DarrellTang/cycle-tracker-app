import 'package:cycle_tracker_app/dependencies.dart';
import 'package:cycle_tracker_app/core/constants/app_constants.dart';
import 'package:cycle_tracker_app/core/router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: Routes.home,
    );
  }
}
