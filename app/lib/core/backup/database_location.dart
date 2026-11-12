import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Where the shop's database file lives, and where temporary and safety copies
/// go. One place, so opening the database, backing it up and restoring it can
/// never disagree about the path. Tests use a temp folder instead.
abstract class ShopDatabaseLocation {
  /// The live SQLite file.
  Future<File> databaseFile();

  /// The app's private folder for backup temp files and safety copies.
  Future<Directory> workDirectory();
}

/// The real phone: the app documents folder, as the database has always used.
class DeviceDatabaseLocation implements ShopDatabaseLocation {
  const DeviceDatabaseLocation({this.fileName = 'shop.sqlite'});
  final String fileName;

  @override
  Future<File> databaseFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File(p.join(dir.path, fileName));
  }

  @override
  Future<Directory> workDirectory() async {
    final dir = await getApplicationSupportDirectory();
    final work = Directory(p.join(dir.path, 'backups'));
    return work.create(recursive: true);
  }
}

/// A folder on disk, for tests.
class FolderDatabaseLocation implements ShopDatabaseLocation {
  FolderDatabaseLocation(this.root, {this.fileName = 'shop.sqlite'});
  final Directory root;
  final String fileName;

  @override
  Future<File> databaseFile() async => File(p.join(root.path, fileName));

  @override
  Future<Directory> workDirectory() =>
      Directory(p.join(root.path, 'work')).create(recursive: true);
}
