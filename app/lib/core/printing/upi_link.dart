/// Who gets the money: the shop's UPI ID and the name customers see in their app.
class UpiPayee {
  const UpiPayee({required this.vpa, required this.name});
  final String vpa;
  final String name;
}

/// Builds the standard `upi://pay` link that every UPI app reads from a QR code.
/// Only the standard fields are used (pa, pn, am, cu, tn) so all apps agree.
class UpiLink {
  static final _vpa = RegExp(r'^[a-zA-Z0-9._-]{2,}@[a-zA-Z][a-zA-Z0-9.-]{1,}$');

  /// True for a UPI ID like `shop@okhdfc` or `9800000001@ybl`.
  static bool isValidVpa(String s) => _vpa.hasMatch(s.trim());

  /// The link for paying [amountPaise] (omitted when null or zero, so the
  /// customer types it) to [payee]. Returns null when there is no valid payee.
  /// [note] is the payment remark, for example the bill number.
  static String? build(UpiPayee? payee, {int? amountPaise, String? note}) {
    if (payee == null || !isValidVpa(payee.vpa)) return null;
    final parts = <String>[
      'pa=${payee.vpa.trim()}',
      if (payee.name.trim().isNotEmpty) 'pn=${Uri.encodeComponent(payee.name.trim())}',
      if (amountPaise != null && amountPaise > 0) 'am=${_rupees(amountPaise)}',
      'cu=INR',
      if (note != null && note.trim().isNotEmpty)
        'tn=${Uri.encodeComponent(_clip(note.trim(), 50))}',
    ];
    return 'upi://pay?${parts.join('&')}';
  }

  static String _rupees(int paise) =>
      '${paise ~/ 100}.${(paise % 100).toString().padLeft(2, '0')}';

  static String _clip(String s, int n) => s.length <= n ? s : s.substring(0, n);
}
