import 'package:flutter/material.dart';
import '../models/workout.dart';
import '../theme/app_theme.dart';
import '../widgets/app_card.dart';
import '../widgets/progress_ring.dart';
import '../widgets/workout_card.dart';

class HomeScreen extends StatelessWidget {
  final List<Workout> workouts;
  final Function(Workout) onAddWorkout;
  final VoidCallback? onNavigateToAddWorkout;
  final Function(Workout)? onNavigateToDetails;

  const HomeScreen({
    super.key,
    required this.workouts,
    required this.onAddWorkout,
    this.onNavigateToAddWorkout,
    this.onNavigateToDetails,
  });

  int get _totalCalories =>
      workouts.fold(0, (sum, w) => sum + w.caloriesBurned);
  int get _totalMinutes => workouts.fold(0, (sum, w) => sum + w.duration);

  static const int _calorieGoal = 2000;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            isWide ? AppSpacing.xl : AppSpacing.lg,
            AppSpacing.lg,
            isWide ? AppSpacing.xl : AppSpacing.lg,
            AppSpacing.xxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: AppSpacing.xl),
              _buildHero(),
              const SizedBox(height: AppSpacing.lg),
              _buildStats(),
              const SizedBox(height: AppSpacing.xl),
              GradientButton(
                label: 'Log a workout',
                icon: Icons.add_rounded,
                onPressed: onNavigateToAddWorkout,
              ),
              const SizedBox(height: AppSpacing.xl),
              SectionHeader(
                title: 'Recent workouts',
                actionLabel: workouts.isEmpty ? null : 'See all',
                onAction: () {},
              ),
              const SizedBox(height: AppSpacing.md),
              _buildWorkoutList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Welcome back', style: AppText.h1),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: AppColors.border),
          ),
          child: IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHero() {
    final progress = (_totalCalories / _calorieGoal).clamp(0.0, 1.0);
    final percent = (progress * 100).round();

    return AppCard(
      gradient: AppGradients.hero,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Today\'s burn', style: AppText.label),
                const SizedBox(height: AppSpacing.sm),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text('$_totalCalories', style: AppText.display),
                      const SizedBox(width: 6),
                      Text('kcal', style: AppText.caption),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '$_totalMinutes active minutes',
                  style: AppText.body,
                ),
                const SizedBox(height: AppSpacing.md),
                Pill(
                  label: 'Goal $_calorieGoal kcal',
                  icon: Icons.flag_rounded,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          ProgressRing(
            value: progress,
            size: 104,
            color: AppColors.primary,
            center: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$percent%',
                  style: AppText.h2,
                ),
                Text('of goal', style: AppText.label.copyWith(fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    final avg = workouts.isEmpty ? 0 : (_totalMinutes / workouts.length).round();
    return Row(
      children: [
        Expanded(
          child: StatTile(
            icon: Icons.fitness_center_rounded,
            value: '${workouts.length}',
            label: 'WORKOUTS',
            color: AppColors.lifting,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: StatTile(
            icon: Icons.timer_rounded,
            value: '$_totalMinutes',
            label: 'MINUTES',
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: StatTile(
            icon: Icons.show_chart_rounded,
            value: '$avg',
            label: 'AVG MIN',
            color: AppColors.yoga,
          ),
        ),
      ],
    );
  }

  Widget _buildWorkoutList() {
    if (workouts.isEmpty) {
      return AppCard(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
        child: Column(
          children: [
            Icon(
              Icons.directions_run_rounded,
              size: 56,
              color: AppColors.textMuted.withValues(alpha: 0.6),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('No workouts yet', style: AppText.title),
            const SizedBox(height: 4),
            Text('Log your first session to get started', style: AppText.caption),
          ],
        ),
      );
    }

    final recent = workouts.reversed.take(10).toList();
    return Column(
      children: [
        for (final w in recent)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: WorkoutCard(
              workout: w,
              onTap: onNavigateToDetails == null
                  ? null
                  : () => onNavigateToDetails!(w),
            ),
          ),
      ],
    );
  }
}
