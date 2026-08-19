#!/usr/bin/env bash
#
# Generates the android/ and ios/ runner projects and applies every native
# change PlantSense AI needs. Replaces the manual merge checklist in the README.
#
# Usage:
#   tool/setup_platforms.sh com.yourcompany
#
# The org becomes your Android applicationId / iOS bundle id
# (e.g. com.yourcompany.plantsense_ai). Pick it carefully: it is what you
# register with Firebase and the app stores, and renaming it later means
# re-registering both. Re-running the script is safe; every edit is idempotent.

set -euo pipefail

ORG="${1:-}"
if [[ -z "$ORG" ]]; then
  echo "usage: $0 <org>   e.g. $0 com.yourcompany" >&2
  exit 64
fi

cd "$(dirname "$0")/.."

# flutter create will not rewrite the applicationId of an existing project, so
# warn rather than let the org argument be silently ignored.
if [[ -f android/app/build.gradle.kts ]]; then
  EXISTING="$(sed -n 's/.*applicationId = "\(.*\)".*/\1/p' \
    android/app/build.gradle.kts | head -1)"
  if [[ -n "$EXISTING" && "$EXISTING" != "$ORG."* ]]; then
    echo "WARNING: android/ already exists with applicationId '$EXISTING'," >&2
    echo "which does not match org '$ORG'. flutter create will NOT change it." >&2
    echo "Delete android/ and ios/ first to switch org, or edit the ids by hand." >&2
  fi
fi

echo "==> Generating android/, ios/ and web/ (org: $ORG)"
# --platforms is deliberate: a bare `flutter create .` can clobber lib/main.dart
# and test/widget_test.dart with template versions.
# web is included because it needs no native configuration and gives you a
# zero-credential way to run the app (`flutter run -d chrome`).
flutter create --platforms=android,ios,web --org "$ORG" .

MANIFEST="android/app/src/main/AndroidManifest.xml"
GRADLE="android/app/build.gradle.kts"
PLIST="ios/Runner/Info.plist"

for f in "$MANIFEST" "$GRADLE" "$PLIST"; do
  if [[ ! -f "$f" ]]; then
    echo "ERROR: expected $f to exist after flutter create." >&2
    echo "The Flutter template may have changed (e.g. Groovy build.gradle" >&2
    echo "instead of build.gradle.kts). Patch it by hand using the" >&2
    echo "'Platform configuration' section of README.md." >&2
    exit 1
  fi
done

echo "==> Patching $MANIFEST"
python3 - "$MANIFEST" <<'PY'
import re, sys

path = sys.argv[1]
src = open(path, encoding="utf-8").read()


def die(msg):
    # Failing loudly matters: a silently skipped <queries> patch produces an app
    # that builds and runs but whose mic button never recognises anything.
    sys.exit(f"ERROR: {path}: {msg}\nPatch it by hand (see README.md).")


# Each permission is checked individually - a single sentinel would skip all of
# them for anyone who had already added just one by hand.
permissions = [
    "android.permission.INTERNET",
    "android.permission.CAMERA",
    "android.permission.ACCESS_FINE_LOCATION",
    "android.permission.ACCESS_COARSE_LOCATION",
    "android.permission.POST_NOTIFICATIONS",
    "android.permission.RECORD_AUDIO",
    # flutter_local_notifications reschedules pending reminders after a reboot.
    "android.permission.RECEIVE_BOOT_COMPLETED",
]
missing = [p for p in permissions if f'android:name="{p}"' not in src]
if missing:
    block = "".join(
        f'    <uses-permission android:name="{p}" />\n' for p in missing
    )
    src, n = re.subn(r"^([ \t]*)<application\b", block + r"\1<application", src,
                     count=1, flags=re.M)
    if n != 1:
        die("could not find the <application> tag to insert permissions before")

# Android 11+ package visibility: these let speech_to_text and flutter_tts see
# the on-device recogniser / TTS engine. Without them both silently do nothing.
queries = {
    "android.speech.RecognitionService": "speech_to_text",
    "android.intent.action.TTS_SERVICE": "flutter_tts",
}
for action, pkg in queries.items():
    if action in src:
        continue
    intent = (f"        <!-- {pkg} -->\n"
              f"        <intent>\n"
              f'            <action android:name="{action}" />\n'
              f"        </intent>\n")
    src, n = re.subn(r"^([ \t]*<queries>)\n", r"\1\n" + intent, src,
                     count=1, flags=re.M)
    if n != 1:
        die(f"could not find <queries> to insert the {pkg} intent into")

# image_cropper crops the affected area before diagnosis; on Android its
# activity must be declared by the host app.
if "com.yalantis.ucrop.UCropActivity" not in src:
    ucrop = ('        <!-- image_cropper -->\n'
             '        <activity\n'
             '            android:name="com.yalantis.ucrop.UCropActivity"\n'
             '            android:screenOrientation="portrait"\n'
             '            android:theme="@style/Theme.AppCompat.Light.NoActionBar" />\n')
    src, n = re.subn(r"^([ \t]*)</application>", ucrop + r"\1</application>",
                     src, count=1, flags=re.M)
    if n != 1:
        die("could not find </application> to insert UCropActivity before")

# Human-readable launcher name. Scoped to the <application> open tag so it can
# never rename an <activity> if the template ever labels one.
def relabel(match):
    return re.sub(r'android:label="[^"]*"', 'android:label="PlantSense AI"',
                  match.group(0), count=1)

src, n = re.subn(r"<application\b[^>]*>", relabel, src, count=1)
if n != 1:
    die("could not find the <application> open tag to set the label on")
if 'android:label="PlantSense AI"' not in src:
    die("the <application> tag had no android:label to replace")

open(path, "w", encoding="utf-8").write(src)
print("    permissions, speech/TTS queries, UCropActivity, label OK")
PY

echo "==> Patching $GRADLE"
python3 - "$GRADLE" <<'PY'
import re, sys

path = sys.argv[1]
src = open(path, encoding="utf-8").read()


def die(msg):
    sys.exit(f"ERROR: {path}: {msg}\nPatch it by hand (see README.md).")


# flutter_local_notifications requires core library desugaring.
if "isCoreLibraryDesugaringEnabled" not in src:
    src, n = re.subn(
        r"^([ \t]*)compileOptions \{",
        r"\1compileOptions {\n"
        r"\1    // Required by flutter_local_notifications.\n"
        r"\1    isCoreLibraryDesugaringEnabled = true",
        src, count=1, flags=re.M)
    if n != 1:
        die("could not find compileOptions { to enable desugaring in")

# Firebase Auth requires API 23+. maxOf rather than a literal, so this raises
# the floor without capping it if the Flutter template default is already
# higher.
if "minSdk = flutter.minSdkVersion" in src:
    src = src.replace("minSdk = flutter.minSdkVersion",
                      "// Firebase Auth requires API 23+.\n"
                      "        minSdk = maxOf(23, flutter.minSdkVersion)", 1)
elif "maxOf(23, flutter.minSdkVersion)" not in src:
    die("minSdk was not the expected template value; set it to at least 23")

# The desugaring library itself.
if "desugar_jdk_libs" not in src:
    src = src.rstrip() + """

dependencies {
    // Backports the java.time APIs flutter_local_notifications relies on.
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
"""

open(path, "w", encoding="utf-8").write(src)
print("    desugaring + minSdk >= 23 OK")
PY

echo "==> Patching $PLIST"
python3 - "$PLIST" <<'PY'
import sys
path = sys.argv[1]
src = open(path, encoding="utf-8").read()

entries = {
    "NSCameraUsageDescription":
        "PlantSense uses the camera to photograph plants and soil for analysis.",
    "NSPhotoLibraryUsageDescription":
        "PlantSense lets you attach plant photos for analysis.",
    "NSLocationWhenInUseUsageDescription":
        "Your location provides accurate local weather and plant-care advice.",
    "NSMicrophoneUsageDescription":
        "PlantSense uses the microphone for voice input in chat.",
    "NSSpeechRecognitionUsageDescription":
        "PlantSense transcribes your speech so you can dictate messages.",
}

added = []
block = ""
for key, value in entries.items():
    if f"<key>{key}</key>" in src:
        continue
    block += f"\t<key>{key}</key>\n\t<string>{value}</string>\n"
    added.append(key)

if block:
    # In a well-formed plist the last </dict> is always the top-level one,
    # because any nested dict must close before it.
    if "</dict>" not in src:
        sys.exit(f"ERROR: {path}: no </dict> found; is this a valid plist?")
    idx = src.rindex("</dict>")
    src = src[:idx] + block + src[idx:]
    open(path, "w", encoding="utf-8").write(src)

# Fail rather than ship an app that crashes on first camera/mic access.
import plistlib
with open(path, "rb") as fh:
    parsed = plistlib.load(fh)
for key in entries:
    if key not in parsed:
        sys.exit(f"ERROR: {path}: {key} missing after patching.")

print("    added:", ", ".join(added) if added else "nothing (already present)")
PY

echo
echo "==> Done. Native config applied."
cat <<'NEXT'

Remaining steps that need YOUR credentials (cannot be scripted):

  1. Firebase (only if running with USE_FIREBASE=true):
       dart pub global activate flutterfire_cli
       flutterfire configure
     Then place android/app/google-services.json and
     ios/Runner/GoogleService-Info.plist.

  2. Google Sign-In:
       - Android: register your SHA-1 and SHA-256 in the Firebase console.
       - iOS: add the reversed client ID to Info.plist CFBundleURLSchemes.

  3. iOS deployment target: set to 13.0 or higher in Xcode.

  4. Change AppConfig.nominatimUserAgent to a real contact address before
     shipping - the OpenStreetMap usage policy requires it.

Verify with:
    flutter analyze && flutter test && flutter build apk --debug
NEXT
