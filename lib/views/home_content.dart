// ignore_for_file: use_build_context_synchronously

// home_content.dart
import 'package:flutter/material.dart';
import 'package:new_wall_paper_app/provider/home-content-provider.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../utils/app-color.dart';
import '../widgets/full_screen_image_page.dart';
import '../viewmodels/theme_view_model.dart';
// import 'home_state.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeState(),
      child: const HomeContentView(),
    );
  }
}

class HomeContentView extends StatelessWidget {
  const HomeContentView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeViewModel = Provider.of<ThemeViewModel>(context);
    final homeState = Provider.of<HomeState>(context);

    Color wallpaperColor =
        themeViewModel.isDarkMode ? Colors.white : Colors.black;
    Color wallpaperTextColor =
        themeViewModel.isDarkMode ? Colors.black : Colors.white;
    Color selectedColor = themeViewModel.isDarkMode
        ? const Color(0xff7B39FD)
        : AppColor.categoryLightThemeColorselect;
    Color defaultColor = themeViewModel.isDarkMode
        ? const Color(0xff4C3D90)
        : const Color(0xffE5D7FF);

    return Scaffold(
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 0.0),
              child: Wrap(
                // spacing: 18,
                // runSpacing: 4,
                children: ['Wallpaper', 'Popular', 'Nature', 'Random']
                    .map((category) {
                  final isSelected = category == homeState.selectedCategory;
                  return GestureDetector(
                    onTap: () => homeState.selectCategory(category),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 5,
                        horizontal: 10,
                      ),
                      margin: const EdgeInsets.only(right: 5),
                      decoration: BoxDecoration(
                        color: category == 'Wallpaper'
                            ? wallpaperColor
                            : (isSelected ? selectedColor : defaultColor),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Text(
                            category,
                            style: TextStyle(
                              color: isSelected || category == 'Wallpaper'
                                  ? wallpaperTextColor
                                  : Colors.black,
                            ),
                          ),
                          if (category == 'Wallpaper') ...[
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
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
          const SizedBox(height: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: homeState.isLoading && homeState.currentImages.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : NotificationListener<ScrollNotification>(
                      onNotification: (ScrollNotification scrollInfo) {
                        if (!homeState.isLoading &&
                            scrollInfo.metrics.pixels ==
                                scrollInfo.metrics.maxScrollExtent) {
                          homeState.fetchCategoryImageUrls(
                              homeState.selectedCategory);
                        }
                        return true;
                      },
                      child: StaggeredGridView.countBuilder(
                        controller: homeState.scrollController,
                        crossAxisCount: 2,
                        itemCount: homeState.currentImages.length +
                            (homeState.isLoading ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == homeState.currentImages.length) {
                            return const Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          return GestureDetector(
                            onTap: () async {
                              bool isFavorite = await homeState.isImageFavorite(
                                  homeState.currentImages[index]);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FullScreenImagePage(
                                    imageUrl: homeState.currentImages[index],
                                    isFavorite: isFavorite,
                                    onFavoriteToggle: () {},
                                    image: const [],
                                  ),
                                ),
                              );
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CachedNetworkImage(
                                imageUrl: homeState.currentImages[index],
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: Colors.grey[300],
                                ),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              ),
                            ),
                          );
                        },
                        staggeredTileBuilder: (int index) =>
                            StaggeredTile.extent(
                          1,
                          index.isEven ? 200 : 300,
                        ),
                        mainAxisSpacing: 4.0,
                        crossAxisSpacing: 4.0,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
