import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/core/backup/database_location.dart';
import 'package:shop_app/core/bootstrap.dart';
import 'package:shop_app/core/db/app_database.dart';
import 'package:shop_app/core/db/repositories/settings_repository.dart';
import 'package:shop_app/core/sync/device_identity.dart';
import 'package:shop_app/features/sync/device_choice_screen.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('a new install is phone A and remembers it', () async {
    final id = MemoryDeviceIdentity();
    final s = await ensureShopSession(db, identity: id);
    expect(s.series, 'A');
    expect(id.value, s.deviceId);
    final again = await ensureShopSession(db, identity: id);
    expect(again.deviceId, s.deviceId);
  });

  test('a second phone added to the data gets series B and stamps its own changes', () async {
    final a = await ensureShopSession(db, identity: MemoryDeviceIdentity());
    final bIdentity = MemoryDeviceIdentity();
    final b = await addThisPhone(db, bIdentity, label: 'Counter phone');
    expect(b.invoiceSeriesPrefix, 'B');

    final sb = await ensureShopSession(db, identity: bIdentity);
    expect(sb.deviceId, b.id);
    expect(sb.series, 'B');
    await SettingsRepository(sb.ctx).set('upi_id', 'b@upi');
    final mine = await (db.select(db.outbox)..where((t) => t.originDeviceId.equals(b.id))).get();
    expect(mine.map((o) => o.seq), [1, 2], reason: 'its device row, then the setting');

    // Phone A still knows it is A.
    final sa = await ensureShopSession(db, identity: MemoryDeviceIdentity(a.deviceId));
    expect(sa.series, 'A');
  });

  test('with two phones in the data and no identity, the app must ask', () async {
    await ensureShopSession(db, identity: MemoryDeviceIdentity());
    await addThisPhone(db, MemoryDeviceIdentity(), label: 'Counter phone');
    await expectLater(ensureShopSession(db, identity: MemoryDeviceIdentity()), throwsA(isA<DeviceChoiceNeeded>()));
  });

  test('a phone whose own device is not in the data (old backup restored) must ask', () async {
    await ensureShopSession(db, identity: MemoryDeviceIdentity());
    final e = await ensureShopSession(db, identity: MemoryDeviceIdentity('a-phone-that-is-not-here'))
        .then<Object?>((_) => null, onError: (Object e) => e);
    expect(e, isA<DeviceChoiceNeeded>());
    expect((e as DeviceChoiceNeeded).devices.single.invoiceSeriesPrefix, 'A');
  });

  test('next series letter skips the ones in use', () {
    expect(nextSeriesLetter(['A']), 'B');
    expect(nextSeriesLetter(['A', 'B', 'D']), 'C');
    expect(nextSeriesLetter([]), 'A');
  });

  test('the identity file survives being read and rewritten, and can be cleared', () async {
    final dir = Directory.systemTemp.createTempSync('identity_');
    addTearDown(() => dir.deleteSync(recursive: true));
    final id = FileDeviceIdentity(FolderDatabaseLocation(dir));
    expect(await id.read(), isNull);
    await id.write('dev-1');
    expect(await id.read(), 'dev-1');
    await id.write('dev-2');
    expect(await FileDeviceIdentity(FolderDatabaseLocation(dir)).read(), 'dev-2');
    await id.clear();
    expect(await id.read(), isNull);
  });
}
