"# Fitness Progress Tracker

A Flutter application for tracking fitness workouts and monitoring progress. Built for CSE101 Final Project.

## Quick Start

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run

# Build for Android
flutter build apk --debug
```

## Project Structure

```
lib/
├── main.dart                      # App entry point & navigation
├── models/
│   └── workout.dart              # Workout data model
└── screens/
    ├── home_screen.dart          # Home/workout list
    ├── add_workout_screen.dart   # Form for adding workouts
    ├── summary_screen.dart       # Statistics & profile
    └── workout_details_screen.dart # Workout details view
```

## Features

- **Log Workouts**: Add running, weight lifting, cardio, or yoga sessions
- **Track Metrics**: Duration, distance, weight, reps, sets, calories
- **View Summary**: Statistics on total workouts, calories, time spent
- **Progress Analysis**: Breakdown of workout types and goals
- **Form Validation**: Required fields and numeric validation
- **Responsive Design**: Works on mobile, tablet, and desktop
- **Local Data**: All data stored in runtime (no database)

## Requirements Met

✓ 3+ Screens (Home, Form, Summary, Details)  
✓ Navigation between screens  
✓ All required UI widgets (Text, Icon, Image, Container, Card, Button, TextField, AppBar)  
✓ Layout widgets (Column, Row, ListView, GridView, Expanded, Stack)  
✓ Form with validation  
✓ Local data only (List, Map)  
✓ Responsive design  
✓ No databases (Hive, Firebase, SQLite, etc.)  

## Team

- John Cyrus
- John Llyod

See `PROJECT_DOCUMENTATION.md` for detailed documentation." 
