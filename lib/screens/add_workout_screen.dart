import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/stats.dart';
import '../models/workout.dart';
import '../theme/app_theme.dart';
import '../theme/workout_style.dart';
import '../widgets/app_card.dart';

class AddWorkoutScreen extends StatefulWidget {
  final Function(Workout) onAddWorkout;

  /// When provided the form opens in "edit" mode and is pre-filled.
  final Workout? initial;

  /// Enables the delete action (only used in edit mode).
  final VoidCallback? onDelete;

  const AddWorkoutScreen({
    super.key,
    required this.onAddWorkout,
    this.initial,
    this.onDelete,
  });

  @override
  State<AddWorkoutScreen> createState() => _AddWorkoutScreenState();
}

class _AddWorkoutScreenState extends State<AddWorkoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _duration = TextEditingController();
  final _distance = TextEditingController();
  final _weight = TextEditingController();
  final _reps = TextEditingController();
  final _sets = TextEditingController();
  final _calories = TextEditingController();
  final _notes = TextEditingController();

  String _type = WorkoutStyle.types.first;

  bool get _isEditing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final w = widget.initial;
    if (w != null) {
      _type = w.type;
      _duration.text = '${w.duration}';
      _distance.text = w.distance == null ? '' : '${w.distance}';
      _weight.text = w.weight == null ? '' : '${w.weight}';
      _reps.text = w.reps == null ? '' : '${w.reps}';
      _sets.text = w.sets == null ? '' : '${w.sets}';
      _calories.text = '${w.caloriesBurned}';
      _notes.text = w.notes;
    }
  }

  @override
  void dispose() {
    _duration.dispose();
    _distance.dispose();
    _weight.dispose();
    _reps.dispose();
    _sets.dispose();
    _calories.dispose();
    _notes.dispose();
    super.dispose();
  }

  String? _requiredPositive(String? value, String field) {
    if (value == null || value.trim().isEmpty) return '$field is required';
    final n = int.tryParse(value);
    if (n == null || n <= 0) return 'Enter a positive number';
    return null;
  }

  String? _optionalPositive(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final n = double.tryParse(value);
    if (n == null || n <= 0) return 'Enter a positive number';
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final workout = Workout(
      id: widget.initial?.id ?? const Uuid().v4(),
      date: widget.initial?.date ?? WorkoutStats.formatDate(DateTime.now()),
      type: _type,
      duration: int.parse(_duration.text),
      distance: _distance.text.isEmpty ? null : double.parse(_distance.text),
      weight: _weight.text.isEmpty ? null : double.parse(_weight.text),
      reps: _reps.text.isEmpty ? null : int.parse(_reps.text),
      sets: _sets.text.isEmpty ? null : int.parse(_sets.text),
      caloriesBurned: int.parse(_calories.text),
      notes: _notes.text.trim(),
    );

    widget.onAddWorkout(workout);

    if (_isEditing) {
      Navigator.pop(context);
    } else {
      _formKey.currentState!.reset();
      _duration.clear();
      _distance.clear();
      _weight.clear();
      _reps.clear();
      _sets.clear();
      _calories.clear();
      _notes.clear();
      setState(() => _type = WorkoutStyle.types.first);
    }
  }

  Future<void> _confirmDelete() async {
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
      widget.onDelete?.call();
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit workout' : 'Log workout'),
        automaticallyImplyLeading: _isEditing,
        actions: [
          if (widget.onDelete != null)
            IconButton(
              onPressed: _confirmDelete,
              tooltip: 'Delete',
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.danger,
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.xxl,
          ),
          children: [
            const Text('Workout type', style: AppText.label),
            const SizedBox(height: AppSpacing.md),
            _buildTypeSelector(),
            const SizedBox(height: AppSpacing.xl),
            _buildSection(
              title: 'Session',
              children: [
                _Field(
                  label: 'Duration (minutes)',
                  controller: _duration,
                  icon: Icons.timer_rounded,
                  required: true,
                  keyboardType: TextInputType.number,
                  validator: (v) => _requiredPositive(v, 'Duration'),
                ),
                _Field(
                  label: 'Distance (km)',
                  controller: _distance,
                  icon: Icons.straighten_rounded,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: _optionalPositive,
                ),
                _Field(
                  label: 'Calories burned',
                  controller: _calories,
                  icon: Icons.local_fire_department_rounded,
                  required: true,
                  keyboardType: TextInputType.number,
                  validator: (v) => _requiredPositive(v, 'Calories'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildSection(
              title: 'Strength (optional)',
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _Field(
                        label: 'Weight (kg)',
                        controller: _weight,
                        icon: Icons.fitness_center_rounded,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        validator: _optionalPositive,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _Field(
                        label: 'Reps',
                        controller: _reps,
                        icon: Icons.repeat_rounded,
                        keyboardType: TextInputType.number,
                        validator: _optionalPositive,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                _Field(
                  label: 'Sets',
                  controller: _sets,
                  icon: Icons.layers_rounded,
                  keyboardType: TextInputType.number,
                  validator: _optionalPositive,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildSection(
              title: 'Notes',
              children: [
                TextFormField(
                  controller: _notes,
                  maxLines: 4,
                  maxLength: 200,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'How did it feel?',
                    counterStyle: TextStyle(color: AppColors.textMuted),
                  ),
                  validator: (v) {
                    if (v != null && v.length > 200) {
                      return 'Keep notes under 200 characters';
                    }
                    return null;
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            GradientButton(
              label: 'Save workout',
              icon: Icons.check_rounded,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final type in WorkoutStyle.types)
          _TypeChip(
            type: type,
            selected: _type == type,
            onTap: () => setState(() => _type = type),
          ),
      ],
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.toUpperCase(), style: AppText.label),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              for (int i = 0; i < children.length; i++) ...[
                if (i > 0) const SizedBox(height: AppSpacing.lg),
                children[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String type;
  final bool selected;
  final VoidCallback onTap;

  const _TypeChip({
    required this.type,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = WorkoutStyle.color(type);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.16) : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: selected ? color : AppColors.border,
            width: 1.4,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              WorkoutStyle.icon(type),
              size: 17,
              color: selected ? color : AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              type,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final bool required;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _Field({
    required this.label,
    required this.controller,
    required this.icon,
    this.required = false,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: AppText.caption.copyWith(color: AppColors.textSecondary),
              ),
            ),
            if (required)
              Text(
                ' *',
                style: AppText.caption.copyWith(color: AppColors.primary),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20, color: AppColors.textMuted),
          ),
        ),
      ],
    );
  }
}
