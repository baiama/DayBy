import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/glass_field.dart';
import '../../core/widgets/gradient_scaffold.dart';
import '../../core/widgets/primary_button.dart';
import 'validators.dart';

/// Not in the Figma file yet; built in the login screen's style.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ссылка для сброса отправлена на ${_email.text.trim()}')),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GradientScaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 53, vertical: 24),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Восстановление пароля', style: AppText.h2(c.text)),
                const SizedBox(height: 12),
                Text(
                  'Введите почту, и мы пришлём ссылку для сброса пароля.',
                  style: AppText.body(c.text),
                ),
                const SizedBox(height: 40),
                GlassField(
                  testId: 'forgot_email',
                  controller: _email,
                  hint: 'Почта',
                  keyboardType: TextInputType.emailAddress,
                  validator: validateEmail,
                ),
                const SizedBox(height: 40),
                PrimaryButton(
                  label: 'Отправить ссылку',
                  testId: 'forgot_submit',
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
