import 'package:cycle_tracker_app/dependencies.dart';
import 'package:cycle_tracker_app/core/router.dart';

/// Home screen displaying family member profiles and cycle overview
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cycle Tracker'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to Cycle Tracker',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Track and understand family menstrual cycles',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            const Text(
              'Test Navigation:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, Routes.profile),
                  child: const Text('Profile'),
                ),
                ElevatedButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, Routes.cycleDetails),
                  child: const Text('Cycle Details'),
                ),
                ElevatedButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, Routes.settings),
                  child: const Text('Settings'),
                ),
                ElevatedButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/invalid-route'),
                  child: const Text('404 Test'),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to add profile screen
        },
        tooltip: 'Add Profile',
        child: const Icon(Icons.add),
      ),
    );
  }
}
