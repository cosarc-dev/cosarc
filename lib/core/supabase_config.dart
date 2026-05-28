import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://ndwwizuoqlwkpkilcybe.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5kd3dpenVvcWx3a3BraWxjeWJlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg5OTQ3MjQsImV4cCI6MjA5NDU3MDcyNH0.tvjbmhABbQnD799Eh1r9eXpVwgJRG5yIJM5AWvlSg6M';

  static bool _isInitialized = false;
  static Object? _lastError;

  static bool get isInitialized => _isInitialized;
  static Object? get lastError => _lastError;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      ).timeout(const Duration(seconds: 12));
      _isInitialized = true;
      _lastError = null;
    } catch (error) {
      _lastError = error;
      rethrow;
    }
  }
}

SupabaseClient get supabase => Supabase.instance.client;
