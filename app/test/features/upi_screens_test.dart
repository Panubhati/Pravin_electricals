import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shop_app/core/db/repositories/audit_repository.dart';
import 'package:shop_app/core/db/repositories/settings_repository.dart';
import 'package:shop_app/features/billing/bill_screen.dart';
import 'package:shop_app/features/settings/settings_screen.dart';

import '../helpers/app_harness.dart';

Future<void> openPaySheet(WidgetTester tester) async {
  await tester.enterText(find.byKey(const Key('searchField')), '1.5 sqmm');
  await settle(tester);
  await tester.tap(find.byKey(const Key('result_0')));
  await settle(tester);
  await tester.enterText(find.byKey(const Key('qty_0')), '2.5');
  await tester.pump();
  await tester.tap(find.byKey(const Key('payButton')));
  await settle(tester);
}

void main() {
  group('UPI ID in Settings', () {
    harnessTest('the owner saves a UPI ID; it is shown, stored and audited', (tester, h) async {
      await h.pump(tester, const SettingsScreen());
      expect(find.text('Not set'), findsOneWidget);

      await tester.tap(find.byKey(const Key('settingUpi')));
      await settle(tester);
      await tester.enterText(find.byKey(const Key('upiIdField')), 'pravin@okhdfc');
      await tester.tap(find.byKey(const Key('upiSave')));
      await settle(tester);

      expect(find.text('pravin@okhdfc'), findsOneWidget);
      await db(tester, () async {
        final payee = await SettingsRepository(h.session.ctx).upiPayee('Pravin Electricals');
        expect(payee!.vpa, 'pravin@okhdfc');
        expect(payee.name, 'Pravin Electricals'); // defaults to the shop name
        final audit = await AuditRepository(h.session.ctx).list(actions: {'upi_changed'});
        expect(audit, hasLength(1));
        expect(audit.single.userName, 'Owner');
      });
    }, sample: false);

    harnessTest('a bad UPI ID is refused with a plain message', (tester, h) async {
      await h.pump(tester, const SettingsScreen());
      await tester.tap(find.byKey(const Key('settingUpi')));
      await settle(tester);
      await tester.enterText(find.byKey(const Key('upiIdField')), 'not a upi id');
      await tester.tap(find.byKey(const Key('upiSave')));
      await settle(tester);
      expect(find.text('UPI ID should look like shop@bank.'), findsOneWidget);
      expect(find.text('Not set'), findsOneWidget);
    }, sample: false);

    harnessTest('clearing the UPI ID turns QR codes off', (tester, h) async {
      await db(tester, () => SettingsRepository(h.session.ctx).setUpi(vpa: 'old@ybl'));
      await h.pump(tester, const SettingsScreen());
      expect(find.text('old@ybl'), findsOneWidget);
      await tester.tap(find.byKey(const Key('settingUpi')));
      await settle(tester);
      await tester.enterText(find.byKey(const Key('upiIdField')), '');
      await tester.tap(find.byKey(const Key('upiSave')));
      await settle(tester);
      expect(find.text('Not set'), findsOneWidget);
    }, sample: false);
  });

  group('QR on the Pay screen', () {
    harnessTest('no UPI amount, no QR; typing a UPI amount shows it for exactly that amount', (tester, h) async {
      await db(tester, () => SettingsRepository(h.session.ctx).setUpi(vpa: 'pravin@okhdfc'));
      await h.pump(tester, const BillScreen());
      await openPaySheet(tester); // 2.5 m wire = Rs 119.00, all cash by default
      expect(find.byType(QrImageView), findsNothing);

      await tester.tap(find.text('All UPI'));
      await settle(tester);
      expect(find.byType(QrImageView), findsOneWidget);
      expect(find.text('Customer scans to pay ₹119.00'), findsOneWidget);
      expect(
          find.byKey(const ValueKey(
              'upiQr|upi://pay?pa=pravin@okhdfc&pn=Pravin%20Electricals&am=119.00&cu=INR')),
          findsOneWidget);

      // A mixed payment: the QR follows the UPI part only.
      await tester.enterText(find.widgetWithText(TextField, 'UPI'), '50');
      await tester.pump();
      expect(find.text('Customer scans to pay ₹50.00'), findsOneWidget);
      expect(
          find.byKey(const ValueKey(
              'upiQr|upi://pay?pa=pravin@okhdfc&pn=Pravin%20Electricals&am=50.00&cu=INR')),
          findsOneWidget);

      // Clearing the UPI amount removes it.
      await tester.enterText(find.widgetWithText(TextField, 'UPI'), '');
      await tester.pump();
      expect(find.byType(QrImageView), findsNothing);
    }, sample: true);

    harnessTest('without a UPI ID the owner gets a hint and no QR', (tester, h) async {
      await h.pump(tester, const BillScreen());
      await openPaySheet(tester);
      await tester.tap(find.text('All UPI'));
      await settle(tester);
      expect(find.byType(QrImageView), findsNothing);
      expect(find.byKey(const Key('upiHint')), findsOneWidget);
    }, sample: true);

    harnessTest('counter staff see the QR when a UPI ID exists, and no hint when it does not', (tester, h) async {
      final counter = await h.addCounterUser(tester);
      await h.pump(tester, const BillScreen(), user: counter);
      await openPaySheet(tester);
      await tester.tap(find.text('All UPI'));
      await settle(tester);
      expect(find.byKey(const Key('upiHint')), findsNothing);
      expect(find.byType(QrImageView), findsNothing);
    }, sample: true);

    harnessTest('counter staff see the shop QR once the owner has set a UPI ID', (tester, h) async {
      await db(tester, () => SettingsRepository(h.session.ctx).setUpi(vpa: 'pravin@okhdfc'));
      final counter = await h.addCounterUser(tester);
      await h.pump(tester, const BillScreen(), user: counter);
      await openPaySheet(tester);
      await tester.tap(find.text('All UPI'));
      await settle(tester);
      expect(find.byType(QrImageView), findsOneWidget);
    }, sample: true);
  });
}
