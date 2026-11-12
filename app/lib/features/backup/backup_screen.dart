import 'package:flutter/material.dart';

import '../../shared/strings.dart';
import 'backup_section.dart';

/// Settings, Backup and restore: back up now, restore, undo, the reminder.
class BackupScreen extends StatelessWidget {
  const BackupScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(S.settingsBackupTitle)),
        body: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: const [BackupSection()],
        ),
      );
}
