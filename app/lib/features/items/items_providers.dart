import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/repositories/item_repository.dart';
import '../../core/providers.dart';
import 'item_form_service.dart';

/// Items for the list screen. The key is (search text, show inactive).
final itemListProvider = FutureProvider.autoDispose
    .family<List<ItemListEntry>, ({String query, bool inactive})>(
  (ref, key) => ref
      .watch(itemRepositoryProvider)
      .listItems(query: key.query, includeInactive: key.inactive),
);

/// One item's full detail for the form.
final itemDetailProvider = FutureProvider.autoDispose.family<ItemDetail, String>(
  (ref, id) => ref.watch(itemRepositoryProvider).getDetail(id),
);

final itemFormServiceProvider = Provider<ItemFormService>(
  (ref) => ItemFormService(ref.watch(sessionProvider).requireValue.ctx),
);
