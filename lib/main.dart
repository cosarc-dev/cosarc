import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/supabase_config.dart';
import 'screens/app_start/app_start_screen.dart';
import 'models/food_log.dart';
import 'models/food_adapter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(FoodLogAdapter());
  }

  if (!Hive.isBoxOpen('daily_logs')) {
    await Hive.openBox<FoodLog>('daily_logs');
  }

  await SupabaseConfig.initialize();

  runApp(const CosarcApp());
}

class CosarcApp extends StatelessWidget {
  const CosarcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cosarc',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0C0C0C),
        textTheme: GoogleFonts.montserratTextTheme(
          Theme.of(context).textTheme.apply(
                bodyColor: Colors.white,
                displayColor: Colors.white,
              ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF161616),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          hintStyle: const TextStyle(color: Colors.white54),
        ),
      ),
      home: const AppStartScreen(),
    );
  }
}
