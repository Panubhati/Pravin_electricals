import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/debug/demo_shop.dart';
import '../../core/debug/speed_check.dart';
import '../../core/providers.dart';
import '../../shared/format.dart';
import '../../shared/strings.dart';
import '../../shared/widgets.dart';
import '../../shared/theme.dart';

/// Debug builds only (the Home screen hides the entry in release builds).
/// Fills the shop with a big fake shop and times the screens on this phone.
class SpeedScreen extends ConsumerStatefulWidget {
  const SpeedScreen({super.key, this.config = const DemoShopConfig()});

  /// How big the fake shop is (tests use a small one).
  final DemoShopConfig config;

  @override
  ConsumerState<SpeedScreen> createState() => _SpeedScreenState();
}

class _SpeedScreenState extends ConsumerState<SpeedScreen> {
  String _size = '';
  String? _status;
  double? _progress;
  String _progressLabel = '';
  List<SpeedResult>? _results;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _refreshSize();
  }

  Future<void> _refreshSize() async {
    final session = ref.read(sessionProvider).requireValue;
    final line = await shopSizeLine(session);
    if (mounted) setState(() => _size = line);
  }

  /// Fake data goes on top of the real data, so a recent backup must exist to restore from.
  Future<bool> _recentBackup() async {
    final last = await ref.read(settingsRepositoryProvider).lastBackupAt();
    final now = ref.read(sessionProvider).requireValue.ctx.clock();
    return last != null && now.difference(last) < const Duration(hours: 1);
  }

  Future<void> _load() async {
    if (_busy) return;
    if (!await _recentBackup()) {
      if (mounted) setState(() => _status = S.speedNeedBackup);
      return;
    }
    if (!mounted) return;
    final ok = await confirm(context, message: S.speedLoadWarning, confirmLabel: S.speedLoadConfirm);
    if (!ok || !mounted) return;
    setState(() {
      _busy = true;
      _status = null;
      _results = null;
      _progress = 0;
    });
    try {
      final session = ref.read(sessionProvider).requireValue;
      final stats = await DemoShop.load(session, config: widget.config, onProgress: (f, l) {
        if (mounted) {
          setState(() {
            _progress = f;
            _progressLabel = l;
          });
        }
      });
      ref.invalidate(stockBalancesProvider);
      ref.invalidate(partyBalancesProvider);
      await _refreshSize();
      if (mounted) setState(() => _status = '${S.speedLoaded}\n$stats');
    } catch (e) {
      if (mounted) setState(() => _status = '${S.speedFailed}: ${errorMessage(e)}');
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _progress = null;
        });
      }
    }
  }

  Future<void> _run() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _status = S.speedRunning;
      _results = null;
    });
    try {
      final session = ref.read(sessionProvider).requireValue;
      final results = await SpeedCheck.run(session, location: ref.read(databaseLocationProvider));
      if (mounted) setState(() => _results = results);
    } catch (e) {
      if (mounted) setState(() => _status = '${S.speedFailed}: ${errorMessage(e)}');
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          if (_results != null) _status = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;
    return Scaffold(
      appBar: AppBar(title: const Text(S.speedTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(S.speedIntro),
          const SizedBox(height: 12),
          Text('${S.speedShopNow}: $_size', key: const Key('speedSize')),
          const SizedBox(height: 16),
          FilledButton.icon(
            key: const Key('speedLoad'),
            onPressed: _busy ? null : _load,
            icon: const Icon(Icons.storage),
            label: const Text(S.speedLoad),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            key: const Key('speedRun'),
            onPressed: _busy ? null : _run,
            icon: const Icon(Icons.speed),
            label: const Text(S.speedRun),
          ),
          if (_progress != null) ...[
            const SizedBox(height: 12),
            LinearProgressIndicator(value: _progress),
            Text(_progressLabel),
          ],
          if (_status != null) ...[
            const SizedBox(height: 12),
            Text(_status!, key: const Key('speedStatus')),
          ],
          if (results != null) ...[
            const SectionTitle(S.speedResults),
            for (final r in results)
              ListTile(
                key: Key('speed_${r.name}'),
                dense: true,
                contentPadding: EdgeInsets.zero,
                tileColor: Colors.transparent,
                leading: Icon(r.passes() ? Icons.check_circle : Icons.warning_amber_rounded,
                    color: r.passes() ? AppPalette.green : AppPalette.red),
                title: Text(r.name),
                subtitle: Text('${S.speedTarget} ${r.targetMillis} ms'),
                trailing: Text('${r.millis} ms', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            const SizedBox(height: 8),
            Text(S.speedAfter, style: const TextStyle(color: AppPalette.muted)),
          ],
        ],
      ),
    );
  }
}
