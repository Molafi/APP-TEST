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

echo "==> Generating android/ and ios/ (org: $ORG)"
# --platforms is deliberate: a bare `flutter create .` can clobber lib/main.dart
# and test/widget_test.dart with template versions.
flutter create --platforms=android,ios --org "$ORG" .

MANIFEST="android/app/src/main/AndroidManifest.xml"
GRADLE="android/app/build.gradle.kts"
PLIST="ios/Runner/Info.plist"

echo "==> Patching $MANIFEST"
python3 - "$MANIFEST" <<'PY'
import re, sys
path = sys.argv[1]
src = open(path, encoding="utf-8").read()

perms = """    <!-- PlantSense AI -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
    <uses-permission android:name="android.permission.RECORD_AUDIO" />
    <!-- Exact-time reminders on Android 13+ -->
    <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
"""
if "android.permission.CAMERA" not in src:
    src = src.replace("    <application", perms + "    <application", 1)

# speech_to_text needs to see the device speech recognition service.
speech_query = """        <intent>
            <action android:name="android.speech.RecognitionService" />
        </intent>
"""
if "android.speech.RecognitionService" not in src:
    src = src.replace("    <queries>", "    <queries>\n" + speech_query, 1)

# Human-readable launcher name.
src = re.sub(r'android:label="[^"]*"', 'android:label="PlantSense AI"', src, count=1)

open(path, "w", encoding="utf-8").write(src)
print("    permissions + speech query + label OK")
PY

echo "==> Patching $GRADLE"
python3 - "$GRADLE" <<'PY'
import re, sys
path = sys.argv[1]
src = open(path, encoding="utf-8").read()

# flutter_local_notifications requires core library desugaring.
if "isCoreLibraryDesugaringEnabled" not in src:
    src = src.replace(
        "    compileOptions {",
        "    compileOptions {\n"
        "        // Required by flutter_local_notifications.\n"
        "        isCoreLibraryDesugaringEnabled = true",
        1,
    )

# Firebase Auth requires API 23+; Flutter's default floor is lower.
src = re.sub(r"minSdk = flutter\.minSdkVersion", "minSdk = 23", src)

# The desugaring library itself.
if "desugar_jdk_libs" not in src:
    src = src.rstrip() + """

dependencies {
    // Backports the java.time APIs flutter_local_notifications relies on.
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
"""

open(path, "w", encoding="utf-8").write(src)
print("    desugaring + minSdk 23 OK")
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
    # Close out the top-level <dict> last, so append just before it.
    idx = src.rindex("</dict>")
    src = src[:idx] + block + src[idx:]
    open(path, "w", encoding="utf-8").write(src)

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
