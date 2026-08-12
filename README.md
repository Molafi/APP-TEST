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

## 🚦 Demo mode (default)

The app ships configured to run in **demo mode**: an in-memory auth fake, local
(SharedPreferences) storage, canned AI responses, and a sample location. This
means it launches and works end-to-end **without any Firebase or Groq setup**.

```bash
flutter pub get
flutter gen-l10n            # regenerates lib/l10n/app_localizations*.dart
flutter run                 # DEMO_MODE=true by default
```

> Note: the repo already includes committed, generated-equivalent
> `lib/l10n/app_localizations*.dart` so the project analyzes even before you run
> `flutter gen-l10n`. Running the command regenerates equivalent files.

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
2. **Direct dev client** — only when `ALLOW_DIRECT_GROQ=true` and/or
   `USE_AGENTROUTER=true`, with the key supplied via `--dart-define`. Never
   commit a key.
3. **Demo** — used automatically when neither is configured.

### Vision provider — Claude Opus via AgentRouter (optional)

Llama's vision models are adequate but miss fine detail in leaf photos.
[AgentRouter](https://agentrouter.org) is an **OpenAI-compatible** relay fronting
Claude/GPT/Gemini, so image requests can be answered by **Claude Opus** with no
new transport code — the existing `OpenAiCompatibleGateway` is reused with a
different base URL (`https://agentrouter.org/v1`).

When **both** an AgentRouter key and a Groq key are configured, the app builds a
`ModalityRoutingGateway`:

| Request | Provider | Why |
|---|---|---|
| Has an image | Claude Opus (AgentRouter) | Much better photo understanding |
| Text-only chat | Groq Llama | Faster and cheaper, streams tokens |

With only an AgentRouter key, Claude handles everything. With only Groq, nothing
changes from before.

Model IDs on relays drift, so `AGENTROUTER_VISION_MODEL` is tried first and
`AGENTROUTER_VISION_MODEL_FALLBACK` is used automatically on a 404/400. Verify
the current list with:

```bash
curl https://agentrouter.org/v1/models -H "Authorization: Bearer sk-YOUR_KEY"
```

> Use the OpenAI-compatible `/v1/chat/completions` path, **not** the Anthropic
> `/v1/messages` path — the latter only accepts requests that match the Claude
> Code client wire image and will reject this app.

Server-side, `functions/src/index.ts` performs the same modality routing using
an optional `AGENTROUTER_API_KEY` secret:

```bash
firebase functions:secrets:set AGENTROUTER_API_KEY
```

If that secret does not exist, `agentRouterKey()` returns `""` and vision falls
back to Groq, so existing deployments keep working.

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
| `USE_AGENTROUTER` | `false` | Enable the AgentRouter (Claude) transport |
| `AGENTROUTER_API_KEY` | `""` | Dev-only AgentRouter key (`sk-…`) |
| `AGENTROUTER_BASE_URL` | `""` | Override the relay base URL (blank = `https://agentrouter.org/v1`) |
| `AGENTROUTER_VISION_MODEL` | `claude-opus-4-8` | Vision model for image requests |
| `AGENTROUTER_VISION_MODEL_FALLBACK` | `claude-opus-4-6` | Tried if the primary is unavailable |
| `AGENTROUTER_TEXT_MODEL` | `claude-opus-4-8` | Chat model (only when no Groq key is set) |

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

---

## 📱 Platform configuration

The `android/` and `ios/` folders are generated by `flutter create .`. After
generating, merge the following.

### Android — `android/app/src/main/AndroidManifest.xml`
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
```
(`RECORD_AUDIO` is needed for voice dictation via `speech_to_text`.)
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

Run locally (a Flutter toolchain is required):
```bash
dart format .
flutter pub get
flutter gen-l10n
flutter analyze
flutter test
flutter test integration_test
flutter build apk --release
flutter build ios --release --no-codesign   # on macOS
```

> **These were not executed in the authoring sandbox** (no Flutter SDK and no
> internet were available there). Please run them locally; see "Known
> limitations" for the exact caveat.

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

- The authoring environment had **no Flutter SDK and no internet**, so
  `flutter pub get / analyze / test / build` were **not run here**. Dependency
  versions in `pubspec.yaml` are current-compatible but should be resolved with
  `flutter pub get` locally; minor version pins may need adjustment.
- `android/` and `ios/` runner projects must be generated with `flutter create .`
  and then merged with the platform config above. Several added packages need
  native config: `image_cropper` (Android `UCropActivity`, iOS nothing extra),
  `speech_to_text` (mic + speech permission strings), `flutter_tts`,
  `share_plus`, and `home_widget` (native widget extension — see above).
- French and Spanish are partially translated (common strings) with English
  fallback for the rest; run `flutter gen-l10n` after completing the `.arb` files.
- Streaming through the Cloud Function proxy is not implemented (the proxy
  returns the full response); direct/demo paths stream.
- The home-screen widget requires the native widget files described above.
- The Cloud Function rate limit is in-memory (best-effort per instance).
