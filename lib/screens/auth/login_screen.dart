import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../core/theme/cosarc_colors.dart';
import '../../core/theme/cosarc_spacing.dart';
import '../../core/theme/cosarc_typography.dart';
import '../../widgets/cosarc/cosarc_button.dart';
import '../../widgets/cosarc/cosarc_input.dart';
import '../../widgets/cosarc/cosarc_scaffold.dart';
import '../dashboard/dashboard_root.dart';
import '../onboarding/onboarding_wrapper.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  late AnimationController _fadeCtrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOutCubic);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    if (!_isValidEmail(email) || _passwordController.text.isEmpty) {
      _showError('Enter a valid email and password');
      return;
    }
    setState(() => _isLoading = true);
    try {
      await _authService.signIn(email: email, password: _passwordController.text);
      await _routeAfterAuth();
    } catch (e) {
      _showError('Invalid email or password');
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
      _showError('Google sign-in failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _routeAfterAuth() async {
    final needsOnboarding = await _authService.needsOnboarding();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => needsOnboarding ? const OnboardingWrapper() : const DashboardRoot(),
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
    return CosarcScaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: CosarcSpacing.screenHorizontal),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: CosarcSpacing.huge),
                    Text('cosarc', textAlign: TextAlign.center, style: CosarcTypography.brandMark(size: 32)),
                    const SizedBox(height: CosarcSpacing.sm),
                    Text(
                      'Welcome back',
                      textAlign: TextAlign.center,
                      style: CosarcTypography.headline(context).copyWith(fontSize: 24),
                    ),
                    const SizedBox(height: CosarcSpacing.xs),
                    Text(
                      'Sign in to continue your journey',
                      textAlign: TextAlign.center,
                      style: CosarcTypography.body(context),
                    ),
                    const SizedBox(height: CosarcSpacing.huge),
                    CosarcInput(
                      controller: _emailController,
                      label: 'Email',
                      hint: 'you@example.com',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                    ),
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
                          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: CosarcColors.textTertiary,
                          size: 20,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    const SizedBox(height: CosarcSpacing.xxl),
                    CosarcButton(
                      label: 'Sign in',
                      isLoading: _isLoading,
                      onPressed: _isLoading ? null : _login,
                    ),
                    const SizedBox(height: CosarcSpacing.md),
                    _GoogleButton(isLoading: _isLoading, onPressed: _isLoading ? null : _loginWithGoogle),
                    const SizedBox(height: CosarcSpacing.xl),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignupScreen()),
                      ),
                      child: Text(
                        'Create an account',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: CosarcColors.textSecondary,
                            ),
                      ),
                    ),
                    const SizedBox(height: CosarcSpacing.xxl),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GoogleButton extends StatelessWidget {
  const _GoogleButton({required this.isLoading, required this.onPressed});
  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isLoading ? 0.65 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(CosarcSpacing.radiusPill),
          child: Ink(
            height: CosarcSpacing.buttonHeight,
            decoration: BoxDecoration(
              color: CosarcColors.glassFill(0.055),
              borderRadius: BorderRadius.circular(CosarcSpacing.radiusPill),
              border: Border.all(color: CosarcColors.glassBorder()),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/icons/google.png',
                  height: 20,
                  width: 20,
                  errorBuilder: (_, __, ___) => const Icon(Icons.login_rounded, size: 20),
                ),
                const SizedBox(width: CosarcSpacing.sm),
                Text(
                  'Continue with Google',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
