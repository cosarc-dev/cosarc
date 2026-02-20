import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/supabase_config.dart';
import 'screens/app_start/app_start_screen.dart';
import 'screens/onboarding/onboarding_wrapper.dart';
import 'screens/dashboard/dashboard_root.dart';
import 'models/food_log.dart';
import 'models/food_adapter.dart';
import 'services/auth_service.dart';

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

class CosarcApp extends StatefulWidget {
  const CosarcApp({super.key});

  @override
  State<CosarcApp> createState() => _CosarcAppState();
}

class _CosarcAppState extends State<CosarcApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final AuthService _authService = AuthService();
  bool _isHandlingAuth = false;

  @override
  void initState() {
    super.initState();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    supabase.auth.onAuthStateChange.listen((data) async {
      if (_isHandlingAuth) return;

      final session = data.session;

      if (session != null) {
        _isHandlingAuth = true;

        print('🔵 Auth state changed - user logged in: ${session.user.email}');

        await Future.delayed(Duration(milliseconds: 500));

        try {
          await _ensureMemberExists(session.user);

          final needsOnboarding = await _authService.needsOnboarding();

          final context = navigatorKey.currentContext;
          if (context != null && mounted) {
            if (needsOnboarding) {
              print('🔵 Navigating to onboarding');
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const OnboardingWrapper()),
                (route) => false,
              );
            } else {
              print('🔵 Navigating to dashboard');
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const DashboardRoot()),
                (route) => false,
              );
            }
          }
        } catch (e) {
          print('❌ Error handling auth state: $e');
        } finally {
          _isHandlingAuth = false;
        }
      }
    });
  }

  Future<void> _ensureMemberExists(User user) async {
    try {
      final existingMember = await supabase
          .from('members')
          .select('id')
          .eq('auth_user_id', user.id)
          .maybeSingle();

      if (existingMember == null) {
        print('🔵 Creating member record for OAuth user');

        await supabase.from('members').insert({
          'auth_user_id': user.id,
          'email': user.email,
          'name': user.userMetadata?['full_name'] ??
              user.email?.split('@')[0] ??
              'User',
        });

        final member = await supabase
            .from('members')
            .select('id')
            .eq('auth_user_id', user.id)
            .single();

        await supabase.from('streaks').insert({
          'member_id': member['id'],
        });

        print('✅ Member record created');
      } else {
        print('✅ Member record already exists');
      }
    } catch (e) {
      print('❌ Error ensuring member exists: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
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
