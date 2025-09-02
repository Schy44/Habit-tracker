import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mytracker/models/habit_model.dart';
import 'package:mytracker/services/firestore_service.dart';

class HabitService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirestoreService _firestoreService = FirestoreService();

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
    await _firestoreService.updateDocument(
        'users/${habit.userId}/habits', habit.id, habit.toMap());
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
      final habit = Habit.fromMap(habitDoc.data()!, habitDoc.id);
      List<Timestamp> completedDates = List<Timestamp>.from(habit.completedDates);
      final now = DateTime.now().toLocal();
      final todayMidnight = DateTime(now.year, now.month, now.day);

      if (isCompleted) {
        if (habit.frequency == 'Daily') {
          if (!completedDates.any((date) => _isSameDay(date.toDate(), todayMidnight))) {
            completedDates.add(Timestamp.fromDate(todayMidnight));
          }
        } else if (habit.frequency == 'Weekly') {
          final startOfWeek = todayMidnight.subtract(Duration(days: todayMidnight.weekday - 1));
          if (!completedDates.any((date) => date.toDate().isAfter(startOfWeek))) {
            completedDates.add(Timestamp.fromDate(todayMidnight));
          }
        }
      } else {
        if (habit.frequency == 'Daily') {
          completedDates.removeWhere((date) => _isSameDay(date.toDate(), todayMidnight));
        } else if (habit.frequency == 'Weekly') {
          final startOfWeek = todayMidnight.subtract(Duration(days: todayMidnight.weekday - 1));
          completedDates.removeWhere((date) => date.toDate().isAfter(startOfWeek));
        }
      }

      // Recalculate streaks
      final int newCurrentStreak = _calculateCurrentStreak(completedDates, habit.frequency);
      final int newBestStreak = _calculateBestStreak(completedDates, habit.frequency);

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

  int _calculateCurrentStreak(List<Timestamp> completedDates, String frequency) {
    if (completedDates.isEmpty) return 0;

    int currentStreak = 0;
    DateTime lastDate = DateTime.now().toLocal().copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);

    if (frequency == 'Daily') {
      if (completedDates.any((date) => _isSameDay(date.toDate(), lastDate))) {
        currentStreak = 1;
      } else {
        lastDate = lastDate.subtract(const Duration(days: 1));
        if (!completedDates.any((date) => _isSameDay(date.toDate(), lastDate))) {
          return 0;
        }
        currentStreak = 1;
      }

      for (int i = 1; i < completedDates.length + 1; i++) {
        final previousDay = lastDate.subtract(Duration(days: i));
        if (completedDates.any((date) => _isSameDay(date.toDate(), previousDay))) {
          currentStreak++;
        } else {
          break;
        }
      }
    } else if (frequency == 'Weekly') {
      final startOfWeek = lastDate.subtract(Duration(days: lastDate.weekday - 1));
      if (completedDates.any((date) => date.toDate().isAfter(startOfWeek))) {
        currentStreak = 1;
      } else {
        final startOfLastWeek = startOfWeek.subtract(const Duration(days: 7));
        if (!completedDates.any((date) => date.toDate().isAfter(startOfLastWeek) && date.toDate().isBefore(startOfWeek))) {
          return 0;
        }
        currentStreak = 1;
      }

      for (int i = 1; i < completedDates.length + 1; i++) {
        final startOfPreviousWeek = startOfWeek.subtract(Duration(days: 7 * i));
        final endOfPreviousWeek = startOfPreviousWeek.add(const Duration(days: 6));
        if (completedDates.any((date) => date.toDate().isAfter(startOfPreviousWeek) && date.toDate().isBefore(endOfPreviousWeek))) {
          currentStreak++;
        } else {
          break;
        }
      }
    }
    return currentStreak;
  }

  int _calculateBestStreak(List<Timestamp> completedDates, String frequency) {
    if (completedDates.isEmpty) return 0;

    int bestStreak = 0;
    int currentStreak = 0;

    final uniqueSortedDates = completedDates.toSet().toList();
    uniqueSortedDates.sort((a, b) => a.toDate().compareTo(b.toDate()));

    if (uniqueSortedDates.isEmpty) return 0;

    currentStreak = 1;
    bestStreak = 1;

    if (frequency == 'Daily') {
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
    } else if (frequency == 'Weekly') {
      for (int i = 1; i < uniqueSortedDates.length; i++) {
        final previousDate = uniqueSortedDates[i - 1].toDate();
        final currentDate = uniqueSortedDates[i].toDate();

        final startOfPreviousWeek = previousDate.subtract(Duration(days: previousDate.weekday - 1));
        final startOfCurrentWeek = currentDate.subtract(Duration(days: currentDate.weekday - 1));

        if (_isSameDay(startOfCurrentWeek, startOfPreviousWeek.add(const Duration(days: 7)))) {
          currentStreak++;
        } else if (!_isSameDay(startOfCurrentWeek, startOfPreviousWeek)) {
          currentStreak = 1;
        }
        if (currentStreak > bestStreak) {
          bestStreak = currentStreak;
        }
      }
    }

    return bestStreak;
  }
}
