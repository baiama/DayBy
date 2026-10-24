import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import 'test_id.dart';

/// Main call-to-action: 48 px, radius 9, hard bottom shadow.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.testId,
    this.background,
    this.foreground,
    this.shadow,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final String testId;
  final Color? background;
  final Color? foreground;
  final Color? shadow;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final bg = background ?? c.primary;
    final fg = foreground ?? c.onPrimary;
    return TestId(
      testId,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(9),
          boxShadow: [
            BoxShadow(
              color: shadow ?? c.primaryShadow,
              offset: const Offset(0, 4),
              blurRadius: 0.8,
            ),
          ],
        ),
        child: Material(
          color: bg,
          borderRadius: BorderRadius.circular(9),
          child: InkWell(
            borderRadius: BorderRadius.circular(9),
            onTap: loading ? null : onPressed,
            child: Center(
              child: loading
                  ? SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: fg),
                    )
                  : Text(label, style: AppText.button(fg)),
            ),
          ),
        ),
      ),
    );
  }
}
