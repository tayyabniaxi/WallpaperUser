// ignore_for_file: use_build_context_synchronously, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:new_wall_paper_app/provider/category-provider.dart';
import 'package:new_wall_paper_app/utils/app-color.dart';
import 'package:new_wall_paper_app/views/sub_category_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:new_wall_paper_app/widgets/full_screen_image_page.dart';
import 'package:provider/provider.dart';
import '../viewmodels/theme_view_model.dart';

// category_page.dart
class CategoryPage extends StatefulWidget {
  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {

 

  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() {
        if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
          Provider.of<CategoryProvider>(context, listen: false).loadMoreItems();
        }
      });
       final provider = Provider.of<CategoryProvider>(context, listen: false);
       provider.loadSubCategories(provider.selectedCategory);
  }

  

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

 
  

  @override
  Widget build(BuildContext context) {
    final themeViewModel = Provider.of<ThemeViewModel>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);

    Color categoryColor = themeViewModel.isDarkMode ? const Color(0xff4C3D90) : const Color(0xffE5D7FF);
    Color selectedCategoryColor = themeViewModel.isDarkMode ? const Color(0xff7B39FD) : AppColor.categoryLightThemeColorselect;
    Color subCategoryColor = themeViewModel.isDarkMode ? const Color(0xFF4C3D90) : const Color(0xffF8F5FF);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categoryProvider.categories.map((category) {
                  bool isWallpaper = category == 'Wallpaper';

                  Color bgColor = isWallpaper
                      ? (themeViewModel.isDarkMode ? Colors.white : Colors.black)
                      : (categoryProvider.selectedCategory == category ? selectedCategoryColor : categoryColor);
                  Color textColor = isWallpaper
                      ? (themeViewModel.isDarkMode ? Colors.black : Colors.white)
                      : (categoryProvider.selectedCategory == category ? Colors.white : Colors.black);

                  return GestureDetector(
                    onTap: () {
                      if (!isWallpaper) {
                        categoryProvider.loadSubCategories(category);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 15),
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Text(
                            category,
                            style: TextStyle(
                              color: themeViewModel.isDarkMode ? Colors.black : Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (isWallpaper) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: textColor,
                              size: 16,
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 7),
          if (categoryProvider.subCategories.containsKey(categoryProvider.selectedCategory))
            Expanded(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 7),
                        child: Row(
                          children: categoryProvider.displayedSubCategories.map((subCategory) {
                            return GestureDetector(
                              onTap: () async {
                                List<String> images = await categoryProvider.fetchSubcategoryImages(
                                  categoryProvider.selectedCategory,
                                  subCategory
                                );
                  
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SubcategoryPage(
                                      category: categoryProvider.selectedCategory,
                                      subcategory: subCategory,
                                      imageUrls: images,
                                      isFavoriteList: const [],
                                      subCategories: categoryProvider.subCategories[categoryProvider.selectedCategory]!,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                margin: const EdgeInsets.symmetric(horizontal: 5),
                                decoration: BoxDecoration(
                                  color: subCategoryColor,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.grey,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 5,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      categoryProvider.subCategoryIcons[subCategory],
                                      color: themeViewModel.isDarkMode ? Colors.white : Colors.black,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      subCategory,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: themeViewModel.isDarkMode ? Colors.white : Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                      alignment: Alignment.topLeft,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 7),
                        child: Row(
                          children: categoryProvider.subCategories[categoryProvider.selectedCategory]!
                              .skip(5)
                              .map((subCategory) {
                            return GestureDetector(
                              onTap: () async {
                                List<String> images = await categoryProvider.fetchSubcategoryImages(
                                  categoryProvider.selectedCategory,
                                  subCategory
                                );
                  
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SubcategoryPage(
                                      category: categoryProvider.selectedCategory,
                                      subcategory: subCategory,
                                      imageUrls: images,
                                      isFavoriteList: const [],
                                      subCategories: categoryProvider.subCategories[categoryProvider.selectedCategory]!,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                margin: const EdgeInsets.symmetric(horizontal: 5),
                                decoration: BoxDecoration(
                                  color: subCategoryColor,
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(
                                    color: Colors.grey,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 5,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      categoryProvider.subCategoryIcons[subCategory],
                                      color: themeViewModel.isDarkMode ? Colors.white : Colors.black,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      subCategory,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: themeViewModel.isDarkMode ? Colors.white : Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
               
               
                  Divider(color: Colors.grey.shade300, thickness: 1.2),
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: categoryProvider.displayedSubCategories.length,
                      itemBuilder: (context, index) {
                        final subCategory = categoryProvider.displayedSubCategories[index];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 180,
                              margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                              child: FutureBuilder<List<String>>(
                                future: categoryProvider.fetchSubcategoryImages(
                                  categoryProvider.selectedCategory,
                                  subCategory
                                ),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const Center(child: CircularProgressIndicator());
                                  } else if (snapshot.hasError) {
                                    return Center(child: Text('Error: ${snapshot.error}'));
                                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                    return const Center(child: Text('No images available.'));
                                  } else {
                                    final images = snapshot.data!;
                                    return Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                subCategory,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14
                                                ),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                 Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SubcategoryPage(
                                    category: categoryProvider.selectedCategory,
                                    subcategory: subCategory,
                                    imageUrls: images,
                                    isFavoriteList: const [],
                                    subCategories: categoryProvider.subCategories[categoryProvider.selectedCategory]!,
                                  ),
                                ),
                              );
                                                },
                                                child: const Text('View All',
                                                    style: TextStyle( fontSize: 12,color: AppColor.primaryColor, decoration: TextDecoration.underline,decorationColor: AppColor.primaryColor,)),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount:images.length<=5? images.length: 5,
                                            itemBuilder: (context, imgIndex) {
                                              return Container(
                                                width: 90,
                                                margin: const EdgeInsets.symmetric(
                                                    horizontal: 4),

                                                child: GestureDetector(
                                                   onTap: (){
                                                     Navigator.push(
                                                       context,
                                                       MaterialPageRoute(
                                                         builder: (context) => FullScreenImagePage(

                                                           imageUrl: images[imgIndex],
                                                           isFavorite: false,
                                                           onFavoriteToggle: () {},
                                                           image: images,

                                                         ),
                                                       ),
                                                     );
                                                   },
                                                  child: ClipRRect(
                                                    borderRadius: BorderRadius.circular(4),
                                                    child: CachedNetworkImage(
                                                      imageUrl: images[imgIndex],
                                                      fit: BoxFit.cover,
                                                      placeholder: (context, url) =>
                                                          Container(
                                                            color: Colors.grey[300],
                                                          ),
                                                      errorWidget: (context, url, error) =>
                                                      const Icon(Icons.error),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        const SizedBox(height: 6,),
                                          const Divider(),
                                      ],
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),


                ],
              ),
            ),
        ],
      ),
    );
  }

}



