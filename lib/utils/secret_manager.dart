import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'secret_manager_validation.dart';

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
    if (!SecretManagerValidation.isLikelySupabaseUrl(url)) {
      throw const SecretManagerException('SUPABASE_URL is invalid.');
    }
    if (!SecretManagerValidation.isLikelySupabaseAnonKey(anonKey)) {
      throw const SecretManagerException('SUPABASE_ANON_KEY is invalid.');
    }
  }

  static bool isLikelySupabaseUrl(String value) {
    return SecretManagerValidation.isLikelySupabaseUrl(value);
  }

  static bool isLikelySupabaseAnonKey(String value) {
    return SecretManagerValidation.isLikelySupabaseAnonKey(value);
  }
}
