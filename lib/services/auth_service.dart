import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../core/supabase_config.dart';

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
      print('🔵 Starting signup for: $email');

      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Failed to create user account');
      }

      print('🔵 Creating member record...');

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

      print('✅ Signup complete!');
      return response;
    } catch (e) {
      print('❌ Signup error: $e');
      rethrow;
    }
  }

  Future<bool> signInWithGoogle() async {
    if (kIsWeb) {
      return await signInWithGoogleWeb();
    }
    return await signInWithGoogleNative();
  }

  Future<bool> signInWithGoogleWeb() async {
    try {
      print('🔵 Starting Google OAuth (Web)...');

      // Get current URL for redirect
      final currentUrl = Uri.base.toString();
      print('🔵 Current URL: $currentUrl');

      // Start OAuth flow
      await supabase.auth.signInWithOAuth(
        Provider.google,
        redirectTo: currentUrl,
        authScreenLaunchMode: LaunchMode.platformDefault,
      );

      // Wait a moment for redirect to complete
      await Future.delayed(Duration(seconds: 1));

      // Check if user is now logged in
      final session = supabase.auth.currentSession;
      if (session != null) {
        print('✅ Session found after OAuth');
        await _ensureMemberExists();
        return true;
      }

      print('⚠️ No session yet, user will be redirected');
      return true;
    } catch (e) {
      print('❌ Google OAuth error: $e');
      rethrow;
    }
  }

  Future<bool> signInWithGoogleNative() async {
    try {
      print('🔵 Starting Google Sign-In (Native)...');

      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print('⚠️ User cancelled');
        return false;
      }

      print('✅ Google user: ${googleUser.email}');

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null || idToken == null) {
        throw Exception('Missing tokens');
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
      print('❌ Native Google error: $e');
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
        print('🔵 Creating member for OAuth user');

        await supabase.from('members').insert({
          'auth_user_id': user.id,
          'email': user.email,
          'name': user.userMetadata?['full_name'] ??
              user.email?.split('@')[0] ??
              'User',
        });

        final member = await supabase
            .from('members')
            .select('id')
            .eq('auth_user_id', user.id)
            .single();

        await supabase.from('streaks').insert({
          'member_id': member['id'],
        });

        print('✅ Member created');
      }
    } catch (e) {
      print('❌ Error ensuring member: $e');
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
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
      if (!kIsWeb) await _googleSignIn.signOut();
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
      print('❌ Error getting member ID: $e');
      return null;
    }
  }
}
