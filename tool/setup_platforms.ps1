<#
.SYNOPSIS
  Windows PowerShell port of tool/setup_platforms.sh.

.DESCRIPTION
  Generates the android/, ios/ and web/ runner projects and applies every native
  change PlantSense AI needs. The bash version requires bash + python3, which a
  stock Windows install does not have, so this is the equivalent for developers
  building the Android APK from PowerShell.

  Every edit is idempotent, so re-running is safe. Keep this in sync with
  tool/setup_platforms.sh - the README documents what both apply.

.PARAMETER Org
  Reverse-domain org that becomes your Android applicationId / iOS bundle id
  (e.g. com.yourcompany -> com.yourcompany.plantsense_ai). Pick it carefully: it
  is what you register with Firebase and the app stores, and renaming it later
  means re-registering both.

.EXAMPLE
  .\tool\setup_platforms.ps1 com.yourcompany
#>
[CmdletBinding()]
param(
  [Parameter(Mandatory = $true, Position = 0)]
  [string]$Org
)

$ErrorActionPreference = 'Stop'

if ($Org -notmatch '^[A-Za-z][A-Za-z0-9_]*(\.[A-Za-z][A-Za-z0-9_]*)+$') {
  throw "Org '$Org' is not a valid reverse-domain identifier, e.g. com.yourcompany"
}

# Run from the repository root regardless of where the script was invoked from.
Set-Location (Join-Path $PSScriptRoot '..')

function Read-Text {
  param([string]$Path)
  return [System.IO.File]::ReadAllText((Resolve-Path $Path))
}

# Writes UTF-8 with NO byte-order mark. Windows PowerShell's `Set-Content
# -Encoding utf8` adds a BOM, which breaks the Android manifest XML parser.
function Write-TextNoBom {
  param([string]$Path, [string]$Content)
  [System.IO.File]::WriteAllText(
    (Resolve-Path $Path), $Content, (New-Object System.Text.UTF8Encoding($false)))
}

# Replaces the first match and fails if nothing changed.
#
# Failing loudly matters: a silently skipped <queries> patch produces an app that
# builds and runs but whose mic button never recognises anything, which is a far
# more expensive thing to discover later.
function Edit-First {
  param(
    [string]$Text,
    [string]$Pattern,
    [string]$Replacement,
    [string]$Path,
    [string]$What
  )
  $result = [regex]::new($Pattern).Replace($Text, $Replacement, 1)
  if ($result -eq $Text) {
    throw "$Path`: could not $What. Patch it by hand using the 'Platform configuration' section of README.md."
  }
  return $result
}

$gradlePath   = 'android/app/build.gradle.kts'
$manifestPath = 'android/app/src/main/AndroidManifest.xml'
$plistPath    = 'ios/Runner/Info.plist'
$nl           = "`n"

# flutter create will not rewrite the applicationId of an existing project, so
# warn rather than let the org argument be silently ignored.
if (Test-Path $gradlePath) {
  $existing = [regex]::Match((Read-Text $gradlePath),
    'applicationId\s*=\s*"([^"]*)"').Groups[1].Value
  if ($existing -and -not $existing.StartsWith("$Org.")) {
    Write-Warning "android/ already exists with applicationId '$existing', which does not match org '$Org'."
    Write-Warning "flutter create will NOT change it. Delete android/ and ios/ first if you need to switch org."
  }
}

Write-Host "==> Generating android/, ios/ and web/ (org: $Org)" -ForegroundColor Cyan
# --platforms is deliberate: a bare `flutter create .` can clobber lib/main.dart
# and test/widget_test.dart with template versions.
& flutter create --platforms=android,ios,web --org $Org .
if ($LASTEXITCODE -ne 0) { throw 'flutter create failed.' }

foreach ($f in @($manifestPath, $gradlePath)) {
  if (-not (Test-Path $f)) {
    throw "Expected $f after flutter create. The Flutter template may have changed (e.g. a Groovy build.gradle instead of build.gradle.kts). Patch it by hand using README.md."
  }
}

# ---------------------------------------------------------------- manifest ----
Write-Host "==> Patching $manifestPath" -ForegroundColor Cyan
$src = Read-Text $manifestPath

# Checked individually: a single sentinel would skip all of them for anyone who
# had already added just one by hand.
$permissions = @(
  'android.permission.INTERNET',
  'android.permission.CAMERA',
  'android.permission.ACCESS_FINE_LOCATION',
  'android.permission.ACCESS_COARSE_LOCATION',
  'android.permission.POST_NOTIFICATIONS',
  'android.permission.RECORD_AUDIO',
  # flutter_local_notifications reschedules pending reminders after a reboot.
  'android.permission.RECEIVE_BOOT_COMPLETED'
)
$missing = @($permissions | Where-Object { $src -notmatch [regex]::Escape("android:name=`"$_`"") })
if ($missing.Count -gt 0) {
  $block = ($missing | ForEach-Object { "    <uses-permission android:name=`"$_`" />$nl" }) -join ''
  $src = Edit-First $src '(?m)^([ \t]*)<application\b' ($block + '$1<application') `
    $manifestPath 'find the <application> tag to insert permissions before'
}

# Android 11+ package visibility: these let speech_to_text and flutter_tts see
# the on-device recogniser / TTS engine. Without them both silently do nothing.
$queries = [ordered]@{
  'android.speech.RecognitionService' = 'speech_to_text'
  'android.intent.action.TTS_SERVICE' = 'flutter_tts'
}
foreach ($action in $queries.Keys) {
  if ($src -match [regex]::Escape($action)) { continue }
  $pkg = $queries[$action]
  $intent = "        <!-- $pkg -->$nl" +
            "        <intent>$nl" +
            "            <action android:name=`"$action`" />$nl" +
            "        </intent>$nl"
  $src = Edit-First $src '(?m)^([ \t]*<queries>)\r?\n' ('$1' + $nl + $intent) `
    $manifestPath "find <queries> to insert the $pkg intent into"
}

# image_cropper crops the affected area before diagnosis; on Android its activity
# must be declared by the host app.
if ($src -notmatch 'com\.yalantis\.ucrop\.UCropActivity') {
  $ucrop = "        <!-- image_cropper -->$nl" +
           "        <activity$nl" +
           "            android:name=`"com.yalantis.ucrop.UCropActivity`"$nl" +
           "            android:screenOrientation=`"portrait`"$nl" +
           "            android:theme=`"@style/Theme.AppCompat.Light.NoActionBar`" />$nl"
  $src = Edit-First $src '(?m)^([ \t]*)</application>' ($ucrop + '$1</application>') `
    $manifestPath 'find </application> to insert UCropActivity before'
}

# Human-readable launcher name. The <application> tag's android:label is the
# first one in the template (no <activity> carries a label), so replacing the
# first occurrence is safe - and it is verified below rather than assumed.
if ($src -notmatch 'android:label="PlantSense AI"') {
  $src = Edit-First $src 'android:label="[^"]*"' 'android:label="PlantSense AI"' `
    $manifestPath 'find an android:label to set the launcher name on'
}
if ($src -notmatch '(?s)<application\b[^>]*android:label="PlantSense AI"') {
  throw "$manifestPath`: the label was set outside the <application> tag. Fix it by hand (see README.md)."
}

Write-TextNoBom $manifestPath $src
Write-Host '    permissions, speech/TTS queries, UCropActivity, label OK'

# ------------------------------------------------------------------ gradle ----
Write-Host "==> Patching $gradlePath" -ForegroundColor Cyan
$src = Read-Text $gradlePath

# flutter_local_notifications requires core library desugaring. Without it the
# Android build fails outright.
if ($src -notmatch 'isCoreLibraryDesugaringEnabled') {
  $repl = '$1compileOptions {' + $nl +
          '$1    // Required by flutter_local_notifications.' + $nl +
          '$1    isCoreLibraryDesugaringEnabled = true'
  $src = Edit-First $src '(?m)^([ \t]*)compileOptions \{' $repl `
    $gradlePath 'find "compileOptions {" to enable desugaring in'
}

# Firebase Auth requires API 23+. maxOf rather than a literal, so this raises the
# floor without capping it if the template default is already higher.
if ($src -match 'minSdk = flutter\.minSdkVersion') {
  $repl = '// Firebase Auth requires API 23+.' + $nl +
          '        minSdk = maxOf(23, flutter.minSdkVersion)'
  $src = Edit-First $src 'minSdk = flutter\.minSdkVersion' $repl `
    $gradlePath 'raise minSdk to 23'
} elseif ($src -notmatch 'maxOf\(23, flutter\.minSdkVersion\)') {
  throw "$gradlePath`: minSdk was not the expected template value; set it to at least 23 by hand."
}

# The desugaring library itself.
if ($src -notmatch 'desugar_jdk_libs') {
  $src = $src.TrimEnd() + $nl + $nl +
         'dependencies {' + $nl +
         '    // Backports the java.time APIs flutter_local_notifications relies on.' + $nl +
         '    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")' + $nl +
         '}' + $nl
}

Write-TextNoBom $gradlePath $src
Write-Host '    desugaring + minSdk >= 23 OK'

# ------------------------------------------------------------------- plist ----
# iOS cannot be built on Windows, but the file is patched anyway so a checkout
# shared with a macOS machine is already correct.
if (Test-Path $plistPath) {
  Write-Host "==> Patching $plistPath" -ForegroundColor Cyan
  $src = Read-Text $plistPath
  $entries = [ordered]@{
    'NSCameraUsageDescription'            = 'PlantSense uses the camera to photograph plants and soil for analysis.'
    'NSPhotoLibraryUsageDescription'      = 'PlantSense lets you attach plant photos for analysis.'
    'NSLocationWhenInUseUsageDescription' = 'Your location provides accurate local weather and plant-care advice.'
    'NSMicrophoneUsageDescription'        = 'PlantSense uses the microphone for voice input in chat.'
    'NSSpeechRecognitionUsageDescription' = 'PlantSense transcribes your speech so you can dictate messages.'
  }
  $block = ''
  $added = @()
  foreach ($key in $entries.Keys) {
    if ($src -match [regex]::Escape("<key>$key</key>")) { continue }
    $block += "`t<key>$key</key>$nl`t<string>$($entries[$key])</string>$nl"
    $added += $key
  }
  if ($block) {
    # In a well-formed plist the last </dict> is always the top-level one,
    # because any nested dict must close before it.
    $idx = $src.LastIndexOf('</dict>')
    if ($idx -lt 0) { throw "$plistPath`: no </dict> found; is this a valid plist?" }
    $src = $src.Substring(0, $idx) + $block + $src.Substring($idx)
    Write-TextNoBom $plistPath $src
  }
  $addedMsg = if ($added.Count -gt 0) { $added -join ', ' } else { 'nothing (already present)' }
  Write-Host "    added: $addedMsg"
}

Write-Host ''
Write-Host '==> Done. Native config applied.' -ForegroundColor Green
Write-Host @'

Remaining steps that need YOUR credentials (cannot be scripted):

  1. Firebase (only if building with USE_FIREBASE=true):
       dart pub global activate flutterfire_cli
       flutterfire configure
     Then place android/app/google-services.json.

  2. Google Sign-In: register your SHA-1 and SHA-256 in the Firebase console.

  3. Change AppConfig.nominatimUserAgent to a real contact address before
     shipping - the OpenStreetMap usage policy requires it.

Verify, then build:
    flutter analyze
    flutter test
    flutter build apk --debug --dart-define-from-file=dart_defines.json
'@
