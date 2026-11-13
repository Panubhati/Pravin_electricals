import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../db/app_database.dart';
import '../db/repositories/settings_repository.dart';

/// Fingerprint unlock, per person and per phone (A12).
///
/// Android cannot tell whose finger it is: any finger saved in the phone's own
/// settings passes. So each person switches it on for themselves, on their own
/// phone, after typing their PIN. The switch is tied to their current PIN: when
/// the PIN changes (on either phone, or the owner resets it), fingerprint stops
/// working for that person until they switch it on again. A person who is
/// removed no longer appears on the lock screen at all.
class FingerprintLogin {
  FingerprintLogin(this.settings);
  final SettingsRepository settings;

  /// A short tag of the stored PIN hash (never the PIN itself).
  static String pinTag(User u) => sha256.convert(utf8.encode(u.pinHash ?? '')).toString().substring(0, 12);

  static String _entry(User u) => '${u.id}:${pinTag(u)}';

  Future<bool> isOn(User u) async => u.pinHash != null && (await settings.fingerprintEntries()).contains(_entry(u));

  Future<void> setOn(User u, bool on) async {
    final entries = (await settings.fingerprintEntries())..removeWhere((e) => e.startsWith('${u.id}:'));
    if (on) entries.add(_entry(u));
    await settings.setFingerprintEntries(entries);
  }

  /// Whether this person was already asked once on this phone.
  Future<bool> wasOffered(User u) async => (await settings.fingerprintOffered()).contains(u.id);

  Future<void> markOffered(User u) => settings.markFingerprintOffered(u.id);
}
