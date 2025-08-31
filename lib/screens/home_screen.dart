import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mytracker/models/habit_model.dart';
import 'package:mytracker/providers/auth_provider.dart';
import 'package:mytracker/providers/habit_provider.dart';
import 'package:mytracker/providers/theme_notifier.dart';
import 'package:mytracker/screens/habit_creation_screen.dart';
import 'package:mytracker/screens/statistics_screen.dart';
import 'package:mytracker/theme/app_colors.dart';
import 'package:mytracker/theme/app_styles.dart';
import 'package:mytracker/theme/app_typography.dart';
import 'package:mytracker/widgets/empty_state.dart';
import 'package:mytracker/widgets/habit_card.dart';
import 'package:mytracker/widgets/habit_card_skeleton.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Map<String, bool> _completionState = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final habits = Provider.of<HabitProvider>(context, listen: false).habits;
    for (var habit in habits) {
      _completionState.putIfAbsent(habit.id, () => habit.isCompletedToday());
    }
  }

  Future<void> _refreshHabits() async {
    await Provider.of<HabitProvider>(context, listen: false).fetchHabits();
  }

  void _onToggleCompletion(Habit habit, bool isCompleted) {
    setState(() => _completionState[habit.id] = isCompleted);
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${habit.title} marked as ${isCompleted ? 'complete' : 'incomplete'}.'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(label: 'Undo', onPressed: () => setState(() => _completionState[habit.id] = !isCompleted)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final habitProvider = Provider.of<HabitProvider>(context);
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final user = authProvider.currentUser;
    final habits = habitProvider.habits;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: _refreshHabits,
        color: AppColors.primary,
        child: CustomScrollView(
          slivers: [
            _buildAppBar(context, habitProvider, themeNotifier),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppStyles.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${_getGreeting()}, ${user?.displayName ?? 'User'}!', style: AppTypography.textTheme.headlineLarge),
                    const SizedBox(height: AppStyles.lg),
                    _QuickStatsCard(habits: habits, completionState: _completionState),
                    const SizedBox(height: AppStyles.lg),
                    Text("Today's Habits", style: AppTypography.textTheme.headlineMedium),
                    const SizedBox(height: AppStyles.md),
                  ],
                ),
              ),
            ),
            _buildHabitList(habits, habitProvider),
            _buildBottomButtons(context),
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context, HabitProvider habitProvider, ThemeNotifier themeNotifier) {
    return SliverAppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      pinned: true, elevation: 0, centerTitle: false,
      title: Text(_formatDate(DateTime.now()), style: AppTypography.textTheme.bodyMedium),
      actions: [
        if (habitProvider.isLoading) const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
        IconButton(icon: Icon(themeNotifier.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode), tooltip: 'Toggle Theme', onPressed: () => themeNotifier.toggleTheme()),
        IconButton(icon: const Icon(Icons.settings), tooltip: 'Settings', onPressed: () => Navigator.pushNamed(context, '/settings')), // Added Settings button
        const SizedBox(width: AppStyles.sm),
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/profile'); // Navigate to ProfileScreen
          },
          child: const CircleAvatar(radius: 20, child: Icon(Icons.person)),
        ),
        const SizedBox(width: AppStyles.md),
      ],
    );
  }

  Widget _buildHabitList(List<Habit> habits, HabitProvider habitProvider) {
    if (habitProvider.isLoading && habits.isEmpty) {
      return SliverList(delegate: SliverChildBuilderDelegate((c, i) => const HabitCardSkeleton(), childCount: 5));
    }
    if (habits.isEmpty) {
      return const SliverFillRemaining(child: EmptyStateDisplay());
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final habit = habits[index];
          final isCompleted = _completionState[habit.id] ?? false;
          return Dismissible(
            key: ValueKey(habit.id),
            background: _buildSwipeBackground(context, isComplete: true),
            secondaryBackground: _buildSwipeBackground(context, isComplete: false),
            confirmDismiss: (direction) async {
              _onToggleCompletion(habit, direction == DismissDirection.startToEnd);
              return false;
            },
            child: HabitCard(habit: habit, isCompleted: isCompleted, onToggle: (value) => _onToggleCompletion(habit, value)),
          );
        },
        childCount: habits.length,
      ),
    );
  }

  Widget _buildSwipeBackground(BuildContext context, {required bool isComplete}) {
    return Container(
      color: isComplete ? AppColors.success : AppColors.error,
      padding: const EdgeInsets.symmetric(horizontal: AppStyles.lg),
      alignment: isComplete ? Alignment.centerLeft : Alignment.centerRight,
      child: Icon(isComplete ? Icons.check_circle_outline : Icons.cancel_outlined, color: Colors.white),
    );
  }

  SliverToBoxAdapter _buildBottomButtons(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(AppStyles.md),
        child: Row(
          children: [
            Expanded(child: ElevatedButton.icon(icon: const Icon(Icons.add), label: const Text('Add New Habit'), style: AppStyles.primaryButtonStyle, onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HabitCreationScreen())))),
            const SizedBox(width: AppStyles.md),
            Expanded(child: OutlinedButton.icon(icon: const Icon(Icons.bar_chart), label: const Text('Statistics'), style: AppStyles.secondaryButtonStyle, onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const StatisticsScreen())))),
          ],
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    if (hour < 21) return 'Good evening'; // Added this line
    return 'Good night'; // Added this line
  }

  String _formatDate(DateTime date) => DateFormat('E, d MMM').format(date);
}

class _QuickStatsCard extends StatelessWidget {
  final List<Habit> habits;
  final Map<String, bool> completionState;
  const _QuickStatsCard({required this.habits, required this.completionState});

  @override
  Widget build(BuildContext context) {
    final completedToday = completionState.values.where((v) => v).length;
    return Container(
      padding: const EdgeInsets.all(AppStyles.md),
      decoration: AppStyles.cardContainerDecoration.copyWith(color: Theme.of(context).colorScheme.surfaceContainerHighest, boxShadow: [AppStyles.shadows[1]]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Today', '$completedToday/${habits.length} completed', Theme.of(context)),
          _buildStatItem('This Week', '18/25 completed', Theme.of(context)),
          _buildStatItem('Streaks', '3 active', Theme.of(context)),
        ],
      ),
    );
  }
  Widget _buildStatItem(String label, String value, ThemeData theme) => Column(
    children: [Text(value, style: AppTypography.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)), const SizedBox(height: AppStyles.xs), Text(label, style: AppTypography.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7)))],
  );
}
