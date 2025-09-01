import 'package:flutter/material.dart';
import 'package:mytracker/models/quote_model.dart';
import 'package:mytracker/services/quote_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QuoteProvider extends ChangeNotifier {
  final QuoteService _quoteService = QuoteService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Quote> _quotes = [];
  List<Quote> _favoriteQuotes = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Quote> get quotes => _quotes;
  List<Quote> get favoriteQuotes => _favoriteQuotes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchQuotes() async {
    debugPrint('QuoteProvider: fetchQuotes called');
    _isLoading = true;
    _errorMessage = null; // Clear previous errors
    notifyListeners();

    try {
      _quotes = await _quoteService.getQuotes();
      debugPrint('QuoteProvider: Quotes fetched successfully. Count: ${_quotes.length}');
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('QuoteProvider: Error fetching quotes: $_errorMessage');
    } finally {
      _isLoading = false;
      debugPrint('QuoteProvider: isLoading set to false. Notifying listeners.');
      notifyListeners();
    }
  }

  Future<void> addFavoriteQuote(String userId, Quote quote) async {
    try {
      await _quoteService.addFavoriteQuote(userId, quote);
      // Optionally, update local favoriteQuotes list if needed
      // _favoriteQuotes.add(quote); // This might cause duplicates if not handled carefully
      // notifyListeners();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> removeFavoriteQuote(String userId, String quoteId) async {
    try {
      await _quoteService.removeFavoriteQuote(userId, quoteId);
      _favoriteQuotes.removeWhere((quote) => quote.id == quoteId);
      notifyListeners();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> fetchFavoriteQuotes() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = _auth.currentUser;
      if (user != null) {
        _favoriteQuotes = await _quoteService.getFavoriteQuotes(user.uid);
      }
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
