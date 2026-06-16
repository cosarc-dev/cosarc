/// Runtime configuration via `--dart-define` (production) or defaults (local dev).
///
/// Example:
/// ```bash
/// flutter run \
///   --dart-define=SUPABASE_URL=https://lgblxxixgldizfidscpz.supabase.co \
///   --dart-define=SUPABASE_ANON_KEY=your_anon_key \
///   --dart-define=USDA_API_KEY=your_usda_key
/// ```
class AppConfig {
  AppConfig._();

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://lgblxxixgldizfidscpz.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  static const String usdaApiKey = String.fromEnvironment(
    'USDA_API_KEY',
    defaultValue: '',
  );

  static const String nutritionixAppId = String.fromEnvironment(
    'NUTRITIONIX_APP_ID',
    defaultValue: '',
  );

  static const String nutritionixAppKey = String.fromEnvironment(
    'NUTRITIONIX_APP_KEY',
    defaultValue: '',
  );

  static const String edamamAppId = String.fromEnvironment(
    'EDAMAM_APP_ID',
    defaultValue: '',
  );

  static const String edamamAppKey = String.fromEnvironment(
    'EDAMAM_APP_KEY',
    defaultValue: '',
  );

  static const String spoonacularApiKey = String.fromEnvironment(
    'SPOONACULAR_API_KEY',
    defaultValue: '',
  );

  static bool get isSupabaseConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  static String? get configurationError {
    if (supabaseUrl.isEmpty) {
      return 'SUPABASE_URL is not configured.';
    }
    if (supabaseAnonKey.isEmpty) {
      return 'SUPABASE_ANON_KEY is not configured. Pass it via --dart-define.';
    }
    return null;
  }
}
