import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Atharva's Screen Imports
import 'package:cosarc/screens/app_start/app_start_screen.dart';

// Anish's Unity Screen Import
// (Note: If you moved this file into a folder, update the path below)
import 'package:cosarc/screens/dashboard/my_gym_screen.dart';

void main() {
  // 1. Necessary for Unity & Video Player to initialize before the app starts
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const CosarcApp());
}

class CosarcApp extends StatelessWidget {
  const CosarcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cosarc',
      debugShowCheckedModeBanner: false,

      // 2. Cinematic Dark Theme (From Atharva's Repo)
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0C0C0C),
        textTheme: GoogleFonts.montserratTextTheme(
          Theme.of(context).textTheme.apply(bodyColor: Colors.white),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF161616),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          labelStyle: const TextStyle(color: Colors.white70),
        ),
      ),

      // 3. The Entry Point (Starts with Atharva's cinematic intro)
      home: const AppStartScreen(),
    );
  }
}
