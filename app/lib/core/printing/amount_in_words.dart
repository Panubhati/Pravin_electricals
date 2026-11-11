/// Rupee amounts in words, Indian style, for the foot of a tax invoice:
/// 123450 paise -> "Rupees One Thousand Two Hundred Thirty Four and Fifty Paise only".
String amountInWords(int paise) {
  if (paise < 0) throw ArgumentError.value(paise, 'paise', 'must not be negative');
  final rupees = paise ~/ 100;
  final rest = paise % 100;
  final sb = StringBuffer('Rupees ${_words(rupees)}');
  if (rest > 0) sb.write(' and ${_words(rest)} Paise');
  sb.write(' only');
  return sb.toString();
}

const _small = [
  'Zero', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine',
  'Ten', 'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen', 'Sixteen',
  'Seventeen', 'Eighteen', 'Nineteen',
];
const _tens = ['', '', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy', 'Eighty', 'Ninety'];

String _below100(int n) {
  if (n < 20) return _small[n];
  final t = _tens[n ~/ 10];
  return n % 10 == 0 ? t : '$t ${_small[n % 10]}';
}

String _below1000(int n) {
  if (n < 100) return _below100(n);
  final h = '${_small[n ~/ 100]} Hundred';
  return n % 100 == 0 ? h : '$h ${_below100(n % 100)}';
}

/// Words for a whole number using crore, lakh, thousand and hundred.
String _words(int n) {
  if (n == 0) return 'Zero';
  final parts = <String>[];
  var rest = n;
  final crore = rest ~/ 10000000;
  rest %= 10000000;
  final lakh = rest ~/ 100000;
  rest %= 100000;
  final thousand = rest ~/ 1000;
  rest %= 1000;
  if (crore > 0) parts.add('${_words(crore)} Crore');
  if (lakh > 0) parts.add('${_below100(lakh)} Lakh');
  if (thousand > 0) parts.add('${_below100(thousand)} Thousand');
  if (rest > 0) parts.add(_below1000(rest));
  return parts.join(' ');
}
