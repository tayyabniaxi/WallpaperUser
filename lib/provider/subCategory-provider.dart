import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class SubcategoryViewModel extends ChangeNotifier {
  List<String> _currentImageUrls = [];
  String _selectedSubcategory = '';
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  int _currentPage = 0;
  final int _itemsPerPage = 4;
  String? _errorMessage;
  List<String>? _newImages;

  // Getters
  List<String> get currentImageUrls => _currentImageUrls;
  String get selectedSubcategory => _selectedSubcategory;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMoreData => _hasMoreData;
  String? get errorMessage => _errorMessage;
  List<String>? get newImages => _newImages;
  bool get isLoading => _isLoadingMore && _currentImageUrls.isEmpty;

  // Initialize the view model with category
  void initialize(String initialSubcategory, String category) {
    _selectedSubcategory = initialSubcategory;
    loadMoreImages(category);
  }

  // Update selected subcategory
  void updateSelectedSubcategory(String subcategory, String category) {
    _selectedSubcategory = subcategory;
    _resetPagination();
    notifyListeners();
    loadMoreImages(category);
  }

  // Reset pagination variables
  void _resetPagination() {
    _currentPage = 0;
    _hasMoreData = true;
    _currentImageUrls = [];
  }

  // Load more images
  Future<void> loadMoreImages(String category) async {
    if (_isLoadingMore || !_hasMoreData) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      _newImages = await _fetchSubcategoryImages(
        category,
        _selectedSubcategory,
        _currentPage,
        _itemsPerPage,
      );

      if (_newImages?.isEmpty ?? true) {
        _hasMoreData = false;
      } else {
        _currentImageUrls.addAll(_newImages!);
        _currentPage++;
      }

      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Error loading images: $e';
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // Fetch subcategory images from Firestore
  Future<List<String>> _fetchSubcategoryImages(
    String category,
    String subcategory,
    int page,
    int limit,
  ) async {
    final doc = await FirebaseFirestore.instance
        .collection('categories')
        .doc(category)
        .collection('subcategories')
        .doc(subcategory)
        .get();

    if (doc.exists) {
      List<dynamic> imagesData = doc.data()?['images'] ?? [];

      int startIndex = page * limit;

      List<String> newImageUrls = imagesData
          .skip(startIndex)
          .take(limit)
          .where((imageMap) =>
              imageMap is Map<String, dynamic> &&
              imageMap.containsKey('url') &&
              imageMap['url'] is String)
          .map<String>((imageMap) => imageMap['url'] as String)
          .toList();

      return newImageUrls;
    }

    return [];
  }

  // Clear state when disposing
  @override
  void dispose() {
    _currentImageUrls = [];
    _errorMessage = null;
    super.dispose();
  }
}