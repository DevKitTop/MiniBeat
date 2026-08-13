import 'package:flutter_test/flutter_test.dart';

import 'package:rep_mini/core/config/app_config.dart';

void main() {
  group('AppConfig.fromEnv (CFG-003)', () {
    test('exposes supabaseUrl and anonKey when both keys are present', () {
      final config = AppConfig.fromEnv({
        'SUPABASE_URL': 'https://myproject.supabase.co',
        'SUPABASE_ANON_KEY': 'public-anon-key',
      });

      expect(config.supabaseUrl, 'https://myproject.supabase.co');
      expect(config.anonKey, 'public-anon-key');
    });

    test('throws descriptive ConfigException when SUPABASE_URL is missing', () {
      expect(
        () => AppConfig.fromEnv({'SUPABASE_ANON_KEY': 'public-anon-key'}),
        throwsA(
          isA<ConfigException>().having(
            (e) => e.message,
            'message',
            contains('SUPABASE_URL'),
          ),
        ),
      );
    });

    test('throws descriptive ConfigException when SUPABASE_URL is empty', () {
      expect(
        () => AppConfig.fromEnv({
          'SUPABASE_URL': '',
          'SUPABASE_ANON_KEY': 'public-anon-key',
        }),
        throwsA(isA<ConfigException>()),
      );
    });

    test('throws descriptive ConfigException when SUPABASE_ANON_KEY is missing', () {
      expect(
        () => AppConfig.fromEnv({'SUPABASE_URL': 'https://myproject.supabase.co'}),
        throwsA(
          isA<ConfigException>().having(
            (e) => e.message,
            'message',
            contains('SUPABASE_ANON_KEY'),
          ),
        ),
      );
    });

    test('throws descriptive ConfigException when SUPABASE_ANON_KEY is empty', () {
      expect(
        () => AppConfig.fromEnv({
          'SUPABASE_URL': 'https://myproject.supabase.co',
          'SUPABASE_ANON_KEY': '',
        }),
        throwsA(isA<ConfigException>()),
      );
    });
  });
}
