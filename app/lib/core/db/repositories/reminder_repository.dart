import 'package:drift/drift.dart';

import '../../printing/bill_words.dart';
import '../../printing/upi_link.dart';
import '../../sharing/phone_number.dart';
import '../../../shared/format.dart';
import '../../money.dart';
import '../app_database.dart';
import 'audit_repository.dart';
import 'dues_repository.dart';
import 'repo_context.dart';
import 'settings_repository.dart';

/// Payment reminder rules chosen by the owner (Settings, Payment reminders).
class ReminderSettings {
  const ReminderSettings({
    required this.on,
    required this.firstAfterDays,
    required this.repeatEveryDays,
    required this.minimumPaise,
    required this.smsFromThisPhone,
    required this.smsHour,
  });
  final bool on;
  final int firstAfterDays;
  final int repeatEveryDays;
  final int minimumPaise;

  /// Phone-only: this phone sends the automatic SMS (only one phone should).
  final bool smsFromThisPhone;
  final int smsHour;

  static const defaults = ReminderSettings(
    on: false,
    firstAfterDays: 15,
    repeatEveryDays: 7,
    minimumPaise: 10000,
    smsFromThisPhone: false,
    smsHour: 11,
  );
}

/// A customer due for a reminder today.
class DueReminder {
  const DueReminder({
    required this.party,
    required this.amountPaise,
    required this.oldestDue,
    required this.daysOwed,
    required this.number,
    this.lastReminded,
  });
  final Party party;
  final int amountPaise;
  final DateTime oldestDue;
  final int daysOwed;

  /// Phone number with country code, digits only (for SMS and WhatsApp).
  final String number;
  final DateTime? lastReminded;
}

/// Who to remind about money owed, and the record of reminders sent (A11).
class ReminderRepository {
  ReminderRepository(this.ctx)
      : _dues = DuesRepository(ctx),
        _settings = SettingsRepository(ctx),
        _audit = AuditRepository(ctx);

  final RepoContext ctx;
  final DuesRepository _dues;
  final SettingsRepository _settings;
  final AuditRepository _audit;
  AppDatabase get _db => ctx.db;

  Future<ReminderSettings> settings() async {
    const d = ReminderSettings.defaults;
    return ReminderSettings(
      on: (await _settings.get(SettingKeys.remindersOn)) == '1',
      firstAfterDays: await _settings.getInt(SettingKeys.reminderFirstDays, d.firstAfterDays),
      repeatEveryDays: await _settings.getInt(SettingKeys.reminderRepeatDays, d.repeatEveryDays),
      minimumPaise: await _settings.getInt(SettingKeys.reminderMinPaise, d.minimumPaise),
      smsFromThisPhone: (await _settings.get(SettingKeys.reminderSmsHere)) == '1',
      smsHour: await _settings.getInt(SettingKeys.reminderSmsHour, d.smsHour),
    );
  }

  /// Customers to remind today: they owe at least the minimum, their oldest
  /// unpaid bill is old enough, they have a mobile number, reminders are not
  /// switched off for them, and nobody (on either phone) reminded them within
  /// the repeat interval. Skipped-today customers are left out unless asked.
  Future<List<DueReminder>> due({DateTime? now, bool includeSkipped = false}) async {
    final when = now ?? ctx.clock();
    final s = await settings();
    final today = DateTime(when.year, when.month, when.day);
    final skipped = includeSkipped ? <String>{} : await _skippedToday(today);
    final last = await _lastReminded();
    final out = <DueReminder>[];
    for (final d in await _dues.receivables(asOf: when)) {
      final p = d.party;
      final oldest = d.buckets.oldestDue;
      final number = whatsappNumber(p.phone);
      if (p.remindersOff || oldest == null || number == null) continue;
      if (d.buckets.totalDue < s.minimumPaise || d.buckets.totalDue <= 0) continue;
      final days = today.difference(oldest).inDays;
      if (days < s.firstAfterDays) continue;
      final lastAt = last[p.id];
      if (lastAt != null) {
        final lastDay = DateTime(lastAt.year, lastAt.month, lastAt.day);
        if (today.difference(lastDay).inDays < s.repeatEveryDays) continue;
      }
      if (skipped.contains(p.id)) continue;
      out.add(DueReminder(
        party: p,
        amountPaise: d.buckets.totalDue,
        oldestDue: oldest,
        daysOwed: days,
        number: number,
        lastReminded: lastAt,
      ));
    }
    out.sort((a, b) => a.oldestDue.compareTo(b.oldestDue));
    return out;
  }

  Future<Map<String, DateTime>> _lastReminded() async {
    final rows = await _db.customSelect(
      'SELECT party_id AS p, MAX(sent_at) AS t FROM reminders WHERE deleted_at IS NULL GROUP BY party_id',
      readsFrom: {_db.reminders},
    ).get();
    return {
      for (final r in rows)
        r.data['p'] as String: DateTime.fromMillisecondsSinceEpoch((r.data['t'] as int) * 1000),
    };
  }

  /// Records a reminder (synced, so the other phone sees it) and audits it.
  Future<void> record(DueReminder r, {required String channel, String? deviceId, String? createdBy}) async {
    final now = ctx.clock();
    final id = ctx.newId();
    await _db.transaction(() async {
      await ctx.insertRow(
        _db.reminders,
        RemindersCompanion.insert(
          id: id,
          shopId: ctx.shopId,
          createdAt: now,
          updatedAt: now,
          partyId: r.party.id,
          channel: channel,
          amountPaise: r.amountPaise,
          oldestDueAt: r.oldestDue,
          sentAt: now,
          deviceId: Value(deviceId),
          createdBy: Value(createdBy),
        ),
        'reminders',
        id,
      );
      await _audit.record(
        action: 'payment_reminder',
        entity: 'party',
        entityId: r.party.id,
        userId: createdBy,
        after: {'channel': channel, 'amountPaise': r.amountPaise, 'daysOwed': r.daysOwed},
      );
    });
  }

  /// Reminders sent to one customer, newest first.
  Future<List<Reminder>> forParty(String partyId) => (_db.select(_db.reminders)
        ..where((t) => t.partyId.equals(partyId) & t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm.desc(t.sentAt)]))
      .get();

  /// Leaves [partyId] out of today's list on this phone.
  Future<void> skipToday(String partyId, {DateTime? now}) async {
    final when = now ?? ctx.clock();
    final today = _dayKey(DateTime(when.year, when.month, when.day));
    final kept = await _skippedToday(DateTime(when.year, when.month, when.day));
    await _settings.set(SettingKeys.reminderSkip, '$today:${{...kept, partyId}.join(',')}');
  }

  Future<Set<String>> _skippedToday(DateTime today) async {
    final raw = await _settings.get(SettingKeys.reminderSkip) ?? '';
    final i = raw.indexOf(':');
    if (i < 0 || raw.substring(0, i) != _dayKey(today)) return {};
    return raw.substring(i + 1).split(',').where((s) => s.isNotEmpty).toSet();
  }

  static String _dayKey(DateTime d) => '${d.year}-${d.month}-${d.day}';

  /// Switches reminders off (or back on) for one customer. Audited, synced.
  Future<void> setRemindersOff(String partyId, bool off, {String? userId}) async {
    final now = ctx.clock();
    await _db.transaction(() async {
      await (_db.update(_db.parties)..where((t) => t.id.equals(partyId)))
          .write(PartiesCompanion(remindersOff: Value(off), updatedAt: Value(now)));
      final row = await (_db.select(_db.parties)..where((t) => t.id.equals(partyId))).getSingle();
      await ctx.recordOutbox('parties', partyId, 'upsert', row.toJson());
      await _audit.record(
        action: 'edit',
        entity: 'party',
        entityId: partyId,
        userId: userId,
        after: {'remindersOff': off},
      );
    });
  }

  /// The reminder text for [r], in the shop's bill language, with the UPI
  /// link for the amount owed when a UPI ID is set.
  Future<String> message(DueReminder r, {required String shopName}) async {
    final words = BillWords.of(await _settings.billLanguage());
    final payee = await _settings.upiPayee(shopName);
    final link = UpiLink.build(payee, amountPaise: r.amountPaise, note: shopName);
    return words.reminderMessage(
      name: r.party.name,
      shop: shopName,
      amount: Money.format(r.amountPaise),
      since: formatDate(r.oldestDue),
      payLink: link,
    );
  }
}
