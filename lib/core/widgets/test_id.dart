import 'package:flutter/widgets.dart';

/// Stable id for UI tests. Becomes `resource-id` on Android and
/// `accessibilityIdentifier` on iOS, which Maestro matches with `id:`.
/// `container` keeps the id on its own node so siblings don't absorb it.
/// By default the child's text merges into that node (good for buttons and
/// labels); set [keepChildren] for composite rows whose texts tests look up
/// one by one.
class TestId extends StatelessWidget {
  const TestId(this.id, {super.key, required this.child, this.keepChildren = false});

  final String id;
  final Widget child;
  final bool keepChildren;

  @override
  Widget build(BuildContext context) => Semantics(
    identifier: id,
    container: true,
    explicitChildNodes: keepChildren,
    child: child,
  );
}
