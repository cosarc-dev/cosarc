import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import '../../theme/cosarc_colors.dart';
import '../../widgets/cosarc_button.dart';
import '../dashboard/dashboard_root.dart';
import '../onboarding/onboarding_wrapper.dart';

enum OtpChannel { email, phone }

class OtpVerificationScreen extends StatefulWidget {
  final OtpChannel channel;
  final String destination;
  final bool isSignUp;

  const OtpVerificationScreen({
    super.key,
    required this.channel,
    required this.destination,
    this.isSignUp = false,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _authService = AuthService();
  final _otpController = TextEditingController();
  bool _isLoading = false;
  bool _isResending = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final code = _otpController.text.trim();
    if (code.length < 6) {
      _showMessage('Enter the 6-digit code', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (widget.channel == OtpChannel.email) {
        await _authService.verifyEmailOtp(
          email: widget.destination,
          token: code,
        );
      } else {
        await _authService.verifyPhoneOtp(
          phone: widget.destination,
          token: code,
        );
      }

      if (!mounted) return;

      HapticFeedback.mediumImpact();
      _showMessage('Verified successfully');

      final needsOnboarding = await _authService.needsOnboarding();
      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => needsOnboarding
              ? const OnboardingWrapper()
              : const DashboardRoot(),
        ),
        (_) => false,
      );
    } catch (e) {
      if (mounted) {
        _showMessage(AuthService.humanizeError(e), isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resend() async {
    setState(() => _isResending = true);
    try {
      if (widget.channel == OtpChannel.email) {
        await _authService.sendEmailOtp(widget.destination);
      } else {
        await _authService.sendPhoneOtp(widget.destination);
      }
      if (mounted) _showMessage('New code sent');
    } catch (e) {
      if (mounted) _showMessage(AuthService.humanizeError(e), isError: true);
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? CosarcColors.error : CosarcColors.card,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final channelLabel =
        widget.channel == OtpChannel.email ? 'email' : 'phone';

    return Scaffold(
      backgroundColor: CosarcColors.black,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            28,
            16,
            28,
            28 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Verify your $channelLabel',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: CosarcColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We sent a 6-digit code to ${widget.destination}',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  height: 1.5,
                  color: CosarcColors.textSecondary,
                ),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 6,
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 12,
                  color: CosarcColors.textPrimary,
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  counterText: '',
                  hintText: '000000',
                  hintStyle: TextStyle(
                    letterSpacing: 12,
                    color: CosarcColors.textMuted,
                  ),
                ),
                onSubmitted: (_) => _verify(),
              ),
              const SizedBox(height: 24),
              CosarcButton(
                label: 'Verify & Continue',
                isLoading: _isLoading,
                onPressed: _verify,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _isResending ? null : _resend,
                child: _isResending
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        'Resend code',
                        style: GoogleFonts.inter(
                          color: CosarcColors.gold,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
