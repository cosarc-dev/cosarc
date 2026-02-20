import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../onboarding/onboarding_wrapper.dart';
import '../dashboard/dashboard_root.dart';

const Color cosarcPink = Color(0xFFE91E63);

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

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  bool _isLoading = false;
  bool _showEmailForm = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _signUpWithEmail() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
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
      print('🔵 Email signup: ${_emailController.text}');

      await _authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        onboardingData: null,
      );

      print('✅ Account created, going to onboarding');

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OnboardingWrapper()),
        );
      }
    } catch (e) {
      print('❌ Signup error: $e');
      _showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signUpWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      print('🔵 Starting Google signup flow...');

      final success = await _authService.signInWithGoogle();

      if (!success) {
        print('⚠️ User cancelled Google sign-in');
        if (mounted) {
          _showError('Sign-in was cancelled');
        }
        return;
      }

      print('✅ Google authentication successful');
      print('🔵 Checking onboarding status...');

      final needsOnboarding = await _authService.needsOnboarding();

      if (mounted) {
        if (needsOnboarding) {
          print('🔵 Navigating to onboarding...');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const OnboardingWrapper()),
          );
        } else {
          print('🔵 Navigating to dashboard...');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const DashboardRoot()),
          );
        }
      }
    } catch (e) {
      print('❌ Google sign-in failed: $e');

      String errorMessage = 'Google sign-in failed. ';

      if (e.toString().contains('DEVELOPER_ERROR')) {
        errorMessage +=
            'Please check SHA-1 configuration in Google Cloud Console.';
      } else if (e.toString().contains('network_error')) {
        errorMessage += 'Please check your internet connection.';
      } else if (e.toString().contains('sign_in_failed')) {
        errorMessage += 'Unable to complete sign-in. Try again.';
      } else if (e.toString().contains('PlatformException')) {
        errorMessage += 'Google Play Services error.';
      } else {
        errorMessage += 'Please try again.';
      }

      if (mounted) {
        _showError(errorMessage);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showComingSoon(String method) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1A1A1A),
        title: Text('Coming Soon', style: TextStyle(color: Colors.white)),
        content: Text(
          '$method sign-in requires additional setup. Please use email or Google for now.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: cosarcPink)),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topLeft,
                radius: 1.5,
                colors: [
                  cosarcPink.withOpacity(0.08),
                  Colors.black,
                ],
              ),
            ),
          ),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child:
                    _showEmailForm ? _buildEmailForm() : _buildSocialOptions(),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            child: IconButton(
              onPressed: () {
                if (_showEmailForm) {
                  setState(() => _showEmailForm = false);
                } else {
                  Navigator.pop(context);
                }
              },
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white.withOpacity(0.8),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialOptions() {
    return Column(
      children: [
        const SizedBox(height: 60),
        Text(
          "Welcome",
          style: TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.w300,
            color: Colors.white,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Choose how you'd like to continue",
          style: TextStyle(
            fontSize: 15,
            color: Colors.white.withOpacity(0.5),
            fontWeight: FontWeight.w400,
          ),
        ),
        const Spacer(),
        if (_isLoading)
          Column(
            children: [
              CircularProgressIndicator(color: cosarcPink),
              const SizedBox(height: 16),
              Text(
                'Signing you in...',
                style: TextStyle(color: Colors.white.withOpacity(0.7)),
              ),
            ],
          )
        else ...[
          _buildSocialButton(
            icon: 'assets/icons/google.png',
            label: 'Continue with Google',
            onPressed: _signUpWithGoogle,
            isPrimary: true,
          ),
          const SizedBox(height: 16),
          _buildSocialButton(
            icon: null,
            iconWidget: const Icon(Icons.apple, color: Colors.white, size: 24),
            label: 'Continue with Apple',
            onPressed: () => _showComingSoon('Apple'),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                  child: Divider(
                      color: Colors.white.withOpacity(0.1), thickness: 1)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'or',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.3),
                    fontSize: 13,
                  ),
                ),
              ),
              Expanded(
                  child: Divider(
                      color: Colors.white.withOpacity(0.1), thickness: 1)),
            ],
          ),
          const SizedBox(height: 32),
          _buildSocialButton(
            icon: null,
            iconWidget:
                const Icon(Icons.email_outlined, color: Colors.white, size: 22),
            label: 'Continue with Email',
            onPressed: () => setState(() => _showEmailForm = true),
          ),
          const SizedBox(height: 14),
          _buildSocialButton(
            icon: null,
            iconWidget: const Icon(Icons.phone_android_rounded,
                color: Colors.white, size: 22),
            label: 'Continue with Phone',
            onPressed: () => _showComingSoon('Phone'),
          ),
        ],
        const Spacer(),
        Padding(
          padding: const EdgeInsets.only(bottom: 32),
          child: Text(
            'By continuing, you agree to our Terms & Privacy Policy',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.3),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailForm() {
    return Column(
      children: [
        const SizedBox(height: 60),
        Text(
          "Create Account",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Sign up with your email",
          style: TextStyle(
            fontSize: 15,
            color: Colors.white.withOpacity(0.5),
          ),
        ),
        const Spacer(),
        TextField(
          controller: _nameController,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Full Name',
            labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: cosarcPink, width: 2),
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Email',
            labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: cosarcPink, width: 2),
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passwordController,
          obscureText: true,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Password (min 6 characters)',
            labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: cosarcPink, width: 2),
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
          ),
          onSubmitted: (_) => _signUpWithEmail(),
        ),
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [cosarcPink, Color(0xFFD81B60)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: cosarcPink.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: _isLoading ? null : _signUpWithEmail,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
        const Spacer(),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildSocialButton({
    String? icon,
    Widget? iconWidget,
    required String label,
    required VoidCallback onPressed,
    bool isPrimary = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: isPrimary ? Colors.white : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isPrimary
                  ? Colors.transparent
                  : Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null)
                  Image.asset(
                    icon,
                    height: 22,
                    width: 22,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.login,
                      color: isPrimary ? Colors.black : Colors.white,
                      size: 22,
                    ),
                  )
                else if (iconWidget != null)
                  iconWidget,
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isPrimary ? Colors.black : Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
