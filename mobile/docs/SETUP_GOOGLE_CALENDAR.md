# Setup Google Calendar Integration

This guide walks you through configuring a real Google Calendar sync for Harmony.

---

## Prerequisites

- A Google account
- Access to [Google Cloud Console](https://console.cloud.google.com/)
- Flutter SDK installed and `flutter pub get` run

---

## Step 1 — Create a Google Cloud Project

1. Go to [console.cloud.google.com](https://console.cloud.google.com/).
2. Click **Select a project** → **New project**.
3. Name it `harmony-mobile` and click **Create**.

---

## Step 2 — Enable the Google Calendar API

1. In the sidebar, go to **APIs & Services** → **Library**.
2. Search for **Google Calendar API**.
3. Click **Enable**.

---

## Step 3 — Configure the OAuth Consent Screen

1. Go to **APIs & Services** → **OAuth consent screen**.
2. Select **External** (or Internal if your org uses Google Workspace).
3. Fill in:
   - **App name**: Harmony
   - **User support email**: your email
   - **Developer contact email**: your email
4. Click **Save and Continue**.
5. Under **Scopes**, add:
   - `https://www.googleapis.com/auth/calendar`
6. Add your Google account as a **Test user** (required in External mode before publication).
7. Click **Save and Continue** until done.

---

## Step 4 — Create OAuth 2.0 Credentials (Android)

1. Go to **APIs & Services** → **Credentials** → **Create credentials** → **OAuth 2.0 Client IDs**.
2. Select **Android** as application type.
3. Fill in:
   - **Package name**: `com.example.harmony` (must match `applicationId` in `android/app/build.gradle`)
   - **SHA-1 fingerprint**: run the command below to get it:
     ```bash
     keytool -list -v -keystore ~/.android/debug.keystore \
       -alias androiddebugkey -storepass android -keypass android
     ```
4. Click **Create** and download the `google-services.json` file.

---

## Step 5 — Place `google-services.json`

Place the downloaded file at:

```
mobile/android/app/google-services.json
```

> **Do NOT commit this file to version control.** It is already in `.gitignore`.

---

## Step 6 — Create OAuth 2.0 Credentials (iOS)

1. Back in **Credentials**, create another **OAuth 2.0 Client ID**.
2. Select **iOS** as application type.
3. Fill in:
   - **Bundle ID**: `com.example.harmony` (must match `PRODUCT_BUNDLE_IDENTIFIER` in Xcode)
4. Click **Create** and download the `GoogleService-Info.plist` file.

---

## Step 7 — Place `GoogleService-Info.plist`

Place the downloaded file at:

```
mobile/ios/Runner/GoogleService-Info.plist
```

> **Do NOT commit this file to version control.** It is already in `.gitignore`.

---

## Step 8 — Verify the Reverse Client ID (iOS only)

1. Open `GoogleService-Info.plist` and copy the value of `REVERSED_CLIENT_ID`.
2. In Xcode, open `Runner/Info.plist` and verify the `CFBundleURLSchemes` entry contains that value.  
   If it doesn't, add it:
   ```xml
   <key>CFBundleURLTypes</key>
   <array>
     <dict>
       <key>CFBundleURLSchemes</key>
       <array>
         <string>com.googleusercontent.apps.YOUR_CLIENT_ID</string>
       </array>
     </dict>
   </array>
   ```

---

## Step 9 — Test the Integration

1. Run the app in debug mode: `flutter run`
2. Navigate to **Agenda** → tap the **Google Calendar** sync button.
3. The Google Sign-In sheet should appear.
4. After signing in, events from your Google Calendar should appear in the Harmony agenda.

---

## Environment Variables (CI/CD)

For CI pipelines, do **not** hard-code credentials. Instead:

1. Store `google-services.json` content as a CI secret (e.g., `GOOGLE_SERVICES_JSON`).
2. In your CI script, write it to the correct path before building:
   ```bash
   echo "$GOOGLE_SERVICES_JSON" > android/app/google-services.json
   ```

---

## Troubleshooting

| Issue | Fix |
|---|---|
| `PlatformException: sign_in_failed` | Verify SHA-1 fingerprint in GCP credentials matches your keystore |
| `403 access_denied` | Add your test account under OAuth consent screen → Test users |
| Events not appearing | Check that the `calendar` scope was granted during sign-in |
| `410 Gone` from Calendar API | Automatic — Harmony resets the sync token and performs a full re-sync |
