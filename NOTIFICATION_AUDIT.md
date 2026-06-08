# Notification System Audit

## Current Status: ⚠️ FOREGROUND ONLY

### What Works ✅

1. **UI Switches**: All 4 notification toggles in Settings work
   - Results
   - My Numbers  
   - Daily Insight
   - Weekly Summary

2. **Preferences Saved**: User preferences are correctly saved to SharedPreferences via `InsightService`

3. **Permission Handling**: Proper permission requests for:
   - Android 13+ (`POST_NOTIFICATIONS`)
   - iOS (alert, sound)

4. **Notification Service**: `NotificationService` can display notifications:
   - `showResultReady(count)` - Result ready notifications
   - `showDailyInsight(body)` - Daily insight
   - `showWeeklySummary(body)` - Weekly summary

5. **Logic**: `ResultNotificationService.checkAndNotify()` has complete logic:
   - Checks user preferences
   - Respects daily cap (2 notifications/day)
   - Generates localized content
   - Marks picks as notified

### What's Missing ❌

**CRITICAL: No Background Scheduling**

The notifications are only checked when:
- User opens the app (HomeScreen.initState)
- User refreshes the home screen

**This means:**
- Notifications will NEVER fire if the app is not opened
- Daily Insight won't fire at 9 AM unless user opens app
- Weekly Summary won't fire on Sunday unless user opens app
- Result notifications only fire when user manually opens app

## Code Locations

### Settings UI
- `lib/screens/settings_screen.dart` - Toggle switches
- `lib/services/insight_service.dart` - Preference storage

### Notification Logic
- `lib/services/notification_service.dart` - Display notifications
- `lib/services/result_notification_service.dart` - Check & notify logic
- `lib/screens/home_screen.dart` - Triggers checkAndNotify() on app open

### Initialization
- `lib/main.dart` - Calls `NotificationService.instance.init()`
- `android/app/src/main/AndroidManifest.xml` - Has POST_NOTIFICATIONS permission

## Solutions

### Option 1: Workmanager (Recommended)
Add `workmanager` package for periodic background tasks:
- Schedule daily check at 9 AM for Daily Insight
- Schedule weekly check on Sunday for Weekly Summary
- Schedule periodic checks (every 6-12 hours) for Result notifications

**Pros:**
- Cross-platform (Android & iOS)
- Survives app restarts
- Battery efficient

**Cons:**
- iOS has strict background limits
- Not guaranteed to run exactly on time

### Option 2: Scheduled Notifications
Use `flutter_local_notifications` zonedSchedule:
- Pre-schedule notifications at fixed times
- Re-schedule after notification fires

**Pros:**
- No background task needed
- More reliable timing

**Cons:**
- Need to regenerate content at schedule time (can't be dynamic)
- Must re-schedule after each notification

### Option 3: Hybrid Approach
- Use workmanager for Result/My Numbers (needs fresh data)
- Use zonedSchedule for Daily Insight/Weekly Summary (content can be pre-generated)

## Recommended Implementation

### Phase 1: Add Background Task Runner
```yaml
# pubspec.yaml
dependencies:
  workmanager: ^0.5.2
```

### Phase 2: Create Background Task
```dart
// lib/services/background_task_service.dart
class BackgroundTaskService {
  static void callbackDispatcher() {
    Workmanager().executeTask((task, inputData) async {
      await ResultNotificationService.instance.checkAndNotify();
      return Future.value(true);
    });
  }

  static Future<void> init() async {
    await Workmanager().initialize(callbackDispatcher);
  }

  static Future<void> scheduleNotificationCheck() async {
    // Daily check at 9 AM
    await Workmanager().registerPeriodicTask(
      'notification-check',
      'notificationCheck',
      frequency: Duration(hours: 24),
    );
  }

  static Future<void> cancelNotificationCheck() async {
    await Workmanager().cancelByUniqueName('notification-check');
  }
}
```

### Phase 3: Hook Up Settings
When user toggles notification:
- If ANY notification enabled → schedule background task
- If ALL notifications disabled → cancel background task

## Debug Logging Needed

Add logs to track:
1. Permission request → granted/denied
2. Background task registered → success/fail
3. Background task fired → timestamp
4. Notification check started → timestamp
5. Notification sent → type, count
6. Notification cancelled → reason

## Testing Plan

1. **Test Daily Insight**:
   - Enable Daily Insight
   - Close app completely
   - Wait until next day 9 AM
   - Check if notification appears

2. **Test Weekly Summary**:
   - Enable Weekly Summary
   - Close app
   - Wait until Sunday 9 AM
   - Check if notification appears

3. **Test Result Notification**:
   - Save a pick with upcoming draw date
   - Enable Results & My Numbers
   - Close app
   - Wait for draw date to pass
   - Open app (should trigger check)
   - Verify notification

## Current Workaround

**For users to receive notifications NOW:**
1. Enable desired notifications in Settings
2. Open the app at least once per day
3. Notifications will fire during that app session (if conditions met)

This is why you're not seeing notifications - the app needs to be opened for the check to run!
