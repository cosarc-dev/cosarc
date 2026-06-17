import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import '../../theme/cosarc_colors.dart';
import '../../widgets/cosarc_button.dart';
import '../../widgets/cosarc_page_route.dart';
import '../dashboard/dashboard_root.dart';
import '../onboarding/onboarding_wrapper.dart';
import 'otp_verification_screen.dart';
import 'signup_screen.dart';

enum _LoginMethod { password, emailOtp, phoneOtp }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();

  _LoginMethod _method = _LoginMethod.password;
  bool _obscurePassword = true;
  bool _isLoading = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _navigateAfterAuth() async {
    final needsOnboarding = await _authService.needsOnboarding();
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      CosarcPageRoute(
        page: needsOnboarding
            ? const OnboardingWrapper()
            : const DashboardRoot(),
      ),
    );
  }

  Future<void> _loginWithPassword() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      _showError('Please enter email and password');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      await _navigateAfterAuth();
    } catch (e) {
      _showError(AuthService.humanizeError(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendEmailOtp() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _showError('Enter a valid email address');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authService.sendEmailOtp(email);
      if (!mounted) return;
      Navigator.push(
        context,
        CosarcPageRoute(
          page: OtpVerificationScreen(
            channel: OtpChannel.email,
            destination: email,
          ),
        ),
      );
    } catch (e) {
      _showError(AuthService.humanizeError(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendPhoneOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.length < 10) {
      _showError('Enter a valid phone number with country code');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authService.sendPhoneOtp(phone);
      if (!mounted) return;
      Navigator.push(
        context,
        CosarcPageRoute(
          page: OtpVerificationScreen(
            channel: OtpChannel.phone,
            destination: phone,
          ),
        ),
      );
    } catch (e) {
      _showError(AuthService.humanizeError(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final success = await _authService.signInWithGoogle();
      if (!success) {
        if (mounted) _showError('Sign-in was cancelled');
        return;
      }
      await _navigateAfterAuth();
    } catch (e) {
      _showError(AuthService.humanizeError(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: CosarcColors.error,
      ),
    );
  }

  void _submit() {
    switch (_method) {
      case _LoginMethod.password:
        _loginWithPassword();
      case _LoginMethod.emailOtp:
        _sendEmailOtp();
      case _LoginMethod.phoneOtp:
        _sendPhoneOtp();
    }
  }

  String get _submitLabel {
    switch (_method) {
      case _LoginMethod.password:
        return 'Sign In';
      case _LoginMethod.emailOtp:
      case _LoginMethod.phoneOtp:
        return 'Send Code';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CosarcColors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [CosarcColors.charcoal, CosarcColors.black],
                ),
              ),
            ),
          ),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      28,
                      24,
                      28,
                      24 + MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight - 48),
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Spacer(flex: 1),
                            Text(
                              'cosarc',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 42,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                                color: CosarcColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'PREMIUM GYM ERP',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 3,
                                color: CosarcColors.gold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Welcome back',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                color: CosarcColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 36),
                            _buildMethodTabs(),
                            const SizedBox(height: 24),
                            ..._buildFields(),
                            const SizedBox(height: 24),
                            CosarcButton(
                              label: _submitLabel,
                              isLoading: _isLoading,
                              onPressed: _submit,
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                const Expanded(child: Divider()),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Text(
                                    'or',
                                    style: GoogleFonts.inter(
                                      color: CosarcColors.textMuted,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                const Expanded(child: Divider()),
                              ],
                            ),
                            const SizedBox(height: 20),
                            CosarcButton(
                              label: 'Continue with Google',
                              variant: CosarcButtonVariant.secondary,
                              icon: Icons.g_mobiledata_rounded,
                              isLoading: _isLoading,
                              onPressed: _isLoading ? null : _signInWithGoogle,
                            ),
                            const Spacer(flex: 1),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  CosarcPageRoute(
                                      page: const SignupScreen()),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: Text(
                                  "Don't have an account? Create one",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: CosarcColors.gold,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: CosarcColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CosarcColors.border),
      ),
      child: Row(
        children: [
          _tab('Password', _LoginMethod.password),
          _tab('Email OTP', _LoginMethod.emailOtp),
          _tab('Phone', _LoginMethod.phoneOtp),
        ],
      ),
    );
  }

  Widget _tab(String label, _LoginMethod method) {
    final selected = _method == method;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _method = method),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? CosarcColors.gold.withOpacity(0.15) : null,
            borderRadius: BorderRadius.circular(10),
            border: selected
                ? Border.all(color: CosarcColors.gold.withOpacity(0.4))
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: selected ? CosarcColors.gold : CosarcColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFields() {
    switch (_method) {
      case _LoginMethod.password:
        return [
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autocorrect: false,
            style: const TextStyle(color: CosarcColors.textPrimary),
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            style: const TextStyle(color: CosarcColors.textPrimary),
            decoration: InputDecoration(
              labelText: 'Password',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: CosarcColors.textMuted,
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            onSubmitted: (_) => _loginWithPassword(),
          ),
        ];
      case _LoginMethod.emailOtp:
        return [
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autocorrect: false,
            style: const TextStyle(color: CosarcColors.textPrimary),
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'you@example.com',
            ),
            onSubmitted: (_) => _sendEmailOtp(),
          ),
        ];
      case _LoginMethod.phoneOtp:
        return [
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            style: const TextStyle(color: CosarcColors.textPrimary),
            decoration: const InputDecoration(
              labelText: 'Phone number',
              hintText: '+91 98765 43210',
            ),
            onSubmitted: (_) => _sendPhoneOtp(),
          ),
        ];
    }
  }
}
