import 'package:flutter/material.dart';

import 'models/goals.dart';
import 'models/stats.dart';
import 'models/workout.dart';
import 'screens/add_workout_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/home_screen.dart';
import 'screens/summary_screen.dart';
import 'screens/workout_details_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness Progress Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      builder: (context, child) {
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            textScaler: media.textScaler.clamp(
              minScaleFactor: 0.8,
              maxScaleFactor: 1.15,
            ),
          ),
          child: child!,
        );
      },
      home: const MainApp(),
    );
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _currentIndex = 0;
  late List<Workout> workouts;
  Goals goals = Goals.defaults;

  @override
  void initState() {
    super.initState();
    _initializeSampleData();
  }

  String _dayAgo(int daysAgo) =>
      WorkoutStats.formatDate(DateTime.now().subtract(Duration(days: daysAgo)));

  void _initializeSampleData() {
    workouts = [
      Workout(
        id: '5',
        date: _dayAgo(2),
        type: 'Running',
        duration: 35,
        distance: 6.5,
        caloriesBurned: 400,
        notes: 'Trail running adventure',
      ),
      Workout(
        id: '4',
        date: _dayAgo(1),
        type: 'Yoga',
        duration: 60,
        caloriesBurned: 180,
        notes: 'Relaxing evening yoga',
      ),
      Workout(
        id: '3',
        date: _dayAgo(1),
        type: 'Cardio',
        duration: 25,
        caloriesBurned: 250,
        notes: 'Treadmill session',
      ),
      Workout(
        id: '2',
        date: _dayAgo(0),
        type: 'Weight Lifting',
        duration: 45,
        weight: 75.5,
        reps: 10,
        sets: 3,
        caloriesBurned: 280,
        notes: 'Chest and triceps workout',
      ),
      Workout(
        id: '1',
        date: _dayAgo(0),
        type: 'Running',
        duration: 30,
        distance: 5.0,
        caloriesBurned: 350,
        notes: 'Morning jog at the park',
      ),
    ];
  }

  void _saveWorkout(Workout workout) {
    final index = workouts.indexWhere((w) => w.id == workout.id);
    final isNew = index == -1;

    setState(() {
      if (isNew) {
        workouts.add(workout);
        _currentIndex = 0;
      } else {
        workouts[index] = workout;
      }
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            isNew
                ? '${workout.type} logged · ${workout.caloriesBurned} kcal'
                : '${workout.type} updated',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  void _deleteWorkout(String id) {
    final index = workouts.indexWhere((w) => w.id == id);
    if (index == -1) return;

    final removed = workouts[index];
    setState(() => workouts.removeAt(index));

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${removed.type} deleted'),
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Undo',
            textColor: AppColors.primary,
            onPressed: () {
              setState(() {
                workouts.insert(index.clamp(0, workouts.length), removed);
              });
            },
          ),
        ),
      );
  }

  void _editWorkout(Workout workout) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddWorkoutScreen(
          initial: workout,
          onAddWorkout: _saveWorkout,
          onDelete: () => _deleteWorkout(workout.id),
        ),
      ),
    );
  }

  Future<void> _openDetails(Workout workout) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WorkoutDetailsScreen(
          workout: workout,
          onEdit: () => _editWorkout(workout),
          onDelete: () => _deleteWorkout(workout.id),
        ),
      ),
    );
  }

  void _openCalendar() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CalendarScreen(
          workouts: workouts,
          onOpenDetails: _openDetails,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _currentIndex != 0) {
          setState(() => _currentIndex = 0);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: IndexedStack(
          index: _currentIndex,
          children: [
            HomeScreen(
              workouts: workouts,
              goals: goals,
              onAddWorkout: _saveWorkout,
              onNavigateToAddWorkout: () => setState(() => _currentIndex = 1),
              onNavigateToDetails: _openDetails,
              onDeleteWorkout: _deleteWorkout,
              onOpenCalendar: _openCalendar,
            ),
            AddWorkoutScreen(onAddWorkout: _saveWorkout),
            SummaryScreen(
              workouts: workouts,
              goals: goals,
              onEditGoals: (updated) => setState(() => goals = updated),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: NavigationBar(
            height: 68,
            backgroundColor: Colors.transparent,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            indicatorColor: AppColors.primary.withValues(alpha: 0.18),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            selectedIndex: _currentIndex,
            onDestinationSelected: (i) => setState(() => _currentIndex = i),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.grid_view_outlined, color: AppColors.textMuted),
                selectedIcon:
                    Icon(Icons.grid_view_rounded, color: AppColors.primary),
                label: 'Home',
              ),
              NavigationDestination(
                icon:
                    Icon(Icons.add_circle_outline, color: AppColors.textMuted),
                selectedIcon:
                    Icon(Icons.add_circle_rounded, color: AppColors.primary),
                label: 'Log',
              ),
              NavigationDestination(
                icon: Icon(Icons.insights_outlined, color: AppColors.textMuted),
                selectedIcon:
                    Icon(Icons.insights_rounded, color: AppColors.primary),
                label: 'Summary',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
