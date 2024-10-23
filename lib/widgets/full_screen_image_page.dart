

// ignore_for_file: use_key_in_widget_constructors, unused_element

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:new_wall_paper_app/provider/favorite_toggle.dart';
import 'package:new_wall_paper_app/utils/app-text.dart';
import 'package:new_wall_paper_app/viewmodels/theme_view_model.dart';
import 'package:new_wall_paper_app/views/wallpaper-manager.dart';
import 'package:provider/provider.dart';
import '../utils/image_utils.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
// import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';

class FullScreenImagePage extends StatefulWidget {
  final String imageUrl;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  final List<String> image;

  FullScreenImagePage({
    required this.imageUrl,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required  this.image
  });

  @override
  _FullScreenImagePageState createState() => _FullScreenImagePageState();
}

class _FullScreenImagePageState extends State<FullScreenImagePage> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
      initAppState();
    // Initialize _isFavorite with the value passed from the parent widget
    _isFavorite = widget.isFavorite;
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite; // Toggle the local favorite state
    });
    widget.onFavoriteToggle(); // Call the callback to notify the parent widget
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final favoriteProvider = Provider.of<FavoriteProvider>(context);

    return Scaffold(
      body: ListView(
        children: [
          // Main Image
          Stack(
            children: [
              SizedBox(
                width: screenSize.width,
                height: MediaQuery.of(context).size.height * 0.6,
                child: CachedNetworkImage(
                  imageUrl: widget.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) =>
                      Center(child: Icon(Icons.error)),
                ),
              ),
              // Back Button
              Positioned(
                top: 40,
                left: 20,
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white, size: 30),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
          // Button Overlay
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Favorite Button
                IconButton(
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? Colors.red : Colors.black,
                  ),
                  onPressed: () {
                    setState(() {
                      _isFavorite = !_isFavorite;
                    });
                    favoriteProvider.toggleFavorite(widget.imageUrl);
                    ImageUtils.toggleFavorite(context, widget.imageUrl);
                  },
                ),
                // Download Button
                TextButton(
                  onPressed: () async {
                    await ImageUtils.downloadImage(context, widget.imageUrl);
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.download_sharp, color: Colors.black),
                    ],
                  ),
                ),
                // Set Wallpaper Button
                TextButton(

                  // onPressed: () => {setWallpaper(widget.imageUrl)},
                  onPressed: () async {
                    // setWallpaper(widget.imageUrl);
                    await ImageUtils.setWallpaper(context, widget.imageUrl);
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.wallpaper, color: Colors.black),
                    ],
                  ),
                ),

              ],
            ),
          ),
          widget.image?.isEmpty??false || widget.image?.length==0 ?Container():   Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: AppTextFormate(
              size: 0.02,
              title: "More like this",
              fontWeight: FontWeight.w500,
            ),
          ),
        SizedBox(height: 6,),
        // Related Images Grid
        widget.image?.isEmpty??false || widget.image?.length==0 ?Container():  Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 10,right: 10, bottom: 10),
              child: GridView.builder(

                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(), // Disable internal scrolling

                itemCount: widget.image?.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  childAspectRatio: 1.3,
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullScreenImagePage(

                            imageUrl: widget.image?[index]??"",
                            isFavorite: false,
                            onFavoriteToggle: () {},
                            image: widget.image,

                          ),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: widget.image?[index]??"",
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) =>
                            Center(child: Icon(Icons.error)),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );

  }

   String _platformVersion = 'Unknown';
  String __heightWidth = "Unknown";

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initAppState() async {
    String platformVersion;
    String _heightWidth;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await WallpaperManager.platformVersion ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    try {
      int height = await WallpaperManager.getDesiredMinimumHeight();
      int width = await WallpaperManager.getDesiredMinimumWidth();
      _heightWidth =
          "Width = " + width.toString() + " Height = " + height.toString();
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
      _heightWidth = "Failed to get Height and Width";
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      __heightWidth = _heightWidth;
      _platformVersion = platformVersion;
    });
  }

  Future<void> setWallpaper(String image) async {
    try {
      // String url = "https://source.unsplash.com/random";
      String url =image;
      int location = WallpaperManager
          .BOTH_SCREEN; // or location = WallpaperManager.LOCK_SCREEN;
      var file = await DefaultCacheManager().getSingleFile(url);
      final bool result =
          await WallpaperManager.setWallpaperFromFile(file.path, location);
      print(result);
    } on PlatformException {}
  }

}

