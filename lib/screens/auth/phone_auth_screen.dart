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
import 'otp_verification_screen.dart';

enum PhoneAuthMode { signIn, signUp }

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key, this.mode = PhoneAuthMode.signIn});

  final PhoneAuthMode mode;

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final _authService = AuthService();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
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
        MaterialPageRoute(
          builder: (_) => OtpVerificationScreen(
            phone: phone,
            onVerified: _routeAfterAuth,
          ),
        ),
      );
    } catch (e) {
      _showError(_authService.friendlyAuthError(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _routeAfterAuth() async {
    final needsOnboarding = await _authService.needsOnboarding();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) =>
            needsOnboarding ? const OnboardingWrapper() : const DashboardRoot(),
      ),
      (route) => false,
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: CosarcColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CosarcScaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: CosarcSpacing.screenHorizontal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: CosarcSpacing.lg),
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
              ),
              const SizedBox(height: CosarcSpacing.lg),
              Text('Phone sign-in', style: CosarcTypography.headline(context)),
              const SizedBox(height: CosarcSpacing.sm),
              Text(
                'We\'ll text you a one-time code. Include your country code.',
                style: CosarcTypography.body(context),
              ),
              const SizedBox(height: CosarcSpacing.xxl),
              CosarcInput(
                controller: _phoneController,
                label: 'Phone number',
                hint: '+1 555 000 0000',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: CosarcSpacing.xxl),
              CosarcButton(
                label: 'Send code',
                isLoading: _isLoading,
                onPressed: _isLoading ? null : _sendCode,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
