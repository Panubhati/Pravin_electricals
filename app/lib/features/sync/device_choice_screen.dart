import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/db/app_database.dart';
import '../../core/db/repositories/repo_context.dart';
import '../../core/db/repositories/setup_repository.dart';
import '../../core/providers.dart';
import '../../core/sync/device_identity.dart';
import '../../shared/strings.dart';
import '../../shared/theme.dart';
import '../../shared/widgets.dart';

/// The next free bill series letter (A, B, C...).
String nextSeriesLetter(Iterable<String> used) {
  for (var c = 'A'.codeUnitAt(0); c <= 'Z'.codeUnitAt(0); c++) {
    final letter = String.fromCharCode(c);
    if (!used.contains(letter)) return letter;
  }
  throw DomainException('This shop already has 26 phones');
}

/// Adds a new phone (device row) to the shop and makes this phone that device.
/// Its changes are stamped with the new device from the very first row.
Future<Device> addThisPhone(AppDatabase db, DeviceIdentity identity, {required String label}) async {
  final shop = await (db.select(db.shops)..where((t) => t.deletedAt.isNull())..limit(1)).getSingle();
  final devices = await (db.select(db.devices)..where((t) => t.shopId.equals(shop.id))).get();
  final letter = nextSeriesLetter(devices.map((d) => d.invoiceSeriesPrefix));
  final id = const Uuid().v4();
  final ctx = RepoContext(db, shopId: shop.id)..originDeviceId = id;
  await SetupRepository(ctx).createDevice(id: id, label: label, invoiceSeriesPrefix: letter);
  await identity.write(id);
  return (db.select(db.devices)..where((t) => t.id.equals(id))).getSingle();
}

/// Shown when the data holds more than one phone and this phone does not know
/// which one it is (usually after a backup was restored on a new phone).
class DeviceChoiceScreen extends ConsumerStatefulWidget {
  const DeviceChoiceScreen({super.key, required this.devices});
  final List<Device> devices;

  @override
  ConsumerState<DeviceChoiceScreen> createState() => _DeviceChoiceScreenState();
}

class _DeviceChoiceScreenState extends ConsumerState<DeviceChoiceScreen> {
  bool _busy = false;

  Future<void> _replace(Device d) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(S.deviceReplaceTitle(d.invoiceSeriesPrefix)),
        content: Text(S.deviceReplaceWarn(d.invoiceSeriesPrefix)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text(S.cancel)),
          FilledButton(
            key: const Key('deviceReplaceConfirm'),
            onPressed: () => Navigator.pop(c, true),
            child: const Text(S.deviceReplaceYes),
          ),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _busy = true);
    await ref.read(deviceIdentityProvider)!.write(d.id);
    ref.invalidate(sessionProvider);
  }

  Future<void> _newPhone() async {
    setState(() => _busy = true);
    await addThisPhone(ref.read(databaseProvider), ref.read(deviceIdentityProvider)!, label: S.deviceNewLabel);
    ref.invalidate(sessionProvider);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text(S.deviceChoiceTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(S.deviceChoiceHelp, style: text.bodyLarge),
          const SizedBox(height: 16),
          const SectionTitle(S.deviceChoiceReplace),
          Card(
            child: Column(children: [
              for (final d in widget.devices)
                ListTile(
                  key: Key('deviceChoice_${d.invoiceSeriesPrefix}'),
                  leading: CircleAvatar(
                    backgroundColor: AppPalette.blue.withValues(alpha: 0.1),
                    child: Text(d.invoiceSeriesPrefix, style: const TextStyle(color: AppPalette.blue)),
                  ),
                  title: Text(S.devicePhone(d.invoiceSeriesPrefix)),
                  subtitle: Text(d.label),
                  enabled: !_busy,
                  onTap: () => _replace(d),
                ),
            ]),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            key: const Key('deviceChoiceNew'),
            onPressed: _busy ? null : _newPhone,
            icon: const Icon(Icons.add),
            label: const Text(S.deviceChoiceNew),
          ),
          const SizedBox(height: 8),
          Text(S.deviceChoiceNewHelp, style: text.bodySmall?.copyWith(color: AppPalette.muted)),
        ],
      ),
    );
  }
}
