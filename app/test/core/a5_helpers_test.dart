import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/core/printing/amount_in_words.dart';
import 'package:shop_app/core/printing/upi_link.dart';
import 'package:shop_app/core/sharing/phone_number.dart';

void main() {
  group('amount in words (Indian style)', () {
    test('whole rupees', () {
      expect(amountInWords(0), 'Rupees Zero only');
      expect(amountInWords(100), 'Rupees One only');
      expect(amountInWords(11900), 'Rupees One Hundred Nineteen only');
      expect(amountInWords(1000000), 'Rupees Ten Thousand only');
      expect(amountInWords(2000000), 'Rupees Twenty Thousand only');
    });

    test('paise are spelled out', () {
      expect(amountInWords(123450),
          'Rupees One Thousand Two Hundred Thirty Four and Fifty Paise only');
      expect(amountInWords(50), 'Rupees Zero and Fifty Paise only');
      expect(amountInWords(101), 'Rupees One and One Paise only');
    });

    test('teens, round tens and hundreds read naturally', () {
      expect(amountInWords(1300), 'Rupees Thirteen only');
      expect(amountInWords(4000), 'Rupees Forty only');
      expect(amountInWords(70000), 'Rupees Seven Hundred only');
      expect(amountInWords(70500), 'Rupees Seven Hundred Five only');
    });

    test('lakh and crore grouping', () {
      expect(amountInWords(10000000), 'Rupees One Lakh only');
      expect(amountInWords(12345600), 'Rupees One Lakh Twenty Three Thousand Four Hundred Fifty Six only');
      expect(amountInWords(1000000000), 'Rupees One Crore only');
      expect(amountInWords(1234567800),
          'Rupees One Crore Twenty Three Lakh Forty Five Thousand Six Hundred Seventy Eight only');
      expect(amountInWords(100 * 100 * 10000000), 'Rupees One Hundred Crore only');
    });

    test('a negative amount is refused', () {
      expect(() => amountInWords(-1), throwsArgumentError);
    });
  });

  group('UPI link', () {
    const payee = UpiPayee(vpa: 'pravin@okhdfc', name: 'Pravin Electricals');

    test('a full link with amount and bill number', () {
      expect(UpiLink.build(payee, amountPaise: 11900, note: 'Bill A-0001'),
          'upi://pay?pa=pravin@okhdfc&pn=Pravin%20Electricals&am=119.00&cu=INR&tn=Bill%20A-0001');
    });

    test('paise are padded: Rs 5.05 and Rs 1,234.50', () {
      expect(UpiLink.build(payee, amountPaise: 505), contains('am=5.05'));
      expect(UpiLink.build(payee, amountPaise: 123450), contains('am=1234.50'));
    });

    test('no amount: the customer types it', () {
      final link = UpiLink.build(payee)!;
      expect(link, isNot(contains('am=')));
      expect(UpiLink.build(payee, amountPaise: 0), isNot(contains('am=')));
    });

    test('names with symbols are encoded and long notes are cut to 50', () {
      final link = UpiLink.build(const UpiPayee(vpa: 'a.b@ybl', name: 'Ram & Sons #1'),
          note: 'x' * 80)!;
      expect(link, contains('pn=Ram%20%26%20Sons%20%231'));
      expect(link, contains('tn=${'x' * 50}'));
      expect(link, isNot(contains('x' * 51)));
    });

    test('no payee or a bad UPI ID gives no link', () {
      expect(UpiLink.build(null, amountPaise: 100), isNull);
      expect(UpiLink.build(const UpiPayee(vpa: 'nobank', name: 'X')), isNull);
      expect(UpiLink.build(const UpiPayee(vpa: '', name: 'X')), isNull);
    });

    test('which UPI IDs are valid', () {
      for (final ok in ['shop@okhdfc', '9800000001@ybl', 'a.b-c_d@paytm', ' shop@sbi ']) {
        expect(UpiLink.isValidVpa(ok), isTrue, reason: ok);
      }
      for (final bad in ['shop', '@ybl', 'a@b', 'shop@', 'sh op@ybl', 'shop@@ybl', 'a@1bank']) {
        expect(UpiLink.isValidVpa(bad), isFalse, reason: bad);
      }
    });
  });

  group('WhatsApp number', () {
    test('Indian formats all become 91 + ten digits', () {
      for (final raw in ['9876543210', '98765 43210', '+91 98765-43210', '09876543210', '919876543210', '0091 9876543210']) {
        expect(whatsappNumber(raw), '919876543210', reason: raw);
      }
    });

    test('other countries keep their code', () {
      expect(whatsappNumber('+1 415 555 0132'), '14155550132');
    });

    test('numbers that cannot be WhatsApp numbers give null', () {
      for (final raw in [null, '', 'abc', '12345', '2012345678', '98765']) {
        expect(whatsappNumber(raw), isNull, reason: '$raw');
      }
    });

    test('chat id', () {
      expect(whatsappJid('919876543210'), '919876543210@s.whatsapp.net');
    });
  });
}
