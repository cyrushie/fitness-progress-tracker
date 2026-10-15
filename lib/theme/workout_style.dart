import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Visual identity for each workout type so colors stay consistent everywhere.
class WorkoutStyle {
  WorkoutStyle._();

  static const List<String> types = [
    'Running',
    'Weight Lifting',
    'Cardio',
    'Yoga',
  ];

  static IconData icon(String type) {
    switch (type) {
      case 'Running':
        return Icons.directions_run_rounded;
      case 'Weight Lifting':
        return Icons.fitness_center_rounded;
      case 'Cardio':
        return Icons.favorite_rounded;
      case 'Yoga':
        return Icons.self_improvement_rounded;
      default:
        return Icons.sports_rounded;
    }
  }

  static Color color(String type) {
    switch (type) {
      case 'Running':
        return AppColors.running;
      case 'Weight Lifting':
        return AppColors.lifting;
      case 'Cardio':
        return AppColors.cardio;
      case 'Yoga':
        return AppColors.yoga;
      default:
        return AppColors.primary;
    }
  }

  static String met(String type) {
    switch (type) {
      case 'Running':
        return 'Cardio focus';
      case 'Weight Lifting':
        return 'Strength';
      case 'Cardio':
        return 'Endurance';
      case 'Yoga':
        return 'Recovery';
      default:
        return 'General';
    }
  }
}
