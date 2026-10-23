import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';

/// Translucent input from the login and registration screens:
/// 59 px tall, 20 % white fill, radius 9, soft drop shadow.
class GlassField extends StatefulWidget {
  const GlassField({
    super.key,
    this.controller,
    this.hint,
    this.textColor,
    this.obscure = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.autofillHints,
  });

  final TextEditingController? controller;
  final String? hint;
  final Color? textColor;
  final bool obscure;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final FormFieldValidator<String>? validator;
  final Iterable<String>? autofillHints;

  @override
  State<GlassField> createState() => _GlassFieldState();
}

class _GlassFieldState extends State<GlassField> {
  late bool _hidden = widget.obscure;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final textColor = widget.textColor ?? c.text;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(9),
      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.35)),
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9),
        boxShadow: const [
          BoxShadow(color: Color(0x40000000), offset: Offset(0, 4), blurRadius: 4),
        ],
      ),
      child: TextFormField(
        controller: widget.controller,
        obscureText: _hidden,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        validator: widget.validator,
        autofillHints: widget.autofillHints,
        cursorColor: textColor,
        style: AppText.label(textColor).copyWith(fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: AppText.label(textColor),
          filled: true,
          fillColor: c.glass,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 15, vertical: 19.5),
          border: border,
          enabledBorder: border,
          focusedBorder: border.copyWith(
            borderSide: BorderSide(color: c.accent, width: 1.5),
          ),
          errorStyle: AppText.mono(c.accent, size: 11),
          suffixIcon: widget.obscure
              ? IconButton(
                  onPressed: () => setState(() => _hidden = !_hidden),
                  icon: Icon(
                    _hidden ? Icons.visibility : Icons.visibility_off,
                    color: textColor,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
