# GeoRemind — Flutter rebuild

A Flutter port of the GeoRemind interactive HTML prototype: an AI-powered,
location-aware reminder app. Same screens, same dark purple/emerald visual
language, same "everything is simulated / in-memory" behavior as the
original prototype — now as a real Flutter project you can run on a device
or emulator.

## Run it in VS Code

1. Install the [Flutter SDK](https://docs.flutter.dev/get-started/install) and the **Flutter** + **Dart** VS Code extensions.
2. Open this folder in VS Code (`code georemind_flutter`).
3. Fetch packages:
   ```
   flutter pub get
   ```
4. Pick a device (an emulator, a connected phone, or Chrome for a quick preview) in VS Code's device selector, bottom-right.
5. Run it:
   ```
   flutter run
   ```
   or press **F5**.

## Project layout

```
lib/
  main.dart                    # entry point
  theme/app_theme.dart         # colors, gradients, text styles (from the prototype's CSS vars)
  models/models.dart           # Reminder, Place, ChatEntry, PendingReminder
  state/app_state.dart         # single in-memory store (ChangeNotifier), like the prototype's DB/S
  widgets/common_widgets.dart  # GlassCard, AppButton, PinBadge, ProgressRing, toast, etc.
  screens/
    splash_screen.dart
    root_shell.dart            # bottom nav: Home / Assistant / Reminders / Insights / Settings
    home_screen.dart
    chat_screen.dart, chat_history_screen.dart, conversation_view_screen.dart
    reminders_screen.dart, reminder_details_screen.dart, create_reminder_screen.dart
    places_screen.dart, add_place_screen.dart
    analytics_screen.dart
    settings_screen.dart, settings_detail_screen.dart
    voice_assistant_screen.dart
    notification_preview_screen.dart
    smart_suggestion_screen.dart
```

## What's simulated (same as the HTML prototype)

- **Data** lives only in `AppState` (`lib/state/app_state.dart`) and resets on every fresh launch. Swap in `sqflite`, `Hive`, or a backend API when you're ready to persist it.
- **Voice input** (`voice_assistant_screen.dart`) fakes a transcript instead of using the microphone. For real speech-to-text, add the [`speech_to_text`](https://pub.dev/packages/speech_to_text) package.
- **Geofencing / arrival notifications** (`notification_preview_screen.dart`) is a static mock-up of what a real notification would look like. For the real thing you'll want:
  - [`geolocator`](https://pub.dev/packages/geolocator) or [`geofence_service`](https://pub.dev/packages/geofence_service) for entering/leaving a radius around a saved place
  - [`flutter_local_notifications`](https://pub.dev/packages/flutter_local_notifications) to fire the actual system notification
  - Background execution setup on both Android (foreground service) and iOS (background modes) — geofencing on iOS in particular needs the `Always` location permission
- **"AI" replies** in the chat tab and the smart-suggestion screen are canned strings. Point them at a real LLM (e.g. the Claude API) and your own pattern-detection logic for the real feature.
- **Analytics** numbers on the Insights tab are hard-coded sample data.

## Next steps toward a shippable app

1. Add local persistence (Hive/sqflite) so reminders and places survive a restart.
2. Wire real geolocation + geofencing + local notifications.
3. Add an actual place-search (Google Places / Mapbox) to replace the "Search for a place" stub in `add_place_screen.dart`.
4. Add authentication if you want reminders synced across a user's devices.
5. Replace the canned AI replies with real API calls.
