import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Class to manage statistics data
class StatisticsData with ChangeNotifier {
  // List of selected languages
  List<String> _selectedLanguages = [];
  // Boolean to check if card face is flipped
  bool _isCardFaceFlipped = false;
  // Map to store learned cards
  Map<String, Set<String>> _learnedCards = {};

  // Getters for selected languages and card face status
  List<String> get selectedLanguages => _selectedLanguages;
  bool get isCardFaceFlipped => _isCardFaceFlipped;

  // Constructor
  StatisticsData() {
    loadLearnedCards();
  }

  // Method to load learned cards from shared preferences
  Future<void> loadLearnedCards() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? learnedCardsJson = prefs.getString('learnedCards');
    if (learnedCardsJson != null) {
      Map<String, dynamic> learnedCardsListMap = jsonDecode(learnedCardsJson);
      _learnedCards = learnedCardsListMap.map((key, value) => MapEntry(key, Set<String>.from(value)));
    }
    notifyListeners();
  }

  // Method to add a language to the selected languages list
  void addLanguage(String language) {
    _selectedLanguages.add(language);
    notifyListeners();
  }

  // Method to remove a language from the selected languages list
  void removeLanguage(String language) {
    _selectedLanguages.remove(language);
    notifyListeners();
  }

  // Method to toggle the card face status
  void toggleCardFaceFlipped([bool? newValue]) {
    _isCardFaceFlipped = newValue ?? !_isCardFaceFlipped;
    notifyListeners();
  }

  // Method to mark a card as learned
  Future<void> markCardAsLearned(String card, String language) async {
    _learnedCards.putIfAbsent(language, () => {});
    if (_learnedCards[language]!.length < 1000) {
      _learnedCards[language]?.add(card);
      // Convert learned cards to a map of lists before encoding to JSON
      Map<String, List<String>> learnedCardsListMap = _learnedCards.map((key, value) => MapEntry(key, value.toList()));
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('learnedCards', jsonEncode(learnedCardsListMap));
      notifyListeners();
    }
  }

  // Method to reset statistics
  Future<void> resetStatistics() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    for (String language in _selectedLanguages) {
      await prefs.remove('${language}_currentIndex');
      await prefs.remove('${language}_flashcards');
    }
    _selectedLanguages = [];
    _learnedCards = {};
    // Convert learned cards to a map of lists before encoding to JSON
    Map<String, List<String>> learnedCardsListMap = _learnedCards.map((key, value) => MapEntry(key, value.toList()));
    prefs.setString('learnedCards', jsonEncode(learnedCardsListMap));
    notifyListeners();
  }

  // Method to get the count of learned cards for a specific language
  int getLearnedCardsCount(String language) {
    return _learnedCards[language]?.length ?? 0;
  }

  // Method to check if a card is learned
  bool isCardLearned(String card, String language) {
    return _learnedCards.containsKey(language) && _learnedCards[language]!.contains(card);
  }
}