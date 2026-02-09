import 'package:flutter/material.dart';
import '../onboarding/onboarding_wrapper.dart';

const Color cosarcPink = Color(0xFFE91E63);

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

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
    super.dispose();
  }

  void _goToOnboarding() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const OnboardingWrapper(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Gradient overlay
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
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    
                    // Header
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
                    
                    // Google button
                    _buildSocialButton(
                      icon: 'assets/icons/google.png',
                      label: 'Continue with Google',
                      onPressed: _goToOnboarding,
                      isPrimary: true,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Apple button
                    _buildSocialButton(
                      icon: null,
                      iconWidget: const Icon(Icons.apple, color: Colors.white, size: 24),
                      label: 'Continue with Apple',
                      onPressed: _goToOnboarding,
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Divider
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.white.withOpacity(0.1), thickness: 1)),
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
                        Expanded(child: Divider(color: Colors.white.withOpacity(0.1), thickness: 1)),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Email button
                    _buildSocialButton(
                      icon: null,
                      iconWidget: const Icon(Icons.email_outlined, color: Colors.white, size: 22),
                      label: 'Continue with Email',
                      onPressed: _goToOnboarding,
                    ),
                    
                    const SizedBox(height: 14),
                    
                    // Phone button
                    _buildSocialButton(
                      icon: null,
                      iconWidget: const Icon(Icons.phone_android_rounded, color: Colors.white, size: 22),
                      label: 'Continue with Phone',
                      onPressed: _goToOnboarding,
                    ),
                    
                    const Spacer(),
                    
                    // Terms
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
                ),
              ),
            ),
          ),
          
          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
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
              color: isPrimary ? Colors.transparent : Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null)
                  Image.asset(icon, height: 22, width: 22)
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
