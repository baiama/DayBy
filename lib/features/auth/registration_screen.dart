import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_text.dart';
import '../../core/widgets/dayby_logo.dart';
import '../../core/widgets/glass_field.dart';
import '../../core/widgets/gradient_scaffold.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/test_id.dart';
import 'auth_provider.dart';
import 'validators.dart';

/// Olive registration screen; colours are fixed by the design in both themes.
class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  static const _light = Color(0xFFFFE9DB);

  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    await ref
        .read(authProvider.notifier)
        .register(_name.text.trim(), _email.text.trim(), _password.text);
    if (mounted) context.go('/home');
  }

  Widget _labeled(String label, Widget field) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: AppText.label(_light)),
      const SizedBox(height: 2),
      field,
    ],
  );

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      gradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF66675A), Color(0xFF9C9784)],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 53, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 288),
              child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('DayBy', textAlign: TextAlign.center, style: AppText.logo(_light)),
                    Text(
                      'Давайте создадим вам аккаунт',
                      textAlign: TextAlign.center,
                      style: AppText.button(_light),
                    ),
                    const SizedBox(height: 58),
                    _labeled(
                      'Имя',
                      GlassField(
                        testId: 'register_name',
                        controller: _name,
                        textColor: _light,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.name],
                        validator: validateName,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _labeled(
                      'Электронная почта',
                      GlassField(
                        testId: 'register_email',
                        controller: _email,
                        textColor: _light,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                        validator: validateEmail,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _labeled(
                      'Пароль',
                      GlassField(
                        testId: 'register_password',
                        controller: _password,
                        textColor: _light,
                        obscure: true,
                        autofillHints: const [AutofillHints.newPassword],
                        validator: validatePassword,
                      ),
                    ),
                    const SizedBox(height: 52),
                    PrimaryButton(
                      label: 'Зарегистрироваться',
                      testId: 'register_submit',
                      background: _light,
                      foreground: const Color(0xFF5E604D),
                      shadow: const Color(0xFF4D4D41),
                      loading: _loading,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: 62),
                    const Center(child: DayByLogo(width: 72, color: _light)),
                    const SizedBox(height: 22),
                    Center(
                      child: TestId(
                        'register_login',
                        child: InkWell(
                          onTap: () => context.canPop() ? context.pop() : context.go('/login'),
                          child: Container(
                            padding: const EdgeInsets.only(bottom: 4),
                            decoration: const BoxDecoration(
                              border: Border(bottom: BorderSide(color: Colors.black)),
                            ),
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  const TextSpan(text: 'Уже есть аккаунт?   '),
                                  TextSpan(
                                    text: 'Войти',
                                    style: AppText.mono(Colors.black, weight: FontWeight.w700),
                                  ),
                                ],
                              ),
                              style: AppText.mono(Colors.black, weight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
