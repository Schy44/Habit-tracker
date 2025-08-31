import 'package:flutter/material.dart';
import 'package:mytracker/screens/habit_creation_screen.dart';
import 'package:mytracker/theme/app_colors.dart';
import 'package:mytracker/theme/app_styles.dart';
import 'package:mytracker/theme/app_typography.dart';

class EmptyStateDisplay extends StatelessWidget {
  const EmptyStateDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.add_task, size: 64, color: AppColors.textHint),
          const SizedBox(height: AppStyles.md),
          Text('No habits yet!', style: AppTypography.textTheme.headlineSmall),
          const SizedBox(height: AppStyles.sm),
          Text('Ready to build some great habits?', style: AppTypography.textTheme.bodyLarge, textAlign: TextAlign.center),
          const SizedBox(height: AppStyles.lg),
          ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HabitCreationScreen())), child: const Text('Add Your First Habit')),
        ],
      ),
    );
  }
}
