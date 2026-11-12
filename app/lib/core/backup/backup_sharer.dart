import 'dart:io';

import 'package:flutter/services.dart';

/// Hands a backup file to another app (email, Drive, WhatsApp...). The real one
/// talks to Android; tests use a fake.
abstract class BackupSharer {
  /// Opens the phone's share sheet with [file] attached. [subject] is used as
  /// the email subject.
  Future<void> shareFile(File file, {String? subject, String? text});
}

class DeviceBackupSharer implements BackupSharer {
  static const _channel = MethodChannel('com.pravinelectricals.shop_app/share');

  @override
  Future<void> shareFile(File file, {String? subject, String? text}) async {
    await _channel.invokeMethod<void>('shareFile', {
      'path': file.path,
      'subject': subject,
      'text': text,
    });
  }
}
