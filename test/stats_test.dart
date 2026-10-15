import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_progress_tracker/models/goals.dart';
import 'package:fitness_progress_tracker/models/stats.dart';
import 'package:fitness_progress_tracker/models/workout.dart';

Workout _w({
  required String date,
  String type = 'Running',
  int duration = 30,
  int calories = 100,
  double? distance,
  double? weight,
}) {
  return Workout(
    id: '$date-$type',
    date: date,
    type: type,
    duration: duration,
    caloriesBurned: calories,
    distance: distance,
    weight: weight,
    notes: '',
  );
}

String _daysAgo(int days) =>
    WorkoutStats.formatDate(DateTime.now().subtract(Duration(days: days)));

void main() {
  test('totals sum correctly', () {
    final list = [
      _w(date: _daysAgo(0), duration: 30, calories: 300),
      _w(date: _daysAgo(0), duration: 20, calories: 200, distance: 5),
    ];
    expect(WorkoutStats.totalMinutes(list), 50);
    expect(WorkoutStats.totalCalories(list), 500);
    expect(WorkoutStats.totalDistance(list), 5);
  });

  test('current streak counts consecutive days up to today', () {
    final list = [
      _w(date: _daysAgo(0)),
      _w(date: _daysAgo(1)),
      _w(date: _daysAgo(2)),
      _w(date: _daysAgo(4)),
    ];
    expect(WorkoutStats.currentStreak(list), 3);
  });

  test('current streak is zero when last workout is older than yesterday', () {
    final list = [_w(date: _daysAgo(3)), _w(date: _daysAgo(4))];
    expect(WorkoutStats.currentStreak(list), 0);
  });

  test('longest streak finds the best run', () {
    final list = [
      _w(date: _daysAgo(0)),
      _w(date: _daysAgo(1)),
      _w(date: _daysAgo(5)),
      _w(date: _daysAgo(6)),
      _w(date: _daysAgo(7)),
    ];
    expect(WorkoutStats.longestStreak(list), 3);
    expect(WorkoutStats.currentStreak(list), 2);
  });

  test('achievements unlock against running totals', () {
    final many = List.generate(10, (i) => _w(date: _daysAgo(i), calories: 600));
    final list = WorkoutStats.achievements(many, Goals.defaults);

    expect(list.firstWhere((a) => a.title == 'First Step').unlocked, isTrue);
    expect(list.firstWhere((a) => a.title == 'Committed').unlocked, isTrue);
    expect(list.firstWhere((a) => a.title == '5K Club').unlocked, isTrue);
    expect(list.firstWhere((a) => a.title == 'Veteran').unlocked, isFalse);
  });

  test('records pick the maximum value', () {
    final list = [
      _w(date: _daysAgo(0), calories: 100, distance: 2, weight: 50),
      _w(date: _daysAgo(1), calories: 400, distance: 7, weight: 80),
    ];
    expect(WorkoutStats.recordCalories(list)!.caloriesBurned, 400);
    expect(WorkoutStats.recordDistance(list)!.distance, 7);
    expect(WorkoutStats.recordWeight(list)!.weight, 80);
  });

  test('monthlyMinutes returns the requested window', () {
    final months = WorkoutStats.monthlyMinutes(
      [_w(date: _daysAgo(0), duration: 40)],
      months: 6,
    );
    expect(months.length, 6);
    expect(months.last.value, 40); // current month
  });
}
