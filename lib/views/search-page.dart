
// search_image_page.dart
import 'package:flutter/material.dart';
import 'package:new_wall_paper_app/provider/search-provider.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:new_wall_paper_app/widgets/full_screen_image_page.dart';
// import 'search_state.dart';

class SearchImagePage extends StatelessWidget {
  const SearchImagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SearchState(),
      child: const SearchImageContent(),
    );
  }
}

class SearchImageContent extends StatelessWidget {
  const SearchImageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchState>(
      builder: (context, searchState, _) {
        return Scaffold(
        

                appBar: AppBar(
                  backgroundColor: Colors.white,
                  elevation: 0,
        title: const Text(
          'Search Page',
          style: TextStyle(fontSize: 18, color: Colors.black),
        ),
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: const Icon(Icons.arrow_back, color: Colors.black, )),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
                  controller: searchState.searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by image name',
                    hintStyle: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.normal,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: searchState.performSearch,
                    ),
                  ),
                  onChanged: searchState.onSearchChanged,
                ),
          ),
        ),
      ),
          body: GestureDetector(
            onTap: () {
            // Remove focus when tapping outside the TextField
            FocusScope.of(context).unfocus();
          },
          behavior: HitTestBehavior.opaque,
            child: Stack(
              children: [
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: searchState.searchImages(searchState.searchQuery),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
          
                    final images = snapshot.data ?? [];
                    if (images.isEmpty) {
                      return const Center(child: Text('No images found.'));
                    }
          
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      child: StaggeredGridView.countBuilder(
                        crossAxisCount: 2,
                        staggeredTileBuilder: (int index) =>
                            StaggeredTile.extent(1, index.isEven ? 200 : 300),
                        mainAxisSpacing: 4.0,
                        crossAxisSpacing: 4.0,
                        itemCount: images.length,
                        itemBuilder: (context, index) {
                          final isPro = images[index]['isPro'];
          
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FullScreenImagePage(
                                    imageUrl: images[index]['url'],
                                    isFavorite: false,
                                    onFavoriteToggle: () {},
                                    image: const [],
                                  ),
                                ),
                              );
                            },
                            child: Stack(
                              alignment: Alignment.center,
                              fit: StackFit.expand,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: CachedNetworkImage(
                                    imageUrl: images[index]['url'],
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) =>
                                        Container(color: Colors.grey[300]),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
                                  ),
                                ),
                                if (isPro)
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 8,
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 1,
                                          horizontal: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade200,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Text(
                                          'Pro',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
                if (searchState.showSuggestions)
                  Container(
                    margin: const EdgeInsets.only(top: 0, left: 8, right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemCount: searchState.suggestedImages.length,
                      itemBuilder: (context, index) {
                        final suggestion = searchState.suggestedImages[index];
                        return ListTile(
                          onTap: () => searchState.selectSuggestion(suggestion['name']),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              suggestion['url'],
                              width: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(suggestion['name']),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}