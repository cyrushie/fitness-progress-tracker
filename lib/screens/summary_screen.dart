import 'package:flutter/material.dart';

import '../models/goals.dart';
import '../models/stats.dart';
import '../models/workout.dart';
import '../theme/app_theme.dart';
import '../theme/workout_style.dart';
import '../widgets/app_card.dart';
import '../widgets/progress_ring.dart';
import '../widgets/trend_chart.dart';

class SummaryScreen extends StatelessWidget {
  final List<Workout> workouts;
  final Goals goals;
  final ValueChanged<Goals>? onEditGoals;

  const SummaryScreen({
    super.key,
    required this.workouts,
    this.goals = Goals.defaults,
    this.onEditGoals,
  });

  int get _totalMinutes => WorkoutStats.totalMinutes(workouts);
  int get _totalCalories => WorkoutStats.totalCalories(workouts);

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

    final week = WorkoutStats.workoutsThisWeek(workouts);
    final weekMinutes = week.fold(0, (s, w) => s + w.duration);
    final todayCalories = WorkoutStats.caloriesOn(workouts, DateTime.now());
    final achievements = WorkoutStats.achievements(workouts, goals);
    final unlockedCount = achievements.where((a) => a.unlocked).length;

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
          _buildHero(mostActive, week.length),
          const SizedBox(height: AppSpacing.lg),
          _buildStatGrid(),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(title: 'Streaks & personal records'),
          const SizedBox(height: AppSpacing.md),
          _buildRecords(),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(title: 'This week'),
          const SizedBox(height: AppSpacing.md),
          _buildWeeklyChart(),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(title: 'Monthly trend'),
          const SizedBox(height: AppSpacing.md),
          _buildMonthlyTrend(),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(title: 'Workout breakdown'),
          const SizedBox(height: AppSpacing.md),
          _buildBreakdown(byType),
          const SizedBox(height: AppSpacing.xl),
          SectionHeader(
            title: 'Goals',
            actionLabel: onEditGoals == null ? null : 'Edit',
            onAction: onEditGoals == null ? null : () => _editGoals(context),
          ),
          const SizedBox(height: AppSpacing.md),
          _GoalCard(
            title: 'Workouts this week',
            current: week.length,
            target: goals.weeklyWorkouts,
            unit: 'sessions',
            icon: Icons.fitness_center_rounded,
            color: AppColors.lifting,
          ),
          const SizedBox(height: AppSpacing.md),
          _GoalCard(
            title: 'Calories today',
            current: todayCalories,
            target: goals.dailyCalories,
            unit: 'kcal',
            icon: Icons.local_fire_department_rounded,
            color: AppColors.cardio,
          ),
          const SizedBox(height: AppSpacing.md),
          _GoalCard(
            title: 'Active time this week',
            current: weekMinutes,
            target: goals.weeklyMinutes,
            unit: 'min',
            icon: Icons.timer_rounded,
            color: AppColors.secondary,
          ),
          const SizedBox(height: AppSpacing.xl),
          SectionHeader(
            title: 'Achievements',
            trailing: Text(
              '$unlockedCount / ${achievements.length}',
              style: AppText.caption.copyWith(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _AchievementGrid(achievements: achievements),
        ],
      ),
    );
  }

  Future<void> _editGoals(BuildContext context) async {
    final updated = await showDialog<Goals>(
      context: context,
      builder: (_) => _EditGoalsDialog(goals: goals),
    );
    if (updated != null) {
      onEditGoals?.call(updated);
    }
  }

  Widget _buildHero(String mostActive, int weekCount) {
    final target = goals.weeklyWorkouts;
    final progress = target <= 0 ? 0.0 : (weekCount / target).clamp(0.0, 1.0);
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
    final distance = WorkoutStats.totalDistance(workouts);
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
                icon: Icons.straighten_rounded,
                value: distance == distance.roundToDouble()
                    ? '${distance.round()}'
                    : distance.toStringAsFixed(1),
                label: 'DISTANCE KM',
                color: AppColors.yoga,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecords() {
    final current = WorkoutStats.currentStreak(workouts);
    final longest = WorkoutStats.longestStreak(workouts);
    final bestDistance = WorkoutStats.recordDistance(workouts);
    final bestCalories = WorkoutStats.recordCalories(workouts);
    final longestSession = WorkoutStats.recordDuration(workouts);
    final heaviest = WorkoutStats.recordWeight(workouts);

    return AppCard(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  icon: Icons.local_fire_department_rounded,
                  color: AppColors.cardio,
                  value: '$current',
                  label: 'CURRENT STREAK',
                  suffix: current == 1 ? 'day' : 'days',
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _MiniStat(
                  icon: Icons.emoji_events_rounded,
                  color: AppColors.warning,
                  value: '$longest',
                  label: 'LONGEST STREAK',
                  suffix: longest == 1 ? 'day' : 'days',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const Divider(),
          const SizedBox(height: AppSpacing.lg),
          _RecordRow(
            icon: Icons.straighten_rounded,
            color: AppColors.running,
            label: 'Best distance',
            value: bestDistance == null
                ? '—'
                : '${bestDistance.distance} km',
            detail: bestDistance?.type,
          ),
          const SizedBox(height: AppSpacing.md),
          _RecordRow(
            icon: Icons.bolt_rounded,
            color: AppColors.cardio,
            label: 'Most calories',
            value: bestCalories == null ? '—' : '${bestCalories.caloriesBurned} kcal',
            detail: bestCalories?.type,
          ),
          const SizedBox(height: AppSpacing.md),
          _RecordRow(
            icon: Icons.timer_rounded,
            color: AppColors.secondary,
            label: 'Longest session',
            value: longestSession == null ? '—' : '${longestSession.duration} min',
            detail: longestSession?.type,
          ),
          const SizedBox(height: AppSpacing.md),
          _RecordRow(
            icon: Icons.fitness_center_rounded,
            color: AppColors.lifting,
            label: 'Heaviest lift',
            value: heaviest == null ? '—' : '${heaviest.weight} kg',
            detail: heaviest?.type,
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart() {
    final start = WorkoutStats.startOfWeek(DateTime.now());
    final days = List.generate(7, (i) => start.add(Duration(days: i)));
    final values =
        days.map((d) => WorkoutStats.minutesOn(workouts, d)).toList();
    final maxMinutes =
        values.fold(0, (m, v) => v > m ? v : m).clamp(1, 1 << 30);

    const weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final total = values.fold(0, (s, v) => s + v);

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
                label: '$total min',
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
                for (var i = 0; i < 7; i++)
                  Expanded(
                    child: _Bar(
                      label: weekdays[i],
                      value: values[i],
                      max: maxMinutes,
                      highlight: values[i] == maxMinutes && values[i] > 0,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyTrend() {
    final entries = WorkoutStats.monthlyMinutes(workouts, months: 6);
    final values = entries.map((e) => e.value.toDouble()).toList();
    final labels = entries.map((e) => e.key).toList();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Active minutes per month', style: AppText.caption),
              ),
              const Pill(
                label: 'Last 6 months',
                icon: Icons.calendar_month_rounded,
                color: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          TrendChart(
            values: values,
            labels: labels,
            color: AppColors.primary,
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
    final safeTarget = target <= 0 ? 1 : target;
    final ratio = (current / safeTarget).clamp(0.0, 1.0);
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

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;
  final String suffix;

  const _MiniStat({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
    required this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
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
                child: Icon(icon, size: 16, color: color),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(value, style: AppText.h1),
                const SizedBox(width: 4),
                Text(suffix, style: AppText.caption),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: AppText.label.copyWith(letterSpacing: 0.8),
          ),
        ],
      ),
    );
  }
}

class _RecordRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final String? detail;

  const _RecordRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppRadius.xs),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: AppText.caption.copyWith(color: AppColors.textPrimary),
              ),
              if (detail != null)
                Text(
                  detail!,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.label.copyWith(letterSpacing: 0),
                ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          value,
          style: AppText.title.copyWith(color: color, fontSize: 14),
        ),
      ],
    );
  }
}

class _AchievementGrid extends StatelessWidget {
  final List<Achievement> achievements;

  const _AchievementGrid({required this.achievements});

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < achievements.length; i += 2) {
      final hasSecond = i + 1 < achievements.length;
      rows.add(
        Padding(
          padding: EdgeInsets.only(
            bottom: i + 2 < achievements.length ? AppSpacing.md : 0,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _AchievementTile(achievement: achievements[i])),
              const SizedBox(width: AppSpacing.md),
              if (hasSecond)
                Expanded(
                  child: _AchievementTile(achievement: achievements[i + 1]),
                )
              else
                const Expanded(child: SizedBox()),
            ],
          ),
        ),
      );
    }
    return Column(children: rows);
  }
}

class _AchievementTile extends StatelessWidget {
  final Achievement achievement;

  const _AchievementTile({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final unlocked = achievement.unlocked;
    final color = unlocked ? achievement.color : AppColors.textMuted;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  unlocked ? achievement.icon : Icons.lock_rounded,
                  size: 18,
                  color: color,
                ),
              ),
              const Spacer(),
              if (unlocked)
                const Icon(
                  Icons.check_circle_rounded,
                  size: 16,
                  color: AppColors.success,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            achievement.title,
            overflow: TextOverflow.ellipsis,
            style: AppText.title.copyWith(
              fontSize: 13.5,
              color: unlocked ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            achievement.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppText.label.copyWith(letterSpacing: 0, height: 1.3),
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              value: achievement.ratio,
              minHeight: 5,
              backgroundColor: AppColors.surfaceHigh,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            achievement.progressLabel,
            style: AppText.label.copyWith(letterSpacing: 0, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _EditGoalsDialog extends StatefulWidget {
  final Goals goals;

  const _EditGoalsDialog({required this.goals});

  @override
  State<_EditGoalsDialog> createState() => _EditGoalsDialogState();
}

class _EditGoalsDialogState extends State<_EditGoalsDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _calories;
  late final TextEditingController _workouts;
  late final TextEditingController _minutes;

  @override
  void initState() {
    super.initState();
    _calories = TextEditingController(text: '${widget.goals.dailyCalories}');
    _workouts = TextEditingController(text: '${widget.goals.weeklyWorkouts}');
    _minutes = TextEditingController(text: '${widget.goals.weeklyMinutes}');
  }

  @override
  void dispose() {
    _calories.dispose();
    _workouts.dispose();
    _minutes.dispose();
    super.dispose();
  }

  String? _validate(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    final n = int.tryParse(value.trim());
    if (n == null || n <= 0) return 'Enter a positive number';
    if (n > 100000) return 'Value too large';
    return null;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      Goals(
        dailyCalories: int.parse(_calories.text.trim()),
        weeklyWorkouts: int.parse(_workouts.text.trim()),
        weeklyMinutes: int.parse(_minutes.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surfaceAlt,
      title: const Text('Edit goals'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _calories,
              keyboardType: TextInputType.number,
              validator: _validate,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Daily calories (kcal)',
                labelStyle: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _workouts,
              keyboardType: TextInputType.number,
              validator: _validate,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Workouts per week',
                labelStyle: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _minutes,
              keyboardType: TextInputType.number,
              validator: _validate,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Active minutes per week',
                labelStyle: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
