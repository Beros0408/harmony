# Sprint 2 — iOS App Extension Setup (Xcode)

The files under `ios/HarmonyCallDirectoryExtension/` are committed to the repo but the
Xcode target and App Group entitlements must be configured manually (Xcode GUI only — no
CLI equivalent for App Extensions targeting a device).

## Steps

### 1. Add the App Extension target

1. Open `mobile/ios/Runner.xcworkspace` in Xcode.
2. **File → New → Target → Call Directory Extension**.
3. Name: `HarmonyCallDirectoryExtension`.
4. Bundle ID: `com.harmony.harmony.HarmonyCallDirectoryExtension`.
5. Uncheck "Activate scheme" (keep Runner as the active scheme).
6. Delete the generated `CallDirectoryHandler.swift` — replace with the committed
   `HarmonyCallDirectoryHandler.swift` and `SharedRulesStore.swift`.

### 2. Enable App Groups on both targets

For **Runner** and **HarmonyCallDirectoryExtension**:
1. Select the target → **Signing & Capabilities → + Capability → App Groups**.
2. Add group: `group.com.harmony.app.shared`.
3. Xcode will add the entitlement automatically; verify it matches
   `HarmonyCallDirectoryExtension.entitlements` in this repo.

### 3. Link the extension entitlements file

In the extension target → **Build Settings → Code Signing Entitlements**, set:
```
ios/HarmonyCallDirectoryExtension/HarmonyCallDirectoryExtension.entitlements
```

### 4. Add the extension to Runner's Embed App Extensions build phase

Runner target → **Build Phases → Embed Foundation Extensions** → `+` →
select `HarmonyCallDirectoryExtension`.

### 5. Enable the extension on device

**iOS Settings → Phone → Call Blocking & Identification → Harmony** → toggle ON.

## Limitations (documented honestly)

- `CXCallDirectoryProvider` cannot intercept calls in real time — it provides a static
  list of numbers to iOS. The system reloads the list only when `CXCallDirectoryManager`
  calls `reloadExtension`.
- Outgoing call risk detection (Phase 5) is **Flutter-side only** — iOS CallKit does not
  expose an outgoing call interception API to third-party apps.
- XCTest targets are written and committed but must be **run in Xcode** — no CLI runner
  is available without a macOS/simulator environment.
