import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:rep_mini/core/policy/product_policy.dart';

void main() {
  group('ProductPolicy constants (CFG-004)', () {
    test('max upload size is exactly 30 MB', () {
      expect(ProductPolicy.maxUploadSizeBytes, 30 * 1024 * 1024);
    });

    test('allowlist contains exactly the supported formats', () {
      expect(
        ProductPolicy.supportedFormats,
        {'mp3', 'm4a', 'aac', 'flac', 'wav'},
      );
    });

    test('history limit is 20 (BR-011)', () {
      expect(ProductPolicy.historyLimit, 20);
    });

    test('duplicate policy is SHA-256 authoritative', () {
      expect(ProductPolicy.duplicatePolicy, contains('SHA-256'));
      expect(ProductPolicy.duplicatePolicy, contains('size'));
      expect(ProductPolicy.duplicatePolicy, contains('duration'));
    });
  });

  group('ProductPolicy.isSupportedFormat (CFG-004)', () {
    test('accepts every allowlisted format, case-insensitively', () {
      expect(ProductPolicy.isSupportedFormat('mp3'), isTrue);
      expect(ProductPolicy.isSupportedFormat('MP3'), isTrue);
      expect(ProductPolicy.isSupportedFormat('M4A'), isTrue);
      expect(ProductPolicy.isSupportedFormat('aac'), isTrue);
      expect(ProductPolicy.isSupportedFormat('flac'), isTrue);
      expect(ProductPolicy.isSupportedFormat('WAV'), isTrue);
    });

    test('accepts a leading dot', () {
      expect(ProductPolicy.isSupportedFormat('.mp3'), isTrue);
      expect(ProductPolicy.isSupportedFormat('.FLAC'), isTrue);
    });

    test('rejects unsupported formats such as OGG and OPUS', () {
      expect(ProductPolicy.isSupportedFormat('ogg'), isFalse);
      expect(ProductPolicy.isSupportedFormat('OPUS'), isFalse);
      expect(ProductPolicy.isSupportedFormat('wma'), isFalse);
      expect(ProductPolicy.isSupportedFormat(''), isFalse);
    });
  });

  group('ProductPolicy.isWithinUploadLimit (CFG-004)', () {
    test('accepts payloads up to and including 30 MB', () {
      expect(ProductPolicy.isWithinUploadLimit(0), isTrue);
      expect(ProductPolicy.isWithinUploadLimit(ProductPolicy.maxUploadSizeBytes),
          isTrue);
    });

    test('rejects payloads above 30 MB', () {
      expect(
        ProductPolicy.isWithinUploadLimit(ProductPolicy.maxUploadSizeBytes + 1),
        isFalse,
      );
      expect(ProductPolicy.isWithinUploadLimit(10 * 1024 * 1024 * 1024), isFalse);
    });
  });

  group('CFG-005 single source of truth', () {
    test('policy literals appear only in product_policy.dart', () {
      final libFiles = Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))
          .toList();
      // The scan must actually traverse the tree.
      expect(libFiles, isNotEmpty);

      const banned = [
        '31457280',
        '30 * 1024 * 1024',
        "'mp3'",
        "'m4a'",
        "'aac'",
        "'flac'",
        "'wav'",
      ];
      for (final file in libFiles) {
        if (file.path.endsWith('product_policy.dart')) continue;
        final content = file.readAsStringSync();
        for (final literal in banned) {
          expect(
            content,
            isNot(contains(literal)),
            reason: '${file.path} duplicates policy literal "$literal" (CFG-005)',
          );
        }
      }
    });
  });

  group('CFG-002 no secrets in code', () {
    final secretPatterns = [
      RegExp(r'service[-_]role'),
      RegExp(r'BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY'),
      RegExp(r'sk_live_[A-Za-z0-9]'),
      RegExp(r'eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}'),
    ];

    test('lib/ sources contain no secret material', () {
      final libFiles = Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))
          .toList();
      expect(libFiles, isNotEmpty);

      for (final file in libFiles) {
        final content = file.readAsStringSync();
        for (final pattern in secretPatterns) {
          expect(
            pattern.hasMatch(content),
            isFalse,
            reason: '${file.path} may contain secret material (CFG-002)',
          );
        }
      }
    });

    test('.env.example ships placeholders only', () {
      final example = File('.env.example').readAsStringSync();

      expect(example, contains('SUPABASE_URL='));
      expect(example, contains('SUPABASE_ANON_KEY='));
      expect(example, contains('YOUR_PROJECT_REF.supabase.co'));
      for (final pattern in secretPatterns) {
        expect(
          pattern.hasMatch(example),
          isFalse,
          reason: '.env.example may contain secret material (CFG-002)',
        );
      }
    });
  });
}
