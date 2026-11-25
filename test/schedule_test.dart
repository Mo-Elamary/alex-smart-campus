import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:smart_campus/screens/home_screen.dart';

void main() {
  late Directory dir;
  setUp(() async {
    dir = await Directory.systemTemp.createTemp('campus_test_');
    Hive.init(dir.path);
    await Hive.openBox('schedules');
  });
  tearDown(() async {
    await Hive.close();
    await dir.delete(recursive: true);
  });

  testWidgets('schedule dialog supports saving, editing and cancelling', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: SchedulePage(uid: 'student')),
      ),
    );
    await tester.tap(find.text('Add class'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Course name'),
      'Mobile Computing',
    );
    await tester.enterText(find.widgetWithText(TextFormField, 'Room'), 'A12');
    await tester.tap(find.text('Choose time'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      await tester.tap(find.text('Save'));
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Mobile Computing'), findsOneWidget);
    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Room'), 'B14');
    await tester.runAsync(() async {
      await tester.tap(find.text('Save'));
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.textContaining('B14'), findsOneWidget);
    await tester.tap(find.text('Add class'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
