String? validateEmail(String? v) {
  final value = v?.trim() ?? '';
  if (value.isEmpty) return 'Введите почту';
  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) {
    return 'Неверный формат почты';
  }
  return null;
}

String? validatePassword(String? v) {
  if ((v ?? '').length < 6) return 'Минимум 6 символов';
  return null;
}

String? validateName(String? v) =>
    (v?.trim() ?? '').isEmpty ? 'Введите имя' : null;
