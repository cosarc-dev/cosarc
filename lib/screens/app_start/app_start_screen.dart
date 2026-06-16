import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../core/config/app_config.dart';
import '../../core/supabase_config.dart';
import '../../core/theme/cosarc_colors.dart';
import '../../core/theme/cosarc_motion.dart';
import '../../core/theme/cosarc_spacing.dart';
import '../../core/theme/cosarc_transitions.dart';
import '../../core/theme/cosarc_typography.dart';
import '../../widgets/cosarc/cosarc_button.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import '../dashboard/dashboard_root.dart';
import '../onboarding/onboarding_wrapper.dart';

class AppStartScreen extends StatefulWidget {
  const AppStartScreen({super.key});

  @override
  State<AppStartScreen> createState() => _AppStartScreenState();
}

class _AppStartScreenState extends State<AppStartScreen>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _controller;
  final AuthService _authService = AuthService();
  bool _navigated = false;

  late AnimationController _logoCtrl;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;

  static const _videoPaths = [
    'assets/backgrounds/cosarc_intro.mp4',
    'assets/backgrounds/app_intro.mp4',
  ];

  @override
  void initState() {
    super.initState();
    _logoCtrl = AnimationController(vsync: this, duration: CosarcMotion.hero);
    _logoScale = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: CosarcMotion.easeOut),
    );
    _logoOpacity = CurvedAnimation(parent: _logoCtrl, curve: CosarcMotion.easeOut);
    _logoCtrl.forward();
    _initVideo();
  }

  Future<void> _initVideo() async {
    for (final path in _videoPaths) {
      try {
        final controller = VideoPlayerController.asset(path);
        await controller.initialize().timeout(const Duration(seconds: 6));
        controller
          ..setVolume(0)
          ..setLooping(true)
          ..play();
        _controller = controller;
        if (mounted) setState(() {});
        break;
      } catch (_) {
        continue;
      }
    }

    final wait = _controller?.value.duration ?? const Duration(seconds: 3);
    final delay = wait > Duration.zero && wait < const Duration(seconds: 8)
        ? wait
        : const Duration(milliseconds: 2800);
    Future.delayed(delay, _goNext);
  }

  Future<void> _goNext() async {
    if (!mounted || _navigated) return;
    _navigated = true;

    final configError = AppConfig.configurationError;
    if (configError != null) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        CosarcFadeThroughRoute(
          builder: (_) => _ConfigurationErrorScreen(message: configError),
        ),
      );
      return;
    }

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
      CosarcFadeThroughRoute(builder: (_) => nextScreen),
    );
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CosarcColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_controller != null && _controller!.value.isInitialized)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller!.value.size.width,
                height: _controller!.value.size.height,
                child: VideoPlayer(_controller!),
              ),
            )
          else
            const DecoratedBox(
              decoration: BoxDecoration(gradient: CosarcColors.meshGradient),
            ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.15),
                  CosarcColors.background.withOpacity(0.92),
                ],
              ),
            ),
          ),
          Center(
            child: FadeTransition(
              opacity: _logoOpacity,
              child: ScaleTransition(
                scale: _logoScale,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('cosarc', style: CosarcTypography.brandMark(size: 48)),
                    const SizedBox(height: CosarcSpacing.sm),
                    Text(
                      'DISCIPLINE · DESIGN · DELIVERY',
                      style: CosarcTypography.overline(''),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: CosarcSpacing.huge),
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: CosarcColors.primary.withOpacity(0.7),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfigurationErrorScreen extends StatelessWidget {
  const _ConfigurationErrorScreen({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CosarcColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(CosarcSpacing.screenHorizontal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Icon(
                Icons.settings_outlined,
                size: 48,
                color: CosarcColors.textTertiary,
              ),
              const SizedBox(height: CosarcSpacing.lg),
              Text(
                'Configuration required',
                style: CosarcTypography.headline(context),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: CosarcSpacing.sm),
              Text(
                message,
                style: CosarcTypography.body(context),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: CosarcSpacing.md),
              Text(
                'Run with:\nflutter run \\\n  --dart-define=SUPABASE_ANON_KEY=your_key',
                style: CosarcTypography.caption(context).copyWith(
                  fontFamily: 'monospace',
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              CosarcButton(
                label: 'Continue offline to login UI',
                variant: CosarcButtonVariant.secondary,
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    CosarcFadeThroughRoute(builder: (_) => const LoginScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
