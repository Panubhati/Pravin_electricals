import 'package:flutter/material.dart';

import 'format.dart';
import 'strings.dart';
import 'theme.dart';

/// Shows [message] at the bottom of the screen.
void toast(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

/// Shows a plain-language error for [error].
void toastError(BuildContext context, Object error) =>
    toast(context, errorMessage(error));

/// Asks a yes/no question. Returns true only when the user confirms.
Future<bool> confirm(
  BuildContext context, {
  required String message,
  String confirmLabel = 'Yes',
}) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(S.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return ok == true;
}

/// A centred message for an empty list or an error, with a soft icon.
class EmptyState extends StatelessWidget {
  const EmptyState(this.message, {super.key, this.icon = Icons.inbox_outlined});
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(color: AppPalette.blueTint, shape: BoxShape.circle),
                child: Icon(icon, size: 30, color: AppPalette.blue),
              ),
              const SizedBox(height: 16),
              Text(message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppPalette.muted)),
            ],
          ),
        ),
      );
}

/// A small label such as "Low stock". [color] says what it means: use
/// [AppPalette.green], [AppPalette.amber] or [AppPalette.red].
class StatusChip extends StatelessWidget {
  const StatusChip(this.text, {super.key, this.color = AppPalette.amber});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
      );
}

/// A heading above a group of rows or fields.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 8),
        child: Text(
          text.toUpperCase(),
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppPalette.muted,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
        ),
      );
}

/// A white rounded block with a thin border: the basic container of the app.
class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.onTap, this.color});
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) => Card(
        color: color,
        clipBehavior: Clip.antiAlias,
        child: InkWell(onTap: onTap, child: Padding(padding: padding, child: child)),
      );
}

/// A grey placeholder bar shown while a list loads (calmer than a spinner).
class SkeletonList extends StatefulWidget {
  const SkeletonList({super.key, this.rows = 6});
  final int rows;

  @override
  State<SkeletonList> createState() => _SkeletonListState();
}

class _SkeletonListState extends State<SkeletonList> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => DelayedFadeIn(child: _skeleton());

  Widget _skeleton() => AnimatedBuilder(
        animation: _c,
        builder: (_, __) {
          final tone = Color.lerp(AppPalette.line, AppPalette.page, _c.value)!;
          Widget bar(double w, double h) => Container(
                width: w,
                height: h,
                decoration: BoxDecoration(color: tone, borderRadius: BorderRadius.circular(6)),
              );
          return ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: widget.rows,
            itemBuilder: (_, i) => Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Row(
                children: [
                  Container(width: 40, height: 40, decoration: BoxDecoration(color: tone, shape: BoxShape.circle)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [bar(160 + (i % 3) * 30, 14), const SizedBox(height: 8), bar(100, 10)],
                    ),
                  ),
                  bar(56, 14),
                ],
              ),
            ),
          );
        },
      );
}

/// A green tick that pops in, shown when something has been saved.
class SuccessTick extends StatelessWidget {
  const SuccessTick({super.key, this.size = 88});
  final double size;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.6, end: 1),
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutBack,
        builder: (_, v, child) => Opacity(opacity: v.clamp(0, 1), child: Transform.scale(scale: v, child: child)),
        child: Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(color: AppPalette.greenTint, shape: BoxShape.circle),
          child: Icon(Icons.check_rounded, size: size * 0.6, color: AppPalette.green),
        ),
      );
}

/// Names rows by what people see (item or customer name), but stays unique
/// when two rows share a name (the same wire from two brands): the second one
/// gets its id added. Flutter needs sibling keys to be unique.
class RowKeys {
  final _seen = <String>{};
  String of(String name, String id) => _seen.add(name) ? name : '$name#$id';
}

/// A white rounded card holding rows with thin lines between them, with an
/// optional section title above (the look used across Settings and lists).
class CardGroup extends StatelessWidget {
  const CardGroup({
    super.key,
    this.title,
    required this.children,
    this.margin = const EdgeInsets.fromLTRB(16, 16, 16, 0),
    this.indent = 56,
  });
  final String? title;
  final List<Widget> children;
  final EdgeInsetsGeometry margin;

  /// Where the divider starts (56 lines up with text after a leading icon).
  final double indent;

  @override
  Widget build(BuildContext context) => Padding(
        padding: margin,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null)
              Padding(padding: const EdgeInsets.only(left: 4, bottom: 8), child: SectionTitle(title!)),
            Card(
              margin: EdgeInsets.zero,
              clipBehavior: Clip.antiAlias,
              child: Column(children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0) Divider(height: 1, indent: indent),
                  children[i],
                ],
              ]),
            ),
          ],
        ),
      );
}

/// One row of a card group drawn as part of a lazy list: rounded top on the
/// first row, rounded bottom on the last, a thin line between rows. Lets long
/// reports (hundreds of items) build only the rows on screen.
class CardSlice extends StatelessWidget {
  const CardSlice({super.key, required this.first, required this.last, required this.child, this.indent = 16});
  final bool first;
  final bool last;
  final Widget child;
  final double indent;

  @override
  Widget build(BuildContext context) {
    const side = BorderSide(color: AppPalette.line);
    final radius = BorderRadius.vertical(
      top: Radius.circular(first ? 14 : 0),
      bottom: Radius.circular(last ? 14 : 0),
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppPalette.card,
        borderRadius: radius,
        border: Border(
          left: side,
          right: side,
          top: first ? side : BorderSide.none,
          bottom: last ? side : BorderSide.none,
        ),
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          child,
          if (!last) Divider(height: 1, indent: indent),
        ]),
      ),
    );
  }
}

/// A card group whose rows are built only when scrolled into view.
class SliverCardGroup extends StatelessWidget {
  const SliverCardGroup({super.key, required this.count, required this.itemBuilder, this.indent = 16});
  final int count;
  final Widget Function(BuildContext, int) itemBuilder;
  final double indent;

  @override
  Widget build(BuildContext context) => SliverList.builder(
        itemCount: count,
        itemBuilder: (c, i) => CardSlice(first: i == 0, last: i == count - 1, indent: indent, child: itemBuilder(c, i)),
      );
}

/// Fades its child in only after a short wait, so a screen whose data arrives
/// at once never flashes a spinner or grey placeholder (that flash reads as lag).
class DelayedFadeIn extends StatefulWidget {
  const DelayedFadeIn({super.key, required this.child, this.delay = const Duration(milliseconds: 250)});
  final Widget child;
  final Duration delay;

  @override
  State<DelayedFadeIn> createState() => _DelayedFadeInState();
}

class _DelayedFadeInState extends State<DelayedFadeIn> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: widget.delay + const Duration(milliseconds: 200),
  )..forward();
  late final Animation<double> _opacity = CurvedAnimation(
    parent: _c,
    curve: Interval(
      widget.delay.inMilliseconds / (widget.delay.inMilliseconds + 200),
      1,
      curve: Curves.easeOut,
    ),
  );

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(opacity: _opacity, child: widget.child);
}

/// The loading spinner, shown only when loading takes a moment.
class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) =>
      const DelayedFadeIn(child: Center(child: CircularProgressIndicator()));
}
