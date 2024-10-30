// ignore_for_file: use_key_in_widget_constructors, unused_element, prefer_is_empty, prefer_const_constructors_in_immutables, library_private_types_in_public_api, use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:new_wall_paper_app/provider/favorite_toggle.dart';
import 'package:new_wall_paper_app/provider/image_show-full-screen-provider.dart';
import 'package:new_wall_paper_app/utils/app-text.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../utils/image_utils.dart';

import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'dart:io';

class FullScreenImagePage extends StatefulWidget {
  final String imageUrl;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  final List<String> image;

  FullScreenImagePage({
    required this.imageUrl,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.image,
  });

  @override
  _FullScreenImagePageState createState() => _FullScreenImagePageState();
}

class _FullScreenImagePageState extends State<FullScreenImagePage> {
  late bool _isFavorite;
  final GlobalKey _imageKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    Provider.of<FullImageShowProvider>(context, listen: false).resetFilters();
    _isFavorite = widget.isFavorite;
  }

  Future<void> _setWallpaper() async {
    final fullImageshowProvider =
        Provider.of<FullImageShowProvider>(context, listen: false);
    Uint8List? filteredImage;
    if (fullImageshowProvider.isFilterActive) {
      filteredImage =
          await LocalImageUtils.captureFilteredImage(context, _imageKey);
    }
    await LocalImageUtils.setWallpaper(context, widget.imageUrl,
        filteredImage: filteredImage);
  }

  Future<void> _downloadImage() async {
    final fullImageshowProvider =
        Provider.of<FullImageShowProvider>(context, listen: false);
    Uint8List? filteredImage;
    if (fullImageshowProvider.isFilterActive) {
      filteredImage =
          await LocalImageUtils.captureFilteredImage(context, _imageKey);
    }
    await LocalImageUtils.downloadImage(context, widget.imageUrl,
        filteredImage: filteredImage);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final favoriteProvider = Provider.of<FavoriteProvider>(context);
    final fullImageshowProvider = Provider.of<FullImageShowProvider>(context);

    return Scaffold(
      body: RepaintBoundary(
        key: _imageKey,
        child: ListView(
          children: [
            // Main Image
            Stack(
              children: [
                ColorFiltered(
                  colorFilter: ColorFilter.matrix(
                      fullImageshowProvider.getColorMatrix()),
                  child: SizedBox(
                    width: screenSize.width,
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: CachedNetworkImage(
                      imageUrl: widget.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) =>
                          const Center(child: Icon(Icons.error)),
                    ),
                  ),
                ),
                // Back Button
                Positioned(
                  top: 40,
                  left: 20,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: Colors.white, size: 30),
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
                    },
                  ),
                  TextButton(
                    onPressed: fullImageshowProvider.isFilterActive
                        ? _downloadImage
                        : () async {
                            await ImageUtils.downloadImage(
                                context, widget.imageUrl);
                          },
                    child:
                        const Icon(Icons.download_sharp, color: Colors.black),
                  ),
                  IconButton(
                    onPressed: () {
                      fullImageshowProvider.showFilterBottomSheet(context);
                    },
                    icon: const Icon(Icons.water_drop_outlined),
                  ),
                  TextButton(
                    onPressed: fullImageshowProvider.isFilterActive
                        ? _setWallpaper
                        : () async {
                            await ImageUtils.setWallpaper(
                                context, widget.imageUrl);
                          },
                    child: const Icon(Icons.wallpaper, color: Colors.black),
                  ),
                ],
              ),
            ),
            widget.image.isEmpty || widget.image.length == 0
                ? Container()
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: AppTextFormate(
                      size: 0.02,
                      title: "More like this",
                      fontWeight: FontWeight.w500,
                    ),
                  ),
            const SizedBox(
              height: 6,
            ),
            widget.image.isEmpty || widget.image.length == 0
                ? Container()
                : Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 10, right: 10, bottom: 10),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: widget.image.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          childAspectRatio: 1.3,
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FullScreenImagePage(
                                    imageUrl: widget.image[index],
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
                                imageUrl: widget.image[index],
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator()),
                                errorWidget: (context, url, error) =>
                                    const Center(child: Icon(Icons.error)),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class LocalImageUtils {
  static Future<Uint8List?> captureFilteredImage(
      BuildContext context, GlobalKey key) async {
    try {
      RenderRepaintBoundary boundary =
          key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      print("Error capturing image: $e");
      return null;
    }
  }

  static Future<void> setWallpaper(BuildContext context, String imageUrl,
      {Uint8List? filteredImage}) async {
    try {
      final bytes = filteredImage ?? await downloadImageBytes(imageUrl);
      if (bytes != null) {
        final directory = await getApplicationDocumentsDirectory();
        final path = "${directory.path}/wallpaper_image.png";
        final file = File(path);

        await file.writeAsBytes(bytes);

        final location = WallpaperManager.HOME_SCREEN;
        await WallpaperManager.setWallpaperFromFile(
          file.path,
          location,
        );

        print("Wallpaper set successfully from $path");
        showSnackbar(context, 'Wallpaper set successfully');
      } else {
        print("No image data to set as wallpaper.");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No image data available.")),
        );
      }
    } catch (e) {
      print("Error setting wallpaper: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to set wallpaper")),
      );
    }
  }

  static Future<void> downloadImage(BuildContext context, String imageUrl,
      {Uint8List? filteredImage}) async {
    try {
      final bytes = filteredImage ?? await downloadImageBytes(imageUrl);
      if (bytes != null) {
        final directory = await getApplicationDocumentsDirectory();
        final path = "${directory.path}/downloaded_image.png";
        final file = File(path);
        await file.writeAsBytes(bytes);
        print("Image downloaded to $path");

        showSnackbar(context, 'Your image is saved');
      }
    } catch (e) {
      print("Error downloading image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to download image")),
      );
    }
  }

  static Future<Uint8List?> downloadImageBytes(String imageUrl) async {
    try {
      return Uint8List.fromList([]);
    } catch (e) {
      print("Download error: $e");
      return null;
    }
  }
}
