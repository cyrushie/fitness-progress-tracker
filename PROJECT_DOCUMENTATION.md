# Fitness Progress Tracker - CSE101 Final Project

## Project Overview
A Flutter application that allows users to track their fitness workouts and monitor their progress. The app enables users to log different types of workouts (Running, Weight Lifting, Cardio, Yoga), view their workout history, and analyze their fitness progress through statistics and summaries.

**Assigned to:** John Cyrus and John Llyod

---

## Features Implemented

### 1. **Home Screen** ✓
- Displays today's workout summary with quick statistics
- Shows number of workouts, total calories burned, and total time spent
- Lists all logged workouts in a scrollable ListView
- Quick add workout button for easy access
- Tappable workout cards to view detailed information
- Empty state message when no workouts exist
- Responsive design that adapts to different screen sizes

### 2. **Add Workout Form Screen** ✓
- Comprehensive form with the following fields:
  - **Workout Type** (dropdown): Running, Weight Lifting, Cardio, Yoga
  - **Duration** (required): Minutes spent working out
  - **Distance** (optional): Kilometers traveled (for running/cardio)
  - **Weight** (optional): Weight lifted in kg
  - **Reps** (optional): Number of repetitions
  - **Sets** (optional): Number of sets completed
  - **Calories Burned** (required): Total calories burned
  - **Notes** (optional): Personal notes about the workout

#### Form Validation:
- Required fields: Workout Type, Duration, Calories Burned
- Numeric validation for all numeric fields
- Positive number validation for duration and calories
- Optional fields validated only if provided
- Notes limited to 200 characters maximum
- Clear error messages for invalid input

### 3. **Summary/Profile Screen** ✓
- **Fitness Profile Header**: User profile card with motivational message
- **Key Statistics Grid**: 
  - Total Workouts
  - Total Minutes
  - Total Calories
  - Average Duration
- **Most Active Type**: Shows which workout type the user does most
- **Workout Breakdown**: Percentage breakdown of each workout type with progress bars
- **Fitness Goals Section**: 
  - Weekly Target (20 workouts)
  - Calorie Burn Goal (5000 calories)
  - Time Target (300 minutes)
- **Responsive Grid Layout**: Adapts columns based on screen size

### 4. **Workout Details Screen** ✓
- Full details view for individual workouts
- Displays all workout information in an organized grid layout
- Shows relevant metrics (duration, distance, reps, sets, etc.)
- Includes complete notes section
- Back navigation button
- Clean card-based UI design

### 5. **Navigation System** ✓
- Bottom Navigation Bar with three main screens:
  - Home
  - Log Workout
  - Summary/Profile
- Page navigation between Home and Details screens
- Smooth transitions between screens
- Prevents back navigation on main screen

---

## UI Widgets Used (Per Requirements)

✓ **Text** - Used throughout for labels, values, and content  
✓ **Icon** - Workout type icons, navigation icons, stat icons  
✓ **Container** - Layout containers, decoration containers  
✓ **Card** - Workout cards, stat cards, detail cards  
✓ **Button** - Add workout, submit, cancel, back buttons  
✓ **TextField** - Form input fields with validation  
✓ **AppBar** - Top navigation bar on each screen  
✓ **Column & Row** - Layout structure throughout  
✓ **ListView** - Workout list display  
✓ **GridView** - Statistics and workout breakdown display  
✓ **Expanded & Flexible** - Responsive sizing  
✓ **Image & Icons** - Material Design Icons  

---

## Data Management

### Local Data Structure
All data uses runtime Lists and Maps (no databases):

```dart
// Workout Model
{
  'id': unique identifier,
  'date': '2026-10-15',
  'type': 'Running' | 'Weight Lifting' | 'Cardio' | 'Yoga',
  'duration': 30 (minutes),
  'distance': 5.0 (km, optional),
  'weight': 75.5 (kg, optional),
  'reps': 10 (optional),
  'sets': 3 (optional),
  'caloriesBurned': 250,
  'notes': 'Felt great!'
}
```

### Sample Data
The app initializes with 5 sample workouts demonstrating:
- Different workout types
- Varied durations and intensities
- Different data point combinations
- Real-world scenarios

### Runtime Calculations
- Total workouts, minutes, calories computed on-the-fly
- Average duration calculated from all workouts
- Workout type breakdown counted dynamically
- Most active type determined from counts
- Progress bar percentages calculated based on totals

---

## Responsive Design

### Breakpoints
- **Mobile**: < 600px width
- **Tablet/Desktop**: ≥ 600px width

### Layout Adaptations
- Single column layout on mobile
- Multi-column grid on larger screens
- Font sizes scale appropriately
- Padding adjusts based on screen size
- Grid columns change (2 on mobile, 3+ on tablet)

---

## Project Structure

```
lib/
├── main.dart                  # Main app entry point & navigation
├── models/
│   └── workout.dart          # Workout data model
└── screens/
    ├── home_screen.dart      # Home/List screen
    ├── add_workout_screen.dart # Form screen
    ├── summary_screen.dart    # Statistics/Profile screen
    └── workout_details_screen.dart # Detail view
```

---

## Technologies & Dependencies

- **Flutter**: 3.44.8 (Stable)
- **Dart**: 3.12.2+
- **uuid**: 4.6.0 (for generating unique workout IDs)
- **Material Design 3**: For modern UI components

### No Databases Used ✓
- ✓ No Hive
- ✓ No Firebase
- ✓ No SQLite
- ✓ No Firestore
- ✓ No Supabase
- ✓ No MySQL
- ✓ All data is temporary/runtime only

---

## How to Run

### Prerequisites
- Flutter SDK installed
- Android SDK or iOS development tools
- Text editor or IDE (VS Code, Android Studio)

### Installation & Running
```bash
# Navigate to project directory
cd fitness-progress-tracker

# Install dependencies
flutter pub get

# Run on connected device or emulator
flutter run

# Release build
flutter build apk --release  # Android
flutter build ios --release  # iOS
```

### Running on Emulator
```bash
# Start Android emulator first (from Android Studio)
# Then run:
flutter run
```

---

## Testing Conducted

### UI Testing
✓ All screens render correctly  
✓ Navigation between screens works smoothly  
✓ Form validation displays appropriate error messages  
✓ Sample data displays correctly on home screen  
✓ Statistics calculate accurately on summary screen  
✓ Responsive layout works on different screen sizes  
✓ Bottom navigation bar switches screens correctly  
✓ Add workout functionality properly adds items to list  
✓ Workout details display complete information  

### Form Validation Testing
✓ Required fields show errors when empty  
✓ Numeric fields reject non-numeric input  
✓ Positive number validation works  
✓ Optional fields accept valid input when provided  
✓ Notes character limit enforced  

### Data Testing
✓ Sample data initializes on app start  
✓ New workouts properly added to list  
✓ Statistics update when workouts are added  
✓ Data persists during app session  

---

## Screenshots

### 1. Home Screen
- Displays today's summary statistics
- Shows list of workouts with type icons
- Add workout button visible
- Responsive layout adapts to screen size

### 2. Add Workout Form Screen
- All input fields with proper labels
- Dropdown for workout type selection
- Form validation in action
- Cancel and submit buttons
- Organized field layout

### 3. Summary/Profile Screen
- Statistics grid with 4 key metrics
- Most active workout type display
- Workout type breakdown with progress bars
- Fitness goals section
- Visual hierarchy with cards

### 4. Workout Details Screen
- Full workout information display
- Icon for workout type
- Date and time information
- Organized grid of metrics
- Notes section if available
- Back navigation button

---

## Code Quality

### Best Practices
- Proper state management using `setState()`
- Form validation with `FormState`
- Responsive design using `MediaQuery`
- Clean code organization with separate files
- Reusable widget components
- Proper use of Flutter widgets
- No code smells or anti-patterns

### Error Handling
- Form validation with helpful messages
- Null safety with optional parameters
- Graceful handling of empty states
- Defensive programming practices

---

## Challenges & Solutions

### Challenge 1: Android SDK License Issues
**Solution**: Use debug build instead of release, or run `flutter doctor --android-licenses`

### Challenge 2: Responsive Layout
**Solution**: Use `MediaQuery` for breakpoint detection and conditional widget rendering

### Challenge 3: Form Validation
**Solution**: Use `FormState` with `TextFormField` and custom validators

### Challenge 4: Data Management
**Solution**: Use Lists and Maps with runtime calculations instead of databases

---

## Future Enhancements (Out of Scope)
- Workout history filtering by date range
- Export data to CSV/PDF
- Workout reminders/notifications
- User profiles and multi-user support
- Backend sync and cloud storage
- Social sharing features
- Advanced analytics and charts

---

## Team Roles

- **John Cyrus**: UI/UX Design, Form Implementation
- **John Llyod**: Navigation, Data Model, Summary Statistics

---

## Submission Checklist

- ✓ Flutter project with proper structure
- ✓ 3+ screens (Home, Form, Summary, Details)
- ✓ Form with validation
- ✓ Navigation between screens
- ✓ All required UI widgets used
- ✓ Responsive design
- ✓ Local data only (Lists, Maps)
- ✓ No databases used
- ✓ Code tested and working
- ✓ Screenshots documented
- ✓ Project documentation complete

---

## Contact & Support

For questions about this project, contact:
- **John Cyrus**: [email/contact]
- **John Llyod**: [email/contact]

---

*Project completed for CSE101 Final Project - October 2026*
