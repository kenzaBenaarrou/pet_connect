// This is a basic Flutter widget test for PetConnect app.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pet_con/main.dart';

void main() {
  testWidgets('PetConnect app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: PetConnectApp()));

    // Verify that we can find the app title or login screen
    // This is a basic smoke test to ensure the app builds
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
