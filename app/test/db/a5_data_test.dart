import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/core/bootstrap.dart';
import 'package:shop_app/core/db/app_database.dart';
import 'package:shop_app/core/db/repositories/audit_repository.dart';
import 'package:shop_app/core/db/repositories/invoice_repository.dart';
import 'package:shop_app/core/db/repositories/item_repository.dart';
import 'package:shop_app/core/db/repositories/party_repository.dart';
import 'package:shop_app/core/db/repositories/repo_context.dart';
import 'package:shop_app/core/db/repositories/settings_repository.dart';

void main() {
  late AppDatabase db;
  late ShopSession s;
  late ItemRepository items;
  late String wire, ramesh, sunita;
  var n = 0;

  Future<String> bill(DateTime date, String itemId, int qtyBase, int rate, int factor,
      List<PaymentInput> Function(int) pay,
      {String? partyId}) async {
    final amount = (qtyBase * rate / factor).round();
    final tax = (amount * 1800 / 11800).round();
    return InvoiceRepository(s.ctx).postInvoice(PostInvoiceInput(
      deviceId: s.deviceId,
      series: s.series,
      number: ++n,
      date: date,
      locationId: s.locationId,
      partyId: partyId,
      subtotalPaise: amount,
      discountPaise: 0,
      taxPaise: tax,
      roundOffPaise: 0,
      totalPaise: amount,
      lines: [
        InvoiceLineInput(
          itemId: itemId,
          unitName: 'm',
          qtyEntered: '${qtyBase / 1000}',
          qtyBase: qtyBase,
          ratePaise: rate,
          priceUnitFactor: factor,
          gstRateBp: 1800,
          taxPaise: tax,
          lineTotalPaise: amount,
        ),
      ],
      payments: pay(amount),
    ));
  }

  setUp(() async {
    n = 0;
    db = AppDatabase(NativeDatabase.memory());
    s = await ensureShopSession(db);
    items = ItemRepository(s.ctx);
    wire = await items.createItem(
        name: 'Wire', baseUnit: 'mm', priceUnitFactor: 1000, gstRateBp: 1800, hsn: '8544',
        units: const [ItemUnitInput('m', 1000)]);
    final parties = PartyRepository(s.ctx);
    ramesh = await parties.createParty(kind: 'customer', name: 'Ramesh Electricals');
    sunita = await parties.createParty(kind: 'customer', name: 'Sunita Sharma');
  });
  tearDown(() => db.close());

  group('UPI settings', () {
    test('no UPI ID means no payee', () async {
      expect(await SettingsRepository(s.ctx).upiPayee('Pravin Electricals'), isNull);
    });

    test('the payee name defaults to the shop name', () async {
      final repo = SettingsRepository(s.ctx);
      await repo.setUpi(vpa: 'pravin@okhdfc');
      final p = (await repo.upiPayee('Pravin Electricals'))!;
      expect(p.vpa, 'pravin@okhdfc');
      expect(p.name, 'Pravin Electricals');
      await repo.setUpi(vpa: 'pravin@okhdfc', name: 'Pravin Elec.');
      expect((await repo.upiPayee('Pravin Electricals'))!.name, 'Pravin Elec.');
    });

    test('a bad UPI ID is refused and nothing is saved', () async {
      final repo = SettingsRepository(s.ctx);
      await expectLater(repo.setUpi(vpa: 'nobank'), throwsA(isA<DomainException>()));
      expect(await repo.upiPayee('X'), isNull);
    });

    test('every real change is audited with before and after; no change, no row', () async {
      final repo = SettingsRepository(s.ctx);
      await repo.setUpi(vpa: 'old@ybl', userId: s.userId);
      await repo.setUpi(vpa: 'old@ybl', userId: s.userId); // same again
      await repo.setUpi(vpa: 'new@okhdfc', userId: s.userId);
      final rows = await AuditRepository(s.ctx).list(actions: {'upi_changed'});
      expect(rows, hasLength(2));
      expect(rows.first.row.beforeJson, contains('old@ybl'));
      expect(rows.first.row.afterJson, contains('new@okhdfc'));
      expect(rows.first.userName, 'Owner');
    });

    test('clearing the UPI ID turns the QR off', () async {
      final repo = SettingsRepository(s.ctx);
      await repo.setUpi(vpa: 'old@ybl');
      await repo.setUpi(vpa: '');
      expect(await repo.upiPayee('X'), isNull);
    });
  });

  group('HSN is kept on the sold line', () {
    test('a reprint shows the HSN the item had when it was sold', () async {
      final id = await bill(DateTime(2026, 3, 10, 10), wire, 1000, 4750, 1000,
          (t) => [PaymentInput('cash', t)]);
      await items.updateItem(itemId: wire, name: 'Wire', gstRateBp: 1800, minStockBase: 0, hsn: '9999'); // the item's HSN changes later
      final line = (await InvoiceRepository(s.ctx).details(id)).lines.single;
      expect(line.hsn, '8544');
      expect((await items.getItem(wire)).hsn, '9999');
    });
  });

  group('bills list', () {
    late String b1, b2, b3;
    setUp(() async {
      b1 = await bill(DateTime(2026, 3, 10, 10), wire, 1000, 4750, 1000, (t) => [PaymentInput('cash', t)]);
      b2 = await bill(DateTime(2026, 3, 11, 11), wire, 2000, 4750, 1000,
          (t) => [PaymentInput('upi', 5000), PaymentInput('credit', t - 5000)],
          partyId: ramesh);
      b3 = await bill(DateTime(2026, 3, 11, 15), wire, 500, 4750, 1000,
          (t) => [PaymentInput('cash', t)], partyId: sunita);
    });

    test('newest first, with the customer name and what is still due', () async {
      final all = await InvoiceRepository(s.ctx).list();
      expect(all.map((e) => e.invoice.id), [b3, b2, b1]);
      expect(all[0].partyName, 'Sunita Sharma');
      expect(all[1].partyName, 'Ramesh Electricals');
      expect(all[2].partyName, isNull); // walk-in
      expect(all[1].duePaise, 9500 - 5000);
      expect(all[0].duePaise, 0);
    });

    test('search by bill number or by customer name', () async {
      final repo = InvoiceRepository(s.ctx);
      expect((await repo.list(query: 'A-0002')).map((e) => e.invoice.id), [b2]);
      expect((await repo.list(query: 'ramesh')).map((e) => e.invoice.id), [b2]);
      expect((await repo.list(query: 'sharma')).map((e) => e.invoice.id), [b3]);
      expect(await repo.list(query: 'nobody'), isEmpty);
    });

    test('filter by day, both ends inclusive', () async {
      final repo = InvoiceRepository(s.ctx);
      expect((await repo.list(from: DateTime(2026, 3, 11), to: DateTime(2026, 3, 11))).map((e) => e.invoice.id),
          [b3, b2]);
      expect((await repo.list(to: DateTime(2026, 3, 10))).map((e) => e.invoice.id), [b1]);
      expect(await repo.list(from: DateTime(2026, 3, 12)), isEmpty);
    });

    test('the limit caps the list', () async {
      expect(await InvoiceRepository(s.ctx).list(limit: 2), hasLength(2));
    });
  });
}
