import 'package:flutter/material.dart';
import '../models/workout.dart';
import '../theme/app_theme.dart';
import '../theme/workout_style.dart';
import '../widgets/app_card.dart';
import '../widgets/progress_ring.dart';

class SummaryScreen extends StatelessWidget {
  final List<Workout> workouts;

  const SummaryScreen({
    super.key,
    required this.workouts,
  });

  static const int _workoutGoal = 20;
  static const int _calorieGoal = 5000;
  static const int _minuteGoal = 300;

  int get _totalMinutes => workouts.fold(0, (s, w) => s + w.duration);
  int get _totalCalories => workouts.fold(0, (s, w) => s + w.caloriesBurned);

  Map<String, int> get _byType {
    final map = <String, int>{};
    for (final w in workouts) {
      map[w.type] = (map[w.type] ?? 0) + 1;
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 600;
    final byType = _byType;
    final mostActive = byType.isEmpty
        ? '—'
        : (byType.entries.reduce((a, b) => a.value >= b.value ? a : b)).key;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Summary')),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          isWide ? AppSpacing.xl : AppSpacing.lg,
          AppSpacing.sm,
          isWide ? AppSpacing.xl : AppSpacing.lg,
          AppSpacing.xxl,
        ),
        children: [
          _buildHero(mostActive),
          const SizedBox(height: AppSpacing.lg),
          _buildStatGrid(),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(title: 'This week'),
          const SizedBox(height: AppSpacing.md),
          _buildWeeklyChart(),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(title: 'Workout breakdown'),
          const SizedBox(height: AppSpacing.md),
          _buildBreakdown(byType),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(title: 'Goals'),
          const SizedBox(height: AppSpacing.md),
          _GoalCard(
            title: 'Workouts',
            current: workouts.length,
            target: _workoutGoal,
            unit: 'sessions',
            icon: Icons.fitness_center_rounded,
            color: AppColors.lifting,
          ),
          const SizedBox(height: AppSpacing.md),
          _GoalCard(
            title: 'Calories',
            current: _totalCalories,
            target: _calorieGoal,
            unit: 'kcal',
            icon: Icons.local_fire_department_rounded,
            color: AppColors.cardio,
          ),
          const SizedBox(height: AppSpacing.md),
          _GoalCard(
            title: 'Active time',
            current: _totalMinutes,
            target: _minuteGoal,
            unit: 'min',
            icon: Icons.timer_rounded,
            color: AppColors.secondary,
          ),
        ],
      ),
    );
  }

  Widget _buildHero(String mostActive) {
    final progress = (workouts.length / _workoutGoal).clamp(0.0, 1.0);
    final percent = (progress * 100).round();

    return AppCard(
      gradient: AppGradients.hero,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: AppGradients.primary,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 30),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Fitness profile', style: AppText.h2),
                const SizedBox(height: 6),
                Text(
                  '${workouts.length} workouts · favourite: $mostActive',
                  overflow: TextOverflow.ellipsis,
                  style: AppText.caption,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          ProgressRing(
            value: progress,
            size: 68,
            stroke: 7,
            color: AppColors.primary,
            center: Text(
              '$percent%',
              style: AppText.title.copyWith(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatGrid() {
    final avg = workouts.isEmpty ? 0 : (_totalMinutes / workouts.length).round();
    return Column(
      children: [
        Row(
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
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: StatTile(
                icon: Icons.local_fire_department_rounded,
                value: '$_totalCalories',
                label: 'CALORIES',
                color: AppColors.cardio,
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
        ),
      ],
    );
  }

  Widget _buildWeeklyChart() {
    final byDate = <String, int>{};
    for (final w in workouts) {
      byDate[w.date] = (byDate[w.date] ?? 0) + w.duration;
    }
    final entries = byDate.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final recent = entries.length > 7
        ? entries.sublist(entries.length - 7)
        : entries;

    const weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    if (recent.isEmpty) {
      return AppCard(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: Center(child: Text('No activity yet', style: AppText.caption)),
      );
    }

    final maxMinutes = recent
        .map((e) => e.value)
        .reduce((a, b) => a > b ? a : b)
        .clamp(1, 1 << 30);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Daily active minutes', style: AppText.caption),
              ),
              Pill(
                label: '${recent.fold(0, (s, e) => s + e.value)} min',
                icon: Icons.timer_rounded,
                color: AppColors.secondary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 150,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final e in recent)
                  Expanded(
                    child: _Bar(
                      label: weekdays[
                          (DateTime.parse(e.key).weekday - 1) % 7],
                      value: e.value,
                      max: maxMinutes,
                      highlight: e.value == maxMinutes,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdown(Map<String, int> byType) {
    if (byType.isEmpty) {
      return AppCard(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: Center(child: Text('No workouts yet', style: AppText.caption)),
      );
    }

    final total = workouts.length;
    return AppCard(
      child: Column(
        children: [
          for (int i = 0; i < byType.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.lg),
            _BreakdownRow(
              type: byType.keys.elementAt(i),
              count: byType.values.elementAt(i),
              total: total,
            ),
          ],
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final String label;
  final int value;
  final int max;
  final bool highlight;

  const _Bar({
    required this.label,
    required this.value,
    required this.max,
    required this.highlight,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = (value / max).clamp(0.0, 1.0);
    final height = 8 + ratio * 82;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '$value',
          style: AppText.label.copyWith(
            fontSize: 10,
            letterSpacing: 0,
            color: highlight ? AppColors.textPrimary : AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 14,
          height: height,
          decoration: BoxDecoration(
            gradient: highlight ? AppGradients.primary : null,
            color: highlight ? null : AppColors.surfaceHigh,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(label, style: AppText.label.copyWith(letterSpacing: 0)),
      ],
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final String type;
  final int count;
  final int total;

  const _BreakdownRow({
    required this.type,
    required this.count,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final color = WorkoutStyle.color(type);
    final ratio = total == 0 ? 0.0 : count / total;
    final percent = (ratio * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadius.xs),
              ),
              child: Icon(WorkoutStyle.icon(type), size: 15, color: color),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                type,
                overflow: TextOverflow.ellipsis,
                style: AppText.title.copyWith(fontSize: 14),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              '$count · $percent%',
              style: AppText.caption.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 7,
            backgroundColor: AppColors.surfaceHigh,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _GoalCard extends StatelessWidget {
  final String title;
  final int current;
  final int target;
  final String unit;
  final IconData icon;
  final Color color;

  const _GoalCard({
    required this.title,
    required this.current,
    required this.target,
    required this.unit,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = (current / target).clamp(0.0, 1.0);
    final percent = (ratio * 100).round();

    return AppCard(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppText.title.copyWith(fontSize: 14)),
                    const SizedBox(height: 2),
                    Text('$current / $target $unit',
                        style: AppText.label.copyWith(letterSpacing: 0)),
                  ],
                ),
              ),
              Text(
                '$percent%',
                style: AppText.h2.copyWith(color: color),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 7,
              backgroundColor: AppColors.surfaceHigh,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}
