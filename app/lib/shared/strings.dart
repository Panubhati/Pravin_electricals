import 'strings_mr.dart';

/// Which language the app shows.
enum AppLang { mr, en }

/// All user-facing text, in English and Marathi (A10). Each entry is a getter,
/// so the language can change while the app runs.
abstract final class S {
  /// The language the screens show. Set at start-up from this phone's choice;
  /// tests leave it English.
  static AppLang lang = AppLang.en;
  static bool get _mr => lang == AppLang.mr;

  /// The Marathi text for [key] when Marathi is on, else [english]. A key
  /// with no Marathi yet falls back to English.
  static String _t(String key, String english) => _mr ? (mrStrings[key] ?? english) : english;

  static String get appTitle => _t('appTitle', 'Pravin Electricals');

  // Home
  static String get newBill => _t('newBill', 'New bill');

  static String get loadSampleData => _t('loadSampleData', 'Load sample data (debug)');

  static String get sampleDataLoaded => _t('sampleDataLoaded', 'Sample data loaded');

  // Bill screen
  static String get billTitle => _t('billTitle', 'New bill');

  static String get searchHint => _t('searchHint', 'Search or scan an item');

  static String get scanBarcode => _t('scanBarcode', 'Scan barcode');

  static String get noResults => _t('noResults', 'No items found');

  static String get cartEmpty => _t('cartEmpty', 'Search or scan an item to start the bill');

  static String get noPrice => _t('noPrice', 'No price set for this item. Add a price first.');

  static String get qty => _t('qty', 'Qty');

  static String get unit => _t('unit', 'Unit');

  static String get discount => _t('discount', 'Less ₹');

  static String get remove => _t('remove', 'Remove');

  static String get walkIn => _t('walkIn', 'Walk-in customer');

  static String get chooseCustomer => _t('chooseCustomer', 'Choose customer');

  static String get subtotal => _t('subtotal', 'Subtotal');

  static String get discountLabel => _t('discountLabel', 'Discount');

  static String get roundOff => _t('roundOff', 'Round off');

  static String get total => _t('total', 'Total');

  static String get gstIncluded => _t('gstIncluded', 'GST included');

  static String get pay => _t('pay', 'Pay');

  static String get invalidQty => _t('invalidQty', 'Enter a valid quantity');

  // Customer sheet
  static String get searchCustomer => _t('searchCustomer', 'Search name or phone');

  static String get addCustomer => _t('addCustomer', 'Add new customer');

  static String get customerName => _t('customerName', 'Customer name');

  static String get customerPhone => _t('customerPhone', 'Phone (optional)');

  static String get save => _t('save', 'Save');

  static String get cancel => _t('cancel', 'Cancel');

  // Payment sheet
  static String get paymentTitle => _t('paymentTitle', 'Payment');

  static String get cash => _t('cash', 'Cash');

  static String get upi => _t('upi', 'UPI');

  static String get credit => _t('credit', 'Credit (udhaar)');

  static String get remaining => _t('remaining', 'Remaining');

  static String get fullCash => _t('fullCash', 'All cash');

  static String get fullUpi => _t('fullUpi', 'All UPI');

  static String get fullCredit => _t('fullCredit', 'All credit');

  static String get saveBill => _t('saveBill', 'Save bill');

  static String get creditNeedsCustomer => _t('creditNeedsCustomer', 'Choose a customer to sell on credit');

  static String get overCreditLimit => _t('overCreditLimit', 'This is over the customer\'s credit limit.');

  static String get continueAnyway => _t('continueAnyway', 'Continue anyway');

  // Done
  static String get billSaved => _t('billSaved', 'Bill saved');

  static String get sharePdf => _t('sharePdf', 'Share PDF');

  static String get newBillAgain => _t('newBillAgain', 'New bill');

  // Home tiles
  static String get items => _t('items', 'Items');

  static String get stock => _t('stock', 'Stock');

  static String get purchases => _t('purchases', 'Purchases');

  static String get customers => _t('customers', 'Customers');

  static String get suppliers => _t('suppliers', 'Suppliers');

  static String get dues => _t('dues', 'Dues');

  static String get importData => _t('importData', 'Import');

  // Items
  static String get itemsTitle => _t('itemsTitle', 'Items');

  static String get addItem => _t('addItem', 'Add item');

  static String get editItem => _t('editItem', 'Edit item');

  static String get searchItems => _t('searchItems', 'Search items');

  static String get showInactive => _t('showInactive', 'Show inactive');

  static String get noItems => _t('noItems', 'No items yet. Tap Add item, or use Import to load a file.');

  static String get inactive => _t('inactive', 'Inactive');

  static String get lowStock => _t('lowStock', 'Low stock');

  static String get outOfStock => _t('outOfStock', 'Out of stock');

  static String get negativeStock => _t('negativeStock', 'Negative stock');

  static String get noPriceChip => _t('noPriceChip', 'No price');

  static String get itemName => _t('itemName', 'Item name');

  static String get brand => _t('brand', 'Brand');

  static String get category => _t('category', 'Category');

  static String get hsn => _t('hsn', 'HSN code');

  static String get gstRate => _t('gstRate', 'GST rate');

  static String get itemType => _t('itemType', 'How is it sold?');

  static String get typeLength => _t('typeLength', 'By the metre');

  static String get typePiece => _t('typePiece', 'By the piece');

  static String get typeFixed => _t('typeFixed', 'The type cannot be changed after creation.');

  static String get rollLength => _t('rollLength', 'Roll length (metres)');

  static String get boxSize => _t('boxSize', 'Pieces in a box');

  static String get prices => _t('prices', 'Prices (GST included)');

  static String get retailPrice => _t('retailPrice', 'Retail price');

  static String get contractorPrice => _t('contractorPrice', 'Contractor price');

  static String get dealerPrice => _t('dealerPrice', 'Dealer price');

  static String get costPrice => _t('costPrice', 'Cost price (no GST)');

  static String get minStock => _t('minStock', 'Minimum stock (low stock alert)');

  static String get openingStock => _t('openingStock', 'Stock on hand now (optional)');

  static String get barcode => _t('barcode', 'Barcode (optional)');

  static String get variants => _t('variants', 'Variants and barcodes');

  static String get addVariant => _t('addVariant', 'Add variant or barcode');

  static String get variantName => _t('variantName', 'Variant name (for example Red)');

  static String get itemSaved => _t('itemSaved', 'Item saved');

  static String get activeSwitch => _t('activeSwitch', 'Active (shown in billing)');

  static String get deactivateConfirm => _t('deactivateConfirm', 'Hide this item from billing? Its history is kept.');

  static String get perMetre => _t('perMetre', 'per metre');

  static String get perPiece => _t('perPiece', 'per piece');

  // Stock
  static String get stockTitle => _t('stockTitle', 'Stock');

  static String get searchStock => _t('searchStock', 'Search stock');

  static String get filterAll => _t('filterAll', 'All');

  static String get filterLow => _t('filterLow', 'Low');

  static String get filterNegative => _t('filterNegative', 'Negative');

  static String get noStockItems => _t('noStockItems', 'No items to show.');

  static String get adjustStock => _t('adjustStock', 'Adjust');

  static String get countStock => _t('countStock', 'Count');

  static String get history => _t('history', 'History');

  static String get noHistory => _t('noHistory', 'No stock movements yet.');

  static String get addStock => _t('addStock', 'Add stock');

  static String get removeStock => _t('removeStock', 'Remove stock');

  static String get quantity => _t('quantity', 'Quantity');

  static String get reason => _t('reason', 'Reason');

  static String get reasonDamaged => _t('reasonDamaged', 'Damaged or lost');

  static String get reasonFound => _t('reasonFound', 'Found extra');

  static String get reasonCorrection => _t('reasonCorrection', 'Correction');

  static String get reasonOther => _t('reasonOther', 'Other');

  static String get countedQty => _t('countedQty', 'Counted quantity');

  static String get systemQty => _t('systemQty', 'In the app');

  static String get difference => _t('difference', 'Difference');

  static String get confirmCount => _t('confirmCount', 'Save count');

  static String get stockSaved => _t('stockSaved', 'Stock updated');

  static String get onlyInStock => _t('onlyInStock', 'Only');

  static String get inStockSuffix => _t('inStockSuffix', 'in stock');

  // Parties
  static String get customersTitle => _t('customersTitle', 'Customers');

  static String get suppliersTitle => _t('suppliersTitle', 'Suppliers');

  static String get addParty => _t('addParty', 'Add');

  static String get editParty => _t('editParty', 'Edit');

  static String get noParties => _t('noParties', 'Nobody here yet.');

  static String get partyName => _t('partyName', 'Name');

  static String get phone => _t('phone', 'Phone');

  static String get gstin => _t('gstin', 'GSTIN (optional)');

  static String get stateCode => _t('stateCode', 'State code (for example 27)');

  static String get address => _t('address', 'Address (optional)');

  static String get tier => _t('tier', 'Price level');

  static String get creditLimit => _t('creditLimit', 'Credit limit (Rs, 0 for none)');

  static String get kind => _t('kind', 'Type');

  static String get kindCustomer => _t('kindCustomer', 'Customer');

  static String get kindSupplier => _t('kindSupplier', 'Supplier');

  static String get kindBoth => _t('kindBoth', 'Customer and supplier');

  static String get owes => _t('owes', 'Owes you');

  static String get youOwe => _t('youOwe', 'You owe');

  static String get settled => _t('settled', 'Settled');

  static String get advancePaid => _t('advancePaid', 'Advance');

  static String get statement => _t('statement', 'Statement');

  static String get recordPayment => _t('recordPayment', 'Record payment');

  static String get recordSupplierPayment => _t('recordSupplierPayment', 'Pay supplier');

  static String get amount => _t('amount', 'Amount (Rs)');

  static String get paymentMode => _t('paymentMode', 'Paid by');

  static String get note => _t('note', 'Note (optional)');

  static String get openingBalance => _t('openingBalance', 'Opening balance');

  static String get paymentSaved => _t('paymentSaved', 'Payment saved');

  static String get balance => _t('balance', 'Balance');

  // Dues
  static String get duesTitle => _t('duesTitle', 'Dues');

  static String get receivables => _t('receivables', 'Customers owe');

  static String get payables => _t('payables', 'You owe suppliers');

  static String get noDues => _t('noDues', 'Nothing outstanding.');

  static String get bucket0 => _t('bucket0', '0-30 days');

  static String get bucket31 => _t('bucket31', '31-60 days');

  static String get bucket61 => _t('bucket61', '61-90 days');

  static String get bucket90 => _t('bucket90', 'Over 90 days');

  static String get totalDue => _t('totalDue', 'Total due');

  // Purchases
  static String get purchasesTitle => _t('purchasesTitle', 'Purchases');

  static String get newPurchase => _t('newPurchase', 'New purchase');

  static String get noPurchases => _t('noPurchases', 'No purchases yet.');

  static String get supplier => _t('supplier', 'Supplier');

  static String get chooseSupplier => _t('chooseSupplier', 'Choose supplier');

  static String get supplierInvoiceNo => _t('supplierInvoiceNo', 'Supplier bill number');

  static String get supplierInvoiceDate => _t('supplierInvoiceDate', 'Bill date');

  static String get rateExGst => _t('rateExGst', 'Rate (without GST)');

  static String get gstPercent => _t('gstPercent', 'GST %');

  static String get addLine => _t('addLine', 'Add item');

  static String get savePurchase => _t('savePurchase', 'Save purchase');

  static String get purchaseSaved => _t('purchaseSaved', 'Purchase saved');

  static String get taxableTotal => _t('taxableTotal', 'Total before GST');

  static String get gstAmount => _t('gstAmount', 'GST');

  static String get grandTotal => _t('grandTotal', 'Total');

  static String get purchaseHint => _t('purchaseHint', 'Search an item to add it to this purchase');

  // Import
  static String get importTitle => _t('importTitle', 'Import from file');

  static String get importItems => _t('importItems', 'Import items');

  static String get importParties => _t('importParties', 'Import customers and suppliers');

  static String get chooseFile => _t('chooseFile', 'Choose CSV file');

  static String get downloadTemplate => _t('downloadTemplate', 'Download template');

  static String get importNow => _t('importNow', 'Import now');

  static String get importDone => _t('importDone', 'Import finished');

  static String get importHelp => _t(
    'importHelp',
    'Save your Excel sheet as CSV first (File > Save As > CSV). '
        'Download the template to see the columns.',
  );

  // Login and roles (A4)
  static String get lockTitle => _t('lockTitle', 'Who is using the app?');

  static String get enterPin => _t('enterPin', 'Enter PIN');

  static String get wrongPin => _t('wrongPin', 'Wrong PIN, try again');

  static String get forgotPin => _t('forgotPin', 'Forgot PIN?');

  static String get forgotPinReason => _t('forgotPinReason', 'Confirm it is you to set a new owner PIN');

  static String get forgotPinFailed => _t('forgotPinFailed', 'Could not confirm with the phone lock');

  static String get setupPinTitle => _t('setupPinTitle', 'Set the owner PIN');

  static String get setupPinHelp =>
      _t('setupPinHelp', 'Choose a 4 to 6 digit PIN. You will use it to open the app. Staff get their own PIN.');

  static String get newPin => _t('newPin', 'New PIN');

  static String get confirmPin => _t('confirmPin', 'Enter the PIN again to confirm');

  static String get pinMismatch => _t('pinMismatch', 'The two PINs did not match. Start again.');

  static String get pinRules => _t('pinRules', 'PIN must be 4 to 6 digits');

  static String get lockNow => _t('lockNow', 'Lock');

  static String get unlock => _t('unlock', 'Unlock');

  static String get askOwner => _t('askOwner', 'Ask the owner');

  static String discountTooHigh(int pct) =>
      _mr ? SMr.discountTooHigh(pct) : 'Staff can give up to $pct% discount. Ask the owner.';

  static String lockedWait(int seconds) =>
      _mr ? SMr.lockedWait(seconds) : 'Too many wrong tries. Try again in $seconds seconds.';

  // Dashboard and reports (A4)
  static String get reports => _t('reports', 'Reports');

  static String get reportsTitle => _t('reportsTitle', 'Reports');

  static String get dailySales => _t('dailySales', 'Daily sales');

  static String get itemProfit => _t('itemProfit', 'Item profit');

  static String get stockValue => _t('stockValue', 'Stock value');

  static String get billsCount => _t('billsCount', 'Bills');

  static String get salesTotal => _t('salesTotal', 'Sales');

  static String get paidBy => _t('paidBy', 'Paid by');

  static String get cashInHand => _t('cashInHand', 'Cash in hand');

  static String get cashOpening => _t('cashOpening', 'Cash at start of day');

  static String get cashSales => _t('cashSales', 'Cash sales');

  static String get cashReceived => _t('cashReceived', 'Cash received from customers');

  static String get cashPaidOut => _t('cashPaidOut', 'Cash paid to suppliers');

  static String get cashClosing => _t('cashClosing', 'Cash in hand now');

  static String get cashNote =>
      _t('cashNote', 'Counts cash only. Expenses are not recorded yet. Set the opening cash in Settings.');

  static String get noSalesInPeriod => _t('noSalesInPeriod', 'No sales in this period');

  static String get salesExGst => _t('salesExGst', 'Sales (without GST)');

  static String get costOfGoods => _t('costOfGoods', 'Cost of goods sold');

  static String get profit => _t('profit', 'Profit');

  static String get margin => _t('margin', 'Margin');

  static String get byItem => _t('byItem', 'By item');

  static String get costUnknown => _t('costUnknown', 'Cost price not known');

  static String get costUnknownHelp => _t(
    'costUnknownHelp',
    'These sales are not counted in profit because the item had no cost price '
        'on the day of the bill. Enter a purchase or set a cost price to include future sales.',
  );

  static String get costUnknownStockHelp =>
      _t('costUnknownStockHelp', 'Not counted in the total: no cost price has been entered for these items.');

  static String get returnsNote => _t('returnsNote', 'Sales returns are not included yet.');

  static String get noStockOnHand => _t('noStockOnHand', 'No stock on hand');

  static String get stockValueTotal => _t('stockValueTotal', 'Stock value');

  static String get stockValueNote => _t('stockValueNote', 'Quantity on hand x latest cost price, without GST.');

  static String get todaySales => _t('todaySales', "Today's sales");

  static String get dashboardCash => _t('dashboardCash', 'Cash in hand');

  static String get lowStockItems => _t('lowStockItems', 'Low stock');

  static String get totalDues => _t('totalDues', 'Customers owe');

  static String get biggestDues => _t('biggestDues', 'Biggest dues');

  static String get noDuesYet => _t('noDuesYet', 'No customer dues');

  // Settings, staff and audit (A4)
  static String get settings => _t('settings', 'Settings');

  static String get settingsTitle => _t('settingsTitle', 'Settings');

  static String get settingsShop => _t('settingsShop', 'Shop');

  static String get settingsRules => _t('settingsRules', 'Rules');

  static String get settingsRecords => _t('settingsRecords', 'Records');

  static String get settingSaved => _t('settingSaved', 'Saved');

  static String get shopDetails => _t('shopDetails', 'Shop details');

  static String get shopName => _t('shopName', 'Shop name');

  static String get shopAddress => _t('shopAddress', 'Address');

  static String get shopTerms => _t('shopTerms', 'Terms printed on the bill');

  static String get shopSaved => _t('shopSaved', 'Shop details saved');

  static String get staffAndPins => _t('staffAndPins', 'Staff and PINs');

  static String get addStaff => _t('addStaff', 'Add counter staff');

  static String get staffName => _t('staffName', 'Name');

  static String get staffPin => _t('staffPin', 'PIN (4 to 6 digits)');

  static String get resetPin => _t('resetPin', 'Set new PIN');

  static String get changeMyPin => _t('changeMyPin', 'Change my PIN');

  static String get removeStaff => _t('removeStaff', 'Remove');

  static String get removeStaffConfirm => _t('removeStaffConfirm', 'Remove this person? Their old bills stay.');

  static String get staffAdded => _t('staffAdded', 'Staff added');

  static String get pinChanged => _t('pinChanged', 'PIN changed');

  static String get ownerRole => _t('ownerRole', 'Owner');

  static String get counterRole => _t('counterRole', 'Counter');

  static String get removedLabel => _t('removedLabel', 'Removed');

  static String get counterDiscountLimit => _t('counterDiscountLimit', 'Counter discount limit');

  static String get counterDiscountHelp =>
      _t('counterDiscountHelp', 'Most discount staff can give on one bill line, as a percent.');

  static String get enterWholeNumber0to100 => _t('enterWholeNumber0to100', 'Enter a whole number from 0 to 100');

  static String get enterWholeNumber0to120 => _t('enterWholeNumber0to120', 'Enter a whole number from 0 to 120');

  static String get enterAmount => _t('enterAmount', 'Enter an amount like 5000 or 5000.50');

  static String get openingCash => _t('openingCash', 'Opening cash');

  static String get openingCashHelp => _t('openingCashHelp', 'Cash in the drawer when you started using the app.');

  static String get autoLock => _t('autoLock', 'Auto-lock after');

  static String get autoLockHelp =>
      _t('autoLockHelp', 'Minutes the app can be in the background before it asks for the PIN. 0 means always.');

  static String get auditLog => _t('auditLog', 'Audit log');

  static String get auditHelp =>
      _t('auditHelp', 'Who changed prices, gave discounts, adjusted stock or edited records');

  static String get auditEmpty => _t('auditEmpty', 'Nothing recorded yet');

  static String get auditPrices => _t('auditPrices', 'Prices');

  static String get auditDiscounts => _t('auditDiscounts', 'Discounts');

  static String get auditStock => _t('auditStock', 'Stock');

  static String get auditEdits => _t('auditEdits', 'Edits');

  static String get auditUsers => _t('auditUsers', 'Users and shop');

  static String get pickDates => _t('pickDates', 'Pick dates');

  static String get settingsAlerts => _t('settingsAlerts', 'Alerts');

  static String get dailySummary => _t('dailySummary', 'Daily summary');

  static String get dailySummaryHelp =>
      _t('dailySummaryHelp', "A phone notification each evening with today's sales, cash and dues.");

  static String get summaryTime => _t('summaryTime', 'Summary time');

  static String get summaryTimeHelp =>
      _t('summaryTimeHelp', 'Hour of the day, 0 to 23 (21 means 9 PM). Android may send it a few minutes late.');

  static String get summaryTestNow => _t('summaryTestNow', 'Send a test summary now');

  static String get notificationsBlocked =>
      _t('notificationsBlocked', 'Allow notifications for this app in the phone settings first');

  static String get enterWholeNumber0to23 => _t('enterWholeNumber0to23', 'Enter a whole number from 0 to 23');

  // UPI, bills history and sharing (A5)
  static String get upiSetting => _t('upiSetting', 'UPI ID for QR codes');

  static String get upiNotSet => _t('upiNotSet', 'Not set');

  static String get upiHelp => _t(
    'upiHelp',
    'Customers scan a QR code to pay this UPI ID. It appears on the Pay screen and on every bill PDF. Leave empty to turn QR codes off.',
  );

  static String get upiId => _t('upiId', 'UPI ID (for example shop@okhdfc)');

  static String get upiName => _t('upiName', 'Name customers see (optional)');

  static String get upiSaved => _t('upiSaved', 'UPI ID saved');

  static String get upiOwnerHint => _t('upiOwnerHint', 'Add your UPI ID in Settings to show a payment QR here.');

  static String upiScanToPay(String amount) => _mr ? SMr.upiScanToPay(amount) : 'Customer scans to pay $amount';

  static String get bills => _t('bills', 'Bills');

  static String get billsTitle => _t('billsTitle', 'Bills');

  static String get searchBills => _t('searchBills', 'Search bill number or customer');

  static String get noBills => _t('noBills', 'No bills yet');

  static String get billDetail => _t('billDetail', 'Bill');

  static String get whatsapp => _t('whatsapp', 'WhatsApp');

  static String get sharedViaSheet =>
      _t('sharedViaSheet', 'WhatsApp is not available for this customer, so the share sheet opened');

  static String get dueLabel => _t('dueLabel', 'due');

  static String get sharedNoPhone =>
      _t('sharedNoPhone', 'This customer has no phone number saved, so the share sheet opened instead');

  static String get sharedNoWhatsApp =>
      _t('sharedNoWhatsApp', 'WhatsApp could not be opened, so the share sheet opened instead');

  static String get shareFailed => _t('shareFailed', 'Could not share the bill');

  // Backup and restore (A6)
  static String get settingsBackup => _t('settingsBackup', 'Backup');

  static String get backUpNow => _t('backUpNow', 'Back up now');

  static String get backUpNowHelp => _t(
    'backUpNowHelp',
    'Makes a copy of all your shop data and lets you send it to your own email or Google Drive. Do this often.',
  );

  static String get lastBackupLabel => _t('lastBackupLabel', 'Last backup');

  static String get neverBackedUp => _t('neverBackedUp', 'Never');

  static String get backupFailed => _t('backupFailed', 'Could not make the backup');

  static String get backupFileWarning =>
      _t('backupFileWarning', 'The backup file holds all your bills, customers and PINs. Send it only to yourself.');

  static String get restoreFromBackup => _t('restoreFromBackup', 'Restore from a backup');

  static String get restoreFromBackupHelp =>
      _t('restoreFromBackupHelp', 'Replace everything on this phone with a backup file.');

  static String get restoreTitle => _t('restoreTitle', 'Restore this backup?');

  static String get undoRestoreTitle => _t('undoRestoreTitle', 'Go back to the data from before the restore?');

  static String get backupContains => _t('backupContains', 'This backup contains:');

  static String get restoreReplacesWarning => _t(
    'restoreReplacesWarning',
    'Everything on this phone now (all bills, stock, customers and PINs) will be replaced. '
        'A copy of the current data is kept so you can undo this.',
  );

  static String get restoreFreshNote =>
      _t('restoreFreshNote', 'This phone has no shop data yet, so nothing will be lost.');

  static String get restoreOnePhone => _t(
    'restoreOnePhone',
    'Use only one phone for billing at a time. The same backup on two phones would give the same bill numbers.',
  );

  static String get restoreNow => _t('restoreNow', 'Restore');

  static String get undoRestore => _t('undoRestore', 'Go back');

  static String get restoring => _t('restoring', 'Restoring your data. Please wait...');

  static String get restoreDone => _t('restoreDone', 'Restored. Log in with the PIN you used before.');

  static String get restoreFailed => _t('restoreFailed', 'Could not restore the backup');

  static String get cannotUseBackup => _t('cannotUseBackup', 'This file cannot be used');

  static String get undoLastRestore => _t('undoLastRestore', 'Undo last restore');

  static String get undoLastRestoreHelp =>
      _t('undoLastRestoreHelp', 'Brings back the data that the last restore replaced.');

  static String get backupReminder => _t('backupReminder', 'Backup reminder');

  static String get backupReminderHelp => _t(
    'backupReminderHelp',
    'A notification and a note on the home screen when there has been no backup for 3 days.',
  );

  static String get restoreFromBackupFirstRun => _t('restoreFromBackupFirstRun', 'Restore from a backup instead');

  static String get backupReminderBanner => _t('backupReminderBanner', 'Back up your shop data');

  static String get backupReminderNever => _t('backupReminderNever', 'You have not made a backup yet.');

  static String backupReminderDays(int days) =>
      _mr ? SMr.backupReminderDays(days) : 'Your last backup was $days days ago.';

  static String get backupNowShort => _t('backupNowShort', 'Back up');

  static String get ok => _t('ok', 'OK');

  static String get sendTestReminder => _t('sendTestReminder', 'Send a test reminder now');

  // Check my data (A7)
  static String get dataCheckTitle => _t('dataCheckTitle', 'Check my data');

  static String get dataCheckNeverRun =>
      _t('dataCheckNeverRun', 'Never run. Checks that stock, balances and bill totals all agree.');

  static String get dataCheckPassed => _t('dataCheckPassed', 'All your numbers agree');

  static String get dataCheckPassedShort => _t('dataCheckPassedShort', 'All numbers agree');

  static String dataCheckProblems(int n) =>
      _mr ? SMr.dataCheckProblems(n) : 'Found $n problem${n == 1 ? '' : 's'} in your data';

  static String dataCheckScope(int checks, int records) =>
      _mr ? SMr.dataCheckScope(checks, records) : '$checks checks over $records records';

  static String dataCheckNotes(int n) =>
      _mr ? SMr.dataCheckNotes(n) : '$n note${n == 1 ? '' : 's'} to look at (not errors)';

  static String get dataCheckAdvice => _t(
    'dataCheckAdvice',
    'Tap a problem to open it. Do not change anything yet: tell your developer, so the cause can be found. '
        'Share the report to send it.',
  );

  static String get dataCheckNoteHelp => _t('dataCheckNoteHelp', 'Tap to see what does not add up.');

  static String get dataCheckFailed => _t('dataCheckFailed', 'Could not check the data');

  static String get problemsFound => _t('problemsFound', 'Problems');

  static String get notesFound => _t('notesFound', 'Notes');

  static String andMoreProblems(int n) => _mr ? SMr.andMoreProblems(n) : '...and $n more problems of the same kind';

  static String get shareReport => _t('shareReport', 'Share report');

  static String get runAgain => _t('runAgain', 'Check again');

  static String restoredWithProblems(int n) =>
      _mr
          ? SMr.restoredWithProblems(n)
          : 'The check found $n problem${n == 1 ? '' : 's'}. Open Settings, Check my data.';

  static String get backupProblemsTitle => _t('backupProblemsTitle', 'Your data has problems');

  static String backupProblemsBody(int n) =>
      _mr
          ? SMr.backupProblemsBody(n)
          : 'The data check found $n problem${n == 1 ? '' : 's'}. A backup still keeps everything, '
              'but it will contain the same problems. Back up anyway?';

  static String get backUpAnyway => _t('backUpAnyway', 'Back up anyway');

  // Speed tools, debug builds only (A7)
  static String get speedTools => _t('speedTools', 'Speed test tools (debug)');

  static String get speedTitle => _t('speedTitle', 'Speed test');

  static String get speedIntro => _t(
    'speedIntro',
    'Adds a big fake shop (about 400 items, 200 customers and 30 days of bills) on top of your data and times the '
        'screens on this phone. Make a backup first, and afterwards restore it to remove the fake data.',
  );

  static String get speedShopNow => _t('speedShopNow', 'In this phone now');

  static String get speedLoad => _t('speedLoad', 'Load big demo shop');

  static String get speedRun => _t('speedRun', 'Run speed check');

  static String get speedNeedBackup => _t(
    'speedNeedBackup',
    'Make a backup first (Settings, Backup, Back up now) and check it is in your email or Drive. '
        'Then come back within an hour.',
  );

  static String get speedLoadWarning => _t(
    'speedLoadWarning',
    'This adds hundreds of fake items, customers and bills to this phone. Your real data stays, but you must '
        'restore your backup afterwards to remove the fake data. Continue?',
  );

  static String get speedLoadConfirm => _t('speedLoadConfirm', 'Load demo shop');

  static String get speedLoaded => _t('speedLoaded', 'Demo shop loaded. Now run the speed check.');

  static String get speedRunning => _t('speedRunning', 'Timing the screens...');

  static String get speedFailed => _t('speedFailed', 'Did not finish');

  static String get speedResults => _t('speedResults', 'Results');

  static String get speedTarget => _t('speedTarget', 'Aim: under');

  static String get speedAfter => _t(
    'speedAfter',
    'When you are done: Settings, Restore from a backup, choose your backup, and the fake data is gone.',
  );

  // Returns and cancelled bills (A7)
  static String get returnItems => _t('returnItems', 'Return items');

  static String get returnTitle => _t('returnTitle', 'Return items');

  static String get returnAgainst => _t('returnAgainst', 'Against bill');

  static String get returnHow =>
      _t('returnHow', 'Enter how much of each item is coming back, then choose how to give the money back.');

  static String get returnSold => _t('returnSold', 'Sold');

  static String get returnAlready => _t('returnAlready', 'already returned');

  static String get returnQty => _t('returnQty', 'Back');

  static String get returnAll => _t('returnAll', 'All that is left');

  static String get returnLinesTotal => _t('returnLinesTotal', 'Items returned');

  static String get returnRefundTotal => _t('returnRefundTotal', 'Refund');

  static String get returnCompletes =>
      _t('returnCompletes', 'This returns everything on the bill, so the round-off is given back too.');

  static String get returnGiveBack => _t('returnGiveBack', 'Give the money back');

  static String get refundAllCash => _t('refundAllCash', 'All cash');

  static String get refundAllUpi => _t('refundAllUpi', 'All UPI');

  static String get refundAllAccount => _t('refundAllAccount', 'Off their account');

  static String get refundCash => _t('refundCash', 'Cash');

  static String get refundUpi => _t('refundUpi', 'UPI');

  static String get refundAccount => _t('refundAccount', 'Taken off what they owe');

  static String get refundAddsUp => _t('refundAddsUp', 'The refund adds up');

  static String refundRemaining(String left) => _mr ? SMr.refundRemaining(left) : 'Still to give back: $left';

  static String get returnReason => _t('returnReason', 'Reason (optional)');

  static String get returnConfirm => _t('returnConfirm', 'Return and give money back');

  static String returnApprovalWhat(String amount) => _mr ? SMr.returnApprovalWhat(amount) : 'a return of $amount';

  static String cancelApprovalWhat(String bill) => _mr ? SMr.cancelApprovalWhat(bill) : 'cancelling bill $bill';

  static String get cancelBill => _t('cancelBill', 'Cancel bill');

  static String get keepBill => _t('keepBill', 'Keep the bill');

  static String cancelBillWarning(String total) =>
      _mr
          ? SMr.cancelBillWarning(total)
          : 'This takes the whole bill back: the stock returns, and $total goes back to the customer the way they paid. The bill stays on record marked cancelled.';

  static String get billCancelledNote => _t('billCancelledNote', 'This bill was cancelled');

  static String get creditNotes => _t('creditNotes', 'Credit notes');

  static String get creditNoteTitle => _t('creditNoteTitle', 'Credit note');

  static String get cancelledBadge => _t('cancelledBadge', 'Cancelled');

  static String get returnedBadge => _t('returnedBadge', 'Returned');

  static String get ownerApprovalTitle => _t('ownerApprovalTitle', 'Owner approval needed');

  static String ownerApprovalBody(String what) =>
      _mr ? SMr.ownerApprovalBody(what) : 'The owner must approve $what. Owner, enter your PIN.';

  static String get ownerPinLabel => _t('ownerPinLabel', 'Owner PIN');

  // Day check (A7)
  static String get dayCheckTitle => _t('dayCheckTitle', 'Day check');

  static String get shareSummary => _t('shareSummary', 'Share summary');

  static String get dcSales => _t('dcSales', 'Sales');

  static String get dcCancelled => _t('dcCancelled', 'Cancelled bills');

  static String get dcSalesGross => _t('dcSalesGross', 'Sold on bills');

  static String get dcReturns => _t('dcReturns', 'Taken back (returns and cancels)');

  static String get dcNetSales => _t('dcNetSales', 'Net sales');

  static String get dcHowPaid => _t('dcHowPaid', 'How it was paid');

  static String get dcCollected => _t('dcCollected', 'Collected from customers');

  static String get dcCollectedTotal => _t('dcCollectedTotal', 'Paid against old dues');

  static String get dcPurchases => _t('dcPurchases', 'Purchases');

  static String get dcPurchasesEntered => _t('dcPurchasesEntered', 'Supplier bills entered');

  static String get dcPurchasesTotal => _t('dcPurchasesTotal', 'Purchases total');

  static String get dcPaidSuppliers => _t('dcPaidSuppliers', 'Paid to suppliers');

  static String get dcCashRefunds => _t('dcCashRefunds', 'Cash handed back to customers');

  static String get dcCompareHelp => _t(
    'dcCompareHelp',
    'Put these numbers beside your paper book. If one differs, find the bill or payment that explains it before you close the day.',
  );

  static String get dcCheckedAt => _t('dcCheckedAt', 'Looked at');

  static String get stockSpotCheck => _t('stockSpotCheck', 'Stock spot check');

  static String get spotIntro => _t(
    'spotIntro',
    'Choose a few items, count them on the shelf, and see if the app agrees. Nothing changes unless you tap Apply.',
  );

  static String get spotAddItem => _t('spotAddItem', 'Search an item to check');

  static String get spotAppSays => _t('spotAppSays', 'The app says');

  static String get spotCounted => _t('spotCounted', 'You counted');

  static String get spotMatches => _t('spotMatches', 'Matches');

  static String get spotDifference => _t('spotDifference', 'Difference');

  static String get spotAllMatch => _t('spotAllMatch', 'Everything you counted matches');

  static String spotDifferences(int n) =>
      _mr
          ? SMr.spotDifferences(n)
          : n == 1
          ? '1 item differs from the app'
          : '$n items differ from the app';

  static String get spotApply => _t('spotApply', 'Apply counts');

  static String get spotApplyHelp =>
      _t('spotApplyHelp', 'Apply sets the app\'s stock to what you counted and records it as a stock count.');

  static String spotApplyConfirm(int n) =>
      _mr ? SMr.spotApplyConfirm(n) : 'Set the stock of $n item${n == 1 ? '' : 's'} to what you counted?';

  static String get spotApplied => _t('spotApplied', 'Stock updated to your counts');

  // Home (design refresh)
  static String homeHello(String name) => _mr ? SMr.homeHello(name) : 'Hello, $name';

  static String get homeNewBillHint => _t('homeNewBillHint', 'Search, scan, pay, share');

  static String get homeGroupSell => _t('homeGroupSell', 'Sales');

  static String get homeGroupStock => _t('homeGroupStock', 'Stock and buying');

  static String get homeGroupPeople => _t('homeGroupPeople', 'People and money');

  static String get homeGroupShop => _t('homeGroupShop', 'Shop');

  static String get homeToday => _t('homeToday', 'Today');

  // A8 which phone is this
  static String devicePhone(String letter) => _mr ? SMr.devicePhone(letter) : 'Phone $letter';

  static String get deviceNewLabel => _t('deviceNewLabel', 'New phone');

  static String get deviceChoiceTitle => _t('deviceChoiceTitle', 'Which phone is this?');

  static String get deviceChoiceHelp => _t(
    'deviceChoiceHelp',
    "This shop's data has more than one phone in it, and this phone does not know which one it is. This usually happens after a backup is restored on a new phone.",
  );

  static String get deviceChoiceReplace => _t('deviceChoiceReplace', 'This phone replaces');

  static String get deviceChoiceNew => _t('deviceChoiceNew', 'This is a new phone');

  static String get deviceChoiceNewHelp => _t(
    'deviceChoiceNewHelp',
    'A new phone gets its own bill numbers, so bills never share a number with another phone.',
  );

  static String deviceReplaceTitle(String letter) => _mr ? SMr.deviceReplaceTitle(letter) : 'Replace phone $letter?';

  static String deviceReplaceWarn(String letter) =>
      _mr
          ? SMr.deviceReplaceWarn(letter)
          : 'Only do this if phone $letter is lost, broken or no longer used. If phone $letter is still billing, two phones would give out the same bill numbers.';

  static String get deviceReplaceYes => _t('deviceReplaceYes', 'Yes, replace it');

  // A8 Wi-Fi sync
  static String get phonesTitle => _t('phonesTitle', 'Phones and Wi-Fi sync');

  static String get phonesSettingHelp =>
      _t('phonesSettingHelp', 'Bill on two phones; they share data over the shop Wi-Fi');

  static String get phonesThisPhone => _t('phonesThisPhone', 'This phone');

  static String get phonesNoneYet =>
      _t('phonesNoneYet', 'Only this phone so far. Add a second phone to bill on two phones at once.');

  static String get phonesAdd => _t('phonesAdd', 'Add a phone');

  static String get phonesSyncNow => _t('phonesSyncNow', 'Sync now');

  static String get phonesRemove => _t('phonesRemove', 'Remove this phone from the shop');

  static String phonesRemoveConfirm(String name) =>
      _mr
          ? SMr.phonesRemoveConfirm(name)
          : 'Remove $name? Its bills stay in the shop, but it will no longer sync. To use it again, add it again from this screen.';

  static String get phonesRemoved => _t('phonesRemoved', 'Phone removed');

  static String get phonesRename => _t('phonesRename', 'Rename');

  static String get phonesRenameTitle => _t('phonesRenameTitle', 'Name for this phone');

  static String get phonesClashes => _t('phonesClashes', 'Changes made on both phones at once');

  static String phonesClashesHelp(int n) =>
      _mr
          ? SMr.phonesClashesHelp(n)
          : '$n time${n == 1 ? '' : 's'} in the last 7 days the same thing was changed on both phones before they synced. The later change was kept; both are in the activity log.';

  static String phonesClockWarn(int minutes) =>
      _mr
          ? SMr.phonesClockWarn(minutes)
          : "The two phones' clocks differ by about $minutes minutes. Set both to automatic date and time, or the newer change may not win.";

  static String phonesLastSync(String when) => _mr ? SMr.phonesLastSync(when) : 'Last synced $when';

  static String get phonesNeverSynced => _t('phonesNeverSynced', 'Not synced yet');

  static String get syncOff => _t('syncOff', 'One phone');

  static String get syncSearching => _t('syncSearching', 'Looking for the other phone');

  static String get syncSearchingHelp => _t(
    'syncSearchingHelp',
    'Both phones need the app open and the same shop Wi-Fi. Bills are saved here and go across later.',
  );

  static String get syncSynced => _t('syncSynced', 'Synced');

  static String get syncProblem => _t('syncProblem', 'Sync problem');

  static String get addPhoneTitle => _t('addPhoneTitle', 'Add a phone');

  static String get addPhoneSteps => _t(
    'addPhoneSteps',
    '1. Install the app on the new phone and connect it to the shop Wi-Fi.\n'
        '2. Open the app on the new phone and tap "Join a shop".\n'
        '3. Scan this code with the new phone.',
  );

  static String get addPhoneExpires => _t(
    'addPhoneExpires',
    'This code works once, for 10 minutes. Keep this screen open until the new phone says it has joined.',
  );

  static String addPhoneJoined(String name) => _mr ? SMr.addPhoneJoined(name) : '$name joined the shop';

  static String get addPhoneNoWifi =>
      _t('addPhoneNoWifi', 'This phone is not on a Wi-Fi network. Connect it to the shop Wi-Fi and try again.');

  static String get joinShop => _t('joinShop', 'Join a shop');

  static String get joinShopFirstRun => _t('joinShopFirstRun', 'Join a shop (second phone)');

  static String get joinTitle => _t('joinTitle', 'Join a shop');

  static String get joinHelp => _t(
    'joinHelp',
    "On the owner's phone open Settings, Phones and Wi-Fi sync, Add a phone. Then scan the code it shows. This phone gets a copy of all the shop's data and its own bill numbers.",
  );

  static String get joinName => _t('joinName', 'Name for this phone');

  static String get joinNameDefault => _t('joinNameDefault', 'Counter phone');

  static String get joinScan => _t('joinScan', "Scan the owner's code");

  static String get joinNotShopCode => _t(
    'joinNotShopCode',
    "That is not a shop pairing code. Scan the code on the owner's phone (Settings, Phones and Wi-Fi sync, Add a phone).",
  );

  static String get joining => _t('joining', "Copying the shop's data from the owner's phone...");

  static String get joinDone => _t('joinDone', 'This phone has joined the shop. Log in with your PIN.');

  static String get joinReplaceWarn => _t(
    'joinReplaceWarn',
    "Anything already saved on this phone will be replaced by the shop's data (a safety copy is kept).",
  );

  // A8 cancel purchase, supplier bill entered twice
  static String get purchaseCancel => _t('purchaseCancel', 'Cancel this purchase');

  static String get purchaseCancelHelp => _t(
    'purchaseCancelHelp',
    'Use this when the purchase was entered by mistake, for example the same supplier bill entered on both phones. The stock comes back out and the supplier is no longer owed this amount.',
  );

  static String purchaseCancelConfirm(String no, String total) =>
      _mr
          ? SMr.purchaseCancelConfirm(no, total)
          : 'Cancel purchase $no ($total)? Its stock comes back out and the supplier’s account is reduced by $total. This cannot be undone.';

  static String get purchaseCancelReason => _t('purchaseCancelReason', 'Reason (optional)');

  static String get purchaseCancelled => _t('purchaseCancelled', 'Purchase cancelled');

  static String purchaseCancelWhat(String no) => _mr ? SMr.purchaseCancelWhat(no) : 'cancel supplier bill $no';

  static String get purchaseTwiceBadge => _t('purchaseTwiceBadge', 'Entered twice');

  static String purchaseTwiceNote(int n) =>
      _mr
          ? SMr.purchaseTwiceNote(n)
          : n == 1
          ? 'A supplier bill was entered twice'
          : '$n supplier bills were entered twice';

  static String get purchaseTwiceHelp =>
      _t('purchaseTwiceHelp', 'Usually once on each phone. Open it and cancel the extra copy.');

  // Settings (compact menu)
  static String get settingsBackupTitle => _t('settingsBackupTitle', 'Backup and restore');

  static String get settingsData => _t('settingsData', 'Data');

  static String get settingsBillingRules => _t('settingsBillingRules', 'Billing rules');

  static String get settingsShopDetailsSub => _t('settingsShopDetailsSub', 'Name, GSTIN, address, bill terms');

  static String get settingsStaffSub => _t('settingsStaffSub', 'Counter staff and PINs');

  static String get settingsPhonesOne => _t('settingsPhonesOne', 'One phone');

  static String settingsPhonesMany(int n) => _mr ? SMr.settingsPhonesMany(n) : '$n phones';

  static String get settingsAuditSub => _t('settingsAuditSub', 'Who changed what, and when');

  static String get settingsAlertsTitle => _t('settingsAlertsTitle', 'Daily summary');

  static String get settingsOff => _t('settingsOff', 'Off');

  static String get settingsNeverBackedUp => _t('settingsNeverBackedUp', 'Never backed up');

  static String get backupGroupBackUp => _t('backupGroupBackUp', 'Back up');

  static String get backupGroupRestore => _t('backupGroupRestore', 'Restore');

  static String get backupGroupReminder => _t('backupGroupReminder', 'Reminder');

  static String get settingsPhonesRow => _t('settingsPhonesRow', 'Phones and sync');

  // A10 languages
  static String get settingsLanguageGroup => _t('settingsLanguageGroup', 'Language');
  // Written in both languages so it can always be found.
  static String get settingsAppLanguage => _t('settingsAppLanguage', 'भाषा / Language (this phone)');
  static String get settingsBillLanguage => _t('settingsBillLanguage', 'Bill language (PDF and WhatsApp)');
  static String get settingsBillLanguageHelp =>
      _t('settingsBillLanguageHelp', 'For the whole shop. Customers and your accountant receive bills in this language.');
  static String get languageMarathi => 'मराठी';
  static String get languageEnglish => 'English';

  // A10: text that used to be typed in screens
  static String get auditPriceChange => _t('auditPriceChange', 'Price changed');
  static String get auditPriceOverride => _t('auditPriceOverride', 'Price overridden');
  static String get auditDiscount => _t('auditDiscount', 'Discount given');
  static String get auditStockAdjust => _t('auditStockAdjust', 'Stock adjusted');
  static String get auditStockCount => _t('auditStockCount', 'Stock counted');
  static String get auditEdit => _t('auditEdit', 'Edited');
  static String get auditDelete => _t('auditDelete', 'Deleted');
  static String get auditPinSet => _t('auditPinSet', 'PIN set');
  static String get auditPinChanged => _t('auditPinChanged', 'PIN changed');
  static String get auditPinReset => _t('auditPinReset', 'Owner PIN reset');
  static String get auditUserCreated => _t('auditUserCreated', 'Staff added');
  static String get auditUserDeactivated => _t('auditUserDeactivated', 'Staff removed');
  static String get auditShopUpdated => _t('auditShopUpdated', 'Shop details changed');
  static String get auditUpiChanged => _t('auditUpiChanged', 'UPI ID changed');
  static String get auditBackupMade => _t('auditBackupMade', 'Backup made');
  static String get auditBackupRestored => _t('auditBackupRestored', 'Backup restored');
  static String get auditBackupProblems => _t('auditBackupProblems', 'Backup made (check found problems)');
  static String get auditSalesReturn => _t('auditSalesReturn', 'Items returned');
  static String get auditBillCancelled => _t('auditBillCancelled', 'Bill cancelled');
  static String get auditPurchaseCancelled => _t('auditPurchaseCancelled', 'Purchase cancelled');
  static String get auditSyncConflict => _t('auditSyncConflict', 'Changed on both phones');
  static String get auditPhoneRemoved => _t('auditPhoneRemoved', 'Phone removed');
  static String get auditUnknownUser => _t('auditUnknownUser', 'unknown');
  static String get noUsers => _t('noUsers', 'No users');
  static String get home => _t('home', 'Home');
  static String get gstInclShort => _t('gstInclShort', '(GST incl.)');
  static String get discountTooBig => _t('discountTooBig', 'Discount is more than the line amount');
  static String get billIsEmpty => _t('billIsEmpty', 'The bill is empty');
  static String get payment => _t('payment', 'Payment');
  static String get modeUpi => _t('modeUpi', 'UPI');
  static String get modeCard => _t('modeCard', 'Card');
  static String get modeBank => _t('modeBank', 'Bank');
  static String get periodToday => _t('periodToday', 'Today');
  static String get periodWeek => _t('periodWeek', 'Last 7 days');
  static String get periodMonth => _t('periodMonth', 'This month');
  static String get reportDailySalesSub => _t('reportDailySalesSub', 'Bills, payments and cash for a day');
  static String get reportDayCheckSub => _t('reportDayCheckSub', 'Compare with your paper book');
  static String get reportItemProfitSub => _t('reportItemProfitSub', 'What each item earned');
  static String get reportStockValueSub => _t('reportStockValueSub', 'Stock on hand at cost price');
  static String get importItemsSub => _t('importItemsSub', 'Names, GST, prices, cost, minimum and opening stock');
  static String get importPartiesSub => _t('importPartiesSub', 'Names, phone, GSTIN, credit limit and opening balance');
  static String get templateSaved => _t('templateSaved', 'Template saved');
  static String get importCheckFirst => _t('importCheckFirst', 'Check before importing');
  static String get importFixThese => _t('importFixThese', 'Fix these in your file and choose it again:');
  static String get retailRequired => _t('retailRequired', 'Retail price is required');
  static String get hide => _t('hide', 'Hide');
  static String get optionalSuffix => _t('optionalSuffix', ' (optional)');
  static String get itemHasHistory => _t('itemHasHistory', 'This item already has stock or bills.');
  static String get itemNameRequired => _t('itemNameRequired', 'Item name is required');
  static String get gstChoices => _t('gstChoices', 'GST must be one of 0, 0.25, 3, 5, 12, 18 or 28');
  static String get retailMoreThanZero => _t('retailMoreThanZero', 'Retail price must be more than 0');
  static String get pricesMoreThanZero => _t('pricesMoreThanZero', 'Prices must be more than 0 (leave blank for none)');
  static String get rollMoreThanZero => _t('rollMoreThanZero', 'Roll length must be more than 0');
  static String get boxTwoOrMore => _t('boxTwoOrMore', 'Box size must be 2 or more pieces');
  static String get stockNotNegative => _t('stockNotNegative', 'Stock quantities cannot be negative');
  static String get ledgerBill => _t('ledgerBill', 'Bill');
  static String get ledgerPayment => _t('ledgerPayment', 'Payment received');
  static String get ledgerReturn => _t('ledgerReturn', 'Return');
  static String get ledgerOpening => _t('ledgerOpening', 'Opening balance');
  static String get ledgerAdjustment => _t('ledgerAdjustment', 'Adjustment');
  static String get ledgerPurchase => _t('ledgerPurchase', 'Purchase');
  static String get ledgerSupplierPayment => _t('ledgerSupplierPayment', 'Payment made');
  static String get enterAmountShort => _t('enterAmountShort', 'Enter the amount');
  static String get gstinFormat => _t('gstinFormat', 'GSTIN should be 15 characters, like 27AAAAA0000A1Z5');
  static String get stateCodeFormat => _t('stateCodeFormat', 'State code should be 2 digits, like 27');
  static String get tierRetail => _t('tierRetail', 'Retail');
  static String get tierContractor => _t('tierContractor', 'Contractor');
  static String get tierDealer => _t('tierDealer', 'Dealer');
  static String get enterSupplierBillNo => _t('enterSupplierBillNo', 'Enter the supplier bill number');
  static String get addNewSupplier => _t('addNewSupplier', 'Add new supplier');
  static String get autoLockAlways => _t('autoLockAlways', 'Always');
  static String get enterQtyMoreThanZero => _t('enterQtyMoreThanZero', 'Enter a quantity more than 0');
  static String get enterCountedQty => _t('enterCountedQty', 'Enter the counted quantity');
  static String get moveSale => _t('moveSale', 'Sale');
  static String get moveSaleReturn => _t('moveSaleReturn', 'Sale return');
  static String get movePurchase => _t('movePurchase', 'Purchase');
  static String get movePurchaseReturn => _t('movePurchaseReturn', 'Purchase return');
  static String get moveTransferIn => _t('moveTransferIn', 'Transfer in');
  static String get moveTransferOut => _t('moveTransferOut', 'Transfer out');
  static String get moveAdjustment => _t('moveAdjustment', 'Adjustment');
  static String get moveCount => _t('moveCount', 'Stock count');
  static String get phonesSection => _t('phonesSection', 'Phones');
  static String get theNewPhone => _t('theNewPhone', 'The new phone');
  static String get backupReminderOpenHint => _t('backupReminderOpenHint', 'Open the app, Settings, Backup and restore.');
  static String andMore(int n) => _mr ? SMr.andMore(n) : '...and $n more';
  static String cannotOpenDb(Object e) => _mr ? SMr.cannotOpenDb(e) : 'Could not open the database: $e';
  static String couldNotSaveBill(String why) => _mr ? SMr.couldNotSaveBill(why) : 'Could not save the bill: $why';
  static String lineQtyAt(String qty, String rate) => _mr ? SMr.lineQtyAt(qty, rate) : '$qty at ₹$rate';
  static String lessAmount(String amount) => _mr ? SMr.lessAmount(amount) : 'less $amount';
  static String overdueOver30(String amount) => _mr ? SMr.overdueOver30(amount) : '$amount overdue (over 30 days)';
  static String todayDate(String date) => _mr ? SMr.todayDate(date) : 'Today, $date';
  static String dateRange(String from, String to) => _mr ? SMr.dateRange(from, to) : '$from to $to';
  static String soldQtySales(String qty, String sales) => _mr ? SMr.soldQtySales(qty, sales) : 'Sold $qty  •  sales $sales';
  static String qtyAtRate(String qty, String rate) => _mr ? SMr.qtyAtRate(qty, rate) : '$qty at $rate';
  static String importResult(int created, int skipped, int errors) => _mr ? SMr.importResult(created, skipped, errors) : 'Imported $created. Skipped $skipped that already exist. '
      '$errors row${errors == 1 ? '' : 's'} had problems and ${errors == 1 ? 'was' : 'were'} not imported.';
  static String importSummary(int total, int create, int skipped, int errors) => _mr ? SMr.importSummary(total, create, skipped, errors) : '$total rows in the file: $create will be imported, $skipped skipped, $errors need fixing.';
  static String skippedCount(int n) => _mr ? SMr.skippedCount(n) : '$n skipped';
  static String rowName(int row, String name) => _mr ? SMr.rowName(row, name) : 'Row $row: $name';
  static String priceFieldLabel(String price, String unit) => _mr ? SMr.priceFieldLabel(price, unit) : '$price per $unit';
  static String priceFieldLabelOptional(String price, String unit) => _mr ? SMr.priceFieldLabelOptional(price, unit) : '$price per $unit (optional)';
  static String costToday(String cost) => _mr ? SMr.costToday(cost) : 'Cost today: $cost';
  static String openingBalanceLabel(String side) => _mr ? SMr.openingBalanceLabel(side) : '${S.openingBalance}: $side (Rs)';
  static String enterRateFor(String item) => _mr ? SMr.enterRateFor(item) : 'Enter the rate for $item';
  static String withGst(String amount) => _mr ? SMr.withGst(amount) : '$amount (with GST)';
  static String autoLockMinutesValue(int n) => _mr ? SMr.autoLockMinutesValue(n) : '$n min';
  static String minimumStock(String qty) => _mr ? SMr.minimumStock(qty) : 'Minimum: $qty';
  static String backupShareSubject(String shop) => _mr ? SMr.backupShareSubject(shop) : '$shop backup';
  static String backupShareBody(String shop, int bills, int customers, int items) => _mr ? SMr.backupShareBody(shop, bills, customers, items) : 'Backup of $shop: $bills bills, $customers customers, $items items. '
      'Keep this file safe: it contains all shop data.';
  static String backupCounts(int bills, int customers, int items) => _mr ? SMr.backupCounts(bills, customers, items) : '$bills bills, $customers customers, $items items';
  static String lastBillAt(String when) => _mr ? SMr.lastBillAt(when) : 'Last bill: $when';
  static String dataCheckShareSubject(String shop) => _mr ? SMr.dataCheckShareSubject(shop) : '$shop data check';
  static String dayCheckShareSubject(String shop, String date) => _mr ? SMr.dayCheckShareSubject(shop, date) : '$shop day check $date';
  static String changedFromTo(String label, String from, String to) =>
      _mr ? SMr.changedFromTo(label, from, to) : '$label: $from to $to';
  static String get diskFull =>
      _t('diskFull', 'The phone is out of storage space. Free some space and try again. Nothing was saved.');
  static String get diskIoError => _t('diskIoError',
      'The phone could not write to its storage. Nothing was saved. Try again, and restart the phone if it keeps happening.');
  static String get dataBusy => _t('dataBusy', 'The shop data is busy. Wait a moment and try again.');
  static String somethingWentWrong(String e) => _mr ? SMr.somethingWentWrong(e) : 'Something went wrong: $e';

  // A11 payment reminders
  static String get remindersTitle => _t('remindersTitle', 'Payment reminders');
  static String get remindersSettingsTitle => _t('remindersSettingsTitle', 'Reminder settings');
  static String get remindersOffInfo => _t('remindersOffInfo', 'Payment reminders are off. Switch them on in Reminder settings.');
  static String get remindersTurnOn => _t('remindersTurnOn', 'Send payment reminders');
  static String get remindersHelp => _t('remindersHelp', 'Customers who owe money get a polite message: the first after the days below, then again until they pay. Switch it off for one customer on their page.');
  static String get reminderFirstAfter => _t('reminderFirstAfter', 'First reminder after');
  static String get reminderRepeatEvery => _t('reminderRepeatEvery', 'Then again every');
  static String get reminderMinimum => _t('reminderMinimum', 'Only if they owe at least');
  static String get reminderPreview => _t('reminderPreview', 'Message preview');
  static String get remindersNoneDue => _t('remindersNoneDue', 'Nobody is due for a reminder today.');
  static String get reminderSkipToday => _t('reminderSkipToday', 'Skip today');
  static String get reminderSent => _t('reminderSent', 'Reminder recorded');
  static String get whatsAppMissing => _t('whatsAppMissing', 'WhatsApp is not installed on this phone');
  static String get remindersOffForCustomer => _t('remindersOffForCustomer', 'No payment reminders');
  static String get remindersOffForCustomerHelp => _t('remindersOffForCustomerHelp', 'This customer never gets payment reminders.');
  static String get reminderDaysHelp => _t('reminderDaysHelp', 'Days counted from their oldest unpaid bill.');
  static String get reminderDaysField => _t('reminderDaysField', 'Days');
  static String get reminderSampleName => _t('reminderSampleName', 'Ramesh');
  static String reminderDaysValue(int n) => _mr ? SMr.reminderDaysValue(n) : '$n days';
  static String reminderOwesSince(String date, int days) => _mr ? SMr.reminderOwesSince(date, days) : 'Owes since $date ($days days)';
  static String reminderLast(String when) => _mr ? SMr.reminderLast(when) : 'Last reminded $when';
  static String remindersDueNote(int n) => _mr ? SMr.remindersDueNote(n) : n == 1 ? '1 customer is due for a payment reminder' : '$n customers are due for a payment reminder';
  static String remindersRowValue(int n) => _mr ? SMr.remindersRowValue(n) : 'After $n days';
  static String get reminderSmsSection => _t('reminderSmsSection', "Automatic SMS");
  static String get reminderSmsHere => _t('reminderSmsHere', "Send SMS automatically from this phone");
  static String get reminderSmsHelp => _t('reminderSmsHelp', "Once a day after the time below, this phone texts everyone due, from its own SIM. Switch this on for one phone only.");
  static String get reminderSmsTime => _t('reminderSmsTime', "SMS after");
  static String get reminderSmsTest => _t('reminderSmsTest', "Send a test SMS");
  static String get reminderSmsTestNumber => _t('reminderSmsTestNumber', "Mobile number for the test");
  static String get reminderSmsTestSent => _t('reminderSmsTestSent', "Test SMS sent");
  static String get reminderSmsNoPermission => _t('reminderSmsNoPermission', "SMS permission was not given");
  static String get reminderSmsNotSent => _t('reminderSmsNotSent', "The SMS could not be sent");
  static String get reminderSmsNoteTitle => _t('reminderSmsNoteTitle', "Payment reminders sent");
  static String get reminderSmsSendNow => _t('reminderSmsSendNow', "Send today's SMS now");
  static String reminderSmsNoteBody(int sent, int failed) => _mr ? SMr.reminderSmsNoteBody(sent, failed) : '$sent customers got a reminder by SMS${failed > 0 ? '; $failed could not be sent' : ''}.';
  static String reminderSmsNowResult(int sent) => _mr ? SMr.reminderSmsNowResult(sent) : 'Sent $sent SMS';
}
