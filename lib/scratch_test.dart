import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  print('Initializing Supabase client...');
  const supabaseUrl = 'https://lgblxxixgldizfidscpz.supabase.co';
  const supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJIUzI1NiIsInJlZiI6ImxnYmx4eGl4Z2xkaXpmaWRzY3B6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg1MDA1ODksImV4cCI6MjA5NDA3NjU4OX0.GYARRKYcjPrc2f-TGEAol7Zq1g4oiQJuiT8ZJpKayIA';

  final client = SupabaseClient(supabaseUrl, supabaseAnonKey);

  print('Attempting to sign up...');
  try {
    final res = await client.auth.signUp(
      email: 'testauth123@example.com',
      password: 'testPassword123!',
    );
    print('Sign up success! User: ${res.user?.id}');
  } on AuthException catch (e) {
    print(
        'AuthException during signup: ${e.message} (status: ${e.statusCode})');
  } catch (e) {
    print('Other exception during signup: $e');
  }
}
