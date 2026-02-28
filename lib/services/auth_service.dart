import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  static const Set<String> _allowedRoles = {'Owner', 'FH', 'BH'};

  SupabaseClient get _client => Supabase.instance.client;

  Stream<AuthState> get authChanges => _client.auth.onAuthStateChange;

  Future<void> signIn({required String email, required String password}) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty || !normalizedEmail.contains('@')) {
      throw AuthException('Please enter a valid email address.');
    }
    if (password.trim().length < 8) {
      throw AuthException('Password must be at least 8 characters.');
    }
    await _client.auth.signInWithPassword(email: normalizedEmail, password: password);
  }

  Future<void> signOut() => _client.auth.signOut();

  Future<Map<String, dynamic>?> resolveCurrentUserProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    final metadata = {
      ...user.appMetadata,
      ...user.userMetadata ?? <String, dynamic>{},
    };
    final role = _extractRole(metadata['app_role'] ?? metadata['role']);
    final staffName = _extractString(metadata['staff_name'] ?? metadata['name'] ?? metadata['full_name']);
    final staffId = _extractString(metadata['staff_id']);
    final canManageProducts = _extractBool(metadata['can_manage_products']);

    if (role != null && staffName != null) {
      return {
        'id': staffId ?? user.id,
        'name': staffName,
        'role': role,
        'can_manage_products': canManageProducts,
      };
    }

    final directoryRows = await _client
        .from('staff_directory')
        .select('id, name, role, can_manage_products');

    final staffDirectory = List<Map<String, dynamic>>.from(directoryRows as List<dynamic>);
    Map<String, dynamic>? matched;
    if (staffId != null) {
      matched = _findByField(staffDirectory, 'id', staffId);
    }
    if (matched == null && staffName != null) {
      matched = _findByField(staffDirectory, 'name', staffName);
    }
    matched ??= _findByField(staffDirectory, 'id', user.id);

    if (matched == null) return null;
    final matchedRole = _extractRole(matched['role']);
    if (matchedRole == null) return null;

    return {
      'id': (matched['id'] ?? user.id).toString(),
      'name': (matched['name'] ?? user.email ?? 'Staff').toString(),
      'role': matchedRole,
      'can_manage_products': matched['can_manage_products'] == true,
    };
  }

  Map<String, dynamic>? _findByField(List<Map<String, dynamic>> rows, String field, String value) {
    final normalized = value.trim().toLowerCase();
    for (final row in rows) {
      if ((row[field] ?? '').toString().trim().toLowerCase() == normalized) {
        return row;
      }
    }
    return null;
  }

  String? _extractRole(dynamic value) {
    final role = _extractString(value);
    if (role == null || !_allowedRoles.contains(role)) return null;
    return role;
  }

  String? _extractString(dynamic value) {
    final stringValue = value?.toString().trim();
    if (stringValue == null || stringValue.isEmpty) return null;
    return stringValue;
  }

  bool _extractBool(dynamic value) => value == true;
}
