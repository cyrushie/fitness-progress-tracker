import 'package:flutter/material.dart';

import '../models/stats.dart';
import '../models/workout.dart';
import '../theme/app_theme.dart';
import '../widgets/app_card.dart';
import '../widgets/workout_card.dart';

/// A month grid showing which days had activity. Tap a day to see its sessions.
class CalendarScreen extends StatefulWidget {
  final List<Workout> workouts;
  final Future<void> Function(Workout)? onOpenDetails;

  const CalendarScreen({
    super.key,
    required this.workouts,
    this.onOpenDetails,
  });

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _month;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
  }

  void _changeMonth(int delta) {
    setState(() {
      _month = DateTime(_month.year, _month.month + delta);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 600;
    final pad = isWide ? AppSpacing.xl : AppSpacing.lg;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('History')),
      body: ListView(
        padding: EdgeInsets.fromLTRB(pad, AppSpacing.sm, pad, AppSpacing.xxl),
        children: [
          _buildMonthCard(),
          const SizedBox(height: AppSpacing.lg),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildMonthCard() {
    final firstDay = DateTime(_month.year, _month.month, 1);
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final leading = firstDay.weekday - 1; // Monday = 0
    final totalCells = ((leading + daysInMonth) / 7).ceil() * 7;
    final today = WorkoutStats.dateOnly(DateTime.now());

    const weekLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Row(
            children: [
              _NavButton(
                icon: Icons.chevron_left_rounded,
                onTap: () => _changeMonth(-1),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '${WorkoutStats.monthLabel(_month.month)} ${_month.year}',
                    style: AppText.h2,
                  ),
                ),
              ),
              _NavButton(
                icon: Icons.chevron_right_rounded,
                onTap: () => _changeMonth(1),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              for (final label in weekLabels)
                Expanded(
                  child: Center(
                    child: Text(
                      label,
                      style: AppText.label.copyWith(letterSpacing: 0),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          for (var row = 0; row < totalCells ~/ 7; row++)
            Row(
              children: [
                for (var col = 0; col < 7; col++)
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: _buildDayCell(
                        row * 7 + col - leading + 1,
                        daysInMonth,
                        today,
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildDayCell(int day, int daysInMonth, DateTime today) {
    if (day < 1 || day > daysInMonth) {
      return const SizedBox.shrink();
    }

    final date = DateTime(_month.year, _month.month, day);
    final sessions = WorkoutStats.workoutsOn(widget.workouts, date);
    final hasWorkout = sessions.isNotEmpty;
    final isToday = date == today;
    final calories = sessions.fold(0, (sum, w) => sum + w.caloriesBurned);

    return Padding(
      padding: const EdgeInsets.all(2),
      child: GestureDetector(
        onTap: hasWorkout ? () => _showDay(date, sessions) : null,
        child: Container(
          decoration: BoxDecoration(
            color: hasWorkout ? AppColors.primary : Colors.transparent,
            shape: BoxShape.circle,
            border: isToday && !hasWorkout
                ? Border.all(color: AppColors.primary, width: 1.4)
                : null,
          ),
          child: Center(
            child: hasWorkout
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$day',
                        style: AppText.title.copyWith(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '$calories',
                        style: AppText.label.copyWith(
                          fontSize: 7.5,
                          letterSpacing: 0,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  )
                : Text(
                    '$day',
                    style: AppText.caption.copyWith(
                      color: isToday
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text('Active day (tap to view)', style: AppText.caption),
        const SizedBox(width: AppSpacing.lg),
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 1.4),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text('Today', style: AppText.caption),
      ],
    );
  }

  void _showDay(DateTime date, List<Workout> sessions) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.borderStrong,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(WorkoutStats.formatDate(date), style: AppText.h2),
                const SizedBox(height: 4),
                Text(
                  '${sessions.length} ${sessions.length == 1 ? 'session' : 'sessions'}',
                  style: AppText.caption,
                ),
                const SizedBox(height: AppSpacing.lg),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: sessions.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, i) {
                      final w = sessions[i];
                      return WorkoutCard(
                        workout: w,
                        onTap: widget.onOpenDetails == null
                            ? null
                            : () async {
                                Navigator.pop(sheetContext);
                                await widget.onOpenDetails!(w);
                                if (mounted) setState(() {});
                              },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _NavButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceAlt,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Icon(icon, color: AppColors.textPrimary, size: 22),
        ),
      ),
    );
  }
}
