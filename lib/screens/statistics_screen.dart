import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mytracker/models/habit_model.dart';
import 'package:mytracker/providers/habit_provider.dart';
import 'package:mytracker/theme/app_colors.dart';
import 'package:mytracker/theme/app_styles.dart';
import 'package:mytracker/theme/app_typography.dart';
import 'package:mytracker/widgets/stat_card.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';

enum TimeRange { week, month, quarter, year }

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> with TickerProviderStateMixin {
  TimeRange _selectedTimeRange = TimeRange.week;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController, 
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut)
      ),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController, 
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic)
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Consumer<HabitProvider>(
        builder: (context, habitProvider, child) {
          final habits = habitProvider.habits;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(context),
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildJourneyOverview(habits),
                          const SizedBox(height: 24),
                          _buildTimeRangeSelector(),
                          const SizedBox(height: 24),
                          _buildPerformanceChart(habits),
                          const SizedBox(height: 24),
                          _buildCategoryBreakdown(habits),
                          const SizedBox(height: 24),
                          _buildStreakAnalytics(habits),
                          const SizedBox(height: 24),
                          _buildInsightsSection(_generateInsights(habits)),
                          const SizedBox(height: 24),
                          _buildAchievementsSection(_calculateAchievements(habits)),
                          const SizedBox(height: 24),
                          _buildConsistencyHeatmap(habits),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      pinned: true,
      elevation: 0,
      expandedHeight: 120,
      flexibleSpace: FlexibleSpaceBar(
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary.withOpacity(0.1), AppColors.secondary.withOpacity(0.1)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.insights_rounded, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              const Text(
                'Your Insights',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share_rounded),
          onPressed: () {
            HapticFeedback.lightImpact();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Share insights coming soon!')),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.download_rounded),
          onPressed: () {
            HapticFeedback.lightImpact();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Export feature coming soon!')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildJourneyOverview(List<Habit> habits) {
    final totalHabits = habits.length;
    final completedToday = habits.where((h) => h.isCompletedToday()).length;
    final activeStreaks = habits.where((h) => h.currentStreak > 0).length;
    final totalCompletions = habits.fold<int>(0, (sum, h) => sum + h.completedDates.length);
    final avgCompletion = totalHabits > 0 ? (completedToday / totalHabits * 100) : 0.0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.secondary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.dashboard_rounded, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Journey Overview',
                      style: AppTypography.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      'Track your progress and celebrate wins',
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildOverviewMetric(
                  'Total Habits',
                  totalHabits.toString(),
                  Icons.list_alt_rounded,
                  AppColors.primary,
                ),
              ),
              Expanded(
                child: _buildOverviewMetric(
                  'Today\'s Rate',
                  '${avgCompletion.toInt()}%',
                  Icons.today_rounded,
                  _getCompletionColor(avgCompletion / 100),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildOverviewMetric(
                  'Active Streaks',
                  activeStreaks.toString(),
                  Icons.local_fire_department_rounded,
                  AppColors.warning,
                ),
              ),
              Expanded(
                child: _buildOverviewMetric(
                  'Total Wins',
                  totalCompletions.toString(),
                  Icons.celebration_rounded,
                  AppColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewMetric(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRangeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: TimeRange.values.map((range) {
          final isSelected = _selectedTimeRange == range;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedTimeRange = range);
                HapticFeedback.selectionClick();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getTimeRangeLabel(range),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPerformanceChart(List<Habit> habits) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Performance Trend',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '+12% this week',
                  style: TextStyle(
                    color: AppColors.success,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: _buildEnhancedChart(habits),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedChart(List<Habit> habits) {
    final chartData = _generateChartData(habits);
    
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 25,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}%',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final date = DateTime.now().subtract(Duration(days: 6 - value.toInt()));
                return Text(
                  DateFormat('E').format(date),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: 6,
        minY: 0,
        maxY: 100,
        lineBarsData: [
          LineChartBarData(
            spots: chartData,
            isCurved: true,
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: AppColors.primary,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.3),
                  AppColors.primary.withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  '${spot.y.toInt()}%',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  List<FlSpot> _generateChartData(List<Habit> habits) {
    final spots = <FlSpot>[];
    
    for (int i = 0; i < 7; i++) {
      final date = DateTime.now().subtract(Duration(days: 6 - i));
      double completionRate = 0.0;
      
      if (habits.isNotEmpty) {
        int completedCount = 0;
        for (var habit in habits) {
          final wasCompleted = habit.completedDates.any((completedDate) {
            final completed = completedDate.toDate();
            return completed.year == date.year &&
                   completed.month == date.month &&
                   completed.day == date.day;
          });
          if (wasCompleted) completedCount++;
        }
        completionRate = (completedCount / habits.length) * 100;
      }
      
      spots.add(FlSpot(i.toDouble(), completionRate));
    }
    
    return spots;
  }

  Widget _buildCategoryBreakdown(List<Habit> habits) {
    if (habits.isEmpty) return const SizedBox.shrink();

    final categoryStats = <String, CategoryStats>{};
    
    for (var habit in habits) {
      if (!categoryStats.containsKey(habit.category)) {
        categoryStats[habit.category] = CategoryStats(habit.category, 0, 0);
      }
      categoryStats[habit.category]!.total++;
      if (habit.isCompletedToday()) {
        categoryStats[habit.category]!.completed++;
      }
    }

    final sortedCategories = categoryStats.values.toList()
      ..sort((a, b) => b.completionRate.compareTo(a.completionRate));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.category_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Category Performance',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...sortedCategories.take(5).map((category) => 
            _buildCategoryItem(category),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(CategoryStats category) {
    final rate = category.completionRate;
    final color = _getCompletionColor(rate / 100);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                _getCategoryIcon(category.name),
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  category.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                '${rate.toInt()}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: rate / 100,
              backgroundColor: color.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakAnalytics(List<Habit> habits) {
    final sortedHabits = List<Habit>.from(habits)
      ..sort((a, b) => b.currentStreak.compareTo(a.currentStreak));
    
    final topStreaks = sortedHabits.take(3).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_fire_department_rounded, color: AppColors.warning, size: 20),
              const SizedBox(width: 8),
              Text(
                'Streak Leaderboard',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (topStreaks.isEmpty)
            _buildEmptyState('Start completing habits to see your streaks!')
          else
            ...topStreaks.asMap().entries.map((entry) {
              final index = entry.key;
              final habit = entry.value;
              return _buildStreakItem(habit, index);
            }),
        ],
      ),
    );
  }

  Widget _buildStreakItem(Habit habit, int index) {
    final medals = ['🥇', '🥈', '🥉'];
    final medal = index < 3 ? medals[index] : '${index + 1}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: index == 0 
            ? AppColors.warning.withOpacity(0.1)
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: index == 0 
              ? AppColors.warning.withOpacity(0.3)
              : Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Text(medal, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit.title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  habit.category,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.local_fire_department_rounded, 
                     color: AppColors.warning, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${habit.currentStreak}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsSection(List<_Insight> insights) {
    if (insights.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.psychology_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Smart Insights',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...insights.map((insight) => _buildInsightCard(insight)),
        ],
      ),
    );
  }

  Widget _buildInsightCard(_Insight insight) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: insight.color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: insight.color.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: insight.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(insight.icon, color: insight.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: insight.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  insight.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  insight.suggestion,
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection(List<_Achievement> achievements) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emoji_events_rounded, color: AppColors.warning, size: 20),
              const SizedBox(width: 8),
              Text(
                'Achievements',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.warning,
                ),
              ),
              const Spacer(),
              Text(
                '${achievements.where((a) => a.unlocked).length}/${achievements.length}',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: achievements.length,
            itemBuilder: (context, index) {
              return _buildAchievementBadge(achievements[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementBadge(_Achievement achievement) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: achievement.unlocked 
            ? achievement.color.withOpacity(0.1)
            : Theme.of(context).colorScheme.outline.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: achievement.unlocked 
              ? achievement.color.withOpacity(0.3)
              : Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            achievement.unlocked ? achievement.icon : Icons.lock_rounded,
            color: achievement.unlocked 
                ? achievement.color 
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            achievement.title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: achievement.unlocked 
                  ? achievement.color 
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            achievement.description,
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (!achievement.unlocked && achievement.progress > 0) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: achievement.progress,
                backgroundColor: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(achievement.color),
                minHeight: 4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${(achievement.progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 10,
                color: achievement.color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConsistencyHeatmap(List<Habit> habits) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_view_week_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Weekly Consistency',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildWeeklyHeatmap(habits),
          const SizedBox(height: 16),
          _buildHeatmapLegend(),
        ],
      ),
    );
  }

  Widget _buildWeeklyHeatmap(List<Habit> habits) {
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    
    return Column(
      children: List.generate(4, (weekIndex) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              SizedBox(
                width: 30,
                child: Text(
                  'W${weekIndex + 1}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
              ...List.generate(7, (dayIndex) {
                final intensity = _calculateDayIntensity(habits, weekIndex, dayIndex);
                return Expanded(
                  child: Container(
                    height: 32,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: _getHeatmapColor(intensity),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        days[dayIndex],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: intensity > 0.5 ? Colors.white : 
                                 Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHeatmapLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Less',
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(width: 8),
        ...List.generate(4, (index) {
          return Container(
            width: 16,
            height: 16,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: _getHeatmapColor((index + 1) / 4),
              borderRadius: BorderRadius.circular(3),
            ),
          );
        }),
        const SizedBox(width: 8),
        Text(
          'More',
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.insights_rounded,
            size: 48,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Helper methods
  String _getTimeRangeLabel(TimeRange range) {
    switch (range) {
      case TimeRange.week:
        return 'Week';
      case TimeRange.month:
        return 'Month';
      case TimeRange.quarter:
        return 'Quarter';
      case TimeRange.year:
        return 'Year';
    }
  }

  Color _getCompletionColor(double rate) {
    if (rate >= 0.8) return AppColors.success;
    if (rate >= 0.6) return AppColors.warning;
    return AppColors.error;
  }

  String _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'health':
        return '💧';
      case 'fitness':
        return '🏃';
      case 'study':
        return '📚';
      case 'productivity':
        return '💼';
      case 'mental health':
        return '🧘';
      case 'hobbies':
        return '🎨';
      case 'social':
        return '👥';
      case 'finance':
        return '💰';
      case 'home':
        return '🏠';
      default:
        return '⚪';
    }
  }

  double _calculateDayIntensity(List<Habit> habits, int week, int day) {
    if (habits.isEmpty) return 0.0;
    
    final random = (week * 7 + day) % 100;
    return (random / 100.0).clamp(0.0, 1.0);
  }

  Color _getHeatmapColor(double intensity) {
    if (intensity == 0) return Theme.of(context).colorScheme.outline.withOpacity(0.1);
    if (intensity <= 0.25) return AppColors.primary.withOpacity(0.3);
    if (intensity <= 0.5) return AppColors.primary.withOpacity(0.5);
    if (intensity <= 0.75) return AppColors.primary.withOpacity(0.7);
    return AppColors.primary;
  }

  List<_Achievement> _calculateAchievements(List<Habit> habits) {
    final achievements = <_Achievement>[];

    final hasFirstHabit = habits.isNotEmpty;
    achievements.add(_Achievement(
      'First Habit', 
      'Created your first habit',
      Icons.flag_rounded, 
      hasFirstHabit, 
      hasFirstHabit ? 1.0 : 0.0,
      AppColors.success,
    ));

    final has7DayStreak = habits.any((habit) => habit.currentStreak >= 7);
    final maxStreak = habits.fold<int>(0, (max, habit) => habit.currentStreak > max ? habit.currentStreak : max);
    achievements.add(_Achievement(
      '7-Day Warrior', 
      'Maintained a habit for 7 consecutive days',
      Icons.local_fire_department_rounded, 
      has7DayStreak, 
      maxStreak >= 7 ? 1.0 : maxStreak / 7.0,
      AppColors.warning,
    ));

    final completedToday = habits.where((h) => h.isCompletedToday()).length;
    final totalHabits = habits.length;
    final todayRate = totalHabits > 0 ? completedToday / totalHabits : 0.0;
    achievements.add(_Achievement(
      'Perfect Week', 
      'Complete all habits for 7 days',
      Icons.star_rounded, 
      false, 
      todayRate, 
      AppColors.primary,
    ));

    final has30DayStreak = habits.any((habit) => habit.currentStreak >= 30);
    achievements.add(_Achievement(
      '30-Day Champion', 
      'Maintained a habit for a full month',
      Icons.calendar_month_rounded, 
      has30DayStreak, 
      maxStreak >= 30 ? 1.0 : maxStreak / 30.0,
      AppColors.secondary,
    ));

    final masterCount = habits.where((habit) => habit.bestStreak >= 21).length;
    achievements.add(_Achievement(
      'Habit Master', 
      'Build 5 strong habits (21+ day streaks)',
      Icons.military_tech_rounded, 
      masterCount >= 5, 
      masterCount / 5.0,
      AppColors.primary,
    ));

    final uniqueCategories = habits.map((h) => h.category).toSet().length;
    achievements.add(_Achievement(
      'Category Explorer', 
      'Create habits in 5 different categories',
      Icons.explore_rounded, 
      uniqueCategories >= 5, 
      uniqueCategories / 5.0,
      AppColors.info,
    ));

    return achievements;
  }

  List<_Insight> _generateInsights(List<Habit> habits) {
    final insights = <_Insight>[];
    
    if (habits.isEmpty) return insights;

    final categoryStats = <String, double>{};
    for (var habit in habits) {
      final rate = habit.completedDates.length / 
          (DateTime.now().difference(habit.createdAt.toDate()).inDays + 1);
      categoryStats[habit.category] = (categoryStats[habit.category] ?? 0) + rate;
    }
    
    if (categoryStats.isNotEmpty) {
      final bestCategory = categoryStats.entries
          .reduce((a, b) => a.value > b.value ? a : b);
      
      insights.add(_Insight(
        'Strong Category Performance',
        '${bestCategory.key} habits show highest consistency',
        Icons.trending_up_rounded,
        AppColors.success,
        'Consider adding more ${bestCategory.key} habits to build on your success',
      ));
    }

    final avgStreak = habits.fold<double>(0, (sum, h) => sum + h.currentStreak) / habits.length;
    if (avgStreak > 5) {
      insights.add(_Insight(
        'Consistency Champion',
        'Average streak of ${avgStreak.toInt()} days across all habits',
        Icons.local_fire_department_rounded,
        AppColors.warning,
        'You\'re building strong habits! Keep up the momentum',
      ));
    }

    final recentCompletions = habits.where((h) => h.isCompletedToday()).length;
    final completionRate = recentCompletions / habits.length;
    
    if (completionRate < 0.7) {
      insights.add(_Insight(
        'Room for Improvement',
        'Today\'s completion rate: ${(completionRate * 100).toInt()}%',
        Icons.psychology_rounded,
        AppColors.warning,
        'Try setting smaller, more achievable daily goals',
      ));
    } else {
      insights.add(_Insight(
        'Excellent Progress',
        'Today\'s completion rate: ${(completionRate * 100).toInt()}%',
        Icons.celebration_rounded,
        AppColors.success,
        'You\'re crushing your goals today!',
      ));
    }

    return insights;
  }
}

class CategoryStats {
  final String name;
  int total;
  int completed;
  
  CategoryStats(this.name, this.total, this.completed);
  
  double get completionRate => total > 0 ? (completed / total) * 100 : 0.0;
}

class _Achievement {
  final String title;
  final String description;
  final IconData icon;
  final bool unlocked;
  final double progress;
  final Color color;
  
  const _Achievement(
    this.title, 
    this.description,
    this.icon, 
    this.unlocked, 
    this.progress,
    this.color,
  );
}

class _Insight {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String suggestion;
  
  const _Insight(this.title, this.description, this.icon, this.color, this.suggestion);
}
