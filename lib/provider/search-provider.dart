// search_state.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SearchState extends ChangeNotifier {
  final TextEditingController searchController = TextEditingController();
  String _searchQuery = '';
  List<Map<String, dynamic>> _suggestedImages = [];
  bool _showSuggestions = false;

  // Getters
  String get searchQuery => _searchQuery;
  List<Map<String, dynamic>> get suggestedImages => _suggestedImages;
  bool get showSuggestions => _showSuggestions;

  Future<List<Map<String, dynamic>>> searchImages(String query) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('images')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff')
          .get();

      return querySnapshot.docs.map((doc) => {
        'name': doc['name'],
        'url': doc['url'],
        'isPro': doc['isPro'],
      }).toList();
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error searching images: $e');
      return [];
    }
  }

  void onSearchChanged(String query) async {
    if (query.isNotEmpty) {
      List<Map<String, dynamic>> results = await searchImages(query);
      _suggestedImages = results;
      _showSuggestions = true;
      notifyListeners();
    } else {
      _suggestedImages = [];
      _showSuggestions = false;
      notifyListeners();
    }
  }

  void performSearch() {
    _searchQuery = searchController.text.toLowerCase();
    _showSuggestions = false;
    notifyListeners();
  }

  void selectSuggestion(String name) {
    searchController.text = name;
    _searchQuery = name;
    _showSuggestions = false;
    notifyListeners();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}