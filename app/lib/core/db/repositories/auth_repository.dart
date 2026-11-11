import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';

import '../app_database.dart';
import 'audit_repository.dart';
import 'repo_context.dart';

/// Salted PIN hashing. The stored form is `salt$sha256hex`. This keeps PINs
/// unreadable in the database file; it is a convenience lock, not strong
/// security (the data is on the phone itself, plan A4 note).
class PinHasher {
  static const _sep = '\$';

  static String hash(String pin, {String? salt}) {
    final s = salt ?? _newSalt();
    final digest = sha256.convert(utf8.encode('$s:$pin'));
    return '$s$_sep$digest';
  }

  static bool verify(String pin, String stored) {
    final i = stored.indexOf(_sep);
    if (i <= 0) return false;
    return hash(pin, salt: stored.substring(0, i)) == stored;
  }

  static String _newSalt() {
    final r = Random.secure();
    return base64Url.encode([for (var i = 0; i < 12; i++) r.nextInt(256)]);
  }
}

/// Result of checking a PIN.
class PinResult {
  const PinResult.ok()
      : ok = true,
        lockedUntil = null;
  const PinResult.wrong()
      : ok = false,
        lockedUntil = null;
  const PinResult.locked(DateTime this.lockedUntil) : ok = false;

  final bool ok;

  /// Set when too many wrong tries have locked this user out for a while.
  final DateTime? lockedUntil;
  bool get isLocked => lockedUntil != null;
}

/// Users, roles and PINs. Counter staff are created by the owner; every change
/// is audited (never with the PIN itself).
class AuthRepository {
  AuthRepository(this.ctx) : _audit = AuditRepository(ctx);
  final RepoContext ctx;
  final AuditRepository _audit;

  static const maxFailures = 5;
  static const baseLockSeconds = 30;
  static const maxLockSeconds = 900;

  // Wrong-try counters live in memory: restarting the app clears them, which
  // is acceptable for a convenience lock on the owner's own phone.
  final Map<String, int> _failures = {};
  final Map<String, DateTime> _lockedUntil = {};
  final Map<String, int> _lockRounds = {};

  static bool isValidPin(String pin) => RegExp(r'^\d{4,6}$').hasMatch(pin);

  void _requirePin(String pin) {
    if (!isValidPin(pin)) throw DomainException('PIN must be 4 to 6 digits.');
  }

  void _clearLock(String userId) {
    _failures.remove(userId);
    _lockedUntil.remove(userId);
    _lockRounds.remove(userId);
  }

  Future<List<User>> activeUsers() => (ctx.db.select(ctx.db.users)
        ..where((t) =>
            t.shopId.equals(ctx.shopId) & t.deletedAt.isNull() & t.active.equals(true))
        ..orderBy([(t) => OrderingTerm.asc(t.role), (t) => OrderingTerm.asc(t.name)]))
      .get();

  Future<List<User>> allUsers() => (ctx.db.select(ctx.db.users)
        ..where((t) => t.shopId.equals(ctx.shopId) & t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm.asc(t.role), (t) => OrderingTerm.asc(t.name)]))
      .get();

  Future<User> getUser(String id) async {
    final u = await (ctx.db.select(ctx.db.users)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (u == null) throw DomainException('Unknown user.');
    return u;
  }

  Future<User> owner() => (ctx.db.select(ctx.db.users)
        ..where((t) => t.shopId.equals(ctx.shopId) & t.role.equals('owner'))
        ..limit(1))
      .getSingle();

  /// True once the owner has a PIN. A fresh install has none, and the first
  /// launch asks for one.
  Future<bool> ownerHasPin() async => (await owner()).pinHash != null;

  /// Sets or changes a user's PIN. [byUserId] is who did it, for the audit.
  Future<void> setPin(String userId, String pin, {String? byUserId}) async {
    _requirePin(pin);
    final u = await getUser(userId);
    final firstTime = u.pinHash == null;
    await _write(userId, pinHash: PinHasher.hash(pin));
    _clearLock(userId);
    await _audit.record(
      action: firstTime ? 'pin_set' : 'pin_changed',
      entity: 'user',
      entityId: userId,
      userId: byUserId ?? userId,
      after: {'name': u.name, 'role': u.role},
    );
  }

  /// Owner recovery: set a new owner PIN after the phone's own screen lock was
  /// confirmed (done by the caller). Audited as a reset.
  Future<void> resetOwnerPin(String newPin) async {
    _requirePin(newPin);
    final o = await owner();
    await _write(o.id, pinHash: PinHasher.hash(newPin));
    _clearLock(o.id);
    await _audit.record(
      action: 'pin_reset',
      entity: 'user',
      entityId: o.id,
      userId: o.id,
      after: {'name': o.name, 'role': o.role},
    );
  }

  /// Checks a PIN. Five wrong tries in a row lock the user for 30 seconds, and
  /// each further round doubles the wait (up to 15 minutes).
  Future<PinResult> verify(String userId, String pin) async {
    final u = await getUser(userId);
    if (!u.active || u.deletedAt != null) return const PinResult.wrong();
    final until = _lockedUntil[userId];
    if (until != null && ctx.clock().isBefore(until)) return PinResult.locked(until);
    final stored = u.pinHash;
    if (stored != null && PinHasher.verify(pin, stored)) {
      _clearLock(userId);
      return const PinResult.ok();
    }
    final n = (_failures[userId] ?? 0) + 1;
    if (n >= maxFailures) {
      final round = _lockRounds[userId] ?? 0;
      final seconds = min(baseLockSeconds * (1 << round), maxLockSeconds);
      _lockRounds[userId] = round + 1;
      _failures[userId] = 0;
      final lockedUntil = ctx.clock().add(Duration(seconds: seconds));
      _lockedUntil[userId] = lockedUntil;
      return PinResult.locked(lockedUntil);
    }
    _failures[userId] = n;
    return const PinResult.wrong();
  }

  /// The owner adds counter staff. Names must be unique among current users.
  Future<String> createCounterUser({
    required String name,
    required String pin,
    String? phone,
    String? byUserId,
  }) async {
    _requirePin(pin);
    final n = name.trim();
    if (n.isEmpty) throw DomainException('Enter a name.');
    final clash = (await activeUsers()).any((u) => u.name.toLowerCase() == n.toLowerCase());
    if (clash) throw DomainException('A user named "$n" already exists.');
    final now = ctx.clock();
    final id = ctx.newId();
    await ctx.db.transaction(() async {
      await ctx.insertRow(
        ctx.db.users,
        UsersCompanion.insert(
          id: id,
          shopId: ctx.shopId,
          createdAt: now,
          updatedAt: now,
          name: n,
          role: 'counter',
          phone: Value(phone),
          pinHash: Value(PinHasher.hash(pin)),
        ),
        'users',
        id,
      );
      await _audit.record(
        action: 'user_created',
        entity: 'user',
        entityId: id,
        userId: byUserId,
        after: {'name': n, 'role': 'counter'},
      );
    });
    return id;
  }

  /// Turns a counter user off (their old bills stay). The owner cannot be deactivated.
  Future<void> deactivate(String userId, {String? byUserId}) async {
    final u = await getUser(userId);
    if (u.role == 'owner') throw DomainException('The owner cannot be removed.');
    await ctx.db.transaction(() async {
      await _write(userId, active: false);
      await _audit.record(
        action: 'user_deactivated',
        entity: 'user',
        entityId: userId,
        userId: byUserId,
        before: {'name': u.name, 'role': u.role, 'active': true},
        after: {'active': false},
      );
    });
  }

  Future<void> _write(String userId, {String? pinHash, bool? active}) async {
    final now = ctx.clock();
    await ctx.db.transaction(() async {
      await (ctx.db.update(ctx.db.users)..where((t) => t.id.equals(userId))).write(
        UsersCompanion(
          pinHash: pinHash == null ? const Value.absent() : Value(pinHash),
          active: active == null ? const Value.absent() : Value(active),
          updatedAt: Value(now),
        ),
      );
      final row = await getUser(userId);
      // Same payload as every other table; only the salted hash is stored, never the PIN.
      await ctx.recordOutbox('users', userId, 'upsert', row.toJson());
    });
  }
}
