import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../auth/login_screen.dart';
import '../dashboard/dashboard_root.dart';

class AppStartScreen extends StatefulWidget {
  const AppStartScreen({super.key});

  @override
  State<AppStartScreen> createState() => _AppStartScreenState();
}

class _AppStartScreenState extends State<AppStartScreen> {
  VideoPlayerController? _controller;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    print("🔥 AppStartScreen started");

    _initVideo();

    // 🔥 HARD FAILSAFE (GUARANTEED NAVIGATION)
    Future.delayed(const Duration(seconds: 3), _decideNextScreen);
  }

  Future<void> _initVideo() async {
    try {
      final controller = VideoPlayerController.asset(
        'assets/backgrounds/app_intro.mp4',
      );

      await controller.initialize();

      controller
        ..setVolume(0)
        ..play();

      setState(() {
        _controller = controller;
      });

      print("✅ Video initialized");

    } catch (e) {
      print("❌ Video error: $e");
    }
  }

  void _decideNextScreen() {
    if (!mounted || _navigated) return;
    _navigated = true;

    final session = Supabase.instance.client.auth.currentSession;

    if (session != null) {
      print("➡️ User already logged in");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardRoot()),
      );
    } else {
      print("➡️ No user, going to login");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
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
          : const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
    );
  }
}