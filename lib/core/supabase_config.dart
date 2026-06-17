import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://fqtwwcvwewwvqbvxetww.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZxdHd3Y3Z3ZXd3dnFidnhldHd3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzExMjg1NjQsImV4cCI6MjA4NjcwNDU2NH0.QAqFJWrNvQEIOu5fiLRSVR45idQWjKwSOP2KnyGPIGI';

  /// Google OAuth Web Client ID — required for native Android Google Sign-In.
  /// Get from: Google Cloud Console → APIs & Services → Credentials → Web client
  /// Must match the Client ID configured in Supabase → Authentication → Google.
  /// Pass at build time: --dart-define=GOOGLE_WEB_CLIENT_ID=xxx.apps.googleusercontent.com
  static const String googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue: '',
  );

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }
}

final supabase = Supabase.instance.client;
