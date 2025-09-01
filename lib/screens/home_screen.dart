import 'package:another_carousel_pro/another_carousel_pro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mytracker/models/habit_model.dart';
import 'package:mytracker/models/quote_model.dart';
import 'package:mytracker/models/predefined_categories.dart';
import 'package:mytracker/providers/auth_provider.dart';
import 'package:mytracker/providers/habit_provider.dart';
import 'package:mytracker/providers/quote_provider.dart';
import 'package:mytracker/providers/theme_notifier.dart';
import 'package:mytracker/screens/habit_creation_screen.dart';

import 'package:mytracker/screens/favorites_screen.dart';
import 'package:mytracker/screens/statistics_screen.dart';

import 'package:mytracker/services/firestore_service.dart';
import 'package:mytracker/theme/app_colors.dart';
import 'package:mytracker/theme/app_styles.dart';
import 'package:mytracker/theme/app_typography.dart';
import 'package:mytracker/widgets/empty_state.dart';
import 'package:mytracker/widgets/category_pill.dart';
import 'package:mytracker/widgets/habit_card.dart';
import 'package:mytracker/widgets/habit_card_skeleton.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final Map<String, bool> _completionState = {};
  late AnimationController _greetingAnimationController;
  late AnimationController _cardAnimationController;
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideAnimation;
  final FirestoreService _firestoreService = FirestoreService();
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _greetingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _greetingAnimationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _cardAnimationController, curve: Curves.easeOutCubic));

    _greetingAnimationController.forward();
    _cardAnimationController.forward();
    Provider.of<QuoteProvider>(context, listen: false).fetchQuotes();
  }

  @override
  void dispose() {
    _greetingAnimationController.dispose();
    _cardAnimationController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final habits = Provider.of<HabitProvider>(context, listen: false).habits;
    for (var habit in habits) {
      _completionState.putIfAbsent(habit.id, () => habit.isCompletedToday());
    }
  }

  Future<void> _refreshHabitsAndQuotes() async {
    HapticFeedback.lightImpact();
    await Future.wait([
      Provider.of<HabitProvider>(context, listen: false).fetchHabits(),
      Provider.of<QuoteProvider>(context, listen: false).fetchQuotes(),
    ]);
  }

  void _onToggleCompletion(Habit habit, bool isCompleted) {
    final habitProvider = Provider.of<HabitProvider>(context, listen: false);
    setState(() => _completionState[habit.id] = isCompleted);
    HapticFeedback.mediumImpact();

    try {
      habitProvider.toggleHabitCompletion(habit.id, isCompleted);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isCompleted ? Icons.check_circle : Icons.cancel,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${habit.title} marked as ${isCompleted ? 'complete' : 'incomplete'}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: isCompleted ? AppColors.success : AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Undo',
            textColor: Colors.white,
            onPressed: () {
              setState(() => _completionState[habit.id] = !isCompleted);
              habitProvider.toggleHabitCompletion(habit.id, !isCompleted);
            },
          ),
        ),
      );
    } catch (e) {
      // Revert state if an error occurs
      setState(() => _completionState[habit.id] = !isCompleted);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final habitProvider = Provider.of<HabitProvider>(context);
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final user = authProvider.currentUser;
    final habits = habitProvider.habits.where((habit) {
      return _selectedCategory == null || habit.category == _selectedCategory;
    }).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: _refreshHabitsAndQuotes,
        color: AppColors.primary,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        strokeWidth: 2.5,
        displacement: 60,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildEnhancedAppBar(context, habitProvider, themeNotifier),
            SliverToBoxAdapter(
              child: AnimatedBuilder(
                animation: _fadeInAnimation,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeInAnimation,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildGreetingSection(user),
                          const SizedBox(height: 24),
                          SlideTransition(
                            position: _slideAnimation,
                            child: _EnhancedQuickStatsCard(
                              habits: habits,
                              completionState: _completionState,
                            ),
                          ),
                          const SizedBox(height: 32),
                          _buildSectionHeader("Today's Habits", habits.length),
                          const SizedBox(height: 16),
                          _buildCategoryFilter(),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            _buildEnhancedHabitList(habits, habitProvider),
            _buildEnhancedBottomSection(context),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
      floatingActionButton: _buildEnhancedFAB(context),
    );
  }

  Widget _buildCategoryFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filter by Category',
          style: AppTypography.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppStyles.sm),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              CategoryPill(
                name: 'All',
                isSelected: _selectedCategory == null,
                onTap: () {
                  setState(() {
                    _selectedCategory = null;
                  });
                },
              ),
              const SizedBox(width: AppStyles.sm),
              ...PredefinedCategories.categories.map((category) {
                return Padding(
                  padding: const EdgeInsets.only(right: AppStyles.sm),
                  child: CategoryPill(
                    name: category['name'],
                    isSelected: _selectedCategory == category['name'],
                    onTap: () {
                      setState(() {
                        _selectedCategory = category['name'];
                      });
                    },
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ],
    );
  }

  SliverAppBar _buildEnhancedAppBar(BuildContext context, HabitProvider habitProvider, ThemeNotifier themeNotifier) {
    return SliverAppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      pinned: true,
      elevation: 0,
      centerTitle: false,
      expandedHeight: 80,
      title: Text(
        'MyTracker',
        style: AppTypography.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      actions: [
        if (habitProvider.isLoading)
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          child: IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                themeNotifier.themeMode == ThemeMode.dark
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
                key: ValueKey(themeNotifier.themeMode),
              ),
            ),
            tooltip: 'Toggle Theme',
            onPressed: () {
              HapticFeedback.lightImpact();
              themeNotifier.toggleTheme();
            },
          ),
        ),
        IconButton(
          icon: const Icon(Icons.favorite_border_rounded),
          tooltip: 'Favorite Quotes',
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FavoritesScreen())),
        ),
        IconButton(
          icon: const Icon(Icons.settings_rounded),
          tooltip: 'Settings',
          onPressed: () => Navigator.pushNamed(context, '/settings'),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/profile'),
          child: Container(
            margin: const EdgeInsets.only(right: 20, top: 8, bottom: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const CircleAvatar(
              radius: 18,
              backgroundColor: Colors.transparent,
              child: Icon(Icons.person_rounded, color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGreetingSection(user) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_getGreetingEmoji()} ${_getGreeting()},',
                      style: AppTypography.textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      user?.displayName ?? 'Tracker',
                      style: AppTypography.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                _formatDate(DateTime.now()),
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _getMotivationalMessage(),
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTypography.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count habits',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedHabitList(List<Habit> habits, HabitProvider habitProvider) {
    if (habitProvider.isLoading && habits.isEmpty) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
                (c, i) => const HabitCardSkeleton(),
            childCount: 5,
          ),
        ),
      );
    }

    if (habits.isEmpty) {
      return const SliverFillRemaining(child: EmptyStateDisplay());
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            final habit = habits[index];
            final isCompleted = _completionState[habit.id] ?? false;

            return AnimatedContainer(
              duration: Duration(milliseconds: 300 + (index * 50)),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.only(bottom: 12),
              child: Dismissible(
                key: ValueKey(habit.id),
                background: _buildEnhancedSwipeBackground(context, isComplete: true),
                secondaryBackground: _buildEnhancedSwipeBackground(context, isComplete: false),
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.endToStart) {
                    // Delete action
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
                        await Provider.of<HabitProvider>(context, listen: false).deleteHabit(habit.id);
                        return true; // Dismiss the item
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error deleting habit: $e')),
                        );
                        return false; // Do not dismiss if error
                      }
                    }
                    return false; // Do not dismiss if not confirmed
                  } else {
                    // Complete action
                    _onToggleCompletion(habit, true); // Always true for startToEnd
                    return false; // Do not dismiss, state is handled by _onToggleCompletion
                  }
                },
                child: HabitCard(
                  habit: habit,
                  isCompleted: isCompleted,
                  onToggle: (value) => _onToggleCompletion(habit, value),
                ),
              ),
            );
          },
          childCount: habits.length,
        ),
      ),
    );
  }

  Widget _buildEnhancedSwipeBackground(BuildContext context, {required bool isComplete}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isComplete ? AppColors.success : AppColors.error,
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: isComplete
              ? [AppColors.success, AppColors.success.withOpacity(0.8)]
              : [AppColors.error, AppColors.error.withOpacity(0.8)],
          begin: isComplete ? Alignment.centerLeft : Alignment.centerRight,
          end: isComplete ? Alignment.centerRight : Alignment.centerLeft,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        alignment: isComplete ? Alignment.centerLeft : Alignment.centerRight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isComplete ? Icons.check_circle_rounded : Icons.delete_rounded,
              color: Colors.white,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              isComplete ? 'Complete' : 'Delete',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedBottomSection(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionButton(
                    context: context,
                    icon: Icons.bar_chart_rounded,
                    label: 'Statistics',
                    color: AppColors.secondary,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const StatisticsScreen()),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildQuotesSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuotesSection() {
    return Consumer<QuoteProvider>(
      builder: (context, quoteProvider, child) {
        debugPrint('Home Screen: Rebuilding _buildQuotesSection');
        debugPrint('Home Screen: isLoading: ${quoteProvider.isLoading}, quotes.isEmpty: ${quoteProvider.quotes.isEmpty}, errorMessage: ${quoteProvider.errorMessage}');

        if (quoteProvider.isLoading && quoteProvider.quotes.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (quoteProvider.errorMessage != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppStyles.md),
              child: Text(
                'Error loading quotes: ${quoteProvider.errorMessage}',
                textAlign: TextAlign.center,
                style: AppTypography.textTheme.bodyLarge?.copyWith(color: AppColors.error),
              ),
            ),
          );
        }

        if (quoteProvider.quotes.isEmpty) {
          return const Center(child: Text('No quotes available.'));
        }

        return SizedBox(
          height: 200,
          child: AnotherCarousel(
            images: quoteProvider.quotes.map((quote) => _buildQuoteCard(quote)).toList(),
            dotSize: 4,
            dotBgColor: Colors.transparent,
            dotPosition: DotPosition.bottomCenter,
            indicatorBgPadding: 8,
            animationDuration: const Duration(milliseconds: 800),
          ),
        );
      },
    );
  }

  Widget _buildQuoteCard(Quote quote) {
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.05),
            AppColors.secondary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.format_quote, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Daily Inspiration',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(
                  quote.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: AppColors.primary,
                ),
                onPressed: () async {
                  if (user != null) {
                    setState(() {
                      quote.isFavorite = !quote.isFavorite;
                    });
                    if (quote.isFavorite) {
                      await _firestoreService.addFavoriteQuote(user.uid, quote);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Added to favorites')),
                      );
                    } else {
                      await _firestoreService.removeFavoriteQuote(user.uid, quote.id);
                    }
                  }
                },
              ),
              IconButton(
                icon: Icon(Icons.copy, color: AppColors.primary, size: 20),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: '"${quote.content}" - ${quote.author}'));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Quote copied to clipboard!')),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                '"${quote.content}"',
                style: AppTypography.textTheme.bodyLarge?.copyWith(
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '— ${quote.author}',
            style: AppTypography.textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedFAB(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton(
        backgroundColor: Colors.transparent,
        elevation: 0,
        onPressed: () {
          HapticFeedback.mediumImpact();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HabitCreationScreen()),
          );
        },
        child: const Icon(Icons.add_rounded, size: 28, color: Colors.white),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    if (hour < 21) return 'Good evening';
    return 'Good night';
  }

  String _getGreetingEmoji() {
    final hour = DateTime.now().hour;
    if (hour < 12) return '🌅';
    if (hour < 17) return '☀️';
    if (hour < 21) return '🌆';
    return '🌙';
  }

  String _getMotivationalMessage() {
    final messages = [
      "Ready to build great habits today?",
      "Every small step counts!",
      "You're doing amazing, keep going!",
      "Consistency is the key to success",
      "Make today count!",
    ];
    return messages[DateTime.now().day % messages.length];
  }

  String _formatDate(DateTime date) => DateFormat('EEEE, MMM d').format(date);
}

class _EnhancedQuickStatsCard extends StatelessWidget {
  final List<Habit> habits;
  final Map<String, bool> completionState;

  const _EnhancedQuickStatsCard({
    required this.habits,
    required this.completionState,
  });

  @override
  Widget build(BuildContext context) {
    final completedToday = completionState.values.where((v) => v).length;
    final totalHabits = habits.length;
    final completionRate = totalHabits > 0 ? (completedToday / totalHabits) : 0.0;

    int completedThisWeek = 0;
    int totalDueThisWeek = 0;

    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    for (var habit in habits) {
      if (habit.frequency == 'Daily') {
        totalDueThisWeek += 7;
        for (int i = 0; i < 7; i++) {
          final dateToCheck = startOfWeek.add(Duration(days: i));
          if (habit.completedDates.any((completedDate) =>
              completedDate.toDate().year == dateToCheck.year &&
              completedDate.toDate().month == dateToCheck.month &&
              completedDate.toDate().day == dateToCheck.day)) {
            completedThisWeek++;
          }
        }
      } else if (habit.frequency == 'Weekly') {
        totalDueThisWeek += 1;
        if (habit.completedDates.any((completedDate) {
          final completedDay = completedDate.toDate();
          return completedDay.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
                 completedDay.isBefore(endOfWeek.add(const Duration(days: 1)));
        })) {
          completedThisWeek++;
        }
      }
    }

    final activeStreaks = habits.where((habit) => habit.currentStreak > 0).length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.dashboard_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Today\'s Progress',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getCompletionColor(completionRate).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${(completionRate * 100).toInt()}%',
                  style: TextStyle(
                    color: _getCompletionColor(completionRate),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: completionRate,
              backgroundColor: Colors.grey.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(_getCompletionColor(completionRate)),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildEnhancedStatItem(
                context,
                'Completed',
                '$completedToday/$totalHabits',
                Icons.check_circle_rounded,
                AppColors.success,
              ),
              _buildVerticalDivider(context),
              _buildEnhancedStatItem(
                context,
                'This Week',
                '$completedThisWeek/$totalDueThisWeek',
                Icons.calendar_today_rounded,
                AppColors.primary,
              ),
              _buildVerticalDivider(context),
              _buildEnhancedStatItem(
                context,
                'Streaks',
                '$activeStreaks active',
                Icons.local_fire_department_rounded,
                AppColors.warning,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedStatItem(
      BuildContext context,
      String label,
      String value,
      IconData icon,
      Color color,
      ) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTypography.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider(BuildContext context) {
    return Container(
      height: 40,
      width: 1,
      color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
    );
  }

  Color _getCompletionColor(double rate) {
    if (rate >= 0.8) return AppColors.success;
    if (rate >= 0.5) return AppColors.warning;
    return AppColors.error;
  }
}

