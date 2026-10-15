import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_progress_tracker/main.dart';
import 'package:fitness_progress_tracker/screens/add_workout_screen.dart';
import 'package:fitness_progress_tracker/screens/summary_screen.dart';
import 'package:fitness_progress_tracker/screens/workout_details_screen.dart';
import 'package:fitness_progress_tracker/models/workout.dart';
import 'package:fitness_progress_tracker/theme/app_theme.dart';

Future<void> _setPhone(WidgetTester tester) async {
  tester.view.physicalSize = const Size(360, 640);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Widget _app(Widget child) => MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: child,
    );

void main() {
  testWidgets('Home dashboard renders on a phone size', (tester) async {
    await _setPhone(tester);
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Recent workouts'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Add workout screen renders on a phone size', (tester) async {
    await _setPhone(tester);
    await tester.pumpWidget(
      _app(AddWorkoutScreen(onAddWorkout: (_) {})),
    );
    await tester.pumpAndSettle();
    expect(find.text('Workout type'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Save workout'), 300.0, scrollable: find.byType(Scrollable).first);
    expect(find.text('Save workout'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Summary screen renders on a phone size', (tester) async {
    await _setPhone(tester);
    await tester.pumpWidget(
      _app(SummaryScreen(workouts: [
        Workout(
          id: '1',
          date: '2026-10-15',
          type: 'Weight Lifting',
          duration: 30,
          caloriesBurned: 350,
          notes: 'x',
        ),
        Workout(
          id: '2',
          date: '2026-10-15',
          type: 'Cardio',
          duration: 20,
          caloriesBurned: 200,
          notes: 'x',
        ),
      ])),
    );
    await tester.pumpAndSettle();
    expect(find.text('This week'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Workout breakdown'), 300.0, scrollable: find.byType(Scrollable).first);
    expect(find.text('Workout breakdown'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Details screen renders on a phone size', (tester) async {
    await _setPhone(tester);
    await tester.pumpWidget(
      _app(WorkoutDetailsScreen(
        workout: Workout(
          id: '1',
          date: '2026-10-15',
          type: 'Weight Lifting',
          duration: 30,
          distance: 5.0,
          weight: 70,
          reps: 10,
          sets: 3,
          caloriesBurned: 350,
          notes: 'Felt strong today',
        ),
      )),
    );
    await tester.pumpAndSettle();
    expect(find.text('Metrics'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Notes'), 300.0, scrollable: find.byType(Scrollable).first);
    expect(find.text('Notes'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Form validation shows errors for empty required fields',
      (tester) async {
    await _setPhone(tester);
    await tester.pumpWidget(
      _app(AddWorkoutScreen(onAddWorkout: (_) {})),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Save workout'), 300.0, scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('Save workout'));
    await tester.pumpAndSettle();

    expect(find.text('Duration is required'), findsOneWidget);
    expect(find.text('Calories is required'), findsOneWidget);
  });
}
