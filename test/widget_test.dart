import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cycle_tracker_app/main.dart';

void main() {
  testWidgets('Cycle Tracker app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CycleTrackerApp());

    // Verify that our app loads with the correct title.
    expect(find.text('Cycle Tracker'), findsOneWidget);
    expect(find.text('Welcome to Cycle Tracker'), findsOneWidget);

    // Verify the add button is present
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}
