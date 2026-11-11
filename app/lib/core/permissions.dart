import 'package:flutter_riverpod/flutter_riverpod.dart';

/// What the current user may see or do. In Stage A there is one owner, so
/// everything is allowed. A4 (roles and PIN login) replaces
/// [permissionsProvider] with one driven by the logged-in role, and every
/// screen that reads cost or edits prices already goes through here.
class Permissions {
  const Permissions({required this.canSeeCost, required this.canEditPrices});

  /// Full access (owner).
  const Permissions.owner()
      : canSeeCost = true,
        canEditPrices = true;

  /// Counter staff: no cost price or profit anywhere (plan section 2, rule 10).
  const Permissions.counter()
      : canSeeCost = false,
        canEditPrices = false;

  final bool canSeeCost;
  final bool canEditPrices;
}

final permissionsProvider = Provider<Permissions>((ref) => const Permissions.owner());
