import 'package:flutter/material.dart';
import 'package:mytracker/models/habit_model.dart';
import 'package:mytracker/providers/habit_provider.dart';
import 'package:mytracker/theme/app_colors.dart';
import 'package:mytracker/theme/app_styles.dart';
import 'package:mytracker/theme/app_typography.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // For Timestamp

class _Category {
  final String name;
  final IconData icon;
  const _Category(this.name, this.icon);
}

class HabitCreationScreen extends StatefulWidget {
  final Habit? habit;

  const HabitCreationScreen({super.key, this.habit});

  @override
  State<HabitCreationScreen> createState() => _HabitCreationScreenState();
}

class _HabitCreationScreenState extends State<HabitCreationScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _notesController;
  late TextEditingController _startDateController;

  _Category? _selectedCategory;
  String _frequency = 'Daily';
  bool get isEditMode => widget.habit != null;

  final List<_Category> _categories = const [
    _Category('Health', Icons.water_drop_outlined),
    _Category('Study', Icons.book_outlined),
    _Category('Fitness', Icons.directions_run_outlined),
  ];
  late final Map<String, _Category> _categoryMap = { for (var c in _categories) c.name : c };

  @override
  void initState() {
    super.initState();
    final habit = widget.habit;
    _titleController = TextEditingController(text: habit?.title ?? '');
    _notesController = TextEditingController(text: habit?.notes ?? '');
    _startDateController = TextEditingController(text: habit?.startDate != null ? DateFormat('yMMMd').format(habit!.startDate!.toDate()) : '');

    if (isEditMode && habit != null) {
      _selectedCategory = _categoryMap[habit.category];
      _frequency = habit.frequency;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    _startDateController.dispose();
    super.dispose();
  }

  Future<void> _saveHabit() async {
    print('[_saveHabit] method called.');
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      print('[_saveHabit] Form validation passed.');
      final habitProvider = Provider.of<HabitProvider>(context, listen: false);

      // Parse startDate from controller
      Timestamp? startDateTimestamp;
      if (_startDateController.text.isNotEmpty) {
        try {
          startDateTimestamp = Timestamp.fromDate(DateFormat('yMMMd').parse(_startDateController.text));
        } catch (e) {
          // Handle parsing error if necessary
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invalid start date format.')),
          );
          print('[_saveHabit] Error parsing start date: $e');
          return;
        }
      }

      try {
        if (isEditMode) {
          final updatedHabit = widget.habit!.copyWith(
            title: _titleController.text,
            category: _selectedCategory!.name,
            frequency: _frequency,
            startDate: startDateTimestamp,
            notes: _notesController.text,
            // These fields are not edited on this screen, so copy from original
            userId: widget.habit!.userId,
            createdAt: widget.habit!.createdAt,
            updatedAt: Timestamp.now(),
            completedDates: widget.habit!.completedDates,
            currentStreak: widget.habit!.currentStreak,
            bestStreak: widget.habit!.bestStreak,
            isArchived: widget.habit!.isArchived,
          );
          print('[_saveHabit] Updating habit: ${updatedHabit.toMap()}');
          await habitProvider.updateHabit(updatedHabit);
          print('[_saveHabit] Habit updated successfully.');
        } else {
          final newHabit = Habit(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            userId: '', // userId will be set by HabitProvider
            title: _titleController.text,
            category: _selectedCategory!.name,
            frequency: _frequency,
            startDate: startDateTimestamp,
            notes: _notesController.text,
            createdAt: Timestamp.now(),
            updatedAt: Timestamp.now(),
            completedDates: [],
            currentStreak: 0,
            bestStreak: 0,
            isArchived: false,
          );
          print('[_saveHabit] Creating new habit: ${newHabit.toMap()}');
          await habitProvider.addHabit(newHabit);
          print('[_saveHabit] New habit added successfully.');
        }
        if (mounted) {
          int popCount = isEditMode ? 2 : 1;
          for (int i = 0; i < popCount; i++) {
             if(Navigator.canPop(context)) Navigator.pop(context);
          }
        }
      } catch (e) {
        print('[_saveHabit] Error saving habit: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving habit: $e')),
          );
        }
      }
    } else {
      print('[_saveHabit] Form validation failed.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Habit' : 'New Habit'),
        actions: [
          TextButton(onPressed: _saveHabit, child: const Text('Save')),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppStyles.md),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTitleField(),
              const SizedBox(height: AppStyles.md),
              _buildCategoryDropdown(),
              const SizedBox(height: AppStyles.md),
              _buildFrequencySelector(),
              const SizedBox(height: AppStyles.md),
              _buildStartDateField(), // Added Start Date field
              const SizedBox(height: AppStyles.md),
              _buildNotesField(), // Added Notes field
              const SizedBox(height: AppStyles.lg),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      maxLength: 50,
      decoration: InputDecoration(
        labelText: 'Habit Title *',
        counterText: '${_titleController.text.length}/50',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Title is required.';
        return null;
      },
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<_Category>(
      value: _selectedCategory,
      decoration: InputDecoration(
        labelText: 'Category *',
      ),
      items: _categories.map((category) {
        return DropdownMenuItem<_Category>(
          value: category,
          child: Row(children: [Icon(category.icon, size: 20), const SizedBox(width: AppStyles.sm), Text(category.name)]),
        );
      }).toList(),
      onChanged: (value) => setState(() => _selectedCategory = value),
      validator: (value) => value == null ? 'Category is required.' : null,
    );
  }

  Widget _buildFrequencySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Frequency *', style: AppTypography.textTheme.bodyLarge),
        const SizedBox(height: AppStyles.sm),
        Row(children: [_buildFrequencyOption('Daily'), const SizedBox(width: AppStyles.sm), _buildFrequencyOption('Weekly')]),
      ],
    );
  }

  Widget _buildFrequencyOption(String value) {
    final isSelected = _frequency == value;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _frequency = value),
        borderRadius: BorderRadius.circular(AppStyles.borderRadiusMedium),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppStyles.sm, horizontal: AppStyles.md),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withAlpha((255 * 0.1).round()) : null,
            borderRadius: BorderRadius.circular(AppStyles.borderRadiusMedium),
            border: Border.all(color: isSelected ? AppColors.primary : AppColors.outline),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: AppColors.primary, size: 20), const SizedBox(width: AppStyles.sm), Text(value, style: AppTypography.textTheme.bodyLarge)]),
        ),
      ),
    );
  }

  Widget _buildStartDateField() {
    return TextFormField(
      controller: _startDateController,
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'Start Date (Optional)',
      ),
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: _startDateController.text.isNotEmpty ? DateFormat('yMMMd').parse(_startDateController.text) : DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (pickedDate != null) {
          setState(() {
            _startDateController.text = DateFormat('yMMMd').format(pickedDate);
          });
        }
      },
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      controller: _notesController,
      maxLines: null, // Allows multiple lines
      keyboardType: TextInputType.multiline,
      decoration: InputDecoration(
        labelText: 'Notes/Description (Optional)',
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(child: OutlinedButton(style: AppStyles.secondaryButtonStyle, onPressed: () => Navigator.pop(context), child: const Text('Cancel'))),
        const SizedBox(width: AppStyles.md),
        Expanded(child: ElevatedButton(style: AppStyles.primaryButtonStyle, onPressed: _saveHabit, child: Text(isEditMode ? 'Save Changes' : 'Create Habit'))),
      ],
    );
  }
}