# DayBy — планировщик дел

Мобильное приложение на Flutter (iOS и Android) по макету в Figma.

Сейчас готова только интерфейсная часть: данные демонстрационные и хранятся в памяти, вход имитируется. Подключение Firebase (Auth и Firestore) будет следующим этапом.

## Запуск

```bash
flutter pub get
flutter run
```

## Структура

```
lib/
  core/theme/     цвета и шрифты из Figma, светлая и тёмная темы, настройки оформления
  core/widgets/   общие компоненты (логотип, поля, кнопки, кольцо прогресса, нижняя навигация)
  core/router/    маршруты go_router
  features/auth/      заставка, вход, регистрация, восстановление пароля
  features/tasks/     модель задачи, главная, редактор задачи
  features/lists/     мои списки
  features/stats/     статистика
  features/calendar/  календарь с лентой недели
  features/profile/   профиль и оформление (тема, акцентный цвет, размер текста)
```

Стек: Flutter, Riverpod, go_router, google_fonts, shared_preferences.
