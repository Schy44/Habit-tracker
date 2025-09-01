import 'package:flutter/material.dart';
import 'package:mytracker/models/habit_model.dart';
import 'package:mytracker/models/predefined_categories.dart';
import 'package:mytracker/theme/app_colors.dart';
import 'package:mytracker/theme/app_styles.dart';
import 'package:mytracker/theme/app_typography.dart';
import 'package:mytracker/widgets/animated_checkbox.dart';
import 'package:mytracker/widgets/progress_bar.dart';
import 'dart:math';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final bool isCompleted;
  final ValueChanged<bool> onToggle;

  const HabitCard({super.key, required this.habit, required this.isCompleted, required this.onToggle});

  IconData _getCategoryIcon(String category) {
    final categoryData = PredefinedCategories.categories.firstWhere((c) => c['name'] == category, orElse: () => {'icon': Icons.star});
    return categoryData['icon'];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOverdue = !isCompleted && DateTime.now().hour > 20;

    return AnimatedContainer(
      duration: AppStyles.normalAnimationDuration,
      margin: const EdgeInsets.symmetric(horizontal: AppStyles.md, vertical: AppStyles.xs),
      padding: const EdgeInsets.all(AppStyles.md),
      decoration: AppStyles.cardContainerDecoration.copyWith(
        color: isCompleted ? AppColors.success.withOpacity(0.15) : theme.colorScheme.surfaceContainerHighest,
        border: isOverdue ? Border.all(color: AppColors.warning, width: 1.5) : null,
        boxShadow: [AppStyles.shadows[1]],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedCheckbox(isCompleted: isCompleted, onTap: () => onToggle(!isCompleted)),
              const SizedBox(width: AppStyles.sm),
              Icon(_getCategoryIcon(habit.category), color: theme.colorScheme.primary),
              const SizedBox(width: AppStyles.sm),
              Expanded(child: Text(habit.title, style: AppTypography.textTheme.titleMedium)),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 44.0), // Align with title
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppStyles.xs),
                Row(
                  children: [
                    Text('${habit.category} • ${habit.frequency}', style: AppTypography.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7))),
                    const Spacer(),
                    Text('🔥 ${habit.currentStreak} days', style: AppTypography.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: AppStyles.sm),
                _buildProgressSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    // Placeholder for progress
    final bool hasProgress = Random().nextBool();
    final double progress = Random().nextDouble();

    if (isCompleted) {
      return Text('✓ Completed at 2:30 PM', style: AppTypography.textTheme.bodySmall?.copyWith(color: AppColors.success));
    }

    if (hasProgress) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Progress: ${(progress * 8).toInt()}/8', style: AppTypography.textTheme.bodySmall),
          const SizedBox(height: AppStyles.xs),
          AnimatedProgressBar(value: progress),
        ],
      );
    }

    return Text('Due: Before 8:00 AM', style: AppTypography.textTheme.bodySmall);
  }
}