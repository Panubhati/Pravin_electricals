import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shop_app/core/bootstrap.dart';
import 'package:shop_app/core/db/app_database.dart';
import 'package:shop_app/core/db/repositories/invoice_repository.dart';
import 'package:shop_app/core/db/repositories/item_repository.dart';
import 'package:shop_app/core/db/repositories/party_repository.dart';
import 'package:shop_app/core/printing/invoice_pdf.dart';
import 'package:shop_app/core/printing/invoice_view.dart';
import 'package:shop_app/core/printing/upi_link.dart';

pw.Font _font(String name) =>
    pw.Font.ttf(ByteData.sublistView(File('assets/fonts/$name').readAsBytesSync()));

const _upi = UpiPayee(vpa: 'pravin@okhdfc', name: 'Pravin Electricals');

void main() {
  late AppDatabase db;
  late ShopSession s;
  late ItemRepository items;
  late String wire, sw, ramesh;
  var n = 0;

  Future<InvoiceDetails> bill({
    required String partyId,
    required List<(String, String, int, int, int, int)> lines, // item, qty text, qtyBase, rate, factor, discount
    required List<PaymentInput> Function(int total) pay,
    int roundOff = 0,
    String? snapshot,
  }) async {
    var subtotal = 0, discount = 0, tax = 0;
    final inputs = <InvoiceLineInput>[];
    for (final (item, qty, qtyBase, rate, factor, disc) in lines) {
      final amount = (qtyBase * rate / factor).round();
      final gross = amount - disc;
      final t = (gross * 1800 / 11800).round();
      subtotal += amount;
      discount += disc;
      tax += t;
      inputs.add(InvoiceLineInput(
        itemId: item,
        unitName: factor == 1000 ? 'm' : 'pcs',
        qtyEntered: qty,
        qtyBase: qtyBase,
        ratePaise: rate,
        priceUnitFactor: factor,
        discountPaise: disc,
        gstRateBp: 1800,
        taxPaise: t,
        lineTotalPaise: gross,
      ));
    }
    final total = subtotal - discount + roundOff;
    final id = await InvoiceRepository(s.ctx).postInvoice(PostInvoiceInput(
      deviceId: s.deviceId,
      series: s.series,
      number: ++n,
      date: DateTime(2026, 3, 10, 10),
      locationId: s.locationId,
      partyId: partyId.isEmpty ? null : partyId,
      subtotalPaise: subtotal,
      discountPaise: discount,
      taxPaise: tax,
      roundOffPaise: roundOff,
      totalPaise: total,
      lines: inputs,
      payments: pay(total),
      shopSnapshotJson: snapshot ??
          jsonEncode({
            'name': 'Pravin Electricals',
            'address': 'Shop 4, Market Road, Pune',
            'phone': '9800000000',
            'gstin': '27AABCP1234F1Z5',
            'stateCode': '27',
            'terms': 'Goods once sold will not be taken back.',
          }),
    ));
    return InvoiceRepository(s.ctx).details(id);
  }

  setUp(() async {
    n = 0;
    db = AppDatabase(NativeDatabase.memory());
    s = await ensureShopSession(db);
    items = ItemRepository(s.ctx);
    wire = await items.createItem(
        name: 'Wire 1.5', baseUnit: 'mm', priceUnitFactor: 1000, gstRateBp: 1800, hsn: '8544',
        units: const [ItemUnitInput('m', 1000)]);
    sw = await items.createItem(
        name: '6A switch', baseUnit: 'pcs', gstRateBp: 1800, hsn: '8536',
        units: const [ItemUnitInput('pcs', 1)]);
    ramesh = await PartyRepository(s.ctx).createParty(
        kind: 'customer', name: 'Ramesh Electricals', phone: '9800000001', gstin: '27AAACR0001A1Z5',
        address: '12 Station Road, Pune', stateCode: '27');
  });
  tearDown(() => db.close());

  group('what is printed', () {
    test('a mixed bill: lines, HSN, totals, words, GST split and the payment lines', () async {
      final d = await bill(
        partyId: ramesh,
        lines: [(wire, '2.5', 2500, 4750, 1000, 0), (sw, '10', 10, 1500, 1, 0)],
        roundOff: 25,
        pay: (t) => [PaymentInput('upi', 5000), PaymentInput('credit', t - 5000)],
      );
      final v = InvoiceView.from(d);

      expect(v.shopName, 'Pravin Electricals');
      expect(v.shopContact, 'Phone: 9800000000   GSTIN: 27AABCP1234F1Z5');
      expect(v.billToName, 'Ramesh Electricals');
      expect(v.billToLines, ['9800000001', '12 Station Road, Pune', 'GSTIN: 27AAACR0001A1Z5']);
      expect(v.placeOfSupply, 'Place of supply: 27');
      expect(v.invoiceNo, 'A-0001');
      expect(v.dateText, '10-03-2026');

      expect(v.showHsn, isTrue);
      expect(v.lines.map((l) => (l.name, l.hsn, l.qty, l.rate, l.amount)), [
        ('Wire 1.5', '8544', '2.5 m', '47.50', '118.75'),
        ('6A switch', '8536', '10 pcs', '15.00', '150.00'),
      ]);
      expect(v.subtotal, '268.75');
      expect(v.roundOff, '+ 0.25');
      expect(v.total, '₹269.00');
      expect(v.words, 'Rupees Two Hundred Sixty Nine only');
      expect(v.interState, isFalse); // same state: CGST + SGST
      expect(v.gstRows.single.rate, '18%');
      expect(v.payments, ['UPI: ₹50.00', 'Credit: ₹219.00  (due)']);
      expect(v.dueText, 'Balance due: ₹219.00');
      expect(v.terms, 'Goods once sold will not be taken back.');
    });

    test('a walk-in cash bill has no customer lines and no due', () async {
      final d = await bill(partyId: '', lines: [(sw, '2', 2, 1500, 1, 0)], pay: (t) => [PaymentInput('cash', t)]);
      final v = InvoiceView.from(d);
      expect(v.billToName, 'Walk-in customer');
      expect(v.billToLines, isEmpty);
      expect(v.placeOfSupply, isNull);
      expect(v.dueText, isNull);
      expect(v.payments, ['Cash: ₹30.00']);
      expect(v.discount, isNull);
      expect(v.showDiscount, isFalse);
    });

    test('a discount shows the column and the total line', () async {
      final d = await bill(
          partyId: '', lines: [(sw, '10', 10, 1500, 1, 1000)], pay: (t) => [PaymentInput('cash', t)]);
      final v = InvoiceView.from(d);
      expect(v.showDiscount, isTrue);
      expect(v.lines.single.discount, '10.00');
      expect(v.discount, '- 10.00');
      expect(v.total, '₹140.00');
    });

    test('a customer in another state is billed IGST', () async {
      final other = await PartyRepository(s.ctx)
          .createParty(kind: 'customer', name: 'Delhi Traders', stateCode: '07');
      final d = await bill(partyId: other, lines: [(sw, '2', 2, 1500, 1, 0)], pay: (t) => [PaymentInput('cash', t)]);
      expect(InvoiceView.from(d).interState, isTrue);
    });

    test('an item with no HSN leaves the column out', () async {
      final plain = await items.createItem(
          name: 'Tape', baseUnit: 'pcs', gstRateBp: 1800, units: const [ItemUnitInput('pcs', 1)]);
      final d = await bill(partyId: '', lines: [(plain, '1', 1, 1500, 1, 0)], pay: (t) => [PaymentInput('cash', t)]);
      expect(InvoiceView.from(d).showHsn, isFalse);
    });
  });

  group('the HSN printed is the one sold', () {
    test('a reprint after the item changed still shows the old HSN', () async {
      final d = await bill(partyId: '', lines: [(wire, '1', 1000, 4750, 1000, 0)], pay: (t) => [PaymentInput('cash', t)]);
      await items.updateItem(itemId: wire, name: 'Wire 1.5', gstRateBp: 1800, minStockBase: 0, hsn: '9999');
      final again = await InvoiceRepository(s.ctx).details(d.invoice.id);
      expect(InvoiceView.from(again).lines.single.hsn, '8544');
    });

    test('lines saved before schema v4 fall back to the item\'s current HSN', () async {
      final d = await bill(partyId: '', lines: [(wire, '1', 1000, 4750, 1000, 0)], pay: (t) => [PaymentInput('cash', t)]);
      await (db.update(db.invoiceLines)).write(const InvoiceLinesCompanion(hsn: Value(null)));
      final again = await InvoiceRepository(s.ctx).details(d.invoice.id);
      expect(InvoiceView.from(again).lines.single.hsn, '8544');
    });
  });

  group('UPI QR', () {
    test('no UPI ID, no QR', () async {
      final d = await bill(partyId: ramesh, lines: [(sw, '2', 2, 1500, 1, 0)],
          pay: (t) => [PaymentInput('credit', t)]);
      final v = InvoiceView.from(d);
      expect(v.upiLink, isNull);
      expect(v.upiCaption, isNull);
    });

    test('a bill with credit asks for the balance, with the bill number as the note', () async {
      final d = await bill(partyId: ramesh, lines: [(sw, '10', 10, 1500, 1, 0)],
          pay: (t) => [PaymentInput('cash', 5000), PaymentInput('credit', t - 5000)]);
      final v = InvoiceView.from(d, upi: _upi);
      expect(v.upiLink,
          'upi://pay?pa=pravin@okhdfc&pn=Pravin%20Electricals&am=100.00&cu=INR&tn=Bill%20A-0001');
      expect(v.upiCaption, 'Scan to pay the balance ₹100.00 by UPI');
    });

    test('a fully paid bill still carries a QR, for the full total', () async {
      final d = await bill(partyId: '', lines: [(sw, '2', 2, 1500, 1, 0)], pay: (t) => [PaymentInput('cash', t)]);
      final v = InvoiceView.from(d, upi: _upi);
      expect(v.upiLink, contains('am=30.00'));
      expect(v.upiCaption, 'Pay by UPI (₹30.00)');
    });
  });

  group('the PDF', () {
    final fonts = InvoiceFonts(_font('NotoSans-Regular.ttf'), _font('NotoSans-Bold.ttf'));

    test('renders a valid PDF with and without a QR; the QR makes it bigger', () async {
      final d = await bill(partyId: ramesh, lines: [(wire, '2.5', 2500, 4750, 1000, 0), (sw, '10', 10, 1500, 1, 0)],
          pay: (t) => [PaymentInput('credit', t)]);
      final plain = await buildInvoicePdf(d, fonts, compress: false);
      final withQr = await buildInvoicePdf(d, fonts, upi: _upi, compress: false);
      for (final b in [plain, withQr]) {
        expect(ascii.decode(b.sublist(0, 5)), '%PDF-');
        expect(ascii.decode(b.sublist(b.length - 6)), contains('%%EOF'));
      }
      expect(withQr.length, greaterThan(plain.length));
    });

    test('a long bill runs onto more pages with page numbers and still renders', () async {
      final many = [for (var i = 0; i < 60; i++) (sw, '${i + 1}', i + 1, 1500, 1, 0)];
      final d = await bill(partyId: ramesh, lines: many, pay: (t) => [PaymentInput('cash', t)]);
      final b = await buildInvoicePdf(d, fonts, upi: _upi);
      expect(ascii.decode(b.sublist(0, 5)), '%PDF-');
      // More than one page object.
      final pages = RegExp(r'/Type\s*/Page(?!s)').allMatches(latin1.decode(
          await buildInvoicePdf(d, fonts, upi: _upi, compress: false))).length;
      expect(pages, greaterThan(1));
    });
  });
}
