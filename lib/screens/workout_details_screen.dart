import 'package:flutter/material.dart';
import '../models/workout.dart';
import '../theme/app_theme.dart';
import '../theme/workout_style.dart';
import '../widgets/app_card.dart';

class WorkoutDetailsScreen extends StatelessWidget {
  final Workout workout;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const WorkoutDetailsScreen({
    super.key,
    required this.workout,
    this.onEdit,
    this.onDelete,
  });

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceAlt,
        title: const Text('Delete workout?'),
        content: const Text('This workout will be permanently removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      onDelete?.call();
      if (context.mounted) Navigator.pop(context);
    }
  }

  List<_Metric> _metrics() {
    final list = <_Metric>[
      _Metric('Duration', '${workout.duration}', 'min', Icons.timer_rounded),
      _Metric('Calories', '${workout.caloriesBurned}', 'kcal',
          Icons.local_fire_department_rounded),
    ];
    if (workout.distance != null) {
      list.add(_Metric('Distance', '${workout.distance}', 'km',
          Icons.straighten_rounded));
    }
    if (workout.weight != null) {
      list.add(_Metric(
          'Weight', '${workout.weight}', 'kg', Icons.fitness_center_rounded));
    }
    if (workout.reps != null) {
      list.add(_Metric('Reps', '${workout.reps}', '', Icons.repeat_rounded));
    }
    if (workout.sets != null) {
      list.add(_Metric('Sets', '${workout.sets}', '', Icons.layers_rounded));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final color = WorkoutStyle.color(workout.type);
    final metrics = _metrics();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.xxl,
          ),
          children: [
            _buildHero(context, color),
            const SizedBox(height: AppSpacing.xl),
            const SectionHeader(title: 'Metrics'),
            const SizedBox(height: AppSpacing.md),
            _buildMetrics(metrics),
            if (workout.notes.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xl),
              const SectionHeader(title: 'Notes'),
              const SizedBox(height: AppSpacing.md),
              AppCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                      ),
                      child: Icon(Icons.sticky_note_2_rounded,
                          size: 18, color: color),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(workout.notes, style: AppText.body),
                    ),
                  ],
                ),
              ),
            ],
            if (onEdit != null || onDelete != null) ...[
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  if (onEdit != null)
                    Expanded(
                      child: _ActionButton(
                        label: 'Edit',
                        icon: Icons.edit_rounded,
                        color: AppColors.secondary,
                        onTap: () {
                          Navigator.pop(context);
                          onEdit!.call();
                        },
                      ),
                    ),
                  if (onEdit != null && onDelete != null)
                    const SizedBox(width: AppSpacing.md),
                  if (onDelete != null)
                    Expanded(
                      child: _ActionButton(
                        label: 'Delete',
                        icon: Icons.delete_outline_rounded,
                        color: AppColors.danger,
                        onTap: () => _confirmDelete(context),
                      ),
                    ),
                ],
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            GradientButton(
              label: 'Back to home',
              icon: Icons.arrow_back_rounded,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.35),
            AppColors.surface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_rounded,
                      color: Colors.white, size: 20),
                ),
              ),
              const Spacer(),
              Pill(
                label: WorkoutStyle.met(workout.type),
                color: color,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(WorkoutStyle.icon(workout.type),
                color: Colors.white, size: 34),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(workout.type, style: AppText.h1),
          const SizedBox(height: 4),
          Text(workout.date, style: AppText.caption),
        ],
      ),
    );
  }

  Widget _buildMetrics(List<_Metric> metrics) {
    final rows = <Widget>[];
    for (int i = 0; i < metrics.length; i += 2) {
      final hasSecond = i + 1 < metrics.length;
      rows.add(
        Padding(
          padding: EdgeInsets.only(
            bottom: i + 2 < metrics.length ? AppSpacing.md : 0,
          ),
          child: Row(
            children: [
              Expanded(child: _MetricTile(metric: metrics[i])),
              const SizedBox(width: AppSpacing.md),
              if (hasSecond)
                Expanded(child: _MetricTile(metric: metrics[i + 1]))
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

class _Metric {
  final String label;
  final String value;
  final String unit;
  final IconData icon;

  _Metric(this.label, this.value, this.unit, this.icon);
}

class _MetricTile extends StatelessWidget {
  final _Metric metric;

  const _MetricTile({required this.metric});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(metric.icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(height: AppSpacing.md),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: metric.value,
                    style: AppText.h1,
                  ),
                  if (metric.unit.isNotEmpty)
                    TextSpan(
                      text: ' ${metric.unit}',
                      style: AppText.caption,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(metric.label, style: AppText.label.copyWith(letterSpacing: 0.6)),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: onTap,
        child: Container(
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: AppSpacing.sm),
              Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
