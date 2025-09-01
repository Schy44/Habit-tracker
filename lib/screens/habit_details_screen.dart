import 'package:flutter/material.dart';
import 'package:mytracker/models/habit_model.dart';
import 'package:mytracker/models/predefined_categories.dart';
import 'package:mytracker/providers/habit_provider.dart';
import 'package:mytracker/screens/habit_creation_screen.dart';
import 'package:mytracker/theme/app_colors.dart';
import 'package:mytracker/theme/app_styles.dart';
import 'package:mytracker/theme/app_typography.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

enum _MenuOption { edit, duplicate, archive, delete }

class HabitDetailsScreen extends StatefulWidget {
  final Habit habit;

  const HabitDetailsScreen({super.key, required this.habit});

  @override
  State<HabitDetailsScreen> createState() => _HabitDetailsScreenState();
}

class _HabitDetailsScreenState extends State<HabitDetailsScreen> {
  void _onSelectMenu(BuildContext context, _MenuOption option) {
    switch (option) {
      case _MenuOption.edit:
        _editHabit(context);
        break;
      case _MenuOption.delete:
        _deleteHabit(context);
        break;
      case _MenuOption.duplicate:
      case _MenuOption.archive:
        // TODO: Implement duplicate/archive logic
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${option.name} functionality not implemented yet.')),
        );
        break;
    }
  }

  void _editHabit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HabitCreationScreen(habit: widget.habit),
      ),
    );
  }

  Future<void> _deleteHabit(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Habit?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      try {
        if (!mounted) return;
        await Provider.of<HabitProvider>(context, listen: false).deleteHabit(widget.habit.id);
        if (mounted) Navigator.pop(context);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting habit: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.habit.title),
        actions: [
          PopupMenuButton<_MenuOption>(
            onSelected: (option) => _onSelectMenu(context, option),
            itemBuilder: (context) => [
              const PopupMenuItem(value: _MenuOption.edit, child: Text('Edit')),
              const PopupMenuItem(value: _MenuOption.duplicate, child: Text('Duplicate')),
              const PopupMenuItem(value: _MenuOption.archive, child: Text('Archive')),
              const PopupMenuItem(value: _MenuOption.delete, child: Text('Delete')),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppStyles.md),
        child: Column(
          children: [
            _HabitOverviewCard(habit: widget.habit),
            _ProgressChartCard(),
            _StatisticsCard(habit: widget.habit),
            _NotesCard(notes: widget.habit.notes ?? "No notes for this habit."),
            const SizedBox(height: AppStyles.lg),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.edit_document, size: 18),
            label: const Text('Edit Habit'),
            style: AppStyles.primaryButtonStyle,
            onPressed: () => _editHabit(context),
          ),
        ),
        const SizedBox(width: AppStyles.md),
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.delete_outline, size: 18),
            label: const Text('Delete'),
            style: AppStyles.secondaryButtonStyle.copyWith(
              foregroundColor: WidgetStateProperty.all(AppColors.error),
              side: WidgetStateProperty.all(const BorderSide(color: AppColors.error)),
            ),
            onPressed: () => _deleteHabit(context),
          ),
        ),
      ],
    );
  }
}

class _HabitOverviewCard extends StatelessWidget {
  final Habit habit;
  const _HabitOverviewCard({required this.habit});

  IconData _getCategoryIcon(String category) {
    final categoryData = PredefinedCategories.categories.firstWhere((c) => c['name'] == category, orElse: () => {'icon': Icons.star});
    return categoryData['icon'];
  }

  @override
  Widget build(BuildContext context) {
    return _DetailsCard(
      title: 'Habit Overview',
      child: Column(
        children: [
          Row(
            children: [
              Icon(_getCategoryIcon(habit.category), color: Theme.of(context).colorScheme.primary, size: 28),
              const SizedBox(width: AppStyles.sm),
              Expanded(
                child: Text(habit.title, style: AppTypography.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: AppStyles.sm),
          Align(
            alignment: Alignment.centerLeft,
            child: Text('${habit.category} • ${habit.frequency}', style: AppTypography.textTheme.bodyMedium),
          ),
          const Divider(height: AppStyles.lg),
          _buildStatRow('Current Streak', '🔥 ${habit.currentStreak} days'),
          _buildStatRow('Best Streak', '🏆 ${habit.bestStreak} days'),
          _buildStatRow('Completion Rate', '${(habit.completedDates.length / (DateTime.now().difference(habit.createdAt.toDate()).inDays + 1) * 100).toStringAsFixed(0)}%'),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppStyles.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.textTheme.bodyLarge),
          Text(value, style: AppTypography.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _ProgressChartCard extends StatefulWidget {
  @override
  State<_ProgressChartCard> createState() => _ProgressChartCardState();
}

class _ProgressChartCardState extends State<_ProgressChartCard> {
  int _weekOffset = 0;

  @override
  Widget build(BuildContext context) {
    return _DetailsCard(
      title: 'Progress Chart',
      child: Column(
        children: [
          _buildWeekNavigator(),
          const SizedBox(height: AppStyles.md),
          _buildWeekGrid(),
        ],
      ),
    );
  }

  Widget _buildWeekNavigator() {
    // Logic to get week label
    final now = DateTime.now().add(Duration(days: _weekOffset * 7));
    final weekNumber = (now.day / 7).ceil();
    final month = DateFormat.MMMM().format(now);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(icon: const Icon(Icons.arrow_back_ios), onPressed: () => setState(() => _weekOffset--)),
        Text('Week $weekNumber, $month', style: AppTypography.textTheme.labelLarge),
        IconButton(icon: const Icon(Icons.arrow_forward_ios), onPressed: () => setState(() => _weekOffset++)),
      ],
    );
  }

  Widget _buildWeekGrid() {
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final status = ['done', 'done', 'missed', 'done', 'done', 'missed', 'future']; // Placeholder

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(7, (index) {
        final isToday = _weekOffset == 0 && index == DateTime.now().weekday - 1;
        return Column(
          children: [
            Text(days[index], style: AppTypography.textTheme.bodySmall),
            const SizedBox(height: AppStyles.sm),
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: _getColorForStatus(status[index]),
                borderRadius: BorderRadius.circular(AppStyles.borderRadiusMedium),
                border: isToday ? Border.all(color: AppColors.primary, width: 2) : null,
              ),
              child: _getIconForStatus(status[index]),
            ),
          ],
        );
      }),
    );
  }

  Color _getColorForStatus(String status) {
    switch (status) {
      case 'done': return AppColors.success.withOpacity(0.2);
      case 'missed': return AppColors.error.withOpacity(0.1);
      default: return Theme.of(context).colorScheme.surface;
    }
  }

  Widget _getIconForStatus(String status) {
    switch (status) {
      case 'done': return const Icon(Icons.check, color: AppColors.success);
      case 'missed': return const Icon(Icons.close, color: AppColors.error, size: 18);
      default: return const Icon(Icons.question_mark, color: AppColors.textHint, size: 18);
    }
  }
}

class _StatisticsCard extends StatelessWidget {
  final Habit habit;
  const _StatisticsCard({required this.habit});

  @override
  Widget build(BuildContext context) {
    return _DetailsCard(
      title: 'Statistics',
      child: Column(
        children: [
          _buildStatRow('This Month', '${habit.completedDates.where((d) => d.toDate().month == DateTime.now().month).length}/${DateTime(DateTime.now().year, DateTime.now().month + 1, 0).day} days (${(habit.completedDates.where((d) => d.toDate().month == DateTime.now().month).length / DateTime(DateTime.now().year, DateTime.now().month + 1, 0).day * 100).toStringAsFixed(0)}%)'),
          _buildStatRow('Total Completions', '${habit.completedDates.length}'),
          _buildStatRow('Average per week', '${(habit.completedDates.length / (DateTime.now().difference(habit.createdAt.toDate()).inDays / 7)).toStringAsFixed(1)}'),
          _buildStatRow('Longest streak', '${habit.bestStreak} days'),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.textTheme.bodyLarge),
          Text(value, style: AppTypography.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _NotesCard extends StatelessWidget {
  final String notes;
  const _NotesCard({required this.notes});

  @override
  Widget build(BuildContext context) {
    return _DetailsCard(
      title: 'Notes & Description',
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(notes, style: AppTypography.textTheme.bodyLarge),
      ),
    );
  }
}

// A wrapper for the section cards to reduce boilerplate
class _DetailsCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _DetailsCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: AppStyles.sm),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppStyles.md),
          decoration: AppStyles.cardContainerDecoration.copyWith(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            boxShadow: [], // Flatter look
            border: Border.all(color: AppColors.outline),
          ),
          child: child,
        ),
        const SizedBox(height: AppStyles.lg),
      ],
    );
  }
}
