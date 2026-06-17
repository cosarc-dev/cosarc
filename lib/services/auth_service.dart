import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../core/supabase_config.dart';

class AuthService {
  GoogleSignIn get _googleSignIn {
    final webClientId = SupabaseConfig.googleWebClientId;
    return GoogleSignIn(
      scopes: const ['email', 'profile'],
      serverClientId: webClientId.isNotEmpty ? webClientId : null,
    );
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
    Map<String, dynamic>? onboardingData,
  }) async {
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': name},
      );

      if (response.user == null) {
        throw Exception('Failed to create user account');
      }

      await supabase.from('members').insert({
        'auth_user_id': response.user!.id,
        'email': email,
        'name': name,
      });

      final member = await supabase
          .from('members')
          .select('id')
          .eq('auth_user_id', response.user!.id)
          .single();

      await supabase.from('streaks').insert({
        'member_id': member['id'],
      });

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendEmailOtp(String email) async {
    await supabase.auth.signInWithOtp(
      email: email.trim(),
      shouldCreateUser: true,
    );
  }

  Future<AuthResponse> verifyEmailOtp({
    required String email,
    required String token,
  }) async {
    final response = await supabase.auth.verifyOTP(
      type: OtpType.email,
      email: email.trim(),
      token: token.trim(),
    );

    if (response.user != null) {
      await _ensureMemberExists();
    }

    return response;
  }

  Future<void> sendPhoneOtp(String phone) async {
    final formatted = _formatPhone(phone);
    await supabase.auth.signInWithOtp(
      phone: formatted,
      shouldCreateUser: true,
    );
  }

  Future<AuthResponse> verifyPhoneOtp({
    required String phone,
    required String token,
  }) async {
    final formatted = _formatPhone(phone);
    final response = await supabase.auth.verifyOTP(
      type: OtpType.sms,
      phone: formatted,
      token: token.trim(),
    );

    if (response.user != null) {
      await _ensureMemberExists();
    }

    return response;
  }

  String _formatPhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (cleaned.startsWith('+')) return cleaned;
    if (cleaned.startsWith('91') && cleaned.length == 12) return '+$cleaned';
    if (cleaned.length == 10) return '+91$cleaned';
    return '+$cleaned';
  }

  Future<bool> signInWithGoogle() async {
    if (kIsWeb) {
      return await signInWithGoogleWeb();
    }
    return await signInWithGoogleNative();
  }

  Future<bool> signInWithGoogleWeb() async {
    try {
      final currentUrl = Uri.base.toString();

      await supabase.auth.signInWithOAuth(
        Provider.google,
        redirectTo: currentUrl,
        authScreenLaunchMode: LaunchMode.platformDefault,
      );

      await Future.delayed(const Duration(seconds: 1));

      final session = supabase.auth.currentSession;
      if (session != null) {
        await _ensureMemberExists();
        return true;
      }

      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> signInWithGoogleNative() async {
    try {
      if (SupabaseConfig.googleWebClientId.isEmpty) {
        throw Exception(
          'Google Sign-In requires GOOGLE_WEB_CLIENT_ID. '
          'Set via --dart-define=GOOGLE_WEB_CLIENT_ID=your-web-client-id',
        );
      }

      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return false;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception(
          'Google Sign-In failed: missing ID token. '
          'Verify GOOGLE_WEB_CLIENT_ID matches your Supabase Google provider.',
        );
      }

      final response = await supabase.auth.signInWithIdToken(
        provider: Provider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (response.user != null) {
        await _ensureMemberExists();
        return true;
      }

      return false;
    } catch (e) {
      try {
        await _googleSignIn.signOut();
      } catch (_) {}
      rethrow;
    }
  }

  Future<void> _ensureMemberExists() async {
    if (!isLoggedIn) return;

    try {
      final user = currentUser!;

      final existingMember = await supabase
          .from('members')
          .select('id')
          .eq('auth_user_id', user.id)
          .maybeSingle();

      if (existingMember == null) {
        final name = user.userMetadata?['full_name'] ??
            user.userMetadata?['name'] ??
            user.email?.split('@')[0] ??
            user.phone ??
            'User';

        await supabase.from('members').insert({
          'auth_user_id': user.id,
          'email': user.email,
          'name': name,
        });

        final member = await supabase
            .from('members')
            .select('id')
            .eq('auth_user_id', user.id)
            .single();

        await supabase.from('streaks').insert({
          'member_id': member['id'],
        });
      }
    } catch (e) {
      print('Error ensuring member: $e');
    }
  }

  Future<bool> needsOnboarding() async {
    if (!isLoggedIn) return true;

    try {
      final member = await supabase
          .from('members')
          .select('age')
          .eq('auth_user_id', currentUser!.id)
          .single();

      final age = member['age'];
      return age == null || age == 0;
    } catch (e) {
      return true;
    }
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await supabase.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
      if (!kIsWeb) {
        try {
          await _googleSignIn.signOut();
        } catch (_) {}
      }
    } catch (e) {
      print('Signout error: $e');
    }
  }

  User? get currentUser => supabase.auth.currentUser;
  bool get isLoggedIn => currentUser != null;

  Future<String?> getMemberId() async {
    if (!isLoggedIn) return null;

    try {
      final data = await supabase
          .from('members')
          .select('id')
          .eq('auth_user_id', currentUser!.id)
          .single();
      return data['id'];
    } catch (e) {
      print('Error getting member ID: $e');
      return null;
    }
  }

  static String humanizeError(Object error) {
    final message = error.toString().toLowerCase();

    if (message.contains('invalid login credentials') ||
        message.contains('invalid_credentials')) {
      return 'Invalid email or password. Please try again.';
    }
    if (message.contains('email not confirmed')) {
      return 'Please verify your email before signing in.';
    }
    if (message.contains('user already registered')) {
      return 'An account with this email already exists. Try signing in.';
    }
    if (message.contains('otp') && message.contains('expired')) {
      return 'This code has expired. Request a new one.';
    }
    if (message.contains('invalid otp') || message.contains('token')) {
      return 'Invalid verification code. Please check and try again.';
    }
    if (message.contains('phone') && message.contains('invalid')) {
      return 'Invalid phone number. Include country code (e.g. +91).';
    }
    if (message.contains('developer_error') || message.contains('10:')) {
      return 'Google Sign-In configuration error. '
          'Verify SHA-1 fingerprint and Web Client ID.';
    }
    if (message.contains('network')) {
      return 'Network error. Check your connection and try again.';
    }
    if (message.contains('rate limit')) {
      return 'Too many attempts. Please wait a moment and try again.';
    }

    return 'Something went wrong. Please try again.';
  }
}
