import 'package:uuid/uuid.dart';

import '../db/app_database.dart';
import '../db/repositories/repo_context.dart';
import '../db/repositories/setup_repository.dart';
import 'device_identity.dart';

/// A phone's name as people see it. Phones set up before A8 were all called
/// "This phone", which is wrong when seen from the other phone.
String phoneName(Device d) =>
    d.label.trim().isEmpty || d.label == 'This phone' ? 'Phone ${d.invoiceSeriesPrefix}' : d.label;

/// The next free bill series letter (A, B, C...).
String nextSeriesLetter(Iterable<String> used) {
  for (var c = 'A'.codeUnitAt(0); c <= 'Z'.codeUnitAt(0); c++) {
    final letter = String.fromCharCode(c);
    if (!used.contains(letter)) return letter;
  }
  throw DomainException('This shop already has 26 phones');
}

/// Adds a new phone (device row) to the shop and makes this phone that device.
/// Its changes are stamped with the new device from the very first row.
Future<Device> addThisPhone(AppDatabase db, DeviceIdentity identity, {required String label}) async {
  final shop = await (db.select(db.shops)..where((t) => t.deletedAt.isNull())..limit(1)).getSingle();
  final devices = await (db.select(db.devices)..where((t) => t.shopId.equals(shop.id))).get();
  final letter = nextSeriesLetter(devices.map((d) => d.invoiceSeriesPrefix));
  final id = const Uuid().v4();
  final ctx = RepoContext(db, shopId: shop.id)..originDeviceId = id;
  await SetupRepository(ctx).createDevice(id: id, label: label, invoiceSeriesPrefix: letter);
  await identity.write(id);
  return (db.select(db.devices)..where((t) => t.id.equals(id))).getSingle();
}

