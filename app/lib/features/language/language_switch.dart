import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/i18n/app_language.dart';
import '../../shared/strings.dart';

/// मराठी | English, for this phone. Shown on the PIN screen and in Settings.
/// The names are always written in their own language so anyone can find theirs.
class LanguageSwitch extends ConsumerWidget {
  const LanguageSwitch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(appLanguageProvider);
    return SegmentedButton<AppLang>(
      key: const Key('languageSwitch'),
      showSelectedIcon: false,
      style: const ButtonStyle(visualDensity: VisualDensity.compact),
      segments: const [
        ButtonSegment(value: AppLang.mr, label: Text('मराठी', key: Key('langMr'))),
        ButtonSegment(value: AppLang.en, label: Text('English', key: Key('langEn'))),
      ],
      selected: {lang},
      onSelectionChanged: (s) => setAppLanguage(ref, s.first),
    );
  }
}
