/// All user-facing text lives here so Marathi/Hindi can be added later
/// (plan section 13).
abstract final class S {
  static const appTitle = 'Pravin Electricals';

  // Home
  static const newBill = 'New bill';
  static const loadSampleData = 'Load sample data (debug)';
  static const sampleDataLoaded = 'Sample data loaded';

  // Bill screen
  static const billTitle = 'New bill';
  static const searchHint = 'Search item, brand, SKU or barcode';
  static const scanBarcode = 'Scan barcode';
  static const noResults = 'No items found';
  static const cartEmpty = 'Search or scan an item to start the bill';
  static const noPrice = 'No price set for this item. Add a price first.';
  static const qty = 'Qty';
  static const unit = 'Unit';
  static const discount = 'Discount (Rs)';
  static const remove = 'Remove';
  static const walkIn = 'Walk-in customer';
  static const chooseCustomer = 'Choose customer';
  static const subtotal = 'Subtotal';
  static const discountLabel = 'Discount';
  static const roundOff = 'Round off';
  static const total = 'Total';
  static const gstIncluded = 'GST included';
  static const pay = 'Pay';
  static const invalidQty = 'Enter a valid quantity';

  // Customer sheet
  static const searchCustomer = 'Search name or phone';
  static const addCustomer = 'Add new customer';
  static const customerName = 'Customer name';
  static const customerPhone = 'Phone (optional)';
  static const save = 'Save';
  static const cancel = 'Cancel';

  // Payment sheet
  static const paymentTitle = 'Payment';
  static const cash = 'Cash';
  static const upi = 'UPI';
  static const credit = 'Credit (udhaar)';
  static const remaining = 'Remaining';
  static const fullCash = 'All cash';
  static const fullUpi = 'All UPI';
  static const fullCredit = 'All credit';
  static const saveBill = 'Save bill';
  static const creditNeedsCustomer = 'Choose a customer to sell on credit';
  static const overCreditLimit = 'This is over the customer\'s credit limit.';
  static const continueAnyway = 'Continue anyway';

  // Done
  static const billSaved = 'Bill saved';
  static const sharePdf = 'Share PDF';
  static const newBillAgain = 'New bill';

  // Home tiles
  static const items = 'Items';
  static const stock = 'Stock';
  static const purchases = 'Purchases';
  static const customers = 'Customers';
  static const suppliers = 'Suppliers';
  static const dues = 'Dues';
  static const importData = 'Import';

  // Items
  static const itemsTitle = 'Items';
  static const addItem = 'Add item';
  static const editItem = 'Edit item';
  static const searchItems = 'Search items';
  static const showInactive = 'Show inactive';
  static const noItems = 'No items yet. Tap Add item, or use Import to load a file.';
  static const inactive = 'Inactive';
  static const lowStock = 'Low stock';
  static const outOfStock = 'Out of stock';
  static const negativeStock = 'Negative stock';
  static const noPriceChip = 'No price';
  static const itemName = 'Item name';
  static const brand = 'Brand';
  static const category = 'Category';
  static const hsn = 'HSN code';
  static const gstRate = 'GST rate';
  static const itemType = 'How is it sold?';
  static const typeLength = 'By the metre (cable, wire)';
  static const typePiece = 'By the piece';
  static const typeFixed = 'The type cannot be changed after creation.';
  static const rollLength = 'Roll length (metres)';
  static const boxSize = 'Pieces in a box';
  static const prices = 'Prices (GST included)';
  static const retailPrice = 'Retail price';
  static const contractorPrice = 'Contractor price (optional)';
  static const dealerPrice = 'Dealer price (optional)';
  static const costPrice = 'Cost price, without GST';
  static const minStock = 'Minimum stock (low stock alert)';
  static const openingStock = 'Stock on hand now (optional)';
  static const barcode = 'Barcode (optional)';
  static const variants = 'Variants and barcodes';
  static const addVariant = 'Add variant or barcode';
  static const variantName = 'Variant name (for example Red)';
  static const itemSaved = 'Item saved';
  static const activeSwitch = 'Active (shown in billing)';
  static const deactivateConfirm = 'Hide this item from billing? Its history is kept.';
  static const perMetre = 'per metre';
  static const perPiece = 'per piece';

  // Stock
  static const stockTitle = 'Stock';
  static const searchStock = 'Search stock';
  static const filterAll = 'All';
  static const filterLow = 'Low';
  static const filterNegative = 'Negative';
  static const noStockItems = 'No items to show.';
  static const adjustStock = 'Adjust';
  static const countStock = 'Count';
  static const history = 'History';
  static const noHistory = 'No stock movements yet.';
  static const addStock = 'Add stock';
  static const removeStock = 'Remove stock';
  static const quantity = 'Quantity';
  static const reason = 'Reason';
  static const reasonDamaged = 'Damaged or lost';
  static const reasonFound = 'Found extra';
  static const reasonCorrection = 'Correction';
  static const reasonOther = 'Other';
  static const countedQty = 'Counted quantity';
  static const systemQty = 'In the app';
  static const difference = 'Difference';
  static const confirmCount = 'Save count';
  static const stockSaved = 'Stock updated';
  static const onlyInStock = 'Only';
  static const inStockSuffix = 'in stock';

  // Parties
  static const customersTitle = 'Customers';
  static const suppliersTitle = 'Suppliers';
  static const addParty = 'Add';
  static const editParty = 'Edit';
  static const noParties = 'Nobody here yet.';
  static const partyName = 'Name';
  static const phone = 'Phone';
  static const gstin = 'GSTIN (optional)';
  static const stateCode = 'State code (for example 27)';
  static const address = 'Address (optional)';
  static const tier = 'Price level';
  static const creditLimit = 'Credit limit (Rs, 0 for none)';
  static const kind = 'Type';
  static const kindCustomer = 'Customer';
  static const kindSupplier = 'Supplier';
  static const kindBoth = 'Customer and supplier';
  static const owes = 'Owes you';
  static const youOwe = 'You owe';
  static const settled = 'Settled';
  static const advancePaid = 'Advance';
  static const statement = 'Statement';
  static const recordPayment = 'Record payment';
  static const recordSupplierPayment = 'Pay supplier';
  static const amount = 'Amount (Rs)';
  static const paymentMode = 'Paid by';
  static const note = 'Note (optional)';
  static const openingBalance = 'Opening balance';
  static const paymentSaved = 'Payment saved';
  static const balance = 'Balance';

  // Dues
  static const duesTitle = 'Dues';
  static const receivables = 'Customers owe';
  static const payables = 'You owe suppliers';
  static const noDues = 'Nothing outstanding.';
  static const bucket0 = '0-30 days';
  static const bucket31 = '31-60 days';
  static const bucket61 = '61-90 days';
  static const bucket90 = 'Over 90 days';
  static const totalDue = 'Total due';

  // Purchases
  static const purchasesTitle = 'Purchases';
  static const newPurchase = 'New purchase';
  static const noPurchases = 'No purchases yet.';
  static const supplier = 'Supplier';
  static const chooseSupplier = 'Choose supplier';
  static const supplierInvoiceNo = 'Supplier bill number';
  static const supplierInvoiceDate = 'Bill date';
  static const rateExGst = 'Rate (without GST)';
  static const gstPercent = 'GST %';
  static const addLine = 'Add item';
  static const savePurchase = 'Save purchase';
  static const purchaseSaved = 'Purchase saved';
  static const taxableTotal = 'Total before GST';
  static const gstAmount = 'GST';
  static const grandTotal = 'Total';
  static const purchaseHint = 'Search an item to add it to this purchase';

  // Import
  static const importTitle = 'Import from file';
  static const importItems = 'Import items';
  static const importParties = 'Import customers and suppliers';
  static const chooseFile = 'Choose CSV file';
  static const downloadTemplate = 'Download template';
  static const importNow = 'Import now';
  static const importDone = 'Import finished';
  static const importHelp =
      'Save your Excel sheet as CSV first (File > Save As > CSV). '
      'Download the template to see the columns.';

  // Login and roles (A4)
  static const lockTitle = 'Who is using the app?';
  static const enterPin = 'Enter PIN';
  static const wrongPin = 'Wrong PIN, try again';
  static const forgotPin = 'Forgot PIN?';
  static const forgotPinReason = 'Confirm it is you to set a new owner PIN';
  static const forgotPinFailed = 'Could not confirm with the phone lock';
  static const setupPinTitle = 'Set the owner PIN';
  static const setupPinHelp =
      'Choose a 4 to 6 digit PIN. You will use it to open the app. Staff get their own PIN.';
  static const newPin = 'New PIN';
  static const confirmPin = 'Enter the PIN again to confirm';
  static const pinMismatch = 'The two PINs did not match. Start again.';
  static const pinRules = 'PIN must be 4 to 6 digits';
  static const lockNow = 'Lock';
  static const unlock = 'Unlock';
  static const askOwner = 'Ask the owner';
  static String discountTooHigh(int pct) =>
      'Staff can give up to $pct% discount. Ask the owner.';
  static String lockedWait(int seconds) =>
      'Too many wrong tries. Try again in $seconds seconds.';

  // Dashboard and reports (A4)
  static const reports = 'Reports';
  static const reportsTitle = 'Reports';
  static const dailySales = 'Daily sales';
  static const itemProfit = 'Item profit';
  static const stockValue = 'Stock value';
  static const billsCount = 'Bills';
  static const salesTotal = 'Sales';
  static const paidBy = 'Paid by';
  static const cashInHand = 'Cash in hand';
  static const cashOpening = 'Cash at start of day';
  static const cashSales = 'Cash sales';
  static const cashReceived = 'Cash received from customers';
  static const cashPaidOut = 'Cash paid to suppliers';
  static const cashClosing = 'Cash in hand now';
  static const cashNote =
      'Counts cash only. Expenses are not recorded yet. Set the opening cash in Settings.';
  static const noSalesInPeriod = 'No sales in this period';
  static const salesExGst = 'Sales (without GST)';
  static const costOfGoods = 'Cost of goods sold';
  static const profit = 'Profit';
  static const margin = 'Margin';
  static const byItem = 'By item';
  static const costUnknown = 'Cost price not known';
  static const costUnknownHelp =
      'These sales are not counted in profit because the item had no cost price '
      'on the day of the bill. Enter a purchase or set a cost price to include future sales.';
  static const costUnknownStockHelp =
      'Not counted in the total: no cost price has been entered for these items.';
  static const returnsNote = 'Sales returns are not included yet.';
  static const noStockOnHand = 'No stock on hand';
  static const stockValueTotal = 'Stock value';
  static const stockValueNote = 'Quantity on hand x latest cost price, without GST.';
  static const todaySales = "Today's sales";
  static const dashboardCash = 'Cash in hand';
  static const lowStockItems = 'Low stock';
  static const totalDues = 'Customers owe';
  static const biggestDues = 'Biggest dues';
  static const noDuesYet = 'No customer dues';

  // Settings, staff and audit (A4)
  static const settings = 'Settings';
  static const settingsTitle = 'Settings';
  static const settingsShop = 'Shop';
  static const settingsRules = 'Rules';
  static const settingsRecords = 'Records';
  static const settingSaved = 'Saved';
  static const shopDetails = 'Shop details';
  static const shopName = 'Shop name';
  static const shopAddress = 'Address';
  static const shopTerms = 'Terms printed on the bill';
  static const shopSaved = 'Shop details saved';
  static const staffAndPins = 'Staff and PINs';
  static const addStaff = 'Add counter staff';
  static const staffName = 'Name';
  static const staffPin = 'PIN (4 to 6 digits)';
  static const resetPin = 'Set new PIN';
  static const changeMyPin = 'Change my PIN';
  static const removeStaff = 'Remove';
  static const removeStaffConfirm = 'Remove this person? Their old bills stay.';
  static const staffAdded = 'Staff added';
  static const pinChanged = 'PIN changed';
  static const ownerRole = 'Owner';
  static const counterRole = 'Counter';
  static const removedLabel = 'Removed';
  static const counterDiscountLimit = 'Counter discount limit';
  static const counterDiscountHelp = 'Most discount staff can give on one bill line, as a percent.';
  static const enterWholeNumber0to100 = 'Enter a whole number from 0 to 100';
  static const enterWholeNumber0to120 = 'Enter a whole number from 0 to 120';
  static const enterAmount = 'Enter an amount like 5000 or 5000.50';
  static const openingCash = 'Opening cash';
  static const openingCashHelp = 'Cash in the drawer when you started using the app.';
  static const autoLock = 'Auto-lock after';
  static const autoLockHelp = 'Minutes the app can be in the background before it asks for the PIN. 0 means always.';
  static const auditLog = 'Audit log';
  static const auditHelp = 'Who changed prices, gave discounts, adjusted stock or edited records';
  static const auditEmpty = 'Nothing recorded yet';
  static const auditPrices = 'Prices';
  static const auditDiscounts = 'Discounts';
  static const auditStock = 'Stock';
  static const auditEdits = 'Edits';
  static const auditUsers = 'Users and shop';
  static const pickDates = 'Pick dates';
  static const settingsAlerts = 'Alerts';
  static const dailySummary = 'Daily summary';
  static const dailySummaryHelp = "A phone notification each evening with today's sales, cash and dues.";
  static const summaryTime = 'Summary time';
  static const summaryTimeHelp = 'Hour of the day, 0 to 23 (21 means 9 PM). Android may send it a few minutes late.';
  static const summaryTestNow = 'Send a test summary now';
  static const notificationsBlocked = 'Allow notifications for this app in the phone settings first';
  static const enterWholeNumber0to23 = 'Enter a whole number from 0 to 23';

  // UPI, bills history and sharing (A5)
  static const upiSetting = 'UPI ID for QR codes';
  static const upiNotSet = 'Not set';
  static const upiHelp =
      'Customers scan a QR code to pay this UPI ID. It appears on the Pay screen and on every bill PDF. Leave empty to turn QR codes off.';
  static const upiId = 'UPI ID (for example shop@okhdfc)';
  static const upiName = 'Name customers see (optional)';
  static const upiSaved = 'UPI ID saved';
  static const upiOwnerHint = 'Add your UPI ID in Settings to show a payment QR here.';
  static String upiScanToPay(String amount) => 'Customer scans to pay $amount';
  static const bills = 'Bills';
  static const billsTitle = 'Bills';
  static const searchBills = 'Search bill number or customer';
  static const noBills = 'No bills yet';
  static const billDetail = 'Bill';
  static const whatsapp = 'WhatsApp';
  static const sharedViaSheet = 'WhatsApp is not available for this customer, so the share sheet opened';
  static const dueLabel = 'due';
  static const sharedNoPhone = 'This customer has no phone number saved, so the share sheet opened instead';
  static const sharedNoWhatsApp = 'WhatsApp could not be opened, so the share sheet opened instead';
  static const shareFailed = 'Could not share the bill';

  // Backup and restore (A6)
  static const settingsBackup = 'Backup';
  static const backUpNow = 'Back up now';
  static const backUpNowHelp =
      'Makes a copy of all your shop data and lets you send it to your own email or Google Drive. Do this often.';
  static const lastBackupLabel = 'Last backup';
  static const neverBackedUp = 'Never';
  static const backupFailed = 'Could not make the backup';
  static const backupFileWarning =
      'The backup file holds all your bills, customers and PINs. Send it only to yourself.';
  static const restoreFromBackup = 'Restore from a backup';
  static const restoreFromBackupHelp = 'Replace everything on this phone with a backup file.';
  static const restoreTitle = 'Restore this backup?';
  static const undoRestoreTitle = 'Go back to the data from before the restore?';
  static const backupContains = 'This backup contains:';
  static const restoreReplacesWarning =
      'Everything on this phone now (all bills, stock, customers and PINs) will be replaced. '
      'A copy of the current data is kept so you can undo this.';
  static const restoreFreshNote = 'This phone has no shop data yet, so nothing will be lost.';
  static const restoreOnePhone =
      'Use only one phone for billing at a time. The same backup on two phones would give the same bill numbers.';
  static const restoreNow = 'Restore';
  static const undoRestore = 'Go back';
  static const restoring = 'Restoring your data. Please wait...';
  static const restoreDone = 'Restored. Log in with the PIN you used before.';
  static const restoreFailed = 'Could not restore the backup';
  static const cannotUseBackup = 'This file cannot be used';
  static const undoLastRestore = 'Undo last restore';
  static const undoLastRestoreHelp = 'Brings back the data that the last restore replaced.';
  static const backupReminder = 'Backup reminder';
  static const backupReminderHelp = 'A notification and a note on the home screen when there has been no backup for 3 days.';
  static const restoreFromBackupFirstRun = 'Restore from a backup instead';
  static const backupReminderBanner = 'Back up your shop data';
  static const backupReminderNever = 'You have not made a backup yet.';
  static String backupReminderDays(int days) => 'Your last backup was $days days ago.';
  static const backupNowShort = 'Back up';
  static const ok = 'OK';
  static const sendTestReminder = 'Send a test reminder now';

  // Check my data (A7)
  static const dataCheckTitle = 'Check my data';
  static const dataCheckNeverRun = 'Never run. Checks that stock, balances and bill totals all agree.';
  static const dataCheckPassed = 'All your numbers agree';
  static const dataCheckPassedShort = 'All numbers agree';
  static String dataCheckProblems(int n) => 'Found $n problem${n == 1 ? '' : 's'} in your data';
  static String dataCheckScope(int checks, int records) => '$checks checks over $records records';
  static String dataCheckNotes(int n) => '$n note${n == 1 ? '' : 's'} to look at (not errors)';
  static const dataCheckAdvice =
      'Tap a problem to open it. Do not change anything yet: tell your developer, so the cause can be found. '
      'Share the report to send it.';
  static const dataCheckNoteHelp = 'Tap to see what does not add up.';
  static const dataCheckFailed = 'Could not check the data';
  static const problemsFound = 'Problems';
  static const notesFound = 'Notes';
  static String andMoreProblems(int n) => '...and $n more problems of the same kind';
  static const shareReport = 'Share report';
  static const runAgain = 'Check again';
  static String restoredWithProblems(int n) =>
      'The check found $n problem${n == 1 ? '' : 's'}. Open Settings, Check my data.';
  static const backupProblemsTitle = 'Your data has problems';
  static String backupProblemsBody(int n) =>
      'The data check found $n problem${n == 1 ? '' : 's'}. A backup still keeps everything, '
      'but it will contain the same problems. Back up anyway?';
  static const backUpAnyway = 'Back up anyway';

  // Speed tools, debug builds only (A7)
  static const speedTools = 'Speed test tools (debug)';
  static const speedTitle = 'Speed test';
  static const speedIntro =
      'Adds a big fake shop (about 400 items, 200 customers and 30 days of bills) on top of your data and times the '
      'screens on this phone. Make a backup first, and afterwards restore it to remove the fake data.';
  static const speedShopNow = 'In this phone now';
  static const speedLoad = 'Load big demo shop';
  static const speedRun = 'Run speed check';
  static const speedNeedBackup =
      'Make a backup first (Settings, Backup, Back up now) and check it is in your email or Drive. '
      'Then come back within an hour.';
  static const speedLoadWarning =
      'This adds hundreds of fake items, customers and bills to this phone. Your real data stays, but you must '
      'restore your backup afterwards to remove the fake data. Continue?';
  static const speedLoadConfirm = 'Load demo shop';
  static const speedLoaded = 'Demo shop loaded. Now run the speed check.';
  static const speedRunning = 'Timing the screens...';
  static const speedFailed = 'Did not finish';
  static const speedResults = 'Results';
  static const speedTarget = 'Aim: under';
  static const speedAfter =
      'When you are done: Settings, Restore from a backup, choose your backup, and the fake data is gone.';

  // Returns and cancelled bills (A7)
  static const returnItems = 'Return items';
  static const returnTitle = 'Return items';
  static const returnAgainst = 'Against bill';
  static const returnHow = 'Enter how much of each item is coming back, then choose how to give the money back.';
  static const returnSold = 'Sold';
  static const returnAlready = 'already returned';
  static const returnQty = 'Back';
  static const returnAll = 'All that is left';
  static const returnLinesTotal = 'Items returned';
  static const returnRefundTotal = 'Refund';
  static const returnCompletes = 'This returns everything on the bill, so the round-off is given back too.';
  static const returnGiveBack = 'Give the money back';
  static const refundAllCash = 'All cash';
  static const refundAllUpi = 'All UPI';
  static const refundAllAccount = 'Off their account';
  static const refundCash = 'Cash';
  static const refundUpi = 'UPI';
  static const refundAccount = 'Taken off what they owe';
  static const refundAddsUp = 'The refund adds up';
  static String refundRemaining(String left) => 'Still to give back: $left';
  static const returnReason = 'Reason (optional)';
  static const returnConfirm = 'Return and give money back';
  static String returnApprovalWhat(String amount) => 'a return of $amount';
  static String cancelApprovalWhat(String bill) => 'cancelling bill $bill';
  static const cancelBill = 'Cancel bill';
  static const keepBill = 'Keep the bill';
  static String cancelBillWarning(String total) =>
      'This takes the whole bill back: the stock returns, and $total goes back to the customer the way they paid. The bill stays on record marked cancelled.';
  static const billCancelledNote = 'This bill was cancelled';
  static const creditNotes = 'Credit notes';
  static const creditNoteTitle = 'Credit note';
  static const cancelledBadge = 'Cancelled';
  static const returnedBadge = 'Returned';
  static const ownerApprovalTitle = 'Owner approval needed';
  static String ownerApprovalBody(String what) => 'The owner must approve $what. Owner, enter your PIN.';
  static const ownerPinLabel = 'Owner PIN';

  // Day check (A7)
  static const dayCheckTitle = 'Day check';
  static const shareSummary = 'Share summary';
  static const dcSales = 'Sales';
  static const dcCancelled = 'Cancelled bills';
  static const dcSalesGross = 'Sold on bills';
  static const dcReturns = 'Taken back (returns and cancels)';
  static const dcNetSales = 'Net sales';
  static const dcHowPaid = 'How it was paid';
  static const dcCollected = 'Collected from customers';
  static const dcCollectedTotal = 'Paid against old dues';
  static const dcPurchases = 'Purchases';
  static const dcPurchasesEntered = 'Supplier bills entered';
  static const dcPurchasesTotal = 'Purchases total';
  static const dcPaidSuppliers = 'Paid to suppliers';
  static const dcCashRefunds = 'Cash handed back to customers';
  static const dcCompareHelp =
      'Put these numbers beside your paper book. If one differs, find the bill or payment that explains it before you close the day.';
  static const dcCheckedAt = 'Looked at';
  static const stockSpotCheck = 'Stock spot check';
  static const spotIntro = 'Choose a few items, count them on the shelf, and see if the app agrees. Nothing changes unless you tap Apply.';
  static const spotAddItem = 'Search an item to check';
  static const spotAppSays = 'The app says';
  static const spotCounted = 'You counted';
  static const spotMatches = 'Matches';
  static const spotDifference = 'Difference';
  static const spotAllMatch = 'Everything you counted matches';
  static String spotDifferences(int n) => n == 1 ? '1 item differs from the app' : '$n items differ from the app';
  static const spotApply = 'Apply counts';
  static const spotApplyHelp = 'Apply sets the app\'s stock to what you counted and records it as a stock count.';
  static String spotApplyConfirm(int n) => 'Set the stock of $n item${n == 1 ? '' : 's'} to what you counted?';
  static const spotApplied = 'Stock updated to your counts';

  // Home (design refresh)
  static String homeHello(String name) => 'Hello, $name';
  static const homeNewBillHint = 'Search, scan, pay, share';
  static const homeGroupSell = 'Sales';
  static const homeGroupStock = 'Stock and buying';
  static const homeGroupPeople = 'People and money';
  static const homeGroupShop = 'Shop';
  static const homeToday = 'Today';

  // A8 which phone is this
  static String devicePhone(String letter) => 'Phone $letter';
  static const deviceNewLabel = 'New phone';
  static const deviceChoiceTitle = 'Which phone is this?';
  static const deviceChoiceHelp =
      "This shop's data has more than one phone in it, and this phone does not know which one it is. This usually happens after a backup is restored on a new phone.";
  static const deviceChoiceReplace = 'This phone replaces';
  static const deviceChoiceNew = 'This is a new phone';
  static const deviceChoiceNewHelp = 'A new phone gets its own bill numbers, so bills never share a number with another phone.';
  static String deviceReplaceTitle(String letter) => 'Replace phone $letter?';
  static String deviceReplaceWarn(String letter) =>
      'Only do this if phone $letter is lost, broken or no longer used. If phone $letter is still billing, two phones would give out the same bill numbers.';
  static const deviceReplaceYes = 'Yes, replace it';

  // A8 Wi-Fi sync
  static const phonesTitle = 'Phones and Wi-Fi sync';
  static const phonesSettingHelp = 'Bill on two phones; they share data over the shop Wi-Fi';
  static const phonesThisPhone = 'This phone';
  static const phonesNoneYet = 'Only this phone so far. Add a second phone to bill on two phones at once.';
  static const phonesAdd = 'Add a phone';
  static const phonesSyncNow = 'Sync now';
  static const phonesRemove = 'Remove this phone from the shop';
  static String phonesRemoveConfirm(String name) =>
      'Remove $name? Its bills stay in the shop, but it will no longer sync. To use it again, add it again from this screen.';
  static const phonesRemoved = 'Phone removed';
  static const phonesRename = 'Rename';
  static const phonesRenameTitle = 'Name for this phone';
  static const phonesClashes = 'Changes made on both phones at once';
  static String phonesClashesHelp(int n) =>
      '$n time${n == 1 ? '' : 's'} in the last 7 days the same thing was changed on both phones before they synced. The later change was kept; both are in the activity log.';
  static String phonesClockWarn(int minutes) =>
      "The two phones' clocks differ by about $minutes minutes. Set both to automatic date and time, or the newer change may not win.";
  static String phonesLastSync(String when) => 'Last synced $when';
  static const phonesNeverSynced = 'Not synced yet';
  static const syncOff = 'One phone';
  static const syncSearching = 'Looking for the other phone';
  static const syncSearchingHelp = 'Both phones need the app open and the same shop Wi-Fi. Bills are saved here and go across later.';
  static const syncSynced = 'Synced';
  static const syncProblem = 'Sync problem';
  static const addPhoneTitle = 'Add a phone';
  static const addPhoneSteps =
      '1. Install the app on the new phone and connect it to the shop Wi-Fi.\n'
      '2. Open the app on the new phone and tap "Join a shop".\n'
      '3. Scan this code with the new phone.';
  static const addPhoneExpires = 'This code works once, for 10 minutes. Keep this screen open until the new phone says it has joined.';
  static String addPhoneJoined(String name) => '$name joined the shop';
  static const addPhoneNoWifi = 'This phone is not on a Wi-Fi network. Connect it to the shop Wi-Fi and try again.';
  static const joinShop = 'Join a shop';
  static const joinShopFirstRun = 'Join a shop (second phone)';
  static const joinTitle = 'Join a shop';
  static const joinHelp =
      "On the owner's phone open Settings, Phones and Wi-Fi sync, Add a phone. Then scan the code it shows. This phone gets a copy of all the shop's data and its own bill numbers.";
  static const joinName = 'Name for this phone';
  static const joinNameDefault = 'Counter phone';
  static const joinScan = "Scan the owner's code";
  static const joinNotShopCode = "That is not a shop pairing code. Scan the code on the owner's phone (Settings, Phones and Wi-Fi sync, Add a phone).";
  static const joining = "Copying the shop's data from the owner's phone...";
  static const joinDone = 'This phone has joined the shop. Log in with your PIN.';
  static const joinReplaceWarn = "Anything already saved on this phone will be replaced by the shop's data (a safety copy is kept).";

  // A8 cancel purchase, supplier bill entered twice
  static const purchaseCancel = 'Cancel this purchase';
  static const purchaseCancelHelp =
      'Use this when the purchase was entered by mistake, for example the same supplier bill entered on both phones. The stock comes back out and the supplier is no longer owed this amount.';
  static String purchaseCancelConfirm(String no, String total) =>
      'Cancel purchase $no ($total)? Its stock comes back out and the supplier’s account is reduced by $total. This cannot be undone.';
  static const purchaseCancelReason = 'Reason (optional)';
  static const purchaseCancelled = 'Purchase cancelled';
  static String purchaseCancelWhat(String no) => 'cancel supplier bill $no';
  static const purchaseTwiceBadge = 'Entered twice';
  static String purchaseTwiceNote(int n) =>
      n == 1 ? 'A supplier bill was entered twice' : '$n supplier bills were entered twice';
  static const purchaseTwiceHelp = 'Usually once on each phone. Open it and cancel the extra copy.';

  // Settings (compact menu)
  static const settingsBackupTitle = 'Backup and restore';
  static const settingsData = 'Data';
  static const settingsBillingRules = 'Billing rules';
  static const settingsShopDetailsSub = 'Name, GSTIN, address, bill terms';
  static const settingsStaffSub = 'Counter staff and PINs';
  static const settingsPhonesOne = 'One phone';
  static String settingsPhonesMany(int n) => '$n phones';
  static const settingsAuditSub = 'Who changed what, and when';
  static const settingsAlertsTitle = 'Daily summary';
  static const settingsOff = 'Off';
  static const settingsNeverBackedUp = 'Never backed up';
  static const backupGroupBackUp = 'Back up';
  static const backupGroupRestore = 'Restore';
  static const backupGroupReminder = 'Reminder';
  static const settingsPhonesRow = 'Phones and sync';
}
