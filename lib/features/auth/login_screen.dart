import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/divider_label.dart';
import '../../core/widgets/glass_field.dart';
import '../../core/widgets/gradient_scaffold.dart';
import '../../core/widgets/primary_button.dart';
import 'auth_provider.dart';
import 'validators.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _loading = true);
    await action();
    if (mounted) context.go('/home');
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;
    _run(() => ref.read(authProvider.notifier).signIn(_email.text.trim(), _password.text));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GradientScaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 39, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 315),
              child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('DayBy', textAlign: TextAlign.center, style: AppText.logo(c.text)),
                    const SizedBox(height: 120),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          GlassField(
                            controller: _email,
                            hint: 'Почта',
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.email],
                            validator: validateEmail,
                          ),
                          const SizedBox(height: 33),
                          GlassField(
                            controller: _password,
                            hint: 'Пароль',
                            obscure: true,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.password],
                            validator: validatePassword,
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => context.push('/forgot-password'),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                minimumSize: Size.zero,
                              ),
                              child: Text(
                                'забыли пароль?',
                                style: AppText.mono(c.accent, weight: FontWeight.w700),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          PrimaryButton(
                            label: 'Войти в аккаунт',
                            loading: _loading,
                            onPressed: _submit,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 60),
                    DividerLabel(text: 'Способы входа', color: c.accent),
                    const SizedBox(height: 36),
                    Row(
                      children: [
                        for (final (i, icon) in const [
                          FontAwesomeIcons.google,
                          FontAwesomeIcons.facebookF,
                          FontAwesomeIcons.xTwitter,
                        ].indexed) ...[
                          if (i > 0) const SizedBox(width: 27),
                          Expanded(
                            child: _SocialButton(
                              icon: icon,
                              onTap: () => _run(() => ref
                                  .read(authProvider.notifier)
                                  .signInWithProvider(icon.toString())),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 33),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Нет аккаунта?',
                          style: AppText.mono(c.text, weight: FontWeight.w300),
                        ),
                        TextButton(
                          onPressed: () => context.push('/register'),
                          child: Text(
                            'Создать',
                            style: AppText.mono(c.text, weight: FontWeight.w700),
                          ),
                        ),
                      ],
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

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.icon, required this.onTap});

  final FaIconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      height: 59,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9),
        boxShadow: const [
          BoxShadow(color: Color(0x40000000), offset: Offset(0, 4), blurRadius: 4),
        ],
      ),
      child: Material(
        color: c.glass,
        borderRadius: BorderRadius.circular(9),
        child: InkWell(
          borderRadius: BorderRadius.circular(9),
          onTap: onTap,
          child: Center(child: FaIcon(icon, color: c.text, size: 26)),
        ),
      ),
    );
  }
}
