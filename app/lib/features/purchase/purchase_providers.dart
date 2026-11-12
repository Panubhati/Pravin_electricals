import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/repositories/purchase_repository.dart';
import '../../core/providers.dart';

/// Purchases for the list screen, newest first.
final purchasesProvider = FutureProvider.autoDispose<List<PurchaseListEntry>>(
  (ref) => ref.watch(purchaseRepositoryProvider).list(),
);

/// Purchases whose supplier bill was entered twice (both still standing).
final duplicatePurchasesProvider = FutureProvider.autoDispose<Set<String>>(
  (ref) => ref.watch(purchaseRepositoryProvider).duplicatedPurchaseIds(),
);

/// One purchase with its lines, for the detail screen.
final purchaseDetailsProvider =
    FutureProvider.autoDispose.family<PurchaseDetails, String>(
  (ref, id) => ref.watch(purchaseRepositoryProvider).details(id),
);
