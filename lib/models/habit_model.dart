import 'package:cloud_firestore/cloud_firestore.dart';

class Habit {
  final String id;
  final String userId;
  final String title;
  final String category;
  final String frequency;
  final Timestamp? startDate;
  final String? reminderTime;
  final String? targetGoal;
  final String? notes;
  final Timestamp createdAt;
  final Timestamp updatedAt;
  final List<Timestamp> completedDates;
  final int currentStreak;
  final int bestStreak;
  final bool isArchived;

  Habit({
    required this.id,
    required this.userId,
    required this.title,
    required this.category,
    required this.frequency,
    this.startDate,
    this.reminderTime,
    this.targetGoal,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.completedDates,
    required this.currentStreak,
    required this.bestStreak,
    required this.isArchived,
  });

  // Factory constructor for creating a Habit object from a Firestore document
  factory Habit.fromMap(Map<String, dynamic> data, String documentId) {
    return Habit(
      id: documentId,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      category: data['category'] ?? '',
      frequency: data['frequency'] ?? '',
      startDate: data['startDate'] as Timestamp?,
      reminderTime: data['reminderTime'] as String?,
      targetGoal: data['targetGoal'] as String?,
      notes: data['notes'] as String?,
      createdAt: data['createdAt'] as Timestamp? ?? Timestamp.now(),
      updatedAt: data['updatedAt'] as Timestamp? ?? Timestamp.now(),
      completedDates: (data['completedDates'] as List<dynamic>?)
              ?.map((e) => e as Timestamp)
              .toList() ??
          [],
      currentStreak: data['currentStreak'] ?? 0,
      bestStreak: data['bestStreak'] ?? 0,
      isArchived: data['isArchived'] ?? false,
    );
  }

  // Method for converting a Habit object to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'category': category,
      'frequency': frequency,
      'startDate': startDate,
      'reminderTime': reminderTime,
      'targetGoal': targetGoal,
      'notes': notes,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'completedDates': completedDates,
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'isArchived': isArchived,
    };
  }

  // Check if the habit was completed today
  bool isCompletedToday() {
    if (completedDates.isEmpty) return false;
    final now = DateTime.now();
    final lastCompleted = completedDates.last.toDate(); // Assuming last entry is most recent
    return now.year == lastCompleted.year &&
           now.month == lastCompleted.month &&
           now.day == lastCompleted.day;
  }

  // Create a copy of the Habit object with updated fields
  Habit copyWith({
    String? id,
    String? userId,
    String? title,
    String? category,
    String? frequency,
    Timestamp? startDate,
    String? reminderTime,
    String? targetGoal,
    String? notes,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    List<Timestamp>? completedDates,
    int? currentStreak,
    int? bestStreak,
    bool? isArchived,
  }) {
    return Habit(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      category: category ?? this.category,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      reminderTime: reminderTime ?? this.reminderTime,
      targetGoal: targetGoal ?? this.targetGoal,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedDates: completedDates ?? this.completedDates,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      isArchived: isArchived ?? this.isArchived,
    );
  }
}
