import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/repositories/purchase_repository.dart';
import '../../core/providers.dart';

/// Purchases for the list screen, newest first.
final purchasesProvider = FutureProvider.autoDispose<List<PurchaseListEntry>>(
  (ref) => ref.watch(purchaseRepositoryProvider).list(),
);

/// One purchase with its lines, for the detail screen.
final purchaseDetailsProvider =
    FutureProvider.autoDispose.family<PurchaseDetails, String>(
  (ref, id) => ref.watch(purchaseRepositoryProvider).details(id),
);
