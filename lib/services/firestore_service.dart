import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mytracker/models/user_model.dart';

class FirestoreService {
  // Singleton instance
  static final FirestoreService _instance = FirestoreService._internal();

  // Factory constructor to return the same instance
  factory FirestoreService() {
    return _instance;
  }

  // Private constructor
  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get user document by ID
  Stream<UserModel> getUser(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().map(
        (snapshot) => UserModel.fromMap(snapshot.data()!));
  }

  // Update user document
  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(userId).update(data);
  }
}