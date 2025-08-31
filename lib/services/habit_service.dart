import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mytracker/models/habit_model.dart';

class HabitService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add a new habit
  Future<void> addHabit(Habit habit) async {
    await _firestore.collection('users').doc(habit.userId).collection('habits').doc(habit.id).set(habit.toMap());
  }

  // Get habits for a user
  Stream<List<Habit>> getHabits(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('habits')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Habit.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Update an existing habit
  Future<void> updateHabit(Habit habit) async {
    await _firestore.collection('users').doc(habit.userId).collection('habits').doc(habit.id).update(habit.toMap());
  }

  // Delete a habit
  Future<void> deleteHabit(String userId, String habitId) async {
    await _firestore.collection('users').doc(userId).collection('habits').doc(habitId).delete();
  }

  // Toggle habit completion and calculate streaks
  Future<void> toggleHabitCompletion(String userId, String habitId, bool isCompleted) async {
    final habitRef = _firestore.collection('users').doc(userId).collection('habits').doc(habitId);
    final habitDoc = await habitRef.get();

    if (habitDoc.exists) {
      List<Timestamp> completedDates = List<Timestamp>.from(habitDoc.data()?['completedDates'] ?? []);
      final now = DateTime.now().toLocal();
      final todayMidnight = now.copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);
      final yesterdayMidnight = todayMidnight.subtract(const Duration(days: 1));

      // Remove duplicates and sort dates
      completedDates = completedDates.toSet().toList();
      completedDates.sort((a, b) => a.toDate().compareTo(b.toDate()));

      if (isCompleted) {
        // Only allow marking completion for today or yesterday
        if (!_isSameDay(todayMidnight, now) && !_isSameDay(yesterdayMidnight, now)) {
          // This means the current time is not today or yesterday, so we don't allow marking completion
          // In a real app, you might throw an error or return false.
          return; 
        }

        // Add today's date if not already present
        if (!completedDates.any((date) => _isSameDay(date.toDate(), todayMidnight))) {
          completedDates.add(Timestamp.fromDate(todayMidnight));
        }
      } else {
        // Remove today's date if present
        completedDates.removeWhere((date) => _isSameDay(date.toDate(), todayMidnight));
      }

      // Recalculate streaks
      final int newCurrentStreak = _calculateCurrentStreak(completedDates);
      final int newBestStreak = _calculateBestStreak(completedDates);

      await habitRef.update({
        'completedDates': completedDates,
        'currentStreak': newCurrentStreak,
        'bestStreak': newBestStreak,
        'updatedAt': Timestamp.now(),
      });
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  int _calculateCurrentStreak(List<Timestamp> completedDates) {
    if (completedDates.isEmpty) return 0;

    int currentStreak = 0;
    DateTime lastDate = DateTime.now().toLocal().copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);

    // Check if today is completed
    if (completedDates.any((date) => _isSameDay(date.toDate(), lastDate))) {
      currentStreak = 1;
    } else {
      // If today is not completed, check if yesterday was completed
      lastDate = lastDate.subtract(const Duration(days: 1));
      if (!completedDates.any((date) => _isSameDay(date.toDate(), lastDate))) {
        return 0; // Streak broken if yesterday was not completed
      }
      currentStreak = 1; // Start streak from yesterday
    }

    // Iterate backwards from yesterday
    for (int i = 1; i < completedDates.length + 1; i++) {
      final previousDay = lastDate.subtract(Duration(days: i));
      if (completedDates.any((date) => _isSameDay(date.toDate(), previousDay))) {
        currentStreak++;
      } else {
        break; // Streak broken
      }
    }
    return currentStreak;
  }

  int _calculateBestStreak(List<Timestamp> completedDates) {
    if (completedDates.isEmpty) return 0;

    int bestStreak = 0;
    int currentStreak = 0;

    // Ensure dates are unique and sorted
    final uniqueSortedDates = completedDates.toSet().toList();
    uniqueSortedDates.sort((a, b) => a.toDate().compareTo(b.toDate()));

    if (uniqueSortedDates.isEmpty) return 0;

    currentStreak = 1;
    bestStreak = 1;

    for (int i = 1; i < uniqueSortedDates.length; i++) {
      final previousDate = uniqueSortedDates[i - 1].toDate();
      final currentDate = uniqueSortedDates[i].toDate();

      if (_isSameDay(currentDate, previousDate.add(const Duration(days: 1)))) {
        currentStreak++;
      } else {
        currentStreak = 1;
      }
      if (currentStreak > bestStreak) {
        bestStreak = currentStreak;
      }
    }

    // Edge case: if the last date is not today or yesterday, the current streak might not be the best
    // This logic is for historical best streak, not necessarily ending today.
    return bestStreak;
  }
}
