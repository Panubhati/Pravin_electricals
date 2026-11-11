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
}
