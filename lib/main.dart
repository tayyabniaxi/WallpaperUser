import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:new_wall_paper_app/provider/category-provider.dart';
import 'package:new_wall_paper_app/provider/categoryViewmodel-provider.dart';
import 'package:new_wall_paper_app/provider/favorite_toggle.dart';
import 'package:new_wall_paper_app/provider/home-content-provider.dart';
import 'package:new_wall_paper_app/provider/search-provider.dart';
import 'package:provider/provider.dart';
import 'viewmodels/subcategory_view_model.dart';
import 'viewmodels/theme_view_model.dart';
import 'views/home_page.dart';
import 'package:google_api_availability/google_api_availability.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
  } catch (e) {
    print('Firebase initialization error: $e');
  }

  runApp(MultiProvider(
    providers: [
       ChangeNotifierProvider(create: (_) => FavoriteProvider()),
       ChangeNotifierProvider(create: (_) => CategoryViewModel()),
       ChangeNotifierProvider(create: (_) => SearchState()),
       ChangeNotifierProvider(create: (_) => HomeState()),
       ChangeNotifierProvider(create: (_) => CategoryProvider()),
    ],
    child: const MyApp()));

  await checkGooglePlayServicesAvailability();
}

Future<void> checkGooglePlayServicesAvailability() async {
  GoogleApiAvailability apiAvailability = GoogleApiAvailability.instance;
  final status = await apiAvailability.checkGooglePlayServicesAvailability();

  if (status == GooglePlayServicesAvailability.success) {
    // ignore: avoid_print
    print("Google Play Services is available.");
  } else {
    print("Google Play Services is not available: $status");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider<ThemeViewModel>(

      create: (context) => ThemeViewModel(),
      child: Consumer<ThemeViewModel>(
        builder: (context, themeViewModel, child) {
          return ChangeNotifierProvider<SubcategoryViewModel>(
            create: (context) => SubcategoryViewModel(),
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Wallpaper App',
              theme: themeViewModel.currentTheme,
             
              home: HomePage(),
            ),
          );
        },
      ),
    );
  }
}
