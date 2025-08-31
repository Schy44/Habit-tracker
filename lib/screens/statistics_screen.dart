import 'package:flutter/material.dart';
import 'package:mytracker/theme/app_colors.dart';
import 'package:mytracker/theme/app_styles.dart';
import 'package:mytracker/theme/app_typography.dart';
import 'package:mytracker/widgets/stat_card.dart';
import 'package:provider/provider.dart';
import 'package:mytracker/models/habit_model.dart';
import 'package:mytracker/providers/habit_provider.dart';

// --- Placeholder Data Models (kept for now as chart/achievements are static) ---
class _ChartDataPoint {
  final String label;
  final double value; // 0.0 to 1.0
  const _ChartDataPoint(this.label, this.value);
}

class _Achievement {
  final String title;
  final IconData icon;
  final bool unlocked;
  const _Achievement(this.title, this.icon, this.unlocked);
}

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  // --- Placeholder Data ---
  final List<_ChartDataPoint> _chartData = const [
    _ChartDataPoint('W1', 0.85),
    _ChartDataPoint('W2', 0.60),
    _ChartDataPoint('W3', 0.90),
    _ChartDataPoint('W4', 0.40),
    _ChartDataPoint('W5', 0.75),
    _ChartDataPoint('W6', 0.25),
  ];

  final List<_Achievement> _achievementsData = const [
    _Achievement('7-Day Streak', Icons.local_fire_department, true),
    _Achievement('Perfect Week', Icons.star, true),
    _Achievement('30-Day Challenge', Icons.calendar_month, false),
    _Achievement('Habit Master', Icons.military_tech, false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Progress'),
        actions: [IconButton(icon: const Icon(Icons.bar_chart), tooltip: 'View Charts', onPressed: () {})],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppStyles.md),
        child: Column(
          children: [
            _OverviewCard(),
            _StreakLeaderboardCard(),
            _MonthlyChartCard(data: _chartData),
            _AchievementsCard(achievements: _achievementsData),
          ],
        ),
      ),
    );
  }
}

// --- Section Widgets ---

class _OverviewCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<HabitProvider>(
      builder: (context, habitProvider, child) {
        final habits = habitProvider.habits;
        final activeHabits = habits.length;
        final completedToday = habits.where((h) => h.isCompletedToday()).length;

        return StatCard(
          title: '📈 Overview',
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.2,
            mainAxisSpacing: AppStyles.md,
            crossAxisSpacing: AppStyles.md,
            children: [
              _buildStatItem('Active Habits', activeHabits.toString()),
              _buildStatItem('Completed Today', '$completedToday/$activeHabits'),
              _buildStatItem('Weekly Completion', '78%'), // Placeholder
              _buildStatItem('Active Streaks', '3'), // Placeholder
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: AppTypography.textTheme.headlineMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
        const SizedBox(height: AppStyles.xs),
        Text(label, style: AppTypography.textTheme.bodyMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
      ],
    );
  }
}

class _StreakLeaderboardCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<HabitProvider>(
      builder: (context, habitProvider, child) {
        final habits = habitProvider.habits;
        final sortedHabits = List<Habit>.from(habits);
        sortedHabits.sort((a, b) => b.currentStreak.compareTo(a.currentStreak));

        // Limit to top 5 as per spec
        final topHabits = sortedHabits.take(5).toList();

        return StatCard(
          title: '🔥 Streak Leaderboard',
          child: Column(
            children: List.generate(topHabits.length, (index) {
              final habit = topHabits[index];
              return _LeaderboardTile(rank: index + 1, habit: habit);
            }),
          ),
        );
      },
    );
  }
}

class _MonthlyChartCard extends StatelessWidget {
  final List<_ChartDataPoint> data;
  const _MonthlyChartCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return StatCard(
      title: '📊 Monthly Chart',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Completion Rate', style: AppTypography.textTheme.labelLarge),
          const SizedBox(height: AppStyles.lg),
          SizedBox(
            height: 150,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: data.map((point) => _Bar(label: point.label, value: point.value)).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementsCard extends StatelessWidget {
  final List<_Achievement> achievements;
  const _AchievementsCard({required this.achievements});

  @override
  Widget build(BuildContext context) {
    return StatCard(
      title: '🏆 Achievements',
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2.5,
          crossAxisSpacing: AppStyles.sm,
          mainAxisSpacing: AppStyles.sm,
        ),
        itemCount: achievements.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return _AchievementBadge(achievement: achievements[index]);
        },
      ),
    );
  }
}

// --- Component Widgets ---

class _LeaderboardTile extends StatelessWidget {
  final int rank;
  final Habit habit;
  const _LeaderboardTile({required this.rank, required this.habit});

  @override
  Widget build(BuildContext context) {
    final icons = ['🥇', '🥈', '🥉'];
    final rankText = rank <= 3 ? icons[rank - 1] : '$rank️';
    final textStyle = rank <= 3 ? AppTypography.textTheme.titleMedium : AppTypography.textTheme.bodyLarge;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppStyles.xs),
      child: Row(
        children: [
          Text(rankText, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: AppStyles.md),
          Expanded(child: Text(habit.title, style: textStyle)),
          Text('🔥 ${habit.currentStreak} days', style: textStyle?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final String label;
  final double value;
  const _Bar({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: FractionallySizedBox(
            heightFactor: value,
            alignment: Alignment.bottomCenter,
            child: Container(
              width: 20,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppStyles.xs),
        Text(label, style: AppTypography.textTheme.bodySmall),
      ],
    );
  }
}

class _AchievementBadge extends StatelessWidget {
  final _Achievement achievement;
  const _AchievementBadge({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final color = achievement.unlocked ? AppColors.primary : AppColors.textHint;
    final icon = achievement.unlocked ? achievement.icon : Icons.lock;

    return Card(
      elevation: 0,
      color: color.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppStyles.borderRadiusMedium),
        side: BorderSide(color: color.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppStyles.sm),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: AppStyles.sm),
                Expanded(
                  child: Text(
                    achievement.title,
                    style: AppTypography.textTheme.labelLarge?.copyWith(color: color, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (!achievement.unlocked)
              Padding(
                padding: const EdgeInsets.only(top: AppStyles.xs),
                child: Text('Locked', style: AppTypography.textTheme.bodySmall?.copyWith(color: color)),
              ),
          ],
        ),
      ),
    );
  }
}