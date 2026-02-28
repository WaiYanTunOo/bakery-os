import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Helper for reading and writing secrets to secure storage.
///
/// **Native Platforms** (iOS, Android, macOS, Windows, Linux):
/// - Uses `flutter_secure_storage` for encrypted credential persistence
/// - On first run with `--dart-define`, stores credentials for subsequent launches
///
/// **Web Platform**:
/// - Uses `flutter_dotenv` to load from `.env` file (development only)
/// - Always requires `--dart-define` for production builds
///
/// **CI/Production**:
/// - Pass credentials via `--dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`
class SecretManagerException implements Exception {
  final String message;

  const SecretManagerException(this.message);

  @override
  String toString() => 'SecretManagerException: $message';
}

class SecretManager {
  SecretManager._();

  static const _storage = FlutterSecureStorage();
  static const _urlKey = 'SUPABASE_URL';
  static const _anonKey = 'SUPABASE_ANON_KEY';

  /// Return the stored credentials or throw if they cannot be obtained.
  ///
  /// On native platforms, credentials are stored in secure storage after first
  /// initialization via `--dart-define`. On web, uses `.env` file or `--dart-define`.
  static Future<Map<String, String>> ensureSupabaseCredentials({
    required String envUrl,
    required String envAnonKey,
  }) async {
    final defineUrl = envUrl.trim();
    final defineAnon = envAnonKey.trim();
    String? url = _clean(dotenv.env[_urlKey]);
    String? anon = _clean(dotenv.env[_anonKey]);

    if (kIsWeb) {
      if (defineUrl.isNotEmpty && defineAnon.isNotEmpty) {
        url = defineUrl;
        anon = defineAnon;
      }
    } else {
      final storedUrl = _clean(await _storage.read(key: _urlKey));
      final storedAnon = _clean(await _storage.read(key: _anonKey));
      url = storedUrl ?? url;
      anon = storedAnon ?? anon;

      if ((url == null || anon == null) &&
          defineUrl.isNotEmpty &&
          defineAnon.isNotEmpty) {
        url = defineUrl;
        anon = defineAnon;
        await _storage.write(key: _urlKey, value: url);
        await _storage.write(key: _anonKey, value: anon);
      }
    }

    _validateCredentials(url: url, anonKey: anon);

    final resolvedUrl = url!;
    final resolvedAnon = anon!;
    return {'url': resolvedUrl, 'anonKey': resolvedAnon};
  }

  /// Helper to clear stored credentials. Only works on native platforms.
  /// Useful for testing or if the user wants to reconfigure.
  static Future<void> clear() async {
    if (!kIsWeb) {
      await _storage.delete(key: _urlKey);
      await _storage.delete(key: _anonKey);
    }
  }

  static String? _clean(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }

  static void _validateCredentials({
    required String? url,
    required String? anonKey,
  }) {
    if (url == null || anonKey == null) {
      throw const SecretManagerException(
        'Supabase credentials missing. Provide SUPABASE_URL and SUPABASE_ANON_KEY.',
      );
    }
    if (!isLikelySupabaseUrl(url)) {
      throw const SecretManagerException('SUPABASE_URL is invalid.');
    }
    if (!isLikelySupabaseAnonKey(anonKey)) {
      throw const SecretManagerException('SUPABASE_ANON_KEY is invalid.');
    }
  }

  static bool isLikelySupabaseUrl(String value) {
    final parsed = Uri.tryParse(value.trim());
    if (parsed == null) return false;
    if (parsed.scheme != 'https') return false;
    if (!parsed.hasAuthority) return false;
    if (!parsed.host.contains('supabase.co')) return false;
    if (value.contains('YOUR_SUPABASE_URL_HERE')) return false;
    return true;
  }

  static bool isLikelySupabaseAnonKey(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return false;
    if (trimmed.contains('YOUR_SUPABASE_ANON_KEY_HERE')) return false;
    if (trimmed.length < 20) return false;
    return true;
  }
}
