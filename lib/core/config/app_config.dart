/// Raised when required configuration is missing or malformed (CFG-003).
class ConfigException implements Exception {
  const ConfigException(this.message);

  final String message;

  @override
  String toString() => 'ConfigException: $message';
}

/// Runtime configuration loaded from the environment (CFG-003).
///
/// No silent defaults: a missing required key throws [ConfigException] so the
/// app fails fast at startup instead of misbehaving later.
class AppConfig {
  const AppConfig({required this.supabaseUrl, required this.anonKey});

  /// Supabase project URL (from `SUPABASE_URL`).
  final String supabaseUrl;

  /// Supabase public anon key (from `SUPABASE_ANON_KEY`).
  ///
  /// The anon key is not a secret: access is enforced by backend/storage
  /// authorization (RLS), never by client-side keys (CFG-002, AGENTS.md).
  final String anonKey;

  /// Builds the config from an environment map (e.g. `dotenv.env`).
  ///
  /// Throws [ConfigException] naming the missing key when a required entry is
  /// absent or empty.
  factory AppConfig.fromEnv(Map<String, String> env) {
    final supabaseUrl = env['SUPABASE_URL'];
    if (supabaseUrl == null || supabaseUrl.isEmpty) {
      throw const ConfigException(
        'Missing required key SUPABASE_URL in environment; check .env (CFG-003).',
      );
    }

    final anonKey = env['SUPABASE_ANON_KEY'];
    if (anonKey == null || anonKey.isEmpty) {
      throw const ConfigException(
        'Missing required key SUPABASE_ANON_KEY in environment; '
        'check .env (CFG-003).',
      );
    }

    return AppConfig(supabaseUrl: supabaseUrl, anonKey: anonKey);
  }
}
