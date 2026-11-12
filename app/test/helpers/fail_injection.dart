import 'package:shop_app/core/backup/backup_models.dart';
import 'package:shop_app/core/backup/backup_service.dart';
import 'package:shop_app/core/db/app_database.dart';

/// Makes the database fail part-way through a save, the way a full disk, a dying
/// battery or a crash would. A SQLite trigger refuses the n-th new row written
/// to one table (n = 1 is the very next row), so a test can fail every step of a save.
class FailInjection {
  FailInjection(this.db);
  final AppDatabase db;
  var _n = 0;

  /// Refuse the [nth] row inserted into [table] from now on (1 = the next one).
  Future<String> failInsert(String table, {int nth = 1, String message = 'disk I/O error'}) async {
    final base = (await db.customSelect('SELECT COUNT(*) AS c FROM $table').getSingle()).data['c'] as int;
    final name = 'fail_${table}_${++_n}';
    await db.customStatement(
        'CREATE TRIGGER $name BEFORE INSERT ON $table '
        "WHEN (SELECT COUNT(*) FROM $table) >= ${base + nth - 1} "
        "BEGIN SELECT RAISE(ABORT, '$message'); END");
    return name;
  }

  Future<void> remove(String trigger) => db.customStatement('DROP TRIGGER IF EXISTS $trigger');

  /// Every table's row count and the shop's key sums, to compare before and after.
  Future<DbFingerprint> snapshot() => liveFingerprint(db);
}
