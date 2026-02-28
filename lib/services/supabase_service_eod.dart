part of 'supabase_service.dart';

extension SupabaseServiceEod on SupabaseService {
  Future<bool> insertEodReport({required String shift, required double grossSales, required double promptpay, required double card, required double expectedCash, required double actualCash, required double discrepancy, required String note}) async {
    try {
      InputValidator.validateEodReport(
        shift: shift,
        grossSales: grossSales,
        promptpay: promptpay,
        card: card,
        expectedCash: expectedCash,
        actualCash: actualCash,
        discrepancy: discrepancy,
        note: note,
      );
      final record = {
        'shift': shift.trim(),
        'gross_sales': grossSales,
        'promptpay': promptpay,
        'card': card,
        'expected_cash': expectedCash,
        'actual_cash': actualCash,
        'discrepancy': discrepancy,
        'note': note.trim(),
        'created_at': DateTime.now().toIso8601String(),
      };
      final res = await client.from('eod_reports').insert(record);
      return res != null;
    } on ValidationError {
      rethrow;
    } catch (e) {
      developer.log('SupabaseService.insertEodReport error: $e', name: 'SupabaseService');
      return false;
    }
  }
}