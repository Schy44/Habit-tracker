import 'package:flutter/material.dart';
import 'package:mytracker/models/habit_model.dart';
import 'package:mytracker/services/habit_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HabitProvider with ChangeNotifier {
  final HabitService _habitService = HabitService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Habit> _habits = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Habit> get habits => _habits;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  HabitProvider() {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _listenToHabits(user.uid);
      } else {
        _habits = [];
        notifyListeners();
      }
    });
  }

  void _listenToHabits(String userId) {
    _isLoading = true;
    notifyListeners();
    _habitService.getHabits(userId).listen((habits) {
      _habits = habits;
      _isLoading = false;
      notifyListeners();
    }, onError: (error) {
      _errorMessage = error.toString();
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> fetchHabits() async {
    if (_auth.currentUser != null) {
      _listenToHabits(_auth.currentUser!.uid);
    } else {
      // If no user is logged in, clear habits and stop loading
      _habits = [];
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addHabit(Habit habit) async {
    print('[HabitProvider] addHabit called with habit: ${habit.toMap()}');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      if (_auth.currentUser == null) {
        print('[HabitProvider] Error: User not logged in.');
        throw Exception('User not logged in.');
      }
      // Ensure habit has a userId before adding to Firestore
      final habitWithUserId = habit.copyWith(userId: _auth.currentUser!.uid);
      print('[HabitProvider] Adding habit to service: ${habitWithUserId.toMap()}');
      await _habitService.addHabit(habitWithUserId);
      print('[HabitProvider] Habit added successfully to service.');
    } on Exception catch (e) {
      _errorMessage = e.toString();
      print('[HabitProvider] Error adding habit: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateHabit(Habit habit) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      if (_auth.currentUser == null) {
        throw Exception('User not logged in.');
      }
      await _habitService.updateHabit(habit);
    } on Exception catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteHabit(String habitId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      if (_auth.currentUser == null) {
        throw Exception('User not logged in.');
      }
      await _habitService.deleteHabit(_auth.currentUser!.uid, habitId);
    } on Exception catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleHabitCompletion(String habitId, bool isCompleted) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      if (_auth.currentUser == null) {
        throw Exception('User not logged in.');
      }
      await _habitService.toggleHabitCompletion(_auth.currentUser!.uid, habitId, isCompleted);
    } on Exception catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
