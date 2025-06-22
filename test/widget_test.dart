import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cycle_tracker_app/main.dart';

void main() {
  testWidgets('App loads without crashing', (WidgetTester tester) async {
    // Simple smoke test - just verify app doesn't crash on startup
    await tester.pumpWidget(const CycleTrackerApp());
    await tester.pump();

    // Basic verification that MaterialApp is working
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
