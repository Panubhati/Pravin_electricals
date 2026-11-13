import '../../shared/strings.dart' show AppLang;
import 'amount_in_words.dart';

/// Every word printed on a bill or credit note, and in the WhatsApp message to
/// the customer, in the shop's chosen bill language (A10). This is separate
/// from the screen language: a Marathi-speaking counter may still send English
/// bills, as the owner chooses in Settings. Numbers and dates stay as they are.
class BillWords {
  const BillWords._(this.lang);
  final AppLang lang;

  static const en = BillWords._(AppLang.en);
  static const mr = BillWords._(AppLang.mr);
  static BillWords of(AppLang lang) => lang == AppLang.mr ? mr : en;

  bool get _mr => lang == AppLang.mr;
  String _t(String english, String marathi) => _mr ? marathi : english;

  String get taxInvoice => _t('TAX INVOICE', 'कर बीजक (TAX INVOICE)');
  String get billTo => _t('Bill to', 'ग्राहक');
  String get walkIn => _t('Walk-in customer', 'रोख ग्राहक');
  String invoiceNo(String no) => _t('Invoice no: $no', 'बिल क्र.: $no');
  String date(String d) => _t('Date: $d', 'दिनांक: $d');
  String phone(String p) => _t('Phone: $p', 'फोन: $p');
  String gstin(String g) => 'GSTIN: $g';
  String placeOfSupply(String code) => _t('Place of supply: $code', 'पुरवठ्याचे ठिकाण: $code');
  String get item => _t('Item', 'वस्तू');
  String get hsn => 'HSN';
  String get qty => _t('Qty', 'नग');
  String get rate => _t('Rate', 'दर');
  String get disc => _t('Disc.', 'सूट');
  String get amount => _t('Amount', 'रक्कम');
  String get subtotal => _t('Subtotal', 'बेरीज');
  String get discount => _t('Discount', 'सूट');
  String get roundOff => _t('Round off', 'राउंड ऑफ');
  String get total => _t('Total', 'एकूण');
  String get gstIncludedInTotal => _t('GST included in the total', 'एकूणमध्ये समाविष्ट GST');
  String get gstRate => _t('Rate', 'दर');
  String get taxableValue => _t('Taxable value', 'करपात्र रक्कम');
  String get payment => _t('Payment', 'पैसे');
  String modeLabel(String mode) => switch (mode) {
        'cash' => _t('Cash', 'रोख'),
        'upi' => 'UPI',
        'credit' => _t('Credit', 'उधार'),
        'card' => _t('Card', 'कार्ड'),
        _ => mode,
      };
  String get dueSuffix => _t('  (due)', '  (बाकी)');
  String balanceDue(String amount) => _t('Balance due: $amount', 'बाकी: $amount');
  String scanToPayBalance(String amount) => _t('Scan to pay the balance $amount by UPI', 'बाकी $amount UPI ने देण्यासाठी स्कॅन करा');
  String payByUpi(String amount) => _t('Pay by UPI ($amount)', 'UPI ने पैसे द्या ($amount)');
  String upiNote(String bill) => 'Bill $bill';
  String forShop(String shop) => _t('For $shop', '$shop करिता');
  String get signatory => _t('Authorised signatory', 'अधिकृत सही');
  String get thankYou => _t('Thank you. Visit again.', 'धन्यवाद. पुन्हा या.');
  String get computerInvoice => _t('This is a computer generated invoice.', 'हे संगणकाने बनवलेले बिल आहे.');
  String page(int n, int of) => _t('Page $n of $of', 'पान $n / $of');
  String words(int paise) => _mr ? amountInWordsMr(paise) : amountInWords(paise);

  // Credit note
  String creditNoteTitle({required bool cancel}) =>
      cancel ? _t('CREDIT NOTE (BILL CANCELLED)', 'क्रेडिट नोट (बिल रद्द)') : _t('CREDIT NOTE', 'क्रेडिट नोट');
  String get customer => _t('Customer', 'ग्राहक');
  String creditNoteNo(String no) => _t('Credit note no: $no', 'क्रेडिट नोट क्र.: $no');
  String againstBill(String bill, String date) => _t('Against bill $bill of $date', '$date च्या बिल $bill विरुद्ध');
  String get itemReturned => _t('Item returned', 'परत आलेली वस्तू');
  String get totalRefunded => _t('Total refunded', 'एकूण परत दिले');
  String get gstIncluded => _t('GST included', 'GST सहित');
  String get refund => _t('Refund', 'परत दिलेले पैसे');
  String refundCash(String a) => _t('Cash: $a', 'रोख: $a');
  String refundUpi(String a) => 'UPI: $a';
  String refundAccount(String a) => _t('Taken off your account: $a', 'तुमच्या बाकीतून वजा: $a');
  String reason(String r) => _t('Reason: $r', 'कारण: $r');
  String get computerCreditNote =>
      _t('This is a computer generated credit note.', 'ही संगणकाने बनवलेली क्रेडिट नोट आहे.');

  // Payment reminder (A11), by SMS or WhatsApp. Dates keep English months.
  String reminderMessage({
    required String name,
    required String shop,
    required String amount,
    required String since,
    String? upiId,
  }) =>
      // The UPI ID as plain text (A13): WhatsApp and SMS never make upi:// links
      // tappable. A long press copies it; WhatsApp also gets a QR picture.
      _t(
        'Namaskar $name, $amount is due at $shop since $since. '
            'Please pay when convenient${upiId == null ? '' : ' to UPI ID $upiId'}. Thank you.',
        'नमस्कार $name, $shop कडे $since पासून $amount बाकी आहे. '
            'सोयीनुसार भरावे${upiId == null ? '' : ' (UPI ID: $upiId)'}. धन्यवाद.',
      );

  // WhatsApp messages to the customer
  String billMessage(String bill, String shop, String total, String? due) => _t(
        'Bill $bill from $shop: $total${due == null ? '' : ' (balance due $due)'}. Thank you!',
        '$shop कडून बिल $bill: $total${due == null ? '' : ' (बाकी $due)'}. धन्यवाद!',
      );
  String creditNoteMessage(String note, String shop, String bill, String total) => _t(
        'Credit note $note from $shop for bill $bill: $total refunded. Thank you!',
        '$shop कडून बिल $bill साठी क्रेडिट नोट $note: $total परत दिले. धन्यवाद!',
      );
}

/// "रुपये चोवीस हजार तीनशे एक्याण्णव फक्त", Indian grouping (हजार, लाख, कोटी).
String amountInWordsMr(int paise) {
  if (paise < 0) throw ArgumentError.value(paise, 'paise', 'must not be negative');
  final rupees = paise ~/ 100;
  final rest = paise % 100;
  final sb = StringBuffer('रुपये ${_mrWords(rupees)}');
  if (rest > 0) sb.write(' आणि ${_mr100[rest]} पैसे');
  sb.write(' फक्त');
  return sb.toString();
}

// Marathi numbers 0 to 99 are each their own word.
const _mr100 = [
  'शून्य', 'एक', 'दोन', 'तीन', 'चार', 'पाच', 'सहा', 'सात', 'आठ', 'नऊ',
  'दहा', 'अकरा', 'बारा', 'तेरा', 'चौदा', 'पंधरा', 'सोळा', 'सतरा', 'अठरा', 'एकोणीस',
  'वीस', 'एकवीस', 'बावीस', 'तेवीस', 'चोवीस', 'पंचवीस', 'सव्वीस', 'सत्तावीस', 'अठ्ठावीस', 'एकोणतीस',
  'तीस', 'एकतीस', 'बत्तीस', 'तेहेतीस', 'चौतीस', 'पस्तीस', 'छत्तीस', 'सदतीस', 'अडतीस', 'एकोणचाळीस',
  'चाळीस', 'एक्केचाळीस', 'बेचाळीस', 'त्रेचाळीस', 'चव्वेचाळीस', 'पंचेचाळीस', 'सेहेचाळीस', 'सत्तेचाळीस', 'अठ्ठेचाळीस', 'एकोणपन्नास',
  'पन्नास', 'एक्कावन्न', 'बावन्न', 'त्रेपन्न', 'चोपन्न', 'पंचावन्न', 'छप्पन्न', 'सत्तावन्न', 'अठ्ठावन्न', 'एकोणसाठ',
  'साठ', 'एकसष्ट', 'बासष्ट', 'त्रेसष्ट', 'चौसष्ट', 'पासष्ट', 'सहासष्ट', 'सदुसष्ट', 'अडुसष्ट', 'एकोणसत्तर',
  'सत्तर', 'एक्काहत्तर', 'बाहत्तर', 'त्र्याहत्तर', 'चौऱ्याहत्तर', 'पंच्याहत्तर', 'शहात्तर', 'सत्याहत्तर', 'अठ्ठ्याहत्तर', 'एकोणऐंशी',
  'ऐंशी', 'एक्याऐंशी', 'ब्याऐंशी', 'त्र्याऐंशी', 'चौऱ्याऐंशी', 'पंच्याऐंशी', 'शहाऐंशी', 'सत्त्याऐंशी', 'अठ्ठ्याऐंशी', 'एकोणनव्वद',
  'नव्वद', 'एक्याण्णव', 'ब्याण्णव', 'त्र्याण्णव', 'चौऱ्याण्णव', 'पंच्याण्णव', 'शहाण्णव', 'सत्त्याण्णव', 'अठ्ठ्याण्णव', 'नव्व्याण्णव',
];

const _mrHundreds = ['', 'एकशे', 'दोनशे', 'तीनशे', 'चारशे', 'पाचशे', 'सहाशे', 'सातशे', 'आठशे', 'नऊशे'];

String _mrBelow1000(int n) {
  if (n < 100) return _mr100[n];
  if (n == 100) return 'शंभर';
  final h = _mrHundreds[n ~/ 100];
  return n % 100 == 0 ? h : '$h ${_mr100[n % 100]}';
}

String _mrWords(int n) {
  if (n == 0) return _mr100[0];
  final parts = <String>[];
  var rest = n;
  final crore = rest ~/ 10000000;
  rest %= 10000000;
  final lakh = rest ~/ 100000;
  rest %= 100000;
  final thousand = rest ~/ 1000;
  rest %= 1000;
  if (crore > 0) parts.add('${_mrWords(crore)} कोटी');
  if (lakh > 0) parts.add('${_mr100[lakh]} लाख');
  if (thousand > 0) parts.add('${_mr100[thousand]} हजार');
  if (rest > 0) parts.add(_mrBelow1000(rest));
  return parts.join(' ');
}
