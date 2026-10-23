import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Scaffold with the soft beige → pink background used on most screens.
class GradientScaffold extends StatelessWidget {
  const GradientScaffold({
    super.key,
    required this.body,
    this.gradient,
    this.appBar,
    this.floatingActionButton,
    this.bottomNavigationBar,
  });

  final Widget body;
  final Gradient? gradient;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: gradient ?? context.colors.backgroundGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: appBar,
        body: body,
        floatingActionButton: floatingActionButton,
        bottomNavigationBar: bottomNavigationBar,
      ),
    );
  }
}
