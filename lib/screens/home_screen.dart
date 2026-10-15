import 'package:flutter/material.dart';

import '../models/goals.dart';
import '../models/stats.dart';
import '../models/workout.dart';
import '../theme/app_theme.dart';
import '../theme/workout_style.dart';
import '../widgets/app_card.dart';
import '../widgets/progress_ring.dart';
import '../widgets/workout_card.dart';

class HomeScreen extends StatefulWidget {
  final List<Workout> workouts;
  final Goals goals;
  final Function(Workout) onAddWorkout;
  final VoidCallback? onNavigateToAddWorkout;
  final Function(Workout)? onNavigateToDetails;
  final Function(String id)? onDeleteWorkout;
  final VoidCallback? onOpenCalendar;

  const HomeScreen({
    super.key,
    required this.workouts,
    this.goals = Goals.defaults,
    required this.onAddWorkout,
    this.onNavigateToAddWorkout,
    this.onNavigateToDetails,
    this.onDeleteWorkout,
    this.onOpenCalendar,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  String _filter = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Workout> get _filtered {
    final q = _query.trim().toLowerCase();
    final list = widget.workouts.where((w) {
      final matchesType = _filter == 'All' || w.type == _filter;
      final matchesQuery = q.isEmpty ||
          w.type.toLowerCase().contains(q) ||
          w.notes.toLowerCase().contains(q);
      return matchesType && matchesQuery;
    }).toList();
    return list.reversed.toList();
  }

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
                onPressed: widget.onNavigateToAddWorkout,
              ),
              const SizedBox(height: AppSpacing.xl),
              _buildSearchField(),
              const SizedBox(height: AppSpacing.md),
              _buildFilterChips(),
              const SizedBox(height: AppSpacing.lg),
              SectionHeader(
                title: 'Recent workouts',
                trailing: Text(
                  '${_filtered.length}',
                  style: AppText.caption.copyWith(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
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
            children: const [
              Text('Welcome back', style: AppText.h1),
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
            onPressed: widget.onOpenCalendar,
            tooltip: 'History',
            icon: const Icon(
              Icons.calendar_month_rounded,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHero() {
    final now = DateTime.now();
    final todayCalories = WorkoutStats.caloriesOn(widget.workouts, now);
    final todayMinutes = WorkoutStats.minutesOn(widget.workouts, now);
    final goal = widget.goals.dailyCalories;
    final progress = goal <= 0 ? 0.0 : (todayCalories / goal).clamp(0.0, 1.0);
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
                      Text('$todayCalories', style: AppText.display),
                      const SizedBox(width: 6),
                      Text('kcal', style: AppText.caption),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text('$todayMinutes active minutes', style: AppText.body),
                const SizedBox(height: AppSpacing.md),
                Pill(
                  label: 'Goal $goal kcal',
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
                Text('$percent%', style: AppText.h2),
                Text('of goal', style: AppText.label.copyWith(fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    final totalMinutes = WorkoutStats.totalMinutes(widget.workouts);
    final streak = WorkoutStats.currentStreak(widget.workouts);
    return Row(
      children: [
        Expanded(
          child: StatTile(
            icon: Icons.fitness_center_rounded,
            value: '${widget.workouts.length}',
            label: 'WORKOUTS',
            color: AppColors.lifting,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: StatTile(
            icon: Icons.timer_rounded,
            value: '$totalMinutes',
            label: 'MINUTES',
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: StatTile(
            icon: Icons.local_fire_department_rounded,
            value: '$streak',
            label: 'DAY STREAK',
            color: AppColors.cardio,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: (value) => setState(() => _query = value),
      style: const TextStyle(color: AppColors.textPrimary),
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search by type or notes',
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: AppColors.textMuted,
          size: 20,
        ),
        suffixIcon: _query.isEmpty
            ? null
            : IconButton(
                icon: const Icon(
                  Icons.close_rounded,
                  color: AppColors.textMuted,
                  size: 20,
                ),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _query = '');
                },
              ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', ...WorkoutStyle.types];
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, i) {
          final label = filters[i];
          final selected = _filter == label;
          final color =
              label == 'All' ? AppColors.primary : WorkoutStyle.color(label);
          return GestureDetector(
            onTap: () => setState(() => _filter = label),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              decoration: BoxDecoration(
                color: selected
                    ? color.withValues(alpha: 0.16)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border: Border.all(
                  color: selected ? color : AppColors.border,
                  width: 1.4,
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWorkoutList() {
    if (widget.workouts.isEmpty) {
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

    final items = _filtered;
    if (items.isEmpty) {
      return AppCard(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
        child: Column(
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 48,
              color: AppColors.textMuted.withValues(alpha: 0.6),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('No matching workouts', style: AppText.title),
            const SizedBox(height: 4),
            Text('Try a different search or filter', style: AppText.caption),
          ],
        ),
      );
    }

    return Column(
      children: [
        for (final w in items)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Dismissible(
              key: ValueKey(w.id),
              direction: DismissDirection.endToStart,
              background: _buildDismissBackground(),
              confirmDismiss: (_) => _confirmDelete(w),
              onDismissed: (_) => widget.onDeleteWorkout?.call(w.id),
              child: WorkoutCard(
                workout: w,
                onTap: widget.onNavigateToDetails == null
                    ? null
                    : () => widget.onNavigateToDetails!(w),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDismissBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.4)),
      ),
      child: const Icon(
        Icons.delete_outline_rounded,
        color: AppColors.danger,
      ),
    );
  }

  Future<bool> _confirmDelete(Workout w) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceAlt,
        title: const Text('Delete workout?'),
        content: Text('Remove "${w.type}" from your log?'),
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
    return confirmed ?? false;
  }
}
