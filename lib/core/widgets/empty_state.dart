import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import 'test_id.dart';

/// Friendly placeholder: icon in a soft double circle, title, hint and an
/// optional action. Used wherever a list can be empty.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.testId,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.compact = false,
  });

  final String testId;
  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Smaller art for use inside a card or below other content.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final size = compact ? 88.0 : 132.0;
    return TestId(
      testId,
      keepChildren: true,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: compact ? 16 : 32, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: c.accent.withValues(alpha: 0.12),
              ),
              alignment: Alignment.center,
              child: Container(
                width: size * 0.68,
                height: size * 0.68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: c.accent.withValues(alpha: 0.25),
                ),
                child: Icon(icon, size: size * 0.34, color: c.accent),
              ),
            ),
            SizedBox(height: compact ? 12 : 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppText.h3(c.text).copyWith(fontSize: compact ? 17 : 20, height: 1.2),
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: AppText.body(c.muted).copyWith(height: 1.4),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              TestId(
                '${testId}_action',
                child: OutlinedButton.icon(
                  onPressed: onAction,
                  icon: Icon(Icons.add, color: c.text, size: 18),
                  label: Text(actionLabel!, style: AppText.button(c.text)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: c.text, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
