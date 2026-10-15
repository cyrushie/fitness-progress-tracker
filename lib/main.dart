import 'package:flutter/material.dart';

import 'models/workout.dart';
import 'screens/add_workout_screen.dart';
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

  @override
  void initState() {
    super.initState();
    _initializeSampleData();
  }

  void _initializeSampleData() {
    workouts = [
      Workout(
        id: '1',
        date: '2026-10-15',
        type: 'Running',
        duration: 30,
        distance: 5.0,
        caloriesBurned: 350,
        notes: 'Morning jog at the park',
      ),
      Workout(
        id: '2',
        date: '2026-10-15',
        type: 'Weight Lifting',
        duration: 45,
        weight: 75.5,
        reps: 10,
        sets: 3,
        caloriesBurned: 280,
        notes: 'Chest and triceps workout',
      ),
      Workout(
        id: '3',
        date: '2026-10-14',
        type: 'Cardio',
        duration: 25,
        caloriesBurned: 250,
        notes: 'Treadmill session',
      ),
      Workout(
        id: '4',
        date: '2026-10-14',
        type: 'Yoga',
        duration: 60,
        caloriesBurned: 180,
        notes: 'Relaxing evening yoga',
      ),
      Workout(
        id: '5',
        date: '2026-10-13',
        type: 'Running',
        duration: 35,
        distance: 6.5,
        caloriesBurned: 400,
        notes: 'Trail running adventure',
      ),
    ];
  }

  void _addWorkout(Workout workout) {
    setState(() {
      workouts.add(workout);
      _currentIndex = 0;
    });
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${workout.type} logged · ${workout.caloriesBurned} kcal'),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  void _openDetails(Workout workout) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WorkoutDetailsScreen(workout: workout),
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
              onAddWorkout: _addWorkout,
              onNavigateToAddWorkout: () => setState(() => _currentIndex = 1),
              onNavigateToDetails: _openDetails,
            ),
            AddWorkoutScreen(onAddWorkout: _addWorkout),
            SummaryScreen(workouts: workouts),
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
            labelBehavior:
                NavigationDestinationLabelBehavior.alwaysShow,
            selectedIndex: _currentIndex,
            onDestinationSelected: (i) => setState(() => _currentIndex = i),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.grid_view_outlined, color: AppColors.textMuted),
                selectedIcon: Icon(Icons.grid_view_rounded, color: AppColors.primary),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.add_circle_outline, color: AppColors.textMuted),
                selectedIcon: Icon(Icons.add_circle_rounded, color: AppColors.primary),
                label: 'Log',
              ),
              NavigationDestination(
                icon: Icon(Icons.insights_outlined, color: AppColors.textMuted),
                selectedIcon: Icon(Icons.insights_rounded, color: AppColors.primary),
                label: 'Summary',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
