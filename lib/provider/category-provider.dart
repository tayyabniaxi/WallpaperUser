import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryProvider extends ChangeNotifier {

  

  // Variables
  final List<String> categories = [
    'Wallpaper',
    'Technology',
    'Animals',
    'Sports',
    'Art',
    'Food',
  ];

  final Map<String, List<String>> subCategories = {
    'Technology': [
      'AI',
      'Gadgets',
      'Robots',
      'Coding',
      'VR',
      'AR',
      'Blockchain',
      'Drones',
    ],
    'Animals': [
      'Cats',
      'Dogs',
      'Birds',
      'Wildlife',
      'Aquatic',
      'Insects',
      'Pets',
      'Horses',
    ],
    'Sports': [
      'Football',
      'Basketball',
      'Tennis',
      'Swimming',
      'Running',
      'Cycling',
      'Baseball',
      'Boxing',
    ],
    'Art': [
      'Painting',
      'Photography',
      'Design',
      'Fashion',
      'Digital Art',
      'Calligraphy',
      'Illustration',
      'Typography'
    ],
    'Food': [
      'Fruits',
      'Fast Food',
      'Desserts',
      'Drinks',
      'Seafood',
      'Meat',
      'Baking',
      'Dairy'
    ],
  };

  

  final Map<String, IconData> subCategoryIcons = {
    'AI': Icons.memory,
    'Gadgets': Icons.devices,
    'Robots': Icons.smart_toy,
    'Coding': Icons.code,
    'VR': Icons.vrpano,
    'AR': Icons.view_in_ar,
    'Blockchain': Icons.lock,
    'Drones': Icons.air,
    'Cats': Icons.pets,
    'Dogs': Icons.pets,
    'Birds': Icons.filter_vintage,
    'Wildlife': Icons.nature,
    'Aquatic': Icons.pool,
    'Insects': Icons.bug_report,
    'Pets': Icons.pets,
    'Horses': Icons.directions_run,
    'Football': Icons.sports_football,
    'Basketball': Icons.sports_basketball,
    'Tennis': Icons.sports_tennis,
    'Swimming': Icons.pool,
    'Running': Icons.directions_run,
    'Cycling': Icons.directions_bike,
    'Baseball': Icons.sports_baseball,
    'Boxing': Icons.sports_mma,
    'Painting': Icons.brush,
    'Photography': Icons.camera_alt,
    'Design': Icons.design_services,
    'Fashion': Icons.checkroom,
    'Digital Art': Icons.computer,
    'Calligraphy': Icons.edit,
    'Illustration': Icons.create,
    'Typography': Icons.font_download,
    'Fruits': Icons.apple,
    'Fast Food': Icons.fastfood,
    'Desserts': Icons.cake,
    'Drinks': Icons.local_drink,
    'Seafood': Icons.set_meal,
    'Meat': Icons.dining,
    'Baking': Icons.kitchen,
    'Dairy': Icons.icecream,
  };

  String _selectedCategory = 'Technology';
  final int itemsPerPage = 3;
  int _currentPage = 0;
  List<String> _displayedSubCategories = [];

  // Getters
  String get selectedCategory => _selectedCategory;
  int get currentPage => _currentPage;
  List<String> get displayedSubCategories => _displayedSubCategories;

  // Methods
  void loadSubCategories(String category) {
    _selectedCategory = category;
    _displayedSubCategories = [];
    _currentPage = 0;
    loadMoreItems();
    notifyListeners();
  }

  void loadMoreItems() {
    if (_currentPage * itemsPerPage >= subCategories[_selectedCategory]!.length) {
      return;
    }

    final endIndex = (_currentPage + 1) * itemsPerPage;
    _displayedSubCategories.addAll(subCategories[_selectedCategory]!.sublist(
      _currentPage * itemsPerPage,
      endIndex > subCategories[_selectedCategory]!.length
          ? subCategories[_selectedCategory]!.length
          : endIndex,
    ));
    _currentPage++;
    notifyListeners();
  }

  Future<List<String>> fetchSubcategoryImages(String category, String subcategory) async {
    final doc = await FirebaseFirestore.instance
        .collection('categories')
        .doc(category)
        .collection('subcategories')
        .doc(subcategory)
        .get();

    if (doc.exists) {
      List<dynamic> imagesData = doc.data()?['images'] ?? [];
      return imagesData.map((imageMap) => imageMap['url'] as String).toList();
    }
    return [];
  }

  
}
