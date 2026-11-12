import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/core/backup/backup_service.dart';
import 'package:shop_app/core/backup/database_location.dart';
import 'package:shop_app/core/bootstrap.dart';
import 'package:shop_app/core/db/app_database.dart';
import 'package:shop_app/core/db/repositories/invoice_repository.dart';
import 'package:shop_app/core/db/repositories/item_repository.dart';
import 'package:shop_app/core/db/repositories/setup_repository.dart';
import 'package:shop_app/core/sync/device_identity.dart';
import 'package:shop_app/core/sync/join_shop.dart';
import 'package:shop_app/core/sync/pairing.dart';
import 'package:shop_app/core/sync/sync_crypto.dart';
import 'package:shop_app/core/sync/sync_service.dart';
import 'package:shop_app/core/sync/sync_transport.dart';
import 'package:shop_app/features/billing/domain/bill_calculator.dart';

import '../helpers/seed_rich_shop.dart';
import 'sync_engine_test.dart' show snapshot;

/// Two phones on real HTTP servers on this computer (127.0.0.1): pairing by
/// invite, syncing both ways, and every way a stranger or a removed phone is
/// kept out.
class FilePhone {
  FilePhone(this.dir) : location = FolderDatabaseLocation(dir), identity = null;
  final Directory dir;
  final FolderDatabaseLocation location;
  FileDeviceIdentity? identity;
  late AppDatabase db;
  late ShopSession session;
  late SyncService sync;

  Future<void> open() async {
    identity = FileDeviceIdentity(location);
    db = AppDatabase(NativeDatabase(await location.databaseFile()));
    session = await ensureShopSession(db, identity: identity);
    sync = SyncService(
      db: db,
      session: session,
      makeCopy: () async => File((await BackupService(db, location).createBackup()).path),
      listenPort: 0,
      interval: const Duration(hours: 1), // the tests call syncNow themselves
    );
  }

  Future<void> close() async {
    await sync.stop();
    await db.close();
  }
}

void main() {
  late Directory root;
  late FilePhone a, b;

  setUp(() {
    root = Directory.systemTemp.createTempSync('wifi_sync_');
    a = FilePhone(Directory('${root.path}/a')..createSync());
    b = FilePhone(Directory('${root.path}/b')..createSync());
  });

  tearDown(() async {
    try {
      root.deleteSync(recursive: true);
    } on FileSystemException {
      // Windows may still hold a file; the OS cleans temp.
    }
  });

  /// Phone A with a shop; phone B joins it with the invite, like scanning the QR.
  Future<PairingInvite> pairAB() async {
    await a.open();
    await seedRichShop(a.session);
    await a.sync.start(forPairing: true);
    final invite = PairingInvite(
      shopId: a.session.shopId,
      host: '127.0.0.1',
      port: a.sync.port,
      key: (await a.sync.store.shopKey())!,
      token: await a.sync.store.startPairing(),
      ownerDeviceId: a.session.deviceId,
    );
    final client = SyncClient(key: invite.key, me: const PhoneInfo(deviceId: 'joining', label: 'Counter phone', series: '?'));
    final package = await client.join(invite);
    await installJoinedShop(
      package: package,
      invite: invite,
      location: b.location,
      identity: FileDeviceIdentity(b.location),
      label: 'Counter phone',
    );
    await b.open();
    await b.sync.start();
    await b.sync.syncNow();
    await a.sync.syncNow();
    return invite;
  }

  Future<void> sell(FilePhone p) async {
    final sw = (await ItemRepository(p.session.ctx).search('switch')).first.item;
    final totals = BillCalculator.calculate([
      CartLine(itemId: sw.id, itemName: sw.name, unitName: 'pcs', factorToBase: 1, qtyEntered: '1', ratePaise: 1500, priceUnitFactor: 1),
    ], interState: false);
    final repo = InvoiceRepository(p.session.ctx);
    await repo.postInvoice(totals.toInvoiceInput(
      deviceId: p.session.deviceId,
      series: p.session.series,
      number: await repo.nextNumber(p.session.deviceId, p.session.series),
      date: DateTime.now(),
      locationId: p.session.locationId,
      payments: [PaymentInput('cash', totals.totalPaise)],
    ));
  }

  test('a phone joins with the invite, becomes phone B, and both phones end with the same data', () async {
    await pairAB();
    expect(b.session.series, 'B');
    expect(await b.identity!.read(), b.session.deviceId);
    await sell(a);
    await sell(b);
    await b.sync.syncNow();
    await a.sync.syncNow();
    expect(await snapshot(b.db), await snapshot(a.db));
    expect(a.sync.status.value.state, SyncHealth.synced);
    expect(b.sync.status.value.state, SyncHealth.synced);
    final onA = (await a.db.select(a.db.invoices).get()).map((i) => i.invoiceNoText).toSet();
    expect(onA, contains('B-0001'));
    // Phone A knows phone B's address now (it called in).
    final peerOnA = await a.sync.store.peer(b.session.deviceId);
    expect(peerOnA?.address, '127.0.0.1');
    await b.close();
    await a.close();
  });

  test('the joined phone does not inherit the owner phone\'s backup time or peers list', () async {
    await a.open();
    await a.sync.start(forPairing: true);
    await a.db.customStatement("INSERT INTO app_settings (id, shop_id, created_at, updated_at, key, value) "
        "VALUES ('x', '${a.session.shopId}', 0, 0, 'last_backup_at', '123')");
    final invite = PairingInvite(
      shopId: a.session.shopId, host: '127.0.0.1', port: a.sync.port,
      key: (await a.sync.store.shopKey())!, token: await a.sync.store.startPairing(), ownerDeviceId: a.session.deviceId,
    );
    final package = await SyncClient(key: invite.key, me: const PhoneInfo(deviceId: 'j', label: 'j', series: '?')).join(invite);
    await installJoinedShop(package: package, invite: invite, location: b.location, identity: FileDeviceIdentity(b.location), label: 'Two');
    await b.open();
    expect(await b.db.customSelect("SELECT * FROM app_settings WHERE key = 'last_backup_at'").get(), isEmpty);
    expect((await b.sync.store.peers()).single.deviceId, a.session.deviceId);
    await b.close();
    await a.close();
  });

  test('a pairing code works once and only while fresh', () async {
    final invite = await pairAB();
    final again = SyncClient(key: invite.key, me: const PhoneInfo(deviceId: 'x', label: 'x', series: '?'));
    await expectLater(again.join(invite), throwsA(isA<SyncHttpException>().having((e) => e.refused, 'refused', isTrue)));
    await b.close();
    await a.close();
  });

  test('a phone without the shop key is refused', () async {
    await pairAB();
    final stranger = SyncClient(key: ShopKey.random(), me: const PhoneInfo(deviceId: 'stranger', label: 's', series: 'Z'));
    await expectLater(stranger.hello('127.0.0.1', a.sync.port),
        throwsA(isA<SyncHttpException>().having((e) => e.refused, 'refused', isTrue)));
    await expectLater(stranger.pull('127.0.0.1', a.sync.port, {}), throwsA(isA<SyncHttpException>()));
    await b.close();
    await a.close();
  });

  test('a message changed on the way is refused', () async {
    final invite = await pairAB();
    final sealed = await invite.key.sealJson({'from': b.session.deviceId}, label: 'hello');
    sealed[sealed.length - 3] ^= 0x01;
    final client = HttpClient();
    final req = await client.post('127.0.0.1', a.sync.port, '/v1/hello');
    req.add(Uint8List.fromList(sealed));
    final res = await req.close();
    expect(res.statusCode, HttpStatus.forbidden);
    client.close(force: true);
    await b.close();
    await a.close();
  });

  test('a message replayed as a different request is refused', () async {
    final invite = await pairAB();
    final sealed = await invite.key.sealJson({'from': b.session.deviceId, 'cursor': <String, int>{}}, label: 'hello');
    final client = HttpClient();
    final req = await client.post('127.0.0.1', a.sync.port, '/v1/pull');
    req.add(sealed);
    final res = await req.close();
    expect(res.statusCode, HttpStatus.forbidden);
    client.close(force: true);
    await b.close();
    await a.close();
  });

  test('a removed phone is refused and says so', () async {
    await pairAB();
    await SetupRepository(a.session.ctx).removeDevice(b.session.deviceId);
    await b.sync.syncNow();
    expect(b.sync.status.value.state, SyncHealth.problem);
    expect(b.sync.status.value.message, contains('removed'));
    await b.close();
    await a.close();
  });

  test('when the other phone is away, sync waits quietly and catches up when it is back', () async {
    await pairAB();
    final portA = a.sync.port;
    await a.close();
    await sell(b);
    await b.sync.syncNow();
    expect(b.sync.status.value.state, SyncHealth.searching);

    // Phone A comes back on the same port.
    await a.open();
    a.sync = SyncService(
      db: a.db,
      session: a.session,
      makeCopy: () async => throw UnimplementedError(),
      listenPort: portA,
      interval: const Duration(hours: 1),
    );
    await a.sync.start();
    await b.sync.syncNow();
    await a.sync.syncNow();
    expect(await snapshot(b.db), await snapshot(a.db));
    await b.close();
    await a.close();
  });

  test('a new sale on one phone reaches the other by itself (the nudge)', () async {
    await pairAB();
    final before = (await a.db.select(a.db.invoices).get()).length;
    await sell(b);
    // No syncNow: phone B tells phone A, and phone A pulls.
    final deadline = DateTime.now().add(const Duration(seconds: 10));
    while ((await a.db.select(a.db.invoices).get()).length == before && DateTime.now().isBefore(deadline)) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    expect((await a.db.select(a.db.invoices).get()).length, before + 1);
    await b.close();
    await a.close();
  });
}
