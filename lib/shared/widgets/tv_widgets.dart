import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/app_services.dart';
import '../../core/theme/app_theme.dart';

/// Whether focus/scale animations are enabled (settings + low-memory mode).
class MotionSettings extends InheritedWidget {
  const MotionSettings({super.key, required this.animate, required this.sounds, required super.child});
  final bool animate;
  final bool sounds;

  static MotionSettings? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<MotionSettings>();

  @override
  bool updateShouldNotify(MotionSettings old) => animate != old.animate || sounds != old.sounds;
}

/// A D-pad/gamepad friendly focusable surface with a clear focus ring and a
/// subtle scale animation. Activates with Enter/Select/DPAD_CENTER/Button A.
class TvFocusable extends StatefulWidget {
  const TvFocusable({
    super.key,
    required this.child,
    this.onSelect,
    this.onLongPress,
    this.onFocus,
    this.autofocus = false,
    this.focusNode,
    this.borderRadius = 14,
    this.scale = 1.04,
    this.padding = EdgeInsets.zero,
    this.color,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onSelect;
  final VoidCallback? onLongPress;
  final ValueChanged<bool>? onFocus;
  final bool autofocus;
  final FocusNode? focusNode;
  final double borderRadius;
  final double scale;
  final EdgeInsets padding;
  final Color? color;
  final String? semanticLabel;

  @override
  State<TvFocusable> createState() => _TvFocusableState();
}

class _TvFocusableState extends State<TvFocusable> {
  bool _focused = false;

  void _select() {
    final motion = MotionSettings.maybeOf(context);
    if (motion?.sounds ?? false) SystemSound.play(SystemSoundType.click);
    widget.onSelect?.call();
  }

  @override
  Widget build(BuildContext context) {
    final palette = GameboxPalette.of(context);
    final animate = MotionSettings.maybeOf(context)?.animate ?? true;
    final radius = BorderRadius.circular(widget.borderRadius);
    final duration = animate ? const Duration(milliseconds: 140) : Duration.zero;

    return Semantics(
      button: widget.onSelect != null,
      label: widget.semanticLabel,
      child: AnimatedScale(
        scale: _focused ? widget.scale : 1,
        duration: duration,
        child: AnimatedContainer(
          duration: duration,
          decoration: BoxDecoration(
            color: widget.color ?? palette.card,
            borderRadius: radius,
            border: Border.all(
              color: _focused ? palette.focus : Colors.transparent,
              width: 2.5,
            ),
            boxShadow: _focused
                ? [BoxShadow(color: palette.focus.withValues(alpha: 0.35), blurRadius: 14)]
                : null,
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              focusNode: widget.focusNode,
              autofocus: widget.autofocus,
              borderRadius: radius,
              focusColor: Colors.transparent,
              onTap: widget.onSelect == null ? null : _select,
              onLongPress: widget.onLongPress,
              canRequestFocus: true,
              onFocusChange: (f) {
                setState(() => _focused = f);
                widget.onFocus?.call(f);
                if (f) {
                  Scrollable.ensureVisible(context,
                      alignment: 0.5,
                      duration: animate ? const Duration(milliseconds: 160) : Duration.zero);
                }
              },
              child: Padding(padding: widget.padding, child: widget.child),
            ),
          ),
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.subtitle, this.trailing});
  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title.toUpperCase(), style: t.titleMedium?.copyWith(letterSpacing: 1.2)),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(subtitle!, style: t.bodySmall?.copyWith(color: Colors.white60)),
                  ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip(this.label, {super.key, required this.color, this.icon});
  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.6)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[Icon(icon, size: 14, color: color), const SizedBox(width: 4)],
          Text(label,
              style: TextStyle(color: color, fontSize: 11.5, fontWeight: FontWeight.w700)),
        ]),
      );
}

/// Honest empty state used when there is no real data yet.
class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, required this.message, this.action});
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 52, color: Colors.white38),
          const SizedBox(height: 12),
          Text(title, style: t.titleLarge, textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text(message,
              style: t.bodyMedium?.copyWith(color: Colors.white60), textAlign: TextAlign.center),
          if (action != null) ...[const SizedBox(height: 16), action!],
        ]),
      ),
    );
  }
}

/// Focusable pill button.
class TvButton extends StatelessWidget {
  const TvButton({super.key, required this.label, required this.onPressed, this.icon, this.autofocus = false, this.primary = false});
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool autofocus;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final palette = GameboxPalette.of(context);
    final enabled = onPressed != null;
    return TvFocusable(
      autofocus: autofocus,
      onSelect: onPressed,
      borderRadius: 30,
      scale: 1.06,
      color: primary && enabled ? palette.accent : palette.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      child: Opacity(
        opacity: enabled ? 1 : 0.45,
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 6)],
          Text(label, style: Theme.of(context).textTheme.labelLarge),
        ]),
      ),
    );
  }
}

/// Key/value row that shows UNKNOWN for missing values.
class InfoRow extends StatelessWidget {
  const InfoRow(this.label, this.value, {super.key});
  final String label;
  final Object? value;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final text = (value == null || '$value'.isEmpty) ? 'UNKNOWN' : '$value';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          width: 190,
          child: Text(label, style: t.bodyMedium?.copyWith(color: Colors.white60)),
        ),
        Expanded(
          child: Text(text,
              style: t.bodyMedium?.copyWith(
                color: text == 'UNKNOWN' ? Colors.orangeAccent : Colors.white,
                fontWeight: FontWeight.w600,
              )),
        ),
      ]),
    );
  }
}

/// Standard page scaffold used inside the launcher shell content area.
class PageFrame extends StatelessWidget {
  const PageFrame({super.key, required this.title, this.subtitle, this.actions = const [], required this.child});
  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: t.headlineSmall),
              if (subtitle != null)
                Text(subtitle!, style: t.bodyMedium?.copyWith(color: Colors.white60)),
            ]),
          ),
          for (final a in actions) Padding(padding: const EdgeInsets.only(left: 10), child: a),
        ]),
        const SizedBox(height: 14),
        Expanded(child: child),
      ]),
    );
  }
}

AppServices servicesOf(BuildContext context) => AppScope.of(context);
