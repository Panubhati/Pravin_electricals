import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';

import '../backup/database_location.dart';

/// Opens the on-phone SQLite file. Tests use NativeDatabase.memory() instead.
LazyDatabase openShopDatabase({
  ShopDatabaseLocation location = const DeviceDatabaseLocation(),
}) {
  return LazyDatabase(() async {
    final File file = await location.databaseFile();
    return NativeDatabase.createInBackground(file);
  });
}
