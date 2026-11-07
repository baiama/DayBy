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
| Onboarding | `onboarding_skip`, `onboarding_next`, `onboarding_page_0`…`_2` |
| Home | `home_progress`, `home_search`, `home_profile`, `home_important_empty`, `home_empty`, `home_all_done` |
| Task row | `task_<id>`, `task_<id>_checkbox` |
| Task details | `task_detail_back`, `task_detail_title`, `task_detail_checkbox`, `task_detail_important`, `task_detail_edit`, `task_detail_delete`, `task_delete_confirm`, `task_delete_cancel`, `task_detail_date`, `task_detail_list`, `task_detail_list_<listId>` / `_none`, `task_detail_reminder`, `task_detail_repeat`, `task_detail_repeat_<none/daily/weekdays/weekly/monthly>`, `task_detail_note`, `subtask_add`, `subtask_<id>`, `subtask_<id>_checkbox` |
| Task editor | `task_editor_title`, `task_editor_date`, `task_editor_important`, `task_editor_list_<listId>`, `task_editor_save` |
| Lists | `list_<listId>`, `lists_new`, `lists_empty`, `list_back`, `list_header`, `list_empty`, `list_empty_action`, `list_filter_all` / `_active` / `_done`, `list_filter_empty`, `list_menu`, `list_menu_edit` / `_clear` / `_delete`, `list_delete_confirm`, `list_delete_cancel`, `list_editor_name`, `list_editor_emoji_<n>`, `list_editor_save` |
| Search | `search_back`, `search_input`, `search_filter_important`, `search_filter_active`, `search_filter_list_<listId>`, `search_idle`, `search_empty`, `search_count` |
| Settings | `settings_back`, `settings_reminders`, `settings_sound`, `settings_digest`, `settings_digest_time`, `settings_week_monday` / `_sunday`, `settings_show_completed`, `settings_default_reminder`, `settings_language`, `settings_language_ru` / `_en`, `settings_clear_done`, `settings_clear_confirm`, `settings_clear_cancel`, `settings_about` |
| About | `about_back`, `about_version`, `about_rate`, `about_feedback`, `about_privacy`, `about_terms` |
| Statistics | `stats_total`, `stats_done`, `stats_left`, `stats_week_chart` |
| Calendar | `calendar_today`, `calendar_day_0`…`calendar_day_6`, `calendar_prev_week`, `calendar_next_week`, `calendar_selected_date`, `calendar_empty`, `calendar_empty_action` |
| Profile | `profile_back`, `profile_name`, `profile_email`, `profile_edit_name`, `profile_name_input`, `profile_name_save`, `profile_name_cancel`, `profile_notifications`, `profile_language`, `profile_settings`, `profile_about`, `profile_logout`, `theme_system` / `_light` / `_dark`, `accent_0`…, `text_size_small` / `_medium` / `_large` |

Notes:
- iOS has no system Back and Flutter fields ignore `hideKeyboard`, so flows tap
  `*_back` ids and use `pressKey: Enter` on fields whose action is "done".
- A task row exposes title and list caption as one node, so title asserts end in `.*`.
- Text typed by flows is Latin: Maestro can't type Cyrillic on Android.
