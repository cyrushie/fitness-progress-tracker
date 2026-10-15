import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'goals.dart';
import 'workout.dart';

/// Pure functions that derive insights from the in-memory workout list.
/// Everything here works on a simple [List] without any persistence layer.
class WorkoutStats {
  WorkoutStats._();

  static const List<String> _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  // ----- Date helpers -------------------------------------------------------

  static DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static DateTime? parseDate(String value) {
    final parsed = DateTime.tryParse(value);
    return parsed == null ? null : dateOnly(parsed);
  }

  static String formatDate(DateTime d) {
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$day';
  }

  static String monthLabel(int month) => _monthNames[(month - 1) % 12];

  static DateTime startOfWeek(DateTime d) {
    final day = dateOnly(d);
    return day.subtract(Duration(days: day.weekday - 1)); // Monday
  }

  // ----- Totals -------------------------------------------------------------

  static int totalCalories(List<Workout> w) =>
      w.fold(0, (sum, e) => sum + e.caloriesBurned);

  static int totalMinutes(List<Workout> w) =>
      w.fold(0, (sum, e) => sum + e.duration);

  static double totalDistance(List<Workout> w) =>
      w.fold(0.0, (sum, e) => sum + (e.distance ?? 0));

  // ----- Per-day lookups ----------------------------------------------------

  static List<Workout> workoutsOn(List<Workout> w, DateTime day) {
    final target = dateOnly(day);
    return w.where((e) => parseDate(e.date) == target).toList();
  }

  static int caloriesOn(List<Workout> w, DateTime day) =>
      workoutsOn(w, day).fold(0, (sum, e) => sum + e.caloriesBurned);

  static int minutesOn(List<Workout> w, DateTime day) =>
      workoutsOn(w, day).fold(0, (sum, e) => sum + e.duration);

  // ----- This week ----------------------------------------------------------

  static List<Workout> workoutsThisWeek(List<Workout> w) {
    final start = startOfWeek(DateTime.now());
    final end = start.add(const Duration(days: 7));
    return w.where((e) {
      final d = parseDate(e.date);
      return d != null && !d.isBefore(start) && d.isBefore(end);
    }).toList();
  }

  // ----- Streaks ------------------------------------------------------------

  static Set<DateTime> _activeDays(List<Workout> w) =>
      w.map((e) => parseDate(e.date)).whereType<DateTime>().toSet();

  /// Consecutive days up to today (or yesterday, so a streak isn't lost
  /// before the day is over).
  static int currentStreak(List<Workout> w) {
    final days = _activeDays(w);
    if (days.isEmpty) return 0;

    var cursor = dateOnly(DateTime.now());
    if (!days.contains(cursor)) {
      cursor = cursor.subtract(const Duration(days: 1));
      if (!days.contains(cursor)) return 0;
    }

    var streak = 0;
    while (days.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  static int longestStreak(List<Workout> w) {
    final days = _activeDays(w).toList()..sort();
    if (days.isEmpty) return 0;

    var best = 1;
    var run = 1;
    for (var i = 1; i < days.length; i++) {
      if (days[i].difference(days[i - 1]).inDays == 1) {
        run++;
      } else {
        run = 1;
      }
      if (run > best) best = run;
    }
    return best;
  }

  // ----- Personal records ---------------------------------------------------

  static Workout? recordCalories(List<Workout> w) =>
      w.isEmpty ? null : w.reduce((a, b) => a.caloriesBurned >= b.caloriesBurned ? a : b);

  static Workout? recordDuration(List<Workout> w) =>
      w.isEmpty ? null : w.reduce((a, b) => a.duration >= b.duration ? a : b);

  static Workout? recordDistance(List<Workout> w) {
    final withDistance = w.where((e) => (e.distance ?? 0) > 0).toList();
    if (withDistance.isEmpty) return null;
    return withDistance.reduce((a, b) => (a.distance ?? 0) >= (b.distance ?? 0) ? a : b);
  }

  static Workout? recordWeight(List<Workout> w) {
    final withWeight = w.where((e) => (e.weight ?? 0) > 0).toList();
    if (withWeight.isEmpty) return null;
    return withWeight.reduce((a, b) => (a.weight ?? 0) >= (b.weight ?? 0) ? a : b);
  }

  // ----- Monthly trend ------------------------------------------------------

  /// Returns totals for the last [months] months (oldest first).
  static List<MapEntry<String, int>> monthlyMinutes(
    List<Workout> w, {
    int months = 6,
  }) {
    final now = DateTime.now();
    final result = <MapEntry<String, int>>[];

    for (var i = months - 1; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final total = w.where((e) {
        final d = parseDate(e.date);
        return d != null && d.year == month.year && d.month == month.month;
      }).fold(0, (sum, e) => sum + e.duration);
      result.add(MapEntry(monthLabel(month.month), total));
    }
    return result;
  }

  // ----- Achievements -------------------------------------------------------

  static List<Achievement> achievements(List<Workout> w, Goals goals) {
    final total = w.length;
    final calories = totalCalories(w);
    final distance = totalDistance(w).round();
    final minutes = totalMinutes(w);
    final best = longestStreak(w);
    final week = workoutsThisWeek(w).length;

    return [
      Achievement(
        title: 'First Step',
        description: 'Log your first workout',
        icon: Icons.flag_rounded,
        color: AppColors.running,
        progress: total,
        target: 1,
      ),
      Achievement(
        title: 'Getting Started',
        description: 'Complete 5 workouts',
        icon: Icons.directions_run_rounded,
        color: AppColors.running,
        progress: total,
        target: 5,
      ),
      Achievement(
        title: 'Committed',
        description: 'Complete 10 workouts',
        icon: Icons.fitness_center_rounded,
        color: AppColors.lifting,
        progress: total,
        target: 10,
      ),
      Achievement(
        title: 'Veteran',
        description: 'Complete 25 workouts',
        icon: Icons.military_tech_rounded,
        color: AppColors.warning,
        progress: total,
        target: 25,
      ),
      Achievement(
        title: 'On Fire',
        description: 'Reach a 3-day streak',
        icon: Icons.local_fire_department_rounded,
        color: AppColors.cardio,
        progress: best,
        target: 3,
      ),
      Achievement(
        title: 'Unstoppable',
        description: 'Reach a 7-day streak',
        icon: Icons.whatshot_rounded,
        color: AppColors.danger,
        progress: best,
        target: 7,
      ),
      Achievement(
        title: '1K Club',
        description: 'Burn 1,000 kcal total',
        icon: Icons.bolt_rounded,
        color: AppColors.secondary,
        progress: calories,
        target: 1000,
      ),
      Achievement(
        title: '5K Club',
        description: 'Burn 5,000 kcal total',
        icon: Icons.bolt_rounded,
        color: AppColors.secondary,
        progress: calories,
        target: 5000,
      ),
      Achievement(
        title: 'Distance Demon',
        description: 'Cover 25 km total',
        icon: Icons.straighten_rounded,
        color: AppColors.yoga,
        progress: distance,
        target: 25,
      ),
      Achievement(
        title: 'Time Well Spent',
        description: 'Log 300 active minutes',
        icon: Icons.timer_rounded,
        color: AppColors.yoga,
        progress: minutes,
        target: 300,
      ),
      Achievement(
        title: 'Goal Getter',
        description: 'Hit your weekly goal',
        icon: Icons.emoji_events_rounded,
        color: AppColors.warning,
        progress: week,
        target: goals.weeklyWorkouts,
      ),
    ];
  }
}
