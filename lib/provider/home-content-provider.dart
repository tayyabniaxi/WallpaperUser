// // home_state.dart
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class HomeState extends ChangeNotifier {
//   final FirebaseFirestore firestore = FirebaseFirestore.instance;
//   final ScrollController scrollController = ScrollController();
//   final int pageSize = 6;

//   String _selectedCategory = 'Popular';
//   List<String> _currentImages = [];
//   bool _isLoading = false;
//   bool _hasMore = true;
//   final Map<String, List<String>> _cachedImages = {};

//   // Getters
//   String get selectedCategory => _selectedCategory;
//   List<String> get currentImages => _currentImages;
//   bool get isLoading => _isLoading;
//   bool get hasMore => _hasMore;

//   HomeState() {
//     _init();
//   }

//   void _init() {
//     fetchCategoryImageUrls(_selectedCategory);
//     scrollController.addListener(_onScroll);
//   }

//   void _onScroll() {
//     if (!_isLoading && scrollController.position.pixels ==
//         scrollController.position.minScrollExtent) {
//       fetchCategoryImageUrls(_selectedCategory);
//     }
//   }

//   void selectCategory(String category) {
//     if (category != 'Wallpaper' && category != _selectedCategory) {
//       _selectedCategory = category;
//       fetchCategoryImageUrls(category, refresh: true);
//     }
//   }

//   Future<void> fetchCategoryImageUrls(String category, {bool refresh = false}) async {
//     if (_isLoading) return;

//     _isLoading = true;
//     notifyListeners();

//     if (refresh) {
//       _currentImages = [];
//       _hasMore = true;
//     }

//     if (!_hasMore) {
//       _isLoading = false;
//       notifyListeners();
//       return;
//     }

//     try {
//       final doc = await firestore.collection('categories').doc(category).get();
//       if (doc.exists) {
//         List<String> allImages = List<String>.from(doc['images'] ?? []);
//         int startIndex = _currentImages.length;
//         int endIndex = startIndex + pageSize;

//         if (endIndex > allImages.length) {
//           endIndex = allImages.length;
//           _hasMore = false;
//         }

//         List<String> newImages = allImages.sublist(startIndex, endIndex);
//         _currentImages = [..._currentImages, ...newImages];
//       } else {
//         _hasMore = false;
//       }
//     } catch (e) {
//       print('Error fetching images: $e');
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<bool> isImageFavorite(String url) async {
//     final favRef = firestore.collection('userFavorites').where('url', isEqualTo: url);
//     final snapshot = await favRef.get();
//     return snapshot.docs.isNotEmpty;
//   }

//   @override
//   void dispose() {
//     scrollController.dispose();
//     super.dispose();
//   }
// }

// home_state.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:new_wall_paper_app/views/wallpaper-manager.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeState extends ChangeNotifier {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final ScrollController scrollController = ScrollController();
  final int pageSize = 6;

  String _selectedCategory = 'Popular';
  List<String> _currentImages = [];
  bool _isLoading = false;
  bool _hasMore = true;
  final Map<String, List<String>> _cachedImages = {};

  // Getters
  String get selectedCategory => _selectedCategory;
  List<String> get currentImages => _currentImages;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;

  HomeState() {
    _init();
  }

  void _init() {
    fetchCategoryImageUrls(_selectedCategory);
    scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_isLoading &&
        scrollController.position.pixels ==
            scrollController.position.minScrollExtent) {
      fetchCategoryImageUrls(_selectedCategory);
    }
  }

  void selectCategory(String category) {
    if (category != 'Wallpaper' && category != _selectedCategory) {
      _selectedCategory = category;
      fetchCategoryImageUrls(category, refresh: true);
    }
  }

  Future<void> fetchCategoryImageUrls(String category,
      {bool refresh = false}) async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    if (refresh) {
      _currentImages = [];
      _hasMore = true;
    }

    if (!_hasMore) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final doc = await firestore.collection('categories').doc(category).get();
      if (doc.exists) {
        List<dynamic> imagesData = doc['images'] ?? [];

        List<String> allImages = imagesData
            .where((imageMap) =>
                imageMap is Map<String, dynamic> &&
                imageMap.containsKey('url') &&
                imageMap['url'] is String)
            .map<String>((imageMap) => imageMap['url'] as String)
            .toList();

        int startIndex = _currentImages.length;
        int endIndex = startIndex + pageSize;

        if (endIndex > allImages.length) {
          endIndex = allImages.length;
          _hasMore = false;
        }

        List<String> newImages = allImages.sublist(startIndex, endIndex);
        _currentImages = [..._currentImages, ...newImages];
      } else {
        _hasMore = false;
      }
    } catch (e) {
      print('Error fetching images: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> isImageFavorite(String url) async {
    final favRef =
        firestore.collection('userFavorites').where('url', isEqualTo: url);
    final snapshot = await favRef.get();
    return snapshot.docs.isNotEmpty;
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }


}
