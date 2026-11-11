/// A phone number in the form WhatsApp wants (country code, digits only), or
/// null when it cannot be a WhatsApp number.
///
/// "98765 43210", "+91 98765-43210", "09876543210" and "919876543210" all give
/// "919876543210". Ten-digit Indian mobiles start with 6 to 9; anything else
/// that short (a landline without its code) gives null.
String? whatsappNumber(String? raw) {
  if (raw == null) return null;
  var d = raw.replaceAll(RegExp(r'\D'), '');
  if (d.startsWith('00')) d = d.substring(2); // 0091... international prefix
  if (d.length == 11 && d.startsWith('0')) d = d.substring(1); // 098765...
  if (d.length == 10) {
    return RegExp(r'^[6-9]').hasMatch(d) ? '91$d' : null;
  }
  if (d.length >= 11 && d.length <= 15) return d;
  return null;
}

/// The WhatsApp chat id Android needs to open a given person's chat.
String whatsappJid(String number) => '$number@s.whatsapp.net';
