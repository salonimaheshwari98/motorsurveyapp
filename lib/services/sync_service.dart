import 'dart:async';
import 'local_database.dart';
import 'api_service.dart';

class SyncService {
  /// Syncs all pending local records to the backend server.
  Future<int> syncPending() async {
    final db = await LocalDatabase.getInstance();
    int synced = 0;

    // Sync pending claims
    final pendingClaims = await db.query(
      'claims',
      where: 'sync_status = ?',
      whereArgs: ['pending'],
    );

    for (final row in pendingClaims) {
      try {
        await ApiService.createClaim({
          'claim_number': row['claim_number'],
          'policy_number': row['policy_number'],
          'insurer': row['insurer'],
          'insured_name': row['insured_name'],
          'phone': row['phone'],
          'vehicle_number': row['vehicle_number'],
          'vehicle_model': row['vehicle_model'],
          'manufacture_year': row['manufacture_year'],
          'accident_date': row['accident_date'],
          'accident_location': row['accident_location'],
        });
        await db.update(
          'claims',
          {'sync_status': 'synced'},
          where: 'id = ?',
          whereArgs: [row['id']],
        );
        synced++;
      } catch (_) {
        // Will retry next sync cycle
      }
    }

    return synced;
  }
}
