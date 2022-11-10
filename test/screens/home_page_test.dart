import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_ktv/screens/home_page.dart';

Widget createHomePage() => const MaterialApp(home: Scaffold(body: HomePage()));

void main() {
  group('Main page test', () {
    testWidgets('Navigation to album page when clicking album icon',
        (tester) async {
      // await tester.pumpWidget(createHomePage());
      // TODO
    });

    testWidgets('Navigate to search page when clicking search box',
        (tester) async {
      // await tester.pumpWidget(createHomePage());
      // TODO
    });
  });
}
