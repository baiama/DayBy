import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';

/// White rounded card from the profile screen. Material, so ripples of
/// ListTiles inside paint on the card.
class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) => Material(
    color: context.colors.card,
    borderRadius: BorderRadius.circular(28),
    clipBehavior: Clip.antiAlias,
    child: Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(20),
      child: child,
    ),
  );
}

/// 30 px accent-tinted square with an icon, used as a section marker.
class SectionIcon extends StatelessWidget {
  const SectionIcon(this.icon, {super.key});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: c.accent.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(icon, size: 18, color: c.accent),
    );
  }
}

/// Section icon + Inter title, optional trailing widget.
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.icon, required this.title, this.trailing});

  final IconData icon;
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      SectionIcon(icon),
      const SizedBox(width: 8),
      Expanded(child: Text(title, style: AppText.setting(context.colors.text))),
      ?trailing,
    ],
  );
}

/// Back arrow + title row used at the top of pushed screens.
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({
    super.key,
    required this.title,
    required this.backId,
    this.actions = const [],
    this.fallback = '/home',
  });

  final String title;
  final String backId;
  final List<Widget> actions;
  final String fallback;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      children: [
        Semantics(
          identifier: backId,
          container: true,
          child: IconButton(
            tooltip: 'Назад',
            onPressed: () => context.canPop() ? context.pop() : context.go(fallback),
            icon: Icon(Icons.arrow_back, color: c.text),
          ),
        ),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.h2(c.text),
          ),
        ),
        ...actions,
      ],
    );
  }
}
