import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/debug/sample_data.dart';
import '../../core/providers.dart';
import '../../shared/strings.dart';
import '../billing/bill_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    return Scaffold(
      appBar: AppBar(title: Text(session.valueOrNull?.shop.name ?? S.appTitle)),
      body: session.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not open the database: $e')),
        data: (s) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FilledButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const BillScreen()),
                ),
                icon: const Icon(Icons.receipt_long),
                label: const Text(S.newBill, style: TextStyle(fontSize: 18)),
              ),
              if (kDebugMode) ...[
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final loaded = await SampleData.load(
                      s.ctx,
                      locationId: s.locationId,
                    );
                    messenger.showSnackBar(SnackBar(
                      content: Text(loaded
                          ? S.sampleDataLoaded
                          : 'Items already exist, nothing loaded'),
                    ));
                  },
                  child: const Text(S.loadSampleData),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
