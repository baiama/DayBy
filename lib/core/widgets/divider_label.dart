import 'package:flutter/material.dart';

import '../theme/app_text.dart';

/// «— Способы входа —» divider.
class DividerLabel extends StatelessWidget {
  const DividerLabel({super.key, required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: color, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(text, style: AppText.mono(color)),
        ),
        Expanded(child: Divider(color: color, thickness: 1)),
      ],
    );
  }
}
