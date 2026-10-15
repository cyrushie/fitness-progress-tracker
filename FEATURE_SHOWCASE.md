# Fitness Progress Tracker - Feature Showcase

## Screen-by-Screen Walkthrough

### Home Screen
**Location**: First tab in bottom navigation

**Components**:
- AppBar with title "Fitness Progress Tracker"
- Summary Card displaying:
  - Number of workouts today
  - Total calories burned
  - Total time spent exercising
- "Today's Workouts" section with:
  - Add Workout button
  - List of all logged workouts in Cards
  - Each card shows: workout icon, type, duration, calories
  - Tap any card to view full details
- Empty state with motivational message if no workouts

**Responsive Behavior**:
- On mobile: Single column layout with full-width cards
- On tablet: Stat items arranged in row with better spacing
- Padding adjusts based on screen size

**Navigation**:
- Tab bar to switch to "Log" or "Summary" screens
- Tap "Add" button to navigate to form
- Tap any workout card to view details

---

### Add Workout Form Screen
**Location**: Second tab in bottom navigation or accessible from Home

**Form Fields**:

1. **Workout Type** (Required)
   - Dropdown selector
   - Options: Running, Weight Lifting, Cardio, Yoga
   - Default: Cardio

2. **Duration** (Required)
   - Numeric input
   - Unit: minutes
   - Validation: Must be positive integer

3. **Distance** (Optional)
   - Decimal input
   - Unit: kilometers
   - Validation: Must be positive if provided

4. **Weight** (Optional)
   - Decimal input
   - Unit: kilograms
   - Validation: Must be positive if provided

5. **Reps** (Optional)
   - Integer input
   - Validation: Must be positive if provided

6. **Sets** (Optional)
   - Integer input
   - Validation: Must be positive if provided

7. **Calories Burned** (Required)
   - Integer input
   - Validation: Must be non-negative

8. **Notes** (Optional)
   - Multi-line text input
   - Max 200 characters
   - Validation: Character count enforced

**Validation Features**:
- Real-time error messages
- Required field indicators (*)
- Clear, helpful error text
- Form prevents submission until valid

**Buttons**:
- "Log Workout" - Submits form and navigates to home
- "Cancel" - Discards changes and returns home

**Data Generation**:
- Unique ID created using UUID library
- Date auto-filled with today's date
- All data saved to app's runtime list

---

### Summary/Profile Screen
**Location**: Third tab in bottom navigation

**Profile Header**:
- Person icon in circular container
- Title "Fitness Profile"
- Motivational tagline: "Keep pushing your limits!"

**Key Statistics Grid**:
- Total Workouts (blue)
- Total Minutes (orange)
- Total Calories (red)
- Average Duration (green)
- Grid adapts: 2 columns on mobile, 4 on tablet

**Most Active Type Card**:
- Shows workout type user does most
- Displays relevant icon
- Updates dynamically based on logged workouts

**Workout Breakdown Section**:
- Percentage breakdown of each workout type
- Progress bars showing proportion
- Lists: Running, Weight Lifting, Cardio, Yoga
- Shows count and percentage for each

**Fitness Goals Section**:
- Weekly Target: 20 workouts (shows current progress)
- Calorie Burn Goal: 5000 calories (shows current)
- Time Target: 300 minutes (shows current)
- Visual cards for each goal

**Responsive Behavior**:
- Single column on mobile
- Better spacing on tablet/desktop
- Readable text at all sizes

---

### Workout Details Screen
**Location**: Accessible by tapping a workout card from Home

**Header**:
- Large icon representing workout type
- Workout type title (e.g., "Running")
- Date of workout

**Details Grid**:
- Duration with timer icon
- Calories with fire icon
- Distance (if provided) with location icon
- Weight (if provided) with fitness icon
- Reps (if provided) with repeat icon
- Sets (if provided) with layers icon

**Notes Section**:
- Only displays if notes were added
- Shows full text content
- Card-based layout

**Navigation**:
- Back button to return to Home
- Clean card-based design

---

## Sample Data

The app comes pre-loaded with 5 sample workouts:

1. **Running (2026-10-15)**
   - Duration: 30 min
   - Distance: 5.0 km
   - Calories: 350
   - Notes: "Morning jog at the park"

2. **Weight Lifting (2026-10-15)**
   - Duration: 45 min
   - Weight: 75.5 kg
   - Reps: 10
   - Sets: 3
   - Calories: 280
   - Notes: "Chest and triceps workout"

3. **Cardio (2026-10-14)**
   - Duration: 25 min
   - Calories: 250
   - Notes: "Treadmill session"

4. **Yoga (2026-10-14)**
   - Duration: 60 min
   - Calories: 180
   - Notes: "Relaxing evening yoga"

5. **Running (2026-10-13)**
   - Duration: 35 min
   - Distance: 6.5 km
   - Calories: 400
   - Notes: "Trail running adventure"

---

## Color Scheme

- **Primary**: Deep Purple (RGB: 103, 58, 183)
- **Accent**: Light Purple with opacity
- **Text**: Dark gray/black
- **Secondary**: Light gray backgrounds
- **Icons**: Deep Purple

---

## Typography

- **AppBar Title**: Bold, 18-20px
- **Section Headers**: Bold, 18px
- **Card Titles**: Bold, 16px
- **Body Text**: Regular, 14px
- **Labels**: Regular, 12-14px
- **Stats Numbers**: Bold, 16-28px

---

## User Interactions

### Adding a Workout
1. Click "Add" button on Home or "Log" tab
2. Select workout type from dropdown
3. Enter duration (required)
4. Optionally fill distance, weight, reps, sets
5. Enter calories burned (required)
6. Add notes (optional)
7. Click "Log Workout"
8. Returned to Home with new workout added

### Viewing Workout Details
1. From Home screen, tap any workout card
2. View complete details on Details screen
3. All metrics displayed in organized grid
4. Notes shown if available
5. Click "Back to Home" to return

### Monitoring Progress
1. Click "Summary" tab
2. View all statistics and breakdowns
3. See progress toward fitness goals
4. Review most active workout type
5. Track workout type distribution

---

## Technical Details

### State Management
- Uses `setState()` for state updates
- Maintains List<Workout> in main app state
- Data propagated to child screens via constructor

### Navigation
- Uses named routes and Navigator
- Bottom BottomNavigationBar for main screens
- Push/pop navigation for details screen

### Responsiveness
- MediaQuery for screen size detection
- Conditional widget rendering
- Dynamic padding and spacing
- Flexible/Expanded for layout

### Form Handling
- Global FormKey for form validation
- TextEditingControllers for input
- Custom validators for business logic
- Type-safe data conversion

---

## Performance Considerations

- All data in memory (no I/O delays)
- Instant updates with setState
- Efficient list rendering with ListView
- Grid layout with GridView
- No network calls

---

## Accessibility Features

- Clear visual hierarchy
- Good color contrast
- Semantic widgets used properly
- Icon + text labels
- Proper text sizing
- Touch targets meet minimum size

---

## Error Handling

### Form Validation Errors
- Empty required fields: "X is required"
- Invalid numeric input: "Must be a number"
- Negative values: "Must be positive"
- Text too long: "Max 200 characters"

### Edge Cases Handled
- No workouts logged: Empty state message
- All optional fields: Form still valid
- Large numbers: Handled properly
- Special characters in notes: Allowed

---

## Testing Scenarios

✓ **Happy Path**: Add valid workout, view details, check summary  
✓ **Validation**: Try invalid inputs, see error messages  
✓ **Empty State**: Start app with no workouts  
✓ **Navigation**: Switch between tabs and screens  
✓ **Responsive**: Test on different screen sizes  
✓ **Data Accuracy**: Verify calculations are correct  

---

*For complete documentation, see PROJECT_DOCUMENTATION.md*
