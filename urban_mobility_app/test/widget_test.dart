// This is a basic Flutter widget test for InDriver app.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:urban_mobility_app/main.dart';

void main() {
  testWidgets('InDriver app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const InDriverApp());
    await tester.pump();

    // Verify that the app loads with the correct title
    expect(find.text('InDriver'), findsOneWidget);
    
    // Verify that the welcome message is displayed
    expect(find.text('Encontre sua corrida!'), findsOneWidget);
    
    // Verify that the bottom navigation is present
    expect(find.text('Início'), findsOneWidget);
    expect(find.text('Corridas'), findsOneWidget);
    expect(find.text('Perfil'), findsOneWidget);

    // Verify that location card is present
    expect(find.text('Sua Localização'), findsOneWidget);
    
    // Verify that recent trips section is present
    expect(find.text('Corridas Recentes'), findsOneWidget);
  });
}
