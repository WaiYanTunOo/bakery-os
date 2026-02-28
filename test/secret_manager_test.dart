import 'package:bakery_os/utils/secret_manager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SecretManager validation', () {
    test('accepts valid supabase url', () {
      expect(
        SecretManager.isLikelySupabaseUrl('https://abccompany.supabase.co'),
        isTrue,
      );
    });

    test('rejects invalid supabase url', () {
      expect(SecretManager.isLikelySupabaseUrl('http://example.com'), isFalse);
      expect(
        SecretManager.isLikelySupabaseUrl('YOUR_SUPABASE_URL_HERE'),
        isFalse,
      );
    });

    test('accepts likely valid anon key', () {
      expect(
        SecretManager.isLikelySupabaseAnonKey('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.long-key'),
        isTrue,
      );
    });

    test('rejects invalid anon key', () {
      expect(SecretManager.isLikelySupabaseAnonKey('short_key'), isFalse);
      expect(
        SecretManager.isLikelySupabaseAnonKey('YOUR_SUPABASE_ANON_KEY_HERE'),
        isFalse,
      );
    });
  });
}
