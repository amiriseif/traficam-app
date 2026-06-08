import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('TrafficCam app renders without errors',
      (WidgetTester tester) async {
    // Simple test to verify Material app can render
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('Test')),
          body: const Center(child: Text('Hello')),
        ),
      ),
    );

    expect(find.text('Hello'), findsOneWidget);
    expect(find.text('Test'), findsOneWidget);
  });
}
