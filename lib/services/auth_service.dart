import 'package:flutter/material.dart';
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
    try {
      print('🔵 Starting Google Sign-In...');

      // Clear any existing session
      await _googleSignIn.signOut();

      // Start sign-in flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print('⚠️ User cancelled sign-in');
        return false;
      }

      print('✅ Google account selected: ${googleUser.email}');

      // Get authentication tokens
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null || idToken == null) {
        print('❌ Missing authentication tokens');
        throw Exception('Failed to get authentication tokens from Google');
      }

      print('🔵 Tokens received, authenticating with Supabase...');
      print('Access Token: ${accessToken.substring(0, 20)}...');
      print('ID Token: ${idToken.substring(0, 20)}...');

      // Authenticate with Supabase
      final response = await supabase.auth.signInWithIdToken(
        provider: Provider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (response.user == null) {
        throw Exception('Failed to create Supabase session');
      }

      print('✅ Supabase session created for: ${response.user!.email}');

      // Check if member record exists
      final existingMember = await supabase
          .from('members')
          .select('id, age')
          .eq('auth_user_id', response.user!.id)
          .maybeSingle();

      if (existingMember == null) {
        print('🔵 Creating new member record...');

        await supabase.from('members').insert({
          'auth_user_id': response.user!.id,
          'email': response.user!.email,
          'name': googleUser.displayName ??
              response.user!.email?.split('@')[0] ??
              'User',
        });

        final member = await supabase
            .from('members')
            .select('id')
            .eq('auth_user_id', response.user!.id)
            .single();

        await supabase.from('streaks').insert({
          'member_id': member['id'],
        });

        print('✅ New member record created');
      } else {
        print('✅ Existing member found');
      }

      return true;
    } catch (e, stackTrace) {
      print('❌ Google sign-in error: $e');
      print('Stack trace: $stackTrace');

      // Clean up on error
      try {
        await _googleSignIn.signOut();
      } catch (cleanupError) {
        print('⚠️ Cleanup failed: $cleanupError');
      }

      rethrow;
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
      bool needs = age == null || age == 0;
      print('🔵 User needs onboarding: $needs');
      return needs;
    } catch (e) {
      print('❌ Error checking onboarding status: $e');
      return true;
    }
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      print('🔵 Signing in: $email');

      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      print('✅ Login successful');
      return response;
    } catch (e) {
      print('❌ Login error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
      await _googleSignIn.signOut();
      print('✅ Signed out');
    } catch (e) {
      print('❌ Signout error: $e');
    }
  }

  User? get currentUser => supabase.auth.currentUser;
  bool get isLoggedIn => currentUser != null;

  Future<String?> getMemberId() async {
    if (!isLoggedIn) {
      print('❌ No user logged in');
      return null;
    }

    try {
      final data = await supabase
          .from('members')
          .select('id')
          .eq('auth_user_id', currentUser!.id)
          .single();

      print('✅ Member ID: ${data['id']}');
      return data['id'];
    } catch (e) {
      print('❌ Error getting member ID: $e');
      return null;
    }
  }
}
