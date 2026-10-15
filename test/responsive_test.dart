import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_progress_tracker/main.dart';

Future<void> configure(WidgetTester tester, Size size, double scale) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}

void main() {
  final devices = <String, Size>{
    'small phone': const Size(320, 640),
    'phone': const Size(390, 844),
    'tablet': const Size(800, 1200),
  };

  for (final entry in devices.entries) {
    for (final scale in [0.85, 1.0, 1.15]) {
      testWidgets('${entry.key} @ ${scale}x text', (tester) async {
        await configure(tester, entry.value, scale);
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Log'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Summary'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Home'));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });
    }
  }
}
