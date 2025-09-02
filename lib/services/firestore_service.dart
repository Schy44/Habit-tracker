import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mytracker/models/quote_model.dart';
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

  // Add a favorite quote for a user
  Future<void> addFavoriteQuote(String userId, Quote quote) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(quote.id)
        .set(quote.toJson());
  }

  // Remove a favorite quote for a user
  Future<void> removeFavoriteQuote(String userId, String quoteId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(quoteId)
        .delete();
  }

  // Get all favorite quotes for a user
  Stream<List<Quote>> getFavoriteQuotes(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Quote.fromJson(doc.data())).toList());
  }

  // Generic method to update a document in a specified collection
  Future<void> updateDocument(
      String collection, String docId, Map<String, dynamic> data) async {
    await _firestore.collection(collection).doc(docId).update(data);
  }
}
