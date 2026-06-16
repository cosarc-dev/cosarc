import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/session_preferences.dart';
import '../../core/theme/cosarc_colors.dart';
import '../../core/theme/cosarc_motion.dart';
import '../../core/theme/cosarc_spacing.dart';
import '../../core/theme/cosarc_transitions.dart';
import '../../core/theme/cosarc_typography.dart';
import '../../widgets/cosarc/cosarc_button.dart';
import '../../widgets/cosarc/cosarc_glass.dart';
import '../../widgets/cosarc/cosarc_input.dart';
import '../../widgets/cosarc/cosarc_scaffold.dart';
import '../dashboard/dashboard_root.dart';
import '../onboarding/onboarding_wrapper.dart';
import 'forgot_password_screen.dart';
import 'mfa_challenge_screen.dart';
import 'otp_verification_screen.dart';
import 'phone_auth_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _rememberMe = false;
  bool _useEmailOtp = false;

  late AnimationController _heroCtrl;
  late AnimationController _panelCtrl;
  late Animation<double> _heroFade;
  late Animation<Offset> _panelSlide;

  static const _taglines = [
    'Discipline, distilled.',
    'Your daily contract awaits.',
    'Train with intention.',
  ];

  int _taglineIndex = 0;

  @override
  void initState() {
    super.initState();
    _heroCtrl = AnimationController(
      vsync: this,
      duration: CosarcMotion.hero,
    );
    _panelCtrl = AnimationController(
      vsync: this,
      duration: CosarcMotion.slow,
    );
    _heroFade = CurvedAnimation(parent: _heroCtrl, curve: CosarcMotion.easeOut);
    _panelSlide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _panelCtrl, curve: CosarcMotion.easeOut));

    _heroCtrl.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _panelCtrl.forward();
    });
    _restoreSessionPrefs();
    _cycleTaglines();
  }

  void _cycleTaglines() {
    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      setState(() => _taglineIndex = (_taglineIndex + 1) % _taglines.length);
      _cycleTaglines();
    });
  }

  Future<void> _restoreSessionPrefs() async {
    final remember = await SessionPreferences.instance.rememberMe;
    final email = await SessionPreferences.instance.savedEmail;
    if (mounted) {
      setState(() {
        _rememberMe = remember;
        if (email != null) _emailController.text = email;
      });
    }
  }

  @override
  void dispose() {
    _heroCtrl.dispose();
    _panelCtrl.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    if (!_isValidEmail(email)) {
      _showError('Enter a valid email address');
      return;
    }

    setState(() => _isLoading = true);
    try {
      if (_useEmailOtp) {
        await _authService.sendEmailOtp(email, shouldCreateUser: false);
        if (!mounted) return;
        Navigator.of(context).pushSharedAxis(
          OtpVerificationScreen(email: email, onVerified: _routeAfterAuth),
        );
        return;
      }

      if (_passwordController.text.isEmpty) {
        _showError('Enter your password');
        return;
      }

      await SessionPreferences.instance.setRememberMe(
        enabled: _rememberMe,
        email: email,
      );

      await _authService.signIn(
        email: email,
        password: _passwordController.text,
      );

      if (await _authService.requiresMfaChallenge()) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          CosarcSharedAxisRoute(builder: (_) => const MfaChallengeScreen()),
        );
        return;
      }

      await _routeAfterAuth();
    } catch (e) {
      _showError(_authService.friendlyAuthError(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final success = await _authService.signInWithGoogle();
      if (!success) {
        _showError('Sign-in was cancelled');
        return;
      }
      await _routeAfterAuth();
    } catch (e) {
      _showError(_authService.friendlyAuthError(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loginWithApple() async {
    setState(() => _isLoading = true);
    try {
      final success = await _authService.signInWithApple();
      if (!success) {
        _showError('Sign-in was cancelled');
        return;
      }
      await _routeAfterAuth();
    } catch (e) {
      _showError(_authService.friendlyAuthError(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _routeAfterAuth() async {
    final needsOnboarding = await _authService.needsOnboarding();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      CosarcFadeThroughRoute(
        builder: (_) =>
            needsOnboarding ? const OnboardingWrapper() : const DashboardRoot(),
      ),
    );
  }

  bool _isValidEmail(String email) =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: CosarcColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return CosarcScaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              flex: 38,
              child: FadeTransition(
                opacity: _heroFade,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: CosarcSpacing.screenHorizontal,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: CosarcSpacing.xxl),
                      Text('cosarc', style: CosarcTypography.brandMark(size: 42)),
                      const Spacer(),
                      AnimatedSwitcher(
                        duration: CosarcMotion.medium,
                        child: Text(
                          _taglines[_taglineIndex],
                          key: ValueKey(_taglineIndex),
                          style: CosarcTypography.display(context).copyWith(
                            fontSize: height < 700 ? 32 : 38,
                          ),
                        ),
                      ),
                      const SizedBox(height: CosarcSpacing.sm),
                      Text(
                        'Premium fitness intelligence for people who show up.',
                        style: CosarcTypography.body(context),
                      ),
                      const SizedBox(height: CosarcSpacing.xxl),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 62,
              child: SlideTransition(
                position: _panelSlide,
                child: FadeTransition(
                  opacity: _panelCtrl,
                  child: CosarcGlass(
                    expand: true,
                    radius: CosarcSpacing.radiusXl,
                    blur: 32,
                    opacity: 0.08,
                    padding: EdgeInsets.zero,
                    margin: const EdgeInsets.fromLTRB(
                      CosarcSpacing.md,
                      0,
                      CosarcSpacing.md,
                      CosarcSpacing.lg,
                    ),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(CosarcSpacing.xl),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('Sign in', style: CosarcTypography.title(context)),
                          const SizedBox(height: CosarcSpacing.xxs),
                          Text(
                            'Continue where you left off',
                            style: CosarcTypography.caption(context),
                          ),
                          const SizedBox(height: CosarcSpacing.xl),
                          CosarcInput(
                            controller: _emailController,
                            label: 'Email',
                            hint: 'you@example.com',
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.email],
                          ),
                          if (!_useEmailOtp) ...[
                            const SizedBox(height: CosarcSpacing.lg),
                            CosarcInput(
                              controller: _passwordController,
                              label: 'Password',
                              hint: '••••••••',
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.done,
                              autofillHints: const [AutofillHints.password],
                              onSubmitted: (_) => _login(),
                              suffix: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: CosarcColors.textTertiary,
                                  size: 20,
                                ),
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: CosarcSpacing.md),
                          Row(
                            children: [
                              SizedBox(
                                height: 24,
                                width: 24,
                                child: Checkbox(
                                  value: _rememberMe,
                                  activeColor: CosarcColors.primary,
                                  onChanged: (v) =>
                                      setState(() => _rememberMe = v ?? false),
                                ),
                              ),
                              const SizedBox(width: CosarcSpacing.xs),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _rememberMe = !_rememberMe),
                                  child: Text(
                                    'Remember me',
                                    style: CosarcTypography.caption(context),
                                  ),
                                ),
                              ),
                              if (!_useEmailOtp)
                                TextButton(
                                  onPressed: () => Navigator.of(context)
                                      .pushSharedAxis(
                                    ForgotPasswordScreen(
                                      initialEmail: _emailController.text.trim(),
                                    ),
                                  ),
                                  child: const Text('Forgot?'),
                                ),
                            ],
                          ),
                          const SizedBox(height: CosarcSpacing.sm),
                          GestureDetector(
                            onTap: () => setState(() => _useEmailOtp = !_useEmailOtp),
                            child: Text(
                              _useEmailOtp
                                  ? 'Use password instead'
                                  : 'Sign in with email code',
                              style: CosarcTypography.caption(context).copyWith(
                                color: CosarcColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: CosarcSpacing.xl),
                          CosarcButton(
                            label: _useEmailOtp ? 'Send code' : 'Sign in',
                            isLoading: _isLoading,
                            onPressed: _isLoading ? null : _login,
                          ),
                          const SizedBox(height: CosarcSpacing.xl),
                          Row(
                            children: [
                              Expanded(child: Divider(color: CosarcColors.divider)),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: CosarcSpacing.md,
                                ),
                                child: Text(
                                  'or',
                                  style: CosarcTypography.caption(context),
                                ),
                              ),
                              Expanded(child: Divider(color: CosarcColors.divider)),
                            ],
                          ),
                          const SizedBox(height: CosarcSpacing.lg),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _SocialOrb(
                                icon: Icons.g_mobiledata_rounded,
                                label: 'Google',
                                onTap: _isLoading ? null : _loginWithGoogle,
                              ),
                              if (_authService.isAppleSignInAvailable) ...[
                                const SizedBox(width: CosarcSpacing.md),
                                _SocialOrb(
                                  icon: Icons.apple,
                                  label: 'Apple',
                                  onTap: _isLoading ? null : _loginWithApple,
                                ),
                              ],
                              const SizedBox(width: CosarcSpacing.md),
                              _SocialOrb(
                                icon: Icons.phone_iphone_rounded,
                                label: 'Phone',
                                onTap: _isLoading
                                    ? null
                                    : () => Navigator.of(context).pushSharedAxis(
                                          const PhoneAuthScreen(),
                                        ),
                              ),
                            ],
                          ),
                          const SizedBox(height: CosarcSpacing.xl),
                          TextButton(
                            onPressed: () => Navigator.of(context).pushSharedAxis(
                              const SignupScreen(),
                            ),
                            child: Text(
                              'Create an account',
                              style: CosarcTypography.body(context).copyWith(
                                color: CosarcColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialOrb extends StatelessWidget {
  const _SocialOrb({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onTap == null ? 0.5 : 1,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            CosarcGlass(
              radius: CosarcSpacing.radiusPill,
              blur: 16,
              padding: const EdgeInsets.all(CosarcSpacing.md),
              child: Icon(icon, size: 24),
            ),
            const SizedBox(height: CosarcSpacing.xxs),
            Text(label, style: CosarcTypography.caption(context).copyWith(fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
