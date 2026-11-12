// Marathi text for S (A10). Keys are the S entry names; a missing key shows
// the English text. Functions build sentences with numbers or names.
// ignore_for_file: prefer_single_quotes

const mrStrings = <String, String>{};

abstract final class SMr {
  static String discountTooHigh(int pct) => 'Staff can give up to $pct% discount. Ask the owner.';
  static String lockedWait(int seconds) => 'Too many wrong tries. Try again in $seconds seconds.';
  static String upiScanToPay(String amount) => 'Customer scans to pay $amount';
  static String backupReminderDays(int days) => 'Your last backup was $days days ago.';
  static String dataCheckProblems(int n) => 'Found $n problem${n == 1 ? '' : 's'} in your data';
  static String dataCheckScope(int checks, int records) => '$checks checks over $records records';
  static String dataCheckNotes(int n) => '$n note${n == 1 ? '' : 's'} to look at (not errors)';
  static String andMoreProblems(int n) => '...and $n more problems of the same kind';
  static String restoredWithProblems(int n) =>
      'The check found $n problem${n == 1 ? '' : 's'}. Open Settings, Check my data.';
  static String backupProblemsBody(int n) =>
      'The data check found $n problem${n == 1 ? '' : 's'}. A backup still keeps everything, '
      'but it will contain the same problems. Back up anyway?';
  static String refundRemaining(String left) => 'Still to give back: $left';
  static String returnApprovalWhat(String amount) => 'a return of $amount';
  static String cancelApprovalWhat(String bill) => 'cancelling bill $bill';
  static String cancelBillWarning(String total) =>
      'This takes the whole bill back: the stock returns, and $total goes back to the customer the way they paid. The bill stays on record marked cancelled.';
  static String ownerApprovalBody(String what) => 'The owner must approve $what. Owner, enter your PIN.';
  static String spotDifferences(int n) => n == 1 ? '1 item differs from the app' : '$n items differ from the app';
  static String spotApplyConfirm(int n) => 'Set the stock of $n item${n == 1 ? '' : 's'} to what you counted?';
  static String homeHello(String name) => 'Hello, $name';
  static String devicePhone(String letter) => 'Phone $letter';
  static String deviceReplaceTitle(String letter) => 'Replace phone $letter?';
  static String deviceReplaceWarn(String letter) =>
      'Only do this if phone $letter is lost, broken or no longer used. If phone $letter is still billing, two phones would give out the same bill numbers.';
  static String phonesRemoveConfirm(String name) =>
      'Remove $name? Its bills stay in the shop, but it will no longer sync. To use it again, add it again from this screen.';
  static String phonesClashesHelp(int n) =>
      '$n time${n == 1 ? '' : 's'} in the last 7 days the same thing was changed on both phones before they synced. The later change was kept; both are in the activity log.';
  static String phonesClockWarn(int minutes) =>
      "The two phones' clocks differ by about $minutes minutes. Set both to automatic date and time, or the newer change may not win.";
  static String phonesLastSync(String when) => 'Last synced $when';
  static String addPhoneJoined(String name) => '$name joined the shop';
  static String purchaseCancelConfirm(String no, String total) =>
      'Cancel purchase $no ($total)? Its stock comes back out and the supplier’s account is reduced by $total. This cannot be undone.';
  static String purchaseCancelWhat(String no) => 'cancel supplier bill $no';
  static String purchaseTwiceNote(int n) =>
      n == 1 ? 'A supplier bill was entered twice' : '$n supplier bills were entered twice';
  static String settingsPhonesMany(int n) => '$n phones';
}
