import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'csv_bytes.dart';

/// Picking a CSV and saving a template, behind an interface so tests can use a
/// fake instead of the Android file dialogs.
abstract class FileService {
  /// Lets the user choose a CSV file and returns its text, or null if cancelled.
  /// Throws [FormatException] if the file is not usable (for example Excel).
  Future<String?> pickCsvText();

  /// Lets the user choose where to save [content]. Returns true if saved.
  Future<bool> saveText({required String fileName, required String content});
}

/// The real Android file dialogs (storage access framework: no permission needed).
class DeviceFileService implements FileService {
  const DeviceFileService();

  @override
  Future<String?> pickCsvText() async {
    // Any file type: Android labels CSV files inconsistently, and a type filter
    // would hide them. decodeCsvBytes explains the common wrong-file mistakes.
    final result = await FilePicker.pickFiles(withData: true);
    final bytes = result?.files.firstOrNull?.bytes;
    if (bytes == null) return null;
    return decodeCsvBytes(bytes);
  }

  @override
  Future<bool> saveText({required String fileName, required String content}) async {
    final path = await FilePicker.saveFile(
      dialogTitle: 'Save template',
      fileName: fileName,
      bytes: Uint8List.fromList(utf8.encode(content)),
    );
    return path != null;
  }
}

final fileServiceProvider = Provider<FileService>((ref) => const DeviceFileService());
