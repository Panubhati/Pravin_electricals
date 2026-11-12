import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/sync/device_identity.dart';
import '../../core/sync/join_shop.dart';
import '../../core/sync/pairing.dart';
import '../../core/sync/sync_transport.dart';
import '../../shared/format.dart';
import '../../shared/strings.dart';
import '../../shared/theme.dart';
import '../billing/scan_screen.dart';

/// Opens the camera and returns the scanned text. Tests replace it.
final pairingScannerProvider = Provider<Future<String?> Function(BuildContext)>(
  (ref) => (context) => Navigator.of(context).push<String>(MaterialPageRoute(builder: (_) => const ScanScreen())),
);

/// The second phone's way in: scan the owner's QR, get a copy of the shop's
/// data, and become a new phone of the shop with its own bill numbers.
class JoinShopScreen extends ConsumerStatefulWidget {
  const JoinShopScreen({super.key});

  @override
  ConsumerState<JoinShopScreen> createState() => _JoinShopScreenState();
}

class _JoinShopScreenState extends ConsumerState<JoinShopScreen> {
  final _name = TextEditingController(text: S.joinNameDefault);
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _scanAndJoin() async {
    final code = await ref.read(pairingScannerProvider)(context);
    if (code == null || !mounted) return;
    final invite = PairingInvite.tryDecode(code);
    if (invite == null) {
      setState(() => _error = S.joinNotShopCode);
      return;
    }
    final label = _name.text.trim().isEmpty ? S.joinNameDefault : _name.text.trim();
    setState(() {
      _busy = true;
      _error = null;
    });
    final location = ref.read(databaseLocationProvider);
    final identity = ref.read(deviceIdentityProvider) ?? FileDeviceIdentity(location);
    final restart = ref.read(appRestartProvider);
    final restartContext = context;
    final messenger = ScaffoldMessenger.of(context);
    try {
      final package = await fetchShopCopy(invite, label: label);
      // Nothing may hold the database file open while it is replaced.
      await ref.read(databaseProvider).close();
      await installJoinedShop(package: package, invite: invite, location: location, identity: identity, label: label);
      messenger.showSnackBar(SnackBar(content: Text(S.joinDone), duration: Duration(seconds: 6)));
      if (restartContext.mounted) restart(restartContext);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = switch (e) {
          SyncHttpException(:final message) => message,
          _ => errorMessage(e),
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(S.joinTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(S.joinHelp, style: text.bodyLarge),
          const SizedBox(height: 16),
          TextField(
            key: const Key('joinName'),
            controller: _name,
            enabled: !_busy,
            decoration: InputDecoration(labelText: S.joinName, border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          if (_busy)
            Row(children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Expanded(child: Text(S.joining)),
            ])
          else
            FilledButton.icon(
              key: const Key('joinScan'),
              onPressed: _scanAndJoin,
              icon: const Icon(Icons.qr_code_scanner),
              label: Text(S.joinScan),
            ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, key: const Key('joinError'), style: text.bodyMedium?.copyWith(color: AppPalette.red)),
          ],
          const SizedBox(height: 16),
          Text(S.joinReplaceWarn, style: text.bodySmall?.copyWith(color: AppPalette.muted)),
        ],
      ),
    );
  }
}
