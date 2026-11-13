import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers.dart';
import 'format.dart';
import 'strings.dart';

/// Saves a file into the phone's Downloads folder and says so, with an Open
/// button (A13). On a phone that cannot (Android 9 and older) it runs
/// [fallbackShare] instead and says why.
Future<void> downloadFile(
  BuildContext context,
  WidgetRef ref, {
  required Future<Uint8List> Function() bytes,
  required String filename,
  required String mime,
  required Future<void> Function(Uint8List bytes) fallbackShare,
}) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  final saver = ref.read(fileSaverProvider);
  try {
    final data = await bytes();
    final uri = await saver.saveToDownloads(data, filename, mime);
    if (uri == null) {
      messenger?.showSnackBar(SnackBar(content: Text(S.downloadNotSupported)));
      await fallbackShare(data);
      return;
    }
    messenger?.showSnackBar(SnackBar(
      key: const Key('downloadedSnack'),
      content: Text(S.downloadedTo(filename)),
      duration: const Duration(seconds: 6),
      action: SnackBarAction(label: S.downloadOpen, onPressed: () => saver.open(uri, mime)),
    ));
  } catch (e) {
    messenger?.showSnackBar(SnackBar(content: Text('${S.downloadFailed}: ${errorMessage(e)}')));
  }
}
