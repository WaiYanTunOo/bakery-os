import 'dart:developer' as developer;

class AuditLogger {
  AuditLogger._();

  static void action({
    required String actor,
    required String role,
    required String action,
    required String entity,
    String? entityId,
    Map<String, Object?> metadata = const {},
  }) {
    final payload = {
      'actor': actor,
      'role': role,
      'action': action,
      'entity': entity,
      'entityId': entityId,
      'metadata': metadata,
      'at': DateTime.now().toIso8601String(),
    };

    developer.log(
      'AUDIT $payload',
      name: 'AuditLogger',
      level: 800,
    );
  }
}
