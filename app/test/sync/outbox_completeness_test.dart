import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/core/bootstrap.dart';
import 'package:shop_app/core/db/app_database.dart';
import 'package:shop_app/core/db/repositories/invoice_repository.dart';
import 'package:shop_app/core/db/repositories/item_repository.dart';
import 'package:shop_app/core/db/repositories/party_repository.dart';
import 'package:shop_app/core/db/repositories/return_repository.dart';
import 'package:shop_app/core/db/repositories/settings_repository.dart';
import 'package:shop_app/core/db/repositories/setup_repository.dart';
import 'package:shop_app/core/sync/device_identity.dart';

import '../helpers/seed_rich_shop.dart';

/// Wi-Fi sync sends outbox rows, so every row in every table must be in the
/// outbox, and the newest outbox payload for a row must equal the row itself.
/// A write path that forgets its outbox row (or writes half a row) fails here.
void main() {
  late AppDatabase db;
  late ShopSession s;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    s = await ensureShopSession(db, identity: MemoryDeviceIdentity());
  });
  tearDown(() => db.close());

  Future<void> busyDay() async {
    await seedRichShop(s);
    // Edits and status changes, not only inserts.
    final items = ItemRepository(s.ctx);
    final wire = (await items.search('wire')).first.item;
    await items.updateItem(
        itemId: wire.id, name: '${wire.name} FR', gstRateBp: wire.gstRateBp, minStockBase: 5000, brand: 'Polycab');
    final parties = PartyRepository(s.ctx);
    final c = (await (db.select(db.parties)..where((t) => t.kind.equals('customer'))).get()).first;
    await parties.updateParty(partyId: c.id, kind: c.kind, name: c.name, tier: 'contractor', creditLimitPaise: 500000);
    final settings = SettingsRepository(s.ctx);
    await settings.set('counter_max_discount_pct', '7');
    await settings.set('counter_max_discount_pct', '8');
    await SetupRepository(s.ctx).updateShop(name: 'Pravin Electricals', phone: '9800000000');
    final bills = await InvoiceRepository(s.ctx).list();
    await ReturnRepository(s.ctx).cancelBill(bills.first.invoice.id, deviceId: s.deviceId, series: s.series);
  }

  test('every row of every table matches its newest outbox payload', () async {
    await busyDay();

    final outbox = await (db.select(db.outbox)..orderBy([(t) => OrderingTerm.asc(t.seq)])).get();
    final newest = <String, Map<String, dynamic>>{};
    for (final o in outbox) {
      newest['${o.entity}/${o.entityId}'] = jsonDecode(o.payloadJson) as Map<String, dynamic>;
    }

    final problems = <String>[];
    var tablesWithRows = 0;
    for (final table in db.allTables) {
      final name = table.actualTableName;
      if (name == 'outbox') continue;
      final rows = await db.select(table).get();
      if (rows.isNotEmpty) tablesWithRows++;
      for (final row in rows) {
        final json = jsonDecode(jsonEncode((row as DataClass).toJson())) as Map<String, dynamic>;
        final key = '$name/${json['id']}';
        final sent = newest[key];
        if (sent == null) {
          problems.add('$key has no outbox row');
        } else if (jsonEncode(sent) != jsonEncode(json)) {
          problems.add('$key outbox payload differs:\n  sent $sent\n  row  $json');
        }
      }
    }
    expect(problems, isEmpty, reason: problems.take(10).join('\n'));
    expect(tablesWithRows, greaterThan(15));
  });

  test('outbox rows carry this phone and a strictly increasing sequence', () async {
    await busyDay();
    final outbox = await (db.select(db.outbox)..orderBy([(t) => OrderingTerm.asc(t.seq)])).get();
    expect(outbox, isNotEmpty);
    expect(outbox.every((o) => o.originDeviceId == s.deviceId), isTrue);
    for (var i = 1; i < outbox.length; i++) {
      expect(outbox[i].seq, greaterThan(outbox[i - 1].seq));
    }
    expect(outbox.first.seq, 1, reason: 'the shop set-up rows start the sequence');
  });
}
