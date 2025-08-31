import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:mytracker/models/habit_model.dart';
import 'package:mytracker/providers/habit_provider.dart';
import 'package:mytracker/theme/app_colors.dart';
import 'package:mytracker/theme/app_styles.dart';
import 'package:mytracker/theme/app_typography.dart';
import 'package:mytracker/widgets/category_pill.dart';
import 'package:provider/provider.dart';

class _CategoryData {
  final String name;
  final IconData icon;
  final Color color;
  const _CategoryData(this.name, this.icon, this.color);
}

class HabitCategoriesScreen extends StatefulWidget {
  const HabitCategoriesScreen({super.key});

  @override
  State<HabitCategoriesScreen> createState() => _HabitCategoriesScreenState();
}

class _HabitCategoriesScreenState extends State<HabitCategoriesScreen> {
  String _selectedCategory = 'All';

  final List<_CategoryData> _categories = const [
    _CategoryData('Health', Icons.water_drop_outlined, AppColors.info),
    _CategoryData('Study', Icons.book_outlined, AppColors.accentLavender),
    _CategoryData('Fitness', Icons.directions_run_outlined, Colors.orangeAccent),
    _CategoryData('Productivity', Icons.work_outline, Colors.blueAccent),
    _CategoryData('Mental Health', Icons.self_improvement_outlined, AppColors.accentLavender),
    _CategoryData('Hobbies', Icons.palette_outlined, Colors.pinkAccent),
    _CategoryData('Social', Icons.people_outline, AppColors.success),
    _CategoryData('Finance', Icons.attach_money_outlined, Colors.yellowAccent),
    _CategoryData('Home', Icons.home_outlined, Colors.brown),
    _CategoryData('Others', Icons.more_horiz_outlined, AppColors.textHint),
  ];
  late final Map<String, _CategoryData> _categoryDataMap = { for (var c in _categories) c.name : c };

  @override
  Widget build(BuildContext context) {
    final habitProvider = Provider.of<HabitProvider>(context);
    final groupedHabits = _groupHabits(habitProvider.habits);

    final filteredHabits = _selectedCategory == 'All'
        ? groupedHabits
        : Map.fromEntries(groupedHabits.entries.where((e) => e.key == _selectedCategory));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          IconButton(icon: const Icon(Icons.search), tooltip: 'Search Habits', onPressed: () {}), // TODO: Implement search
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCategoryFilter(),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppStyles.md),
              children: [
                if (filteredHabits.isEmpty)
                  const Center(child: Text('No habits found in this category.'))
                else
                  ...filteredHabits.entries.map((entry) {
                    final categoryName = entry.key;
                    final habits = entry.value;
                    final categoryData = _categoryDataMap[categoryName] ?? _categoryDataMap['Others']!;
                    return _CategorySection(categoryData: categoryData, habits: habits);
                  }),
                const SizedBox(height: AppStyles.md),
                _buildAddNewCategoryButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final allCategories = ['All', ..._categories.map((c) => c.name)];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppStyles.md, vertical: AppStyles.sm),
      child: Row(
        children: allCategories.map((category) {
          return CategoryPill(
            name: category,
            isSelected: _selectedCategory == category,
            onTap: () => setState(() => _selectedCategory = category),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAddNewCategoryButton() {
    return Center(
      child: TextButton.icon(
        icon: const Icon(Icons.add_circle_outline, size: 20),
        label: const Text('Add New Category'),
        style: AppStyles.textButtonStyle,
        onPressed: () {
          // TODO: Implement Add New Category dialog/screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add New Category functionality not implemented.')),
          );
        },
      ),
    );
  }

  Map<String, List<Habit>> _groupHabits(List<Habit> habits) {
    final map = LinkedHashMap<String, List<Habit>>();
    for (final habit in habits) {
      (map[habit.category] ??= []).add(habit);
    }
    return map;
  }
}

class _CategorySection extends StatelessWidget {
  final _CategoryData categoryData;
  final List<Habit> habits;

  const _CategorySection({required this.categoryData, required this.habits});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: AppStyles.sm),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppStyles.borderRadiusMedium),
        side: const BorderSide(color: AppColors.outline),
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        leading: Icon(categoryData.icon, color: categoryData.color),
        title: Text(
          '${categoryData.name} (${habits.length} habits)',
          style: AppTypography.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        childrenPadding: const EdgeInsets.only(bottom: AppStyles.sm),
        children: habits.isEmpty
            ? [const Center(child: Text('No habits in this category yet.'))]
            : habits.map((habit) => _HabitTile(key: ValueKey(habit.id), habit: habit)).toList(),
      ),
    );
  }
}

class _HabitTile extends StatelessWidget {
  final Habit habit;
  const _HabitTile({super.key, required this.habit});

  @override
  Widget build(BuildContext context) {
    final isCompleted = habit.isCompletedToday(); // Assuming this method exists
    return ListTile(
      leading: Transform.scale(
        scale: 1.2,
        child: Checkbox(
          value: isCompleted,
          onChanged: (value) {
            // TODO: Implement toggle completion logic via provider
          },
          activeColor: AppColors.success,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
      title: Text(
        habit.title,
        style: AppTypography.textTheme.bodyLarge?.copyWith(
          decoration: isCompleted ? TextDecoration.lineThrough : null,
          color: isCompleted ? AppColors.textHint : null,
        ),
      ),
      trailing: Text('🔥 ${habit.currentStreak}', style: AppTypography.textTheme.bodyMedium),
    );
  }
}
