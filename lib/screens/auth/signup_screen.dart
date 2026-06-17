import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import '../../theme/cosarc_colors.dart';
import '../../widgets/cosarc_button.dart';
import '../../widgets/cosarc_page_route.dart';
import '../dashboard/dashboard_root.dart';
import '../onboarding/onboarding_wrapper.dart';
import 'login_screen.dart';
import 'otp_verification_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  bool _isLoading = false;
  _SignupView _view = _SignupView.options;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _navigateAfterAuth() async {
    final needsOnboarding = await _authService.needsOnboarding();
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      CosarcPageRoute(
        page: needsOnboarding
            ? const OnboardingWrapper()
            : const DashboardRoot(),
      ),
      (_) => false,
    );
  }

  Future<void> _signUpWithEmail() async {
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      _showError('Please fill all fields');
      return;
    }
    if (_passwordController.text.length < 6) {
      _showError('Password must be at least 6 characters');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
      );
      if (mounted) {
        Navigator.pushReplacement(
          context,
          CosarcPageRoute(page: const OnboardingWrapper()),
        );
      }
    } catch (e) {
      _showError(AuthService.humanizeError(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signUpWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final success = await _authService.signInWithGoogle();
      if (!success) {
        if (mounted) _showError('Sign-up was cancelled');
        return;
      }
      await _navigateAfterAuth();
    } catch (e) {
      _showError(AuthService.humanizeError(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signUpWithEmailOtp() async {
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
            isSignUp: true,
          ),
        ),
      );
    } catch (e) {
      _showError(AuthService.humanizeError(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signUpWithPhone() async {
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
            isSignUp: true,
          ),
        ),
      );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CosarcColors.black,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  28,
                  56,
                  28,
                  28 + MediaQuery.of(context).viewInsets.bottom,
                ),
                child: _buildContent(),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: IconButton(
                  onPressed: () {
                    if (_view != _SignupView.options) {
                      setState(() => _view = _SignupView.options);
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: CosarcColors.textSecondary,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_view) {
      case _SignupView.options:
        return _buildOptions();
      case _SignupView.email:
        return _buildEmailForm();
      case _SignupView.emailOtp:
        return _buildEmailOtpForm();
      case _SignupView.phone:
        return _buildPhoneForm();
    }
  }

  Widget _buildOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        Text(
          'Join cosarc',
          style: GoogleFonts.inter(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: CosarcColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose how you\'d like to get started',
          style: GoogleFonts.inter(
            fontSize: 15,
            color: CosarcColors.textSecondary,
          ),
        ),
        const SizedBox(height: 40),
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(color: CosarcColors.gold),
            ),
          )
        else ...[
          CosarcButton(
            label: 'Continue with Google',
            variant: CosarcButtonVariant.primary,
            icon: Icons.g_mobiledata_rounded,
            onPressed: _signUpWithGoogle,
          ),
          const SizedBox(height: 14),
          CosarcButton(
            label: 'Sign up with Email & Password',
            variant: CosarcButtonVariant.secondary,
            icon: Icons.email_outlined,
            onPressed: () => setState(() => _view = _SignupView.email),
          ),
          const SizedBox(height: 14),
          CosarcButton(
            label: 'Sign up with Email OTP',
            variant: CosarcButtonVariant.secondary,
            icon: Icons.mark_email_read_outlined,
            onPressed: () => setState(() => _view = _SignupView.emailOtp),
          ),
          const SizedBox(height: 14),
          CosarcButton(
            label: 'Sign up with Phone',
            variant: CosarcButtonVariant.secondary,
            icon: Icons.phone_android_rounded,
            onPressed: () => setState(() => _view = _SignupView.phone),
          ),
        ],
        const SizedBox(height: 32),
        GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              CosarcPageRoute(page: const LoginScreen()),
            );
          },
          child: Text(
            'Already have an account? Sign in',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: CosarcColors.gold,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'By continuing, you agree to our Terms & Privacy Policy',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: CosarcColors.textMuted,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        Text(
          'Create Account',
          style: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: CosarcColors.textPrimary,
          ),
        ),
        const SizedBox(height: 32),
        TextField(
          controller: _nameController,
          textInputAction: TextInputAction.next,
          style: const TextStyle(color: CosarcColors.textPrimary),
          decoration: const InputDecoration(labelText: 'Full Name'),
        ),
        const SizedBox(height: 16),
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
          obscureText: true,
          textInputAction: TextInputAction.done,
          style: const TextStyle(color: CosarcColors.textPrimary),
          decoration: const InputDecoration(
            labelText: 'Password (min 6 characters)',
          ),
          onSubmitted: (_) => _signUpWithEmail(),
        ),
        const SizedBox(height: 24),
        CosarcButton(
          label: 'Create Account',
          isLoading: _isLoading,
          onPressed: _signUpWithEmail,
        ),
      ],
    );
  }

  Widget _buildEmailOtpForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        Text(
          'Email Sign Up',
          style: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: CosarcColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'We\'ll send a verification code to your email',
          style: GoogleFonts.inter(
            fontSize: 15,
            color: CosarcColors.textSecondary,
          ),
        ),
        const SizedBox(height: 32),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          autocorrect: false,
          style: const TextStyle(color: CosarcColors.textPrimary),
          decoration: const InputDecoration(labelText: 'Email'),
          onSubmitted: (_) => _signUpWithEmailOtp(),
        ),
        const SizedBox(height: 24),
        CosarcButton(
          label: 'Send Verification Code',
          isLoading: _isLoading,
          onPressed: _signUpWithEmailOtp,
        ),
      ],
    );
  }

  Widget _buildPhoneForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        Text(
          'Phone Sign Up',
          style: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: CosarcColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'We\'ll send an SMS verification code',
          style: GoogleFonts.inter(
            fontSize: 15,
            color: CosarcColors.textSecondary,
          ),
        ),
        const SizedBox(height: 32),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.done,
          style: const TextStyle(color: CosarcColors.textPrimary),
          decoration: const InputDecoration(
            labelText: 'Phone number',
            hintText: '+91 98765 43210',
          ),
          onSubmitted: (_) => _signUpWithPhone(),
        ),
        const SizedBox(height: 24),
        CosarcButton(
          label: 'Send SMS Code',
          isLoading: _isLoading,
          onPressed: _signUpWithPhone,
        ),
      ],
    );
  }
}

enum _SignupView { options, email, emailOtp, phone }
