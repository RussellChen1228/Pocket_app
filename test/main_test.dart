import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_ktv/main.dart';

Widget createMainPage() => MaterialApp(home: MainPage());

void main() {
  group('Main page test', () {
    testWidgets('Testing if bottom navigation bar shows up', (tester) async {
      //TODO
      // await tester.pumpWidget(createMainPage());
      // expect(find.byType(BottomNavigationBar), findsOneWidget);
      // expect(find.byIcon(Icons.home_filled), findsOneWidget);
      // expect(find.byIcon(Icons.library_music), findsOneWidget);
      // expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('Testing bottom navigation bar navigation', (tester) async {
      //TODO: Click library.
      //TODO: Click Search.
      //TODO: Click Home.
    });
  });
}
