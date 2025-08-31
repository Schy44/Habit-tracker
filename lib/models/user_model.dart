import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String userId;
  final String displayName;
  final String email;
  final String? gender;
  final Timestamp? dateOfBirth;
  final double? height;
  final Timestamp createdAt;
  final Timestamp updatedAt;
  final bool profileComplete;
  final Map<String, dynamic> preferences;

  UserModel({
    required this.userId,
    required this.displayName,
    required this.email,
    this.gender,
    this.dateOfBirth,
    this.height,
    required this.createdAt,
    required this.updatedAt,
    required this.profileComplete,
    required this.preferences,
  });

  // Factory constructor for creating a new UserModel object from a map
  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      userId: data['userId'] ?? '',
      displayName: data['displayName'] ?? '',
      email: data['email'] ?? '',
      gender: data['gender'],
      dateOfBirth: data['dateOfBirth'],
      height: (data['height'] as num?)?.toDouble(),
      createdAt: data['createdAt'] ?? Timestamp.now(),
      updatedAt: data['updatedAt'] ?? Timestamp.now(),
      profileComplete: data['profileComplete'] ?? false,
      preferences: data['preferences'] ?? {},
    );
  }

  // Method for converting a UserModel object to a map
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'displayName': displayName,
      'email': email,
      'gender': gender,
      'dateOfBirth': dateOfBirth,
      'height': height,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'profileComplete': profileComplete,
      'preferences': preferences,
    };
  }
}
