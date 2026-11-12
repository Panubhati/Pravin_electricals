import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/app_database.dart';
import '../../core/providers.dart';
import '../../core/sync/phones.dart';

export '../../core/sync/phones.dart' show addThisPhone, nextSeriesLetter;
import '../../shared/strings.dart';
import '../../shared/theme.dart';
import '../../shared/widgets.dart';

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
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text(S.cancel)),
          FilledButton(
            key: const Key('deviceReplaceConfirm'),
            onPressed: () => Navigator.pop(c, true),
            child: Text(S.deviceReplaceYes),
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
      appBar: AppBar(title: Text(S.deviceChoiceTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(S.deviceChoiceHelp, style: text.bodyLarge),
          const SizedBox(height: 16),
          SectionTitle(S.deviceChoiceReplace),
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
                  subtitle: Text(phoneName(d)),
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
            label: Text(S.deviceChoiceNew),
          ),
          const SizedBox(height: 8),
          Text(S.deviceChoiceNewHelp, style: text.bodySmall?.copyWith(color: AppPalette.muted)),
        ],
      ),
    );
  }
}
