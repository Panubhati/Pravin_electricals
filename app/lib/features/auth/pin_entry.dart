import 'package:flutter/material.dart';


/// PIN dots and a number pad. The caller handles what a submitted PIN means;
/// the digits are cleared after every submit.
class PinEntry extends StatefulWidget {
  const PinEntry({
    super.key,
    required this.onSubmit,
    this.title,
    this.message,
    this.submitLabel,
    this.maxLength = 6,
  });

  final Future<void> Function(String pin) onSubmit;
  final String? title;

  /// An error or hint shown above the dots.
  final String? message;
  final String? submitLabel;
  final int maxLength;

  @override
  State<PinEntry> createState() => _PinEntryState();
}

class _PinEntryState extends State<PinEntry> {
  String _pin = '';
  bool _busy = false;

  void _add(String d) {
    if (_busy || _pin.length >= widget.maxLength) return;
    setState(() => _pin += d);
  }

  void _back() {
    if (_busy || _pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  Future<void> _submit() async {
    if (_busy || _pin.length < 4) return;
    final pin = _pin;
    setState(() {
      _busy = true;
      _pin = '';
    });
    try {
      await widget.onSubmit(pin);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _key(String label, {VoidCallback? onTap, Key? key, IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: SizedBox(
        width: 76,
        height: 60,
        child: OutlinedButton(
          key: key,
          onPressed: _busy ? null : onTap,
          style: OutlinedButton.styleFrom(padding: EdgeInsets.zero),
          child: icon != null
              ? Icon(icon)
              : Text(label, style: Theme.of(context).textTheme.headlineSmall),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.title != null)
          Text(widget.title!, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Row(
          key: const Key('pinDots'),
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < widget.maxLength; i++)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 5),
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i < _pin.length ? scheme.primary : Colors.transparent,
                  border: Border.all(color: scheme.primary),
                ),
              ),
          ],
        ),
        SizedBox(
          height: 44,
          child: Center(
            child: widget.message == null
                ? null
                : Text(
                    widget.message!,
                    key: const Key('pinMessage'),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: scheme.error),
                  ),
          ),
        ),
        for (final row in const [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
        ])
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final d in row) _key(d, key: Key('pin_$d'), onTap: () => _add(d)),
            ],
          ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _key('', icon: Icons.backspace_outlined, key: const Key('pinBack'), onTap: _back),
            _key('0', key: const Key('pin_0'), onTap: () => _add('0')),
            _key('', icon: Icons.check, key: const Key('pinOk'), onTap: _submit),
          ],
        ),
      ],
    );
  }
}
