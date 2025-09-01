import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mytracker/models/quote_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // Import for debugPrint

class QuoteService {
  final String _baseUrl = 'https://dummyjson.com/quotes';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Quote>> getQuotes({int limit = 5}) async {
    try {
      debugPrint('Fetching quotes from: $_baseUrl');
      final response = await http.get(Uri.parse(_baseUrl));

      debugPrint('Response status code: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> quotesData = data['quotes'];
        debugPrint('Parsed data length: ${quotesData.length}');

        // Randomize and take 'limit' number of quotes from the fetched data
        quotesData.shuffle();
        final List<Quote> quotes = quotesData.take(limit).map((json) => Quote.fromJson(json)).toList();
        debugPrint('Number of quotes after mapping and limiting: ${quotes.length}');
        return quotes;
      } else {
        throw Exception('Failed to load quotes: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching quotes: $e');
      throw Exception('Failed to connect to the server: $e');
    }
  }

  Future<void> addFavoriteQuote(String userId, Quote quote) async {
    try {
      debugPrint('Adding favorite quote with ID: ${quote.id}');
      await _firestore.collection('users').doc(userId).collection('favorites').doc(quote.id).set(quote.toJson());
      debugPrint('Favorite quote added successfully.');
    } catch (e) {
      debugPrint('Error adding favorite quote: $e');
    }
  }

  Future<void> removeFavoriteQuote(String userId, String quoteId) async {
    try {
      debugPrint('Removing favorite quote: $quoteId for user: $userId');
      await _firestore.collection('users').doc(userId).collection('favorites').doc(quoteId).delete();
      debugPrint('Favorite quote removed successfully.');
    } catch (e) {
      debugPrint('Error removing favorite quote: $e');
    }
  }

  Future<List<Quote>> getFavoriteQuotes(String userId) async {
    try {
      debugPrint('Fetching favorite quotes for user: $userId');
      final snapshot = await _firestore.collection('users').doc(userId).collection('favorites').get();
      debugPrint('Favorite quotes snapshot length: ${snapshot.docs.length}');
      return snapshot.docs.map((doc) => Quote.fromJson(doc.data())).toList();
    } catch (e) {
      debugPrint('Error fetching favorite quotes: $e');
      return [];
    }
  }
}