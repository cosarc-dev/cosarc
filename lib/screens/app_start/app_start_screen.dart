import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../core/supabase_config.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import '../dashboard/dashboard_root.dart';
import '../onboarding/onboarding_wrapper.dart';

class AppStartScreen extends StatefulWidget {
  const AppStartScreen({super.key});

  @override
  State<AppStartScreen> createState() => _AppStartScreenState();
}

class _AppStartScreenState extends State<AppStartScreen> {
  VideoPlayerController? _controller;
  final AuthService _authService = AuthService();
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    try {
      final controller = VideoPlayerController.asset(
        'assets/backgrounds/app_intro.mp4',
      );

      await controller.initialize().timeout(const Duration(seconds: 6));

      controller
        ..setVolume(0)
        ..play();

      _controller = controller;
      if (mounted) setState(() {});

      final duration = controller.value.duration;
      final wait =
          duration > Duration.zero && duration < const Duration(seconds: 8)
              ? duration
              : const Duration(seconds: 3);
      Future.delayed(wait, _goNext);
    } catch (e) {
      _controller?.dispose();
      _controller = null;
      Future.delayed(const Duration(seconds: 2), _goNext);
    }
  }

  Future<void> _goNext() async {
    if (!mounted || _navigated) return;
    _navigated = true;

    Widget nextScreen = const LoginScreen();

    if (SupabaseConfig.isInitialized && _authService.isLoggedIn) {
      try {
        final needsOnboarding = await _authService
            .needsOnboarding()
            .timeout(const Duration(seconds: 12));
        nextScreen =
            needsOnboarding ? const OnboardingWrapper() : const DashboardRoot();
      } catch (e) {
        debugPrint('Startup routing failed: $e');
      }
    }

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => nextScreen),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: _controller != null && _controller!.value.isInitialized
          ? SizedBox(
              width: size.width,
              height: size.height,
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller!.value.size.width,
                  height: _controller!.value.size.height,
                  child: VideoPlayer(_controller!),
                ),
              ),
            )
          : const SizedBox.expand(), // BLACK SCREEN ONLY
    );
  }
}
