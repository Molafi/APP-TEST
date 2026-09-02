# 🌱 PlantSense AI

An intelligent plant & soil assistant built with Flutter. Ask plant questions
by text or photo, get AI-powered diagnoses, and receive location-aware weather
and plant-care advice — in **English or Arabic (full RTL)**.

> **AI results are suggestions, not guarantees.** For serious plant disease,
> pesticide, edible-crop, toxicity or agricultural concerns, consult a qualified
> botanist, agronomist, horticulturist, veterinarian, poison-control service or
> local agricultural authority.

---

## ✨ Features

- **Conversational AI chat** — text + image questions, Markdown answers, copy,
  retry, delete, draft preservation, and a weather/location context strip.
- **Photo diagnosis** — live camera or gallery, structured JSON result
  (plant, what I see, issues + likelihood, treatment, prevention, safety notes,
  conservative confidence), guard rails for non-plant / blurry images, save to
  history, and one-tap "Ask a follow-up" into chat.
- **GeoResearch — site & soil survey** — a location-aware ESTIMATED survey
  covering soil (depth/profile, salinity & sodium, N-P-K nutrients, pH, organic
  matter, substances/contaminants, structure), a **topographic desk study**
  (elevation range, slope & aspect, landform, relief, contours, drainage,
  runoff, flood & erosion risk, grading), **groundwater** (water-table depth,
  aquifer type, yield, quality, seasonal variation, well feasibility, drilling
  depth), **site location** (address, elevation, area, boundaries, access), an
  **aerial/satellite view** of the coordinates, and a preliminary
  **building-suitability screening** (bearing capacity, bedrock depth, candidate
  foundation approach, settlement & expansive-soil risk, seismic context,
  excavation, constraints, required studies). Driven by the user's stated
  **purpose and requirements**, and able to use **official Land Department data
  as authoritative** when the user supplies it. Every section names the
  professional study it cannot replace — see
  [GeoResearch scope & limits](#-georesearch-scope--limits).
- **Weather** — Open-Meteo current, 24h hourly and 7-day forecasts with
  metric/imperial units, cached fallback + "last updated"/live-vs-cached badges.
- **Weather-aware plant-care tips** — deterministic rules first (always work
  offline of the AI), so weather never blocks on the AI provider.
- **Location** — GPS (opt-in) + Nominatim reverse geocoding, manual city search
  with debounce & caching, and full permission/denied/services-off handling.
- **Auth** — email/password, Google Sign-In, password reset, email verification,
  account deletion with re-auth handling.
- **Reminders** — optional local watering/fertilizing/repotting/inspection/
  follow-up notifications (permission requested only when enabled).
- **Privacy first** — location, notifications and image retention are all
  opt-in; delete conversations, diagnoses, or your whole account + data.
- **Accessibility** — semantic labels, 48px targets, dynamic text scaling,
  reduced-motion support, and state never conveyed by colour alone.
- **Safe demo mode** — launches and is fully usable with **no credentials**.

---

## 🚦 Demo mode (default) — how to run

The app ships configured to run in **demo mode**: an in-memory auth fake, local
(SharedPreferences) storage, canned AI responses, and a sample location. It works
end-to-end **without any Firebase or Groq setup** — any email/password logs in.

Requires **Flutter 3.35 or newer** (see Quality gates).

```bash
tool/setup_platforms.sh com.yourcompany   # once: creates android/, ios/, web/
flutter pub get
flutter run -d chrome                     # fastest: no Android SDK or Xcode needed
```

`flutter run` with no `-d` targets a connected device or emulator instead.

**Verified working:** the demo flow was driven end to end in a real browser —
onboarding → skip → login → chat, with the AI returning a structured Markdown
answer and the weather context strip populated.

> Note: `lib/l10n/app_localizations*.dart` is committed so the project analyzes
> immediately, and the committed copies are the exact `gen-l10n` output. Because
> `pubspec.yaml` sets `generate: true`, `flutter pub get` regenerates them
> automatically — so they should produce no diff. Edit the `.arb` files, never
> the generated Dart.

---

## 🏗️ Architecture

Feature-first, with a clear split between **presentation**, **application**
(Riverpod state), **domain** (models/rules), **data** (repositories + services),
and shared **core** infrastructure.

```
lib/
├── main.dart / app.dart / firebase_options.dart (placeholder)
├── l10n/                     # ARB + generated-equivalent AppLocalizations (en/ar)
├── core/
│   ├── config/               # Environment (dart-define flags), AppConfig (limits)
│   ├── constants/ errors/ networking/ routing/ theme/ utils/ widgets/
│   └── services/             # ai_gateway (backend/direct/demo), connectivity,
│                             #   permissions, notifications, local cache, prompts
├── features/
│   ├── onboarding/ splash/ auth/ home/
│   ├── chat/ diagnosis/ weather/ location/ reminders/ profile/
│       └── {data, domain, application, presentation}/
└── models/user_profile.dart

functions/                    # Secure Groq proxy (TypeScript, Cloud Functions v2)
firestore.rules / storage.rules / firestore.indexes.json / firebase.json
test/ (unit, providers, widgets, mocks) + integration_test/
```

### AI provider — Groq (OpenAI-compatible)
Chat and image diagnosis run on **[Groq](https://console.groq.com)** via its
OpenAI-compatible Chat Completions API. Text uses `llama-3.3-70b-versatile`;
image diagnosis uses the vision model `meta-llama/llama-4-scout-17b-16e-instruct`
(both overridable — Groq's free lineup changes over time, so verify current
models at [console.groq.com/docs/models](https://console.groq.com/docs/models)).

The `AiGateway` abstraction (`lib/core/services/ai_gateway.dart`) makes the
transport swappable — `OpenAiCompatibleGateway` works with any OpenAI-compatible
provider by changing the base URL.

**Transport selection (`aiGatewayProvider`):**
1. **Backend proxy** (recommended) — `USE_AI_BACKEND=true` + `AI_BACKEND_URL`.
   The app sends a Firebase ID token; the Groq key stays server-side.
2. **Direct dev client** — only when `ALLOW_DIRECT_GROQ=true` and a key is
   supplied via `--dart-define`. Never commit a key.
3. **Demo** — used automatically when neither is configured.

---

## ⚙️ Build configuration (`--dart-define`)

No secrets live in the client. See `.env.example`. Flags read by `Environment`:

| Define | Default | Purpose |
|---|---|---|
| `DEMO_MODE` | `true` | Run entirely on local fakes |
| `USE_FIREBASE` | `false` | Initialise Firebase (auth/Firestore/Storage) |
| `USE_AI_BACKEND` | `true` | Route AI through the Cloud Function proxy |
| `AI_BACKEND_URL` | `""` | Deployed proxy URL (not a secret) |
| `ALLOW_DIRECT_GROQ` | `false` | Dev-only direct Groq access |
| `GROQ_API_KEY` | `""` | Dev-only key (supply at build time only) |
| `GROQ_TEXT_MODEL` | `llama-3.3-70b-versatile` | Chat model |
| `GROQ_VISION_MODEL` | `meta-llama/llama-4-scout-17b-16e-instruct` | Diagnosis (vision) model |

Production run example:
```bash
flutter run \
  --dart-define=DEMO_MODE=false \
  --dart-define=USE_FIREBASE=true \
  --dart-define=USE_AI_BACKEND=true \
  --dart-define=AI_BACKEND_URL=https://us-central1-<project>.cloudfunctions.net/aiProxy
```

**Quick real-AI dev run (no Firebase, direct Groq)** — for local testing only:
1. Copy `dart_defines.example.json` to `dart_defines.json` (git-ignored) and paste
   your Groq key (get one free at https://console.groq.com/keys).
2. Run with:
   ```bash
   flutter run --dart-define-from-file=dart_defines.json
   ```
Demo auth/storage stay local (any login works), but chat + diagnosis use the real
Groq API. Never commit `dart_defines.json`.

---

## 🔥 Firebase setup

1. Create a Firebase project; enable **Authentication** (Email/Password +
   Google), **Cloud Firestore**, and **Cloud Storage**.
2. Install & run the FlutterFire CLI to generate real config:
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure    # overwrites lib/firebase_options.dart (git-ignored)
   ```
3. Deploy rules & indexes:
   ```bash
   firebase deploy --only firestore:rules,storage:rules,firestore:indexes
   ```

### Google Sign-In
- **Android:** add your SHA-1/SHA-256 in the Firebase console; place
  `google-services.json` in `android/app/`.
- **iOS:** add `GoogleService-Info.plist` to `ios/Runner/`, and add the reversed
  client ID URL scheme to `Info.plist` (`CFBundleURLSchemes`).

---

## ☁️ Cloud Function (secure Groq proxy)

Get a free API key at [console.groq.com/keys](https://console.groq.com/keys), then:
```bash
cd functions
npm install
firebase functions:secrets:set GROQ_API_KEY     # server-side only
npm run deploy                                   # deploys the `aiProxy` function
```
The proxy verifies the Firebase ID token, validates content type/size, applies a
per-user rate limit, reads the key from Secret Manager, calls Groq's
OpenAI-compatible Chat Completions API (selecting the vision model when an image
is attached), and returns normalized errors. It never logs message text or image
bytes, and never returns the key.

> The included per-user rate limit is in-memory (best-effort). For strict limits
> across instances, back it with Firestore or a dedicated rate-limiter.

---

## 🌍 Third-party integrations

- **Groq** — AI chat + vision diagnosis via the OpenAI-compatible Chat
  Completions API. Free API key from [console.groq.com](https://console.groq.com);
  used only server-side by the Cloud Function (or a dev-only direct client).
- **Open-Meteo** — no API key required. Fields: current + hourly + daily as in
  `OpenMeteoService`. Responses are parsed defensively (nullable-safe) and cached
  for 30 min (stale after 3h).
- **Nominatim / OpenStreetMap** — reverse geocoding + search. We send a
  descriptive `User-Agent` (`AppConfig.nominatimUserAgent` — **change the contact
  address** before production), rate-limit to ≥1 req/sec, debounce search, and
  cache results for 7 days, per the OSM usage policy.
- **Esri World Imagery** — aerial/satellite tiles for the GeoResearch view. No
  API key. Tile URLs are computed locally from the coordinates with standard Web
  Mercator maths in `AerialImageryService` (note Esri's `{z}/{y}/{x}` ordering);
  the AI never supplies an image URL. The attribution string returned by the
  service **must stay visible** in the UI. Review Esri's terms before commercial
  use and consider a licensed basemap for production.

---

## 🧭 GeoResearch scope & limits

GeoResearch is a **screening and education tool**, not a survey deliverable.
Understand these boundaries before relying on it:

- **Everything is an estimate** unless the user supplied official data. Values
  are qualitative (low/medium/high) or ranges; the prompt forbids inventing
  precise measured figures (ppm, exact pH, kPa bearing values).
- **It cannot replace professional studies.** Each section states its
  counterpart explicitly: a soil-lab test for nutrients/sodium/salinity, a
  **licensed instrument or drone survey** for design-grade topography and
  contours, a **hydrogeological study plus a drilling permit** for groundwater,
  and a **geotechnical investigation** for anything load-bearing.
- **Building suitability is NOT a geotechnical report** and must never be used
  for foundation design. This is enforced in the prompt and surfaced as a
  high-emphasis warning in the UI.
- **Official Land Department data takes precedence.** When the user enables the
  optional land-record form, those values are passed as separate `land*` context
  keys and the prompt treats them as authoritative — the model may not
  contradict or re-estimate them. When no record is supplied the model is
  instructed **not to invent** parcel numbers, areas, zoning or ownership, and
  the report's `dataSources` says findings are location-based estimates only.
- **Provenance is enforced in code, not just in the prompt.** The fields the app
  owns are assigned by `SoilReport.withUserInputs` and overwrite anything the
  model volunteers: the official land record comes only from what the user
  entered (so a paraphrased parcel number can never appear behind the "Official
  record" badge), the aerial tile URL/attribution is always built locally by
  `AerialImageryService`, and `purpose`/`userRequirements` echo the user's own
  input. Free-text values are sanitised (newlines/commas neutralised, length
  capped) before being flattened into the context line, and requirements are sent
  as context only — never in instruction position.
- **Risk levels fail safe.** Unrecognised risk values parse to `null` and the
  field is hidden, rather than degrading to a reassuring green "Low".
- **Aerial imagery is undated context**, not a current georeferenced aerial
  survey, and plot boundaries shown are not cadastral.

---

## 📱 Platform configuration

The `android/` and `ios/` folders are not committed. Generate them and apply
every native change below in one step:

```bash
tool/setup_platforms.sh com.yourcompany          # macOS / Linux / Git Bash
```

```powershell
.\tool\setup_platforms.ps1 com.yourcompany       # Windows PowerShell
```

Both scripts apply the same edits and are kept in sync; the PowerShell port
exists because the bash version needs `python3`, which a stock Windows install
does not have.

This runs `flutter create --platforms=android,ios --org <org>` (scoped with
`--platforms` so it can't clobber `lib/main.dart` or `test/widget_test.dart`),
then patches the manifest, Gradle config and `Info.plist`. It is idempotent, so
re-running it is safe. Pick the org carefully — it becomes your
`applicationId`/bundle id, which is what you register with Firebase and the app
stores.

The script applies the following; this section is kept as the reference for what
it does and for anyone merging by hand.

### Android — `android/app/src/main/AndroidManifest.xml`
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
```
(`RECORD_AUDIO` is needed for voice dictation via `speech_to_text`;
`RECEIVE_BOOT_COMPLETED` lets pending reminders survive a reboot.)

Android 11+ package visibility — inside `<queries>`, or `speech_to_text` and
`flutter_tts` silently do nothing:
```xml
<intent><action android:name="android.speech.RecognitionService" /></intent>
<intent><action android:name="android.intent.action.TTS_SERVICE" /></intent>
```

`image_cropper` needs its activity declared inside `<application>`:
```xml
<activity
    android:name="com.yalantis.ucrop.UCropActivity"
    android:screenOrientation="portrait"
    android:theme="@style/Theme.AppCompat.Light.NoActionBar" />
```
- `minSdkVersion 23` (Firebase Auth), `compileSdk`/`targetSdk` = latest stable.
- **Enable core library desugaring** (required by `flutter_local_notifications`).
  In `android/app/build.gradle.kts`, inside `compileOptions { ... }` add:
  ```kotlin
  isCoreLibraryDesugaringEnabled = true
  ```
  and add a dependencies block:
  ```kotlin
  dependencies {
      coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
  }
  ```
- Use the modern photo picker (image_picker handles this) — no legacy broad
  storage permissions.
- Do **not** enable cleartext traffic.
- **`android/gradle.properties`** needs:
  ```properties
  kotlin.jvm.target.validation.mode=warning
  ```
  Several plugins (`flutter_timezone`, `flutter_tts`, `share_plus`,
  `speech_to_text`) still pin their Kotlin `jvmTarget` to 1.8 while AGP compiles
  their Java at 11. Since Kotlin 1.9 that mismatch is a hard error and the build
  fails with *"Inconsistent JVM-target compatibility detected for tasks
  `compileDebugJavaWithJavac` (11) and `compileDebugKotlin` (1.8)"*. 1.8 bytecode
  runs fine on an 11 target, so a warning is the correct severity — remove the
  line once those plugins target 11+.

### iOS — `ios/Runner/Info.plist`
```xml
<key>NSCameraUsageDescription</key>
<string>PlantSense uses the camera to photograph plants and soil for analysis.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>PlantSense lets you attach plant photos for analysis.</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>Your location provides accurate local weather and plant-care advice.</string>
<key>NSMicrophoneUsageDescription</key>
<string>PlantSense uses the microphone for voice input in chat.</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>PlantSense transcribes your speech so you can dictate messages.</string>
```
- iOS deployment target 13+; add the Google Sign-In URL scheme; enable the
  Notifications capability if using reminders.

---

## 🌐 Localization workflow

- Source of truth: `lib/l10n/app_en.arb` and `app_ar.arb`.
- Regenerate: `flutter gen-l10n` (config in `l10n.yaml`).
- Add a string to both ARB files, then use `AppLocalizations.of(context).<key>`.
- Language can be changed at runtime (Profile → Settings) without restart; device
  locale is used until a preference is saved. Arabic renders RTL automatically.

---

## 🧪 Testing

```bash
flutter test                         # unit + provider + widget tests
flutter test integration_test        # demo end-to-end flow (mocked services)
```
Covered: diagnosis JSON parsing (incl. malformed + fenced), weather
parsing + missing fields, plant-care rules, retry/backoff, error mapping,
validation, unit conversion, chat provider (send/fail/retry/delete, duplicate
prevention), login widget (+ Arabic RTL), empty chat. Tests use fakes/mocks and
never contact real Groq, Open-Meteo, Nominatim or production Firebase.

### Firebase Emulator Suite (optional)
```bash
firebase emulators:start   # auth, firestore, storage, functions
```

---

## ✅ Quality gates

**Verified on Flutter 3.35.1 / Dart 3.9.0:** `flutter pub get` resolves,
`flutter analyze` reports no issues, and all **52 tests pass**.

```bash
flutter pub get              # also runs gen-l10n (generate: true)
flutter analyze              # verified clean
flutter test                 # verified: 52 passing
```

Still requires the platform projects (`tool/setup_platforms.sh`) plus an Android
SDK / Xcode:
```bash
flutter test integration_test        # needs a device or emulator
flutter build apk --release
flutter build ios --release --no-codesign   # on macOS
```

> **Minimum toolchain is Flutter 3.35.** `settings_screen.dart` uses the
> `RadioGroup` widget, which shipped in 3.35 (`Radio.groupValue`/`onChanged`
> were deprecated after 3.32). Earlier SDKs will not compile.

---

## 🌟 Additional features

- **Streaming AI replies** — chat answers stream in token-by-token (Groq SSE;
  simulated in demo). The backend proxy path returns the full text and emits
  once (streaming through the proxy is a future enhancement).
- **Voice & audio** — dictate messages with the mic (speech_to_text) and read AI
  replies aloud (flutter_tts). Voice locale follows the app language.
- **Native share** — diagnosis summaries open the OS share sheet (share_plus).
- **Image cropping** — crop to the affected area before diagnosis (image_cropper).
- **Groq model fallback** — a backup model is tried automatically if the primary
  one is retired, on both the client and the Cloud Function.
- **My Plants journal** — track plants (species, indoor/outdoor, notes), mark
  watered, ask the AI about a specific plant, and generate a weather-aware
  watering reminder.
- **Multiple conversations** — create/rename/delete conversations; each is
  stored separately (local or `users/{uid}/chats/{chatId}`).
- **Data export** — "Download my data" builds a JSON of your profile,
  conversations, diagnoses, plants and reminders and shares it.
- **Opt-in analytics & crash reporting** — off by default; enable in Settings.
  Backed by Firebase Analytics/Crashlytics only when Firebase is configured, and
  never records message text, images or exact location.

### 🌐 Languages
Supported locales: **English, Arabic (RTL), French, Spanish**. French and
Spanish ship with the most common strings translated and **fall back to English**
for any not-yet-translated key; run `flutter gen-l10n` to regenerate full classes
from the `app_*.arb` files. Change language in Settings without a restart.

### 🏠 Home-screen widget (native setup required)
The Dart side (`HomeWidgetService`) publishes city/temperature/next-watering via
the `home_widget` package. To finish it after `flutter create .`:
- **Android:** add an `AppWidgetProvider` named `PlantSenseWidgetProvider`, its
  `res/xml/*_info.xml`, a widget layout, and register the receiver in
  `AndroidManifest.xml`.
- **iOS:** add a WidgetKit extension named `PlantSenseWidget` and an app group so
  the widget can read the shared data.
See the [home_widget docs](https://pub.dev/packages/home_widget) for the exact
native files.

---

## 🔒 Privacy & data retention

- Location, notifications, image retention and **analytics are OFF by default**.
- With retention off, diagnosis images are used for analysis and then discarded
  (never stored). With it on, compressed JPEGs go to `users/{uid}/diagnoses/`.
- Raw base64 images are never stored in Firestore.
- Delete conversations/diagnoses any time; "Delete all my data" and "Delete
  account" remove chats, diagnoses, reminders, plants, cached data and owned
  Storage files. Deletion is only reported as complete once it has finished.
- "Download my data" exports everything as JSON for portability.
- No background location. Analytics/crash reporting is opt-in and never includes
  message text, images or exact location.

---

## 🛠️ Troubleshooting

- **Google Sign-In fails (Android):** ensure SHA-1/256 are registered and
  `google-services.json` is present.
- **Camera preview black / unavailable:** grant camera permission; use the
  gallery fallback; some emulators lack a camera (handled gracefully).
- **Weather won't load:** check connectivity; the app shows cached data with a
  "last updated" time. Nominatim errors fall back to manual city entry.
- **Account deletion says re-auth required:** log in again, then retry (Firebase
  requires recent auth for deletion).
- **Build can't find `AppLocalizations`:** run `flutter gen-l10n`.

---

## ⚠️ Known limitations

- `android/` and `ios/` runner projects are not committed — run
  `tool/setup_platforms.sh <org>` first. It handles permissions, core library
  desugaring, `minSdk 23` and the iOS usage strings. Still manual afterwards:
  Firebase config files, Google Sign-In SHA-1/SHA-256 + URL scheme, the iOS
  deployment target, and `home_widget`'s native widget extension (see above).
- **No release build has been produced yet.** `analyze` and `test` are verified,
  but `flutter build apk/ios` has never run, so Gradle/CocoaPods dependency
  conflicts between the 20+ plugins are still unproven. Expect to resolve some.
- `flutter pub outdated` reports **73 packages behind** their latest majors
  (`firebase_*` 4.x→6.x, `flutter_riverpod` 2.6→3.4,
  `flutter_local_notifications` 17→22, `permission_handler` 11→13). Everything
  resolves and passes today, but this is real upgrade debt.
- Opt-in analytics is **plumbing only**: the toggle and `TelemetryService`
  exist, but `logEvent`/`recordError` are never called anywhere and Crashlytics
  is not installed as a `FlutterError.onError` handler. Enabling it collects
  nothing.
- Reminder notification bodies are **hardcoded English**
  (`reminder_provider.dart`), so they don't follow the app language.
- `NotificationService.scheduleReminder` **swallows all failures** into a
  `debugPrint`, so a rejected schedule still shows as an enabled reminder.
- "Delete all my data" has two edge cases: a conversation with **>500 messages**
  exceeds Firestore's `WriteBatch` limit, and if the local `conversations` index
  is ever corrupt, `LocalConversationsRepository.list()` returns `[]` and the
  orphaned `chat_messages_<id>` blobs cannot be reached (`LocalCacheService` has
  no key enumeration, so there is no prefix sweep).
- The four bug fixes in this branch **ship without regression tests**. Deletion,
  weekly recurrence and composer teardown have no coverage; the empty-state
  overflow is only covered incidentally by the existing widget tests.
- There is **no profile editing UI** despite the `editProfile`/`displayName`
  strings; the Profile "Edit profile" tile opens Settings. The Terms of Service
  tile also opens the Privacy screen — there is no ToS content.
- French and Spanish are partially translated (common strings) with English
  fallback for the rest; run `flutter gen-l10n` after completing the `.arb` files.
- Streaming through the Cloud Function proxy is not implemented (the proxy
  returns the full response); direct/demo paths stream.
- The home-screen widget requires the native widget files described above.
- The Cloud Function rate limit is in-memory (best-effort per instance).
