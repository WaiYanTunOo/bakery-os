class SecretManagerValidation {
  const SecretManagerValidation._();

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
