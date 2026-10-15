class Workout {
  final String id;
  final String date;
  final String type; // Running, Weight Lifting, Cardio, Yoga
  final int duration; // in minutes
  final double? distance; // in km, optional
  final double? weight; // in kg, optional
  final int? reps; // optional
  final int? sets; // optional
  final int caloriesBurned;
  final String notes;

  Workout({
    required this.id,
    required this.date,
    required this.type,
    required this.duration,
    this.distance,
    this.weight,
    this.reps,
    this.sets,
    required this.caloriesBurned,
    required this.notes,
  });

  // Convert to Map for easier handling
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'type': type,
      'duration': duration,
      'distance': distance,
      'weight': weight,
      'reps': reps,
      'sets': sets,
      'caloriesBurned': caloriesBurned,
      'notes': notes,
    };
  }

  // Create from Map
  factory Workout.fromMap(Map<String, dynamic> map) {
    return Workout(
      id: map['id'] ?? '',
      date: map['date'] ?? '',
      type: map['type'] ?? 'Cardio',
      duration: map['duration'] ?? 0,
      distance: map['distance'],
      weight: map['weight'],
      reps: map['reps'],
      sets: map['sets'],
      caloriesBurned: map['caloriesBurned'] ?? 0,
      notes: map['notes'] ?? '',
    );
  }
}
