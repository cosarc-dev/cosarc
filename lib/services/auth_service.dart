import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/supabase_config.dart';
import '../domain/onboarding/onboarding_profile.dart';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
    Map<String, dynamic>? onboardingData,
  }) async {
    try {
      final cleanEmail = email.trim();
      final response = await supabase.auth
          .signUp(
            email: cleanEmail,
            password: password,
            data: {'full_name': name.trim()},
          )
          .timeout(const Duration(seconds: 20));

      final user = response.user;
      if (user == null) {
        throw Exception('Failed to create user account');
      }

      await ensureMemberExists(user, fallbackName: name.trim());
      debugPrint('Signup complete for $cleanEmail');
      return response;
    } catch (e) {
      debugPrint('Signup error: $e');
      rethrow;
    }
  }

  Future<bool> signInWithGoogle() async {
    if (kIsWeb) {
      return signInWithGoogleWeb();
    }
    return signInWithGoogleNative();
  }

  Future<bool> signInWithGoogleWeb() async {
    try {
      final currentUrl = Uri.base.toString();
      await supabase.auth
          .signInWithOAuth(
            Provider.google,
            redirectTo: currentUrl,
            authScreenLaunchMode: LaunchMode.platformDefault,
          )
          .timeout(const Duration(seconds: 20));

      await Future.delayed(const Duration(seconds: 1));

      final session = supabase.auth.currentSession;
      if (session != null) {
        await ensureMemberExists(session.user);
      }

      return true;
    } catch (e) {
      debugPrint('Google OAuth error: $e');
      rethrow;
    }
  }

  Future<bool> signInWithGoogleNative() async {
    try {
      await _googleSignIn.signOut();

      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return false;

      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null || idToken == null) {
        throw Exception('Google sign-in did not return the required tokens.');
      }

      final response = await supabase.auth
          .signInWithIdToken(
            provider: Provider.google,
            idToken: idToken,
            accessToken: accessToken,
          )
          .timeout(const Duration(seconds: 20));

      final user = response.user;
      if (user == null) return false;

      await ensureMemberExists(user);
      return true;
    } catch (e) {
      debugPrint('Native Google error: $e');
      try {
        await _googleSignIn.signOut();
      } catch (_) {}
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> ensureMemberExists(
    User? user, {
    String? fallbackName,
  }) async {
    user ??= currentUser;
    if (user == null) return null;

    Map<String, dynamic>? member = await _findMember(user.id);
    if (member == null) {
      final name = fallbackName?.trim().isNotEmpty == true
          ? fallbackName!.trim()
          : user.userMetadata?['full_name'] ??
              user.email?.split('@').first ??
              'User';

      try {
        await supabase.from('members').insert({
          'auth_user_id': user.id,
          'email': user.email,
          'name': name,
        }).timeout(const Duration(seconds: 10));
      } catch (e) {
        debugPrint('Member insert skipped/retried: $e');
      }

      member = await _findMember(user.id);
    }

    final memberId = member?['id'];
    if (memberId != null) {
      await _ensureStreakExists(memberId.toString());
    }

    return member;
  }

  Future<Map<String, dynamic>?> _findMember(String authUserId) async {
    try {
      return await supabase
          .from('members')
          .select('id')
          .eq('auth_user_id', authUserId)
          .maybeSingle()
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      debugPrint('Error finding member: $e');
      return null;
    }
  }

  Future<void> _ensureStreakExists(String memberId) async {
    try {
      final existing = await supabase
          .from('streaks')
          .select('id')
          .eq('member_id', memberId)
          .maybeSingle()
          .timeout(const Duration(seconds: 10));

      if (existing != null) return;

      await supabase.from('streaks').insert({
        'member_id': memberId,
      }).timeout(const Duration(seconds: 10));
    } catch (e) {
      debugPrint('Streak insert skipped/retried: $e');
    }
  }

  Future<bool> needsOnboarding() async {
    if (!isLoggedIn) return true;

    try {
      await ensureMemberExists(currentUser);

      final member = await supabase
          .from('members')
          .select(OnboardingProfile.selectColumns)
          .eq('auth_user_id', currentUser!.id)
          .maybeSingle()
          .timeout(const Duration(seconds: 10));

      return !OnboardingProfile.isComplete(member);
    } catch (e) {
      debugPrint('Full onboarding check failed, falling back to age gate: $e');
      try {
        final member = await supabase
            .from('members')
            .select('age')
            .eq('auth_user_id', currentUser!.id)
            .maybeSingle()
            .timeout(const Duration(seconds: 10));
        final age = member?['age'];
        return age == null || (age is num && age < 13);
      } catch (_) {
        return true;
      }
    }
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    final response = await supabase.auth
        .signInWithPassword(
          email: email.trim(),
          password: password,
        )
        .timeout(const Duration(seconds: 20));

    await ensureMemberExists(response.user);
    return response;
  }

  Future<void> signOut() async {
    try {
      await supabase.auth.signOut().timeout(const Duration(seconds: 10));
      if (!kIsWeb) await _googleSignIn.signOut();
    } catch (e) {
      debugPrint('Signout error: $e');
    }
  }

  User? get currentUser => supabase.auth.currentUser;
  bool get isLoggedIn => currentUser != null;

  Future<String?> getMemberId() async {
    if (!isLoggedIn) return null;

    try {
      final member = await ensureMemberExists(currentUser);
      return member?['id']?.toString();
    } catch (e) {
      debugPrint('Error getting member ID: $e');
      return null;
    }
  }
}
