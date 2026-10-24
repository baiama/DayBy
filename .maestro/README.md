# Maestro UI tests

```bash
flutter build ios --simulator --debug
xcrun simctl install booted build/ios/iphonesimulator/Runner.app
maestro test .maestro                 # all flows
maestro test .maestro/flows/05_tasks.yaml
```

Ids come from `TestId` (`lib/core/widgets/test_id.dart`), i.e. `Semantics(identifier:)`,
and are matched with `id:`.

| Screen | Ids |
| --- | --- |
| Login | `login_email`, `login_password`, `login_password_toggle`, `login_forgot_password`, `login_submit`, `login_social_google` / `_facebook` / `_x`, `login_register` |
| Registration | `register_name`, `register_email`, `register_password`, `register_password_toggle`, `register_submit`, `register_login` |
| Forgot password | `forgot_email`, `forgot_submit` |
| Tab bar | `tab_home`, `tab_lists`, `tab_stats`, `tab_calendar`, `fab_add_task` |
| Home | `home_progress`, `home_profile`, `home_important_empty` |
| Task row | `task_<id>`, `task_<id>_checkbox` |
| Task editor | `task_editor_title`, `task_editor_date`, `task_editor_important`, `task_editor_list_<listId>`, `task_editor_save` |
| Lists | `list_<listId>`, `list_back`, `list_empty` |
| Statistics | `stats_total`, `stats_done`, `stats_left`, `stats_week_chart` |
| Calendar | `calendar_today`, `calendar_day_0`…`calendar_day_6`, `calendar_prev_week`, `calendar_next_week`, `calendar_selected_date`, `calendar_empty` |
| Profile | `profile_back`, `profile_name`, `profile_email`, `profile_edit_name`, `profile_name_input`, `profile_name_save`, `profile_name_cancel`, `profile_notifications`, `profile_language`, `profile_about`, `profile_logout`, `theme_system` / `_light` / `_dark`, `accent_0`…, `text_size_small` / `_medium` / `_large` |

Notes:
- iOS has no system Back and Flutter fields ignore `hideKeyboard`, so flows tap
  `*_back` ids and use `pressKey: Enter` on fields whose action is "done".
- A task row exposes title and list caption as one node, so title asserts end in `.*`.
- Text typed by flows is Latin: Maestro can't type Cyrillic on Android.
