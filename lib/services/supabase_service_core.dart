part of 'supabase_service.dart';

class SupabaseService {
  SupabaseService._privateConstructor();
  static final SupabaseService instance = SupabaseService._privateConstructor();

  SupabaseClient client = Supabase.instance.client;

  void overrideClient(SupabaseClient newClient) => client = newClient;

  RealtimeChannel subscribeToTable(String table, Function(PostgresChangePayload) callback) {
    return client
        .channel('public:$table')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: table,
          callback: callback,
        )
        .subscribe();
  }
}