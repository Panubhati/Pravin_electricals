import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/core/bootstrap.dart';
import 'package:shop_app/core/db/app_database.dart';
import 'package:shop_app/core/db/repositories/auth_repository.dart';
import 'package:shop_app/core/db/repositories/repo_context.dart';

void main() {
  late AppDatabase db;
  late AuthRepository auth;
  late String ownerId;
  var now = DateTime(2026, 3, 10, 10);

  setUp(() async {
    now = DateTime(2026, 3, 10, 10);
    db = AppDatabase(NativeDatabase.memory());
    final s = await ensureShopSession(db, clock: () => now);
    auth = AuthRepository(s.ctx);
    ownerId = s.userId;
  });
  tearDown(() => db.close());

  test('a fresh install has no PIN; setting one is audited without the PIN', () async {
    expect(await auth.ownerHasPin(), isFalse);
    await auth.setPin(ownerId, '4821');
    expect(await auth.ownerHasPin(), isTrue);
    final audit = await db.select(db.auditLog).get();
    expect(audit.single.action, 'pin_set');
    expect(audit.single.afterJson, isNot(contains('4821')));
    final stored = (await auth.getUser(ownerId)).pinHash!;
    expect(stored, isNot(contains('4821')));
  });

  test('PIN rules: 4 to 6 digits only', () async {
    for (final bad in ['123', '1234567', 'abcd', '12 34', '']) {
      await expectLater(auth.setPin(ownerId, bad), throwsA(isA<DomainException>()), reason: bad);
    }
    await auth.setPin(ownerId, '123456');
  });

  test('right PIN opens, wrong PIN does not', () async {
    await auth.setPin(ownerId, '4821');
    expect((await auth.verify(ownerId, '4821')).ok, isTrue);
    expect((await auth.verify(ownerId, '0000')).ok, isFalse);
  });

  test('the same PIN hashes differently each time (salted)', () async {
    final a = PinHasher.hash('1111');
    final b = PinHasher.hash('1111');
    expect(a, isNot(b));
    expect(PinHasher.verify('1111', a), isTrue);
    expect(PinHasher.verify('1112', a), isFalse);
    expect(PinHasher.verify('1111', 'garbage'), isFalse);
  });

  test('five wrong tries lock the user, and the wait doubles', () async {
    await auth.setPin(ownerId, '4821');
    for (var i = 0; i < 4; i++) {
      final r = await auth.verify(ownerId, '0000');
      expect(r.ok || r.isLocked, isFalse);
    }
    final fifth = await auth.verify(ownerId, '0000');
    expect(fifth.isLocked, isTrue);
    expect(fifth.lockedUntil, now.add(const Duration(seconds: 30)));

    // Even the right PIN is refused while locked.
    expect((await auth.verify(ownerId, '4821')).isLocked, isTrue);

    // After the wait it works again; a later lock is twice as long.
    now = now.add(const Duration(seconds: 31));
    for (var i = 0; i < 4; i++) {
      await auth.verify(ownerId, '0000');
    }
    final second = await auth.verify(ownerId, '0000');
    expect(second.lockedUntil, now.add(const Duration(seconds: 60)));
    now = now.add(const Duration(seconds: 61));
    expect((await auth.verify(ownerId, '4821')).ok, isTrue);
  });

  test('counter users: created by the owner, unique names, audited', () async {
    final id = await auth.createCounterUser(name: 'Suresh', pin: '2468', byUserId: ownerId);
    expect((await auth.getUser(id)).role, 'counter');
    expect((await auth.verify(id, '2468')).ok, isTrue);
    await expectLater(
        auth.createCounterUser(name: 'suresh', pin: '1357'), throwsA(isA<DomainException>()));
    final actions = (await db.select(db.auditLog).get()).map((a) => a.action);
    expect(actions, contains('user_created'));
  });

  test('a deactivated user cannot log in; the owner cannot be deactivated', () async {
    final id = await auth.createCounterUser(name: 'Suresh', pin: '2468');
    await auth.deactivate(id, byUserId: ownerId);
    expect((await auth.verify(id, '2468')).ok, isFalse);
    expect((await auth.activeUsers()).map((u) => u.name), ['Owner']);
    expect(await auth.allUsers(), hasLength(2));
    await expectLater(auth.deactivate(ownerId), throwsA(isA<DomainException>()));
  });

  test('owner recovery sets a new PIN, clears a lock and is audited', () async {
    await auth.setPin(ownerId, '4821');
    for (var i = 0; i < 5; i++) {
      await auth.verify(ownerId, '0000');
    }
    expect((await auth.verify(ownerId, '4821')).isLocked, isTrue);
    await auth.resetOwnerPin('9999');
    expect((await auth.verify(ownerId, '9999')).ok, isTrue);
    expect((await db.select(db.auditLog).get()).map((a) => a.action), contains('pin_reset'));
  });

  test('user changes reach the outbox, and never with the plain PIN', () async {
    await auth.setPin(ownerId, '4821');
    final rows = (await db.select(db.outbox).get())
        .where((o) => o.entity == 'users' && o.op == 'upsert');
    expect(rows, isNotEmpty);
    for (final r in rows) {
      expect(r.payloadJson, isNot(contains('4821')));
    }
  });
}
