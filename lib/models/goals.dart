import 'package:flutter/material.dart';

/// User-defined fitness goals. Stored as a simple [Map] to avoid any database,
/// as required by the assignment.
class Goals {
  final int dailyCalories; // kcal burned per day
  final int weeklyWorkouts; // sessions per week
  final int weeklyMinutes; // active minutes per week

  const Goals({
    this.dailyCalories = 2000,
    this.weeklyWorkouts = 5,
    this.weeklyMinutes = 150,
  });

  static const Goals defaults = Goals();

  Goals copyWith({
    int? dailyCalories,
    int? weeklyWorkouts,
    int? weeklyMinutes,
  }) {
    return Goals(
      dailyCalories: dailyCalories ?? this.dailyCalories,
      weeklyWorkouts: weeklyWorkouts ?? this.weeklyWorkouts,
      weeklyMinutes: weeklyMinutes ?? this.weeklyMinutes,
    );
  }

  Map<String, int> toMap() {
    return {
      'dailyCalories': dailyCalories,
      'weeklyWorkouts': weeklyWorkouts,
      'weeklyMinutes': weeklyMinutes,
    };
  }

  factory Goals.fromMap(Map<String, int> map) {
    return Goals(
      dailyCalories: map['dailyCalories'] ?? defaults.dailyCalories,
      weeklyWorkouts: map['weeklyWorkouts'] ?? defaults.weeklyWorkouts,
      weeklyMinutes: map['weeklyMinutes'] ?? defaults.weeklyMinutes,
    );
  }
}

/// A single unlockable achievement / badge.
class Achievement {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final int progress;
  final int target;

  const Achievement({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.progress,
    required this.target,
  });

  bool get unlocked => target > 0 && progress >= target;

  double get ratio =>
      target <= 0 ? 1.0 : (progress / target).clamp(0.0, 1.0);

  String get progressLabel => '${progress.clamp(0, target)} / $target';
}
