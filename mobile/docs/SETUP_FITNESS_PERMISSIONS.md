# Setup — Fitness & Activity Permissions

## Android

### Manifest declaration

`ACTIVITY_RECOGNITION` is declared in `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.ACTIVITY_RECOGNITION" />
```

### Runtime request (API 29+)

`ACTIVITY_RECOGNITION` is a "dangerous" permission on Android 10+.
Harmony requests it at runtime via `permission_handler` inside `NativeFitnessRepository.requestActivityPermission()`.

The user sees the system dialog on first launch of the Fitness screen.

### Emulator fallback

Physical step sensors are unavailable on emulators.
`PedometerService.initialize()` catches `MissingPluginException` and sets `_isAvailable = false`.
`NativeFitnessRepository` then falls back to simulated step data (based on current hour).

## iOS

No `NSHealthShareUsageDescription` or HealthKit entitlement is required — the `pedometer` package
targets CoreMotion's step counter only, which does not require HealthKit.

Add `NSMotionUsageDescription` to `Info.plist` if targeting iOS step counting in a future sprint.

## SQLCipher tables (DB v4)

| Table | Purpose |
|---|---|
| `daily_steps` | Daily step records keyed by date |
| `workout_sessions` | Workout sessions with type, duration, distance |

Both tables are created in `DatabaseHelper._onCreate` and migrated in `_onUpgrade` for `oldVersion < 4`.
