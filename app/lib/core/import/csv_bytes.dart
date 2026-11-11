import 'dart:convert';
import 'dart:typed_data';

/// Turns the bytes of a picked file into text for the CSV reader.
///
/// Throws [FormatException] with a plain message for the common mistakes: an
/// Excel file picked instead of a CSV, or a UTF-16 "Unicode text" export.
String decodeCsvBytes(Uint8List bytes) {
  if (bytes.length >= 2 && bytes[0] == 0x50 && bytes[1] == 0x4B) {
    // "PK": a zip container, which is what .xlsx files are.
    throw const FormatException(
        'This looks like an Excel file. Open it in Excel and use '
        'File > Save As > CSV, then choose the CSV file.');
  }
  if (bytes.length >= 2 &&
      ((bytes[0] == 0xFF && bytes[1] == 0xFE) || (bytes[0] == 0xFE && bytes[1] == 0xFF))) {
    throw const FormatException(
        'This file is saved as UTF-16. Save it again as "CSV UTF-8".');
  }
  // Excel on some PCs saves legacy 8-bit text; tolerate stray bytes rather than fail.
  return utf8.decode(bytes, allowMalformed: true);
}
