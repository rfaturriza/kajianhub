import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quranku/features/buletin/presentation/screens/buletin_screen.dart';

void main() {
  group('BuletinScreen', () {
    testWidgets('should display app bar with correct title',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BuletinScreen(),
        ),
      );

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Buletin'), findsOneWidget);
    });

    testWidgets('should display search field', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BuletinScreen(),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
    });
  });
}
