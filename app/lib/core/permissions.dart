import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth/auth_providers.dart';
import 'db/repositories/settings_repository.dart';

/// What the current user may see or do, from their role (plan A4). In Stage A
/// this is a UI-level rule only: the data is on the phone, and server-enforced
/// hiding arrives in Stage B.
class Permissions {
  const Permissions({
    required this.canSeeCost,
    required this.canEditPrices,
    this.canSeeReports = true,
    this.canOpenSettings = true,
    this.canSeeAudit = true,
    this.canSeePurchases = true,
    this.canImport = true,
    this.maxDiscountPercent,
  });

  /// Full access (owner).
  const Permissions.owner()
      : canSeeCost = true,
        canEditPrices = true,
        canSeeReports = true,
        canOpenSettings = true,
        canSeeAudit = true,
        canSeePurchases = true,
        canImport = true,
        maxDiscountPercent = null;

  /// Counter staff: no cost price, profit or reports anywhere (plan section 2,
  /// rule 10), no price edits, discounts up to [maxDiscount] percent per line.
  const Permissions.counter({int maxDiscount = SettingsRepository.defaultCounterMaxDiscountPct})
      : canSeeCost = false,
        canEditPrices = false,
        canSeeReports = false,
        canOpenSettings = false,
        canSeeAudit = false,
        canSeePurchases = false,
        canImport = false,
        maxDiscountPercent = maxDiscount;

  /// Nobody is logged in (the lock screen is showing): nothing is allowed.
  const Permissions.locked()
      : canSeeCost = false,
        canEditPrices = false,
        canSeeReports = false,
        canOpenSettings = false,
        canSeeAudit = false,
        canSeePurchases = false,
        canImport = false,
        maxDiscountPercent = 0;

  final bool canSeeCost;
  final bool canEditPrices;
  final bool canSeeReports;
  final bool canOpenSettings;
  final bool canSeeAudit;

  /// Purchases and supplier payables show what the shop pays (cost).
  final bool canSeePurchases;
  final bool canImport;

  /// Largest discount per bill line as a percent of the line amount, or null
  /// for no limit.
  final int? maxDiscountPercent;

  /// True when [discountPaise] on a line worth [amountPaise] is allowed.
  bool discountAllowed(int discountPaise, int amountPaise) {
    final limit = maxDiscountPercent;
    if (limit == null || discountPaise <= 0) return true;
    return discountPaise * 100 <= amountPaise * limit;
  }
}

final permissionsProvider = Provider<Permissions>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Permissions.locked();
  if (user.role == 'owner') return const Permissions.owner();
  final pct = ref.watch(discountLimitProvider).valueOrNull ??
      SettingsRepository.defaultCounterMaxDiscountPct;
  return Permissions.counter(maxDiscount: pct);
});
