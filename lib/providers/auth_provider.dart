import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mytracker/services/auth_service.dart';
import 'package:mytracker/services/firestore_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // Form fields for Sign Up
  String _signUpDisplayName = '';
  String _signUpEmail = '';
  String _signUpPassword = '';
  String _signUpConfirmPassword = '';
  bool _termsAccepted = false;
  String? _signUpGender;
  DateTime? _signUpDateOfBirth;
  double? _signUpHeight;
  String? _signUpHeightUnit;
  final List<String> _signUpGoalPreferences = [];

  // Form fields for Login
  String _loginEmail = '';
  String _loginPassword = '';
  bool _rememberMe = false;

  // Validation errors
  Map<String, String> _validationErrors = {};

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String get signUpDisplayName => _signUpDisplayName;
  String get signUpEmail => _signUpEmail;
  String get signUpPassword => _signUpPassword;
  String get signUpConfirmPassword => _signUpConfirmPassword;
  bool get termsAccepted => _termsAccepted;
  String? get signUpGender => _signUpGender;
  DateTime? get signUpDateOfBirth => _signUpDateOfBirth;
  double? get signUpHeight => _signUpHeight;
  String? get signUpHeightUnit => _signUpHeightUnit;
  List<String> get signUpGoalPreferences => _signUpGoalPreferences;

  String get loginEmail => _loginEmail;
  String get loginPassword => _loginPassword;
  bool get rememberMe => _rememberMe;

  Map<String, String> get validationErrors => _validationErrors;

  AuthProvider() {
    _currentUser = _authService.getCurrentUser();
    _loadRememberMePreference();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearValidationErrors() {
    _validationErrors = {};
    notifyListeners();
  }

  // --- Sign Up Form Setters ---
  void setSignUpDisplayName(String value) {
    _signUpDisplayName = value;
    _validateSignUpDisplayName(value);
    notifyListeners();
  }

  void setSignUpEmail(String value) {
    _signUpEmail = value;
    _validateEmail(value);
    notifyListeners();
  }

  void setSignUpPassword(String value) {
    _signUpPassword = value;
    _validatePassword(value);
    notifyListeners();
  }

  void setSignUpConfirmPassword(String value) {
    _signUpConfirmPassword = value;
    _validateConfirmPassword(value);
    notifyListeners();
  }

  void setTermsAccepted(bool value) {
    _termsAccepted = value;
    _validateTermsAccepted(value);
    notifyListeners();
  }

  void setSignUpGender(String? value) {
    _signUpGender = value;
    notifyListeners();
  }

  void setSignUpDateOfBirth(DateTime? value) {
    _signUpDateOfBirth = value;
    notifyListeners();
  }

  void setSignUpHeight(double? value) {
    _signUpHeight = value;
    notifyListeners();
  }

  void setSignUpHeightUnit(String? value) {
    _signUpHeightUnit = value;
    notifyListeners();
  }

  void setSignUpGoalPreference(String goal, bool isSelected) {
    if (isSelected) {
      _signUpGoalPreferences.add(goal);
    } else {
      _signUpGoalPreferences.remove(goal);
    }
    notifyListeners();
  }

  // --- Login Form Setters ---
  void setLoginEmail(String value) {
    _loginEmail = value;
    _validateEmail(value);
    notifyListeners();
  }

  void setLoginPassword(String value) {
    _loginPassword = value;
    _validateLoginPassword(value);
    notifyListeners();
  }

  void setRememberMe(bool value) {
    _rememberMe = value;
    _saveRememberMePreference(value);
    notifyListeners();
  }

  // --- Validation Methods ---
  bool _validateSignUpDisplayName(String value) {
    if (value.isEmpty) {
      _validationErrors['displayName'] = 'Display name is required';
      return false;
    }
    _validationErrors.remove('displayName');
    return true;
  }

  bool _validateEmail(String value) {
    if (value.isEmpty) {
      _validationErrors['email'] = 'Email is required';
      return false;
    }
    _validationErrors.remove('email');
    return true;
  }

  bool _validatePassword(String value) {
    if (value.isEmpty) {
      _validationErrors['password'] = 'Password is required';
      return false;
    }
    _validationErrors.remove('password');
    return true;
  }

  bool _validateConfirmPassword(String value) {
    if (value.isEmpty) {
      _validationErrors['confirmPassword'] = 'Confirm password is required';
      return false;
    }
    _validationErrors.remove('confirmPassword');
    return true;
  }

  bool _validateTermsAccepted(bool value) {
    if (!value) {
      _validationErrors['terms'] = 'You must accept the terms and conditions';
      return false;
    }
    _validationErrors.remove('terms');
    return true;
  }

  bool _validateLoginPassword(String value) {
    if (value.isEmpty) {
      _validationErrors['password'] = 'Password is required';
      return false;
    }
    _validationErrors.remove('password');
    return true;
  }

  bool validateSignUpForm() {
    _clearValidationErrors();
    bool isValid = true;
    isValid = _validateSignUpDisplayName(_signUpDisplayName) && isValid;
    isValid = _validateEmail(_signUpEmail) && isValid;
    isValid = _validatePassword(_signUpPassword) && isValid;
    isValid = _validateConfirmPassword(_signUpConfirmPassword) && isValid;
    isValid = _validateTermsAccepted(_termsAccepted) && isValid;
    return isValid;
  }

  bool validateLoginForm() {
    _clearValidationErrors();
    bool isValid = true;
    isValid = _validateEmail(_loginEmail) && isValid;
    isValid = _validateLoginPassword(_loginPassword) && isValid;
    return isValid;
  }

  // --- Authentication Methods ---
  Future<void> signUp() async {
    _setLoading(true);
    _setErrorMessage(null);
    if (!validateSignUpForm()) {
      _setLoading(false);
      return;
    }
    try {
      await _authService.signUpWithEmailAndPassword(
          _signUpEmail, _signUpPassword, _signUpDisplayName);
      _currentUser = _authService.getCurrentUser();

      Map<String, dynamic> userData = {
        'userId': _currentUser!.uid,
        'displayName': _signUpDisplayName,
        'email': _signUpEmail,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
        'profileComplete': true,
        'preferences': {'notifications': true, 'darkMode': false},
      };

      if (_signUpGender != null) {
        userData['gender'] = _signUpGender;
      }
      if (_signUpDateOfBirth != null) {
        userData['dateOfBirth'] = Timestamp.fromDate(_signUpDateOfBirth!);
      }
      if (_signUpHeight != null) {
        userData['height'] = _signUpHeight;
      }
      if (_signUpHeightUnit != null) {
        userData['heightUnit'] = _signUpHeightUnit;
      }
      if (_signUpGoalPreferences.isNotEmpty) {
        userData['goalPreferences'] = _signUpGoalPreferences;
      }

      await _firestoreService.updateUser(
        _currentUser!.uid,
        userData,
      );
    } on Exception catch (e) {
      _setErrorMessage(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signIn() async {
    _setLoading(true);
    _setErrorMessage(null);
    if (!validateLoginForm()) {
      _setLoading(false);
      return;
    }
    try {
      await _authService.signInWithEmailAndPassword(
          _loginEmail, _loginPassword);
      _currentUser = _authService.getCurrentUser();
    } on Exception catch (e) {
      _setErrorMessage(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      await _authService.signOut();
      _currentUser = null;
    } on Exception catch (e) {
      _setErrorMessage(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateUserProfile(String userId, Map<String, dynamic> userData) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      await _firestoreService.updateUser(userId, userData);
    } on Exception catch (e) {
      _setErrorMessage(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // --- Shared Preferences for Remember Me ---
  Future<void> _saveRememberMePreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('rememberMe', value);
  }

  Future<void> _loadRememberMePreference() async {
    final prefs = await SharedPreferences.getInstance();
    _rememberMe = prefs.getBool('rememberMe') ?? false;
    notifyListeners();
  }
}