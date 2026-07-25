import 'app_localizations.dart';

/// English translations (generated-equivalent).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([super.locale = 'en']);

  @override
  String get appTitle => 'PlantSense AI';
  @override
  String get tagline => 'Your intelligent plant & soil assistant';
  @override
  String get retry => 'Retry';
  @override
  String get cancel => 'Cancel';
  @override
  String get confirm => 'Confirm';
  @override
  String get save => 'Save';
  @override
  String get delete => 'Delete';
  @override
  String get close => 'Close';
  @override
  String get next => 'Next';
  @override
  String get back => 'Back';
  @override
  String get skip => 'Skip';
  @override
  String get getStarted => 'Get started';
  @override
  String get openSettings => 'Open settings';
  @override
  String get loading => 'Loading…';
  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get navChat => 'Chat';
  @override
  String get navDiagnose => 'Diagnose';
  @override
  String get navWeather => 'Weather';
  @override
  String get navProfile => 'Profile';

  @override
  String get offlineBanner =>
      "You're offline. Showing cached data where available.";
  @override
  String lastUpdated(String time) => 'Last updated $time';
  @override
  String get cachedData => 'Cached data';
  @override
  String get liveData => 'Live';

  @override
  String get onboardingTitle1 => 'Ask about any plant';
  @override
  String get onboardingBody1 =>
      'Chat with PlantSense AI about plants, pests and soil — using text or photos.';
  @override
  String get onboardingTitle2 => 'Diagnose from a photo';
  @override
  String get onboardingBody2 =>
      'Photograph a leaf, pest or soil issue and get structured, cautious guidance.';
  @override
  String get onboardingTitle3 => 'Weather-aware care';
  @override
  String get onboardingBody3 =>
      'Share your location to get local weather and tailored plant-care tips.';
  @override
  String get onboardingTitle4 => "You're in control";
  @override
  String get onboardingBody4 =>
      'AI results may be inaccurate. You control permissions, image retention and your data.';

  @override
  String get login => 'Log in';
  @override
  String get register => 'Create account';
  @override
  String get email => 'Email';
  @override
  String get password => 'Password';
  @override
  String get confirmPassword => 'Confirm password';
  @override
  String get displayName => 'Display name';
  @override
  String get forgotPassword => 'Forgot password?';
  @override
  String get continueWithGoogle => 'Continue with Google';
  @override
  String get noAccountPrompt => 'New here? Create an account';
  @override
  String get haveAccountPrompt => 'Already have an account? Log in';
  @override
  String get sendResetLink => 'Send reset link';
  @override
  String get resetLinkSent =>
      'If that email exists, a reset link has been sent.';
  @override
  String get verifyEmailNotice => 'Please verify your email address.';
  @override
  String get showPassword => 'Show password';
  @override
  String get hidePassword => 'Hide password';

  @override
  String get emailRequired => 'Please enter your email';
  @override
  String get emailInvalid => 'Enter a valid email address';
  @override
  String get emailTooLong => 'Email is too long';
  @override
  String get passwordRequired => 'Please enter a password';
  @override
  String get passwordTooShort => 'Password must be at least 8 characters';
  @override
  String get passwordTooLong => 'Password is too long';
  @override
  String get passwordWeak => 'Use at least one letter and one number';
  @override
  String get passwordMismatch => 'Passwords do not match';
  @override
  String get nameRequired => 'Please enter a display name';
  @override
  String get nameTooLong => 'Display name is too long';

  @override
  String get chatTitle => 'PlantSense chat';
  @override
  String get chatEmptyTitle => 'Ask your first question';
  @override
  String get chatEmptyBody => 'Tap a suggestion below or type your own question.';
  @override
  String get composerHint => 'Ask about your plant…';
  @override
  String get send => 'Send';
  @override
  String get attachImage => 'Attach image';
  @override
  String get removeImage => 'Remove image';
  @override
  String get voiceInput => 'Voice input';
  @override
  String get readAloud => 'Read aloud';
  @override
  String get stopAudio => 'Stop';
  @override
  String get fromCamera => 'Take a photo';
  @override
  String get fromGallery => 'Choose from gallery';
  @override
  String get copy => 'Copy';
  @override
  String get copied => 'Copied to clipboard';
  @override
  String get deleteConversation => 'Delete conversation';
  @override
  String get deleteConversationConfirm =>
      'Delete this conversation? This cannot be undone.';
  @override
  String get messageFailed => 'Failed to send. Tap to retry.';
  @override
  String get sending => 'Sending…';
  @override
  String get typing => 'PlantSense is thinking…';
  @override
  String charactersRemaining(int count) => '$count characters left';
  @override
  String get aiDisclaimerShort => 'AI suggestions may be inaccurate.';
  @override
  String get contextUnavailable => 'Location/weather context unavailable';

  @override
  String get starterYellowLeaves =>
      "Why are my plant's leaves turning yellow?";
  @override
  String get starterWaterBasil => 'How often should I water my basil?';
  @override
  String get starterSucculentSoil =>
      'What soil mix should I use for succulents?';
  @override
  String get starterIdentifyPest => 'Can you identify this pest?';
  @override
  String get starterTransplant => "Is today's weather safe for transplanting?";
  @override
  String get starterClayDrainage => 'How can I improve drainage in clay soil?';

  @override
  String get diagnoseTitle => 'Diagnose';
  @override
  String get cameraInitializing => 'Starting camera…';
  @override
  String get cameraPermissionTitle => 'Camera access needed';
  @override
  String get cameraPermissionBody =>
      'PlantSense uses your camera to photograph plants and soil for analysis. Photos are only used for the diagnosis you request.';
  @override
  String get cameraPermissionDeniedBody =>
      'Camera permission was denied. You can still pick a photo from your gallery.';
  @override
  String get cameraUnavailable => 'No camera is available on this device.';
  @override
  String get captureFailed => "Couldn't capture the photo. Please try again.";
  @override
  String get allowCamera => 'Allow camera';
  @override
  String get flashOn => 'Flash on';
  @override
  String get flashOff => 'Flash off';
  @override
  String get switchCamera => 'Switch camera';
  @override
  String get capture => 'Capture';
  @override
  String get retake => 'Retake';
  @override
  String get cropImage => 'Crop';
  @override
  String get confirmPhoto => 'Use this photo';
  @override
  String get analyzing => 'Analyzing your photo…';
  @override
  String get cancelAnalysis => 'Cancel analysis';
  @override
  String get diagnosisPlant => 'Plant / subject';
  @override
  String get diagnosisWhatISee => 'What I see';
  @override
  String get diagnosisIssue => 'Issues detected';
  @override
  String get diagnosisTreatment => 'Step-by-step treatment';
  @override
  String get diagnosisPrevention => 'Prevention tips';
  @override
  String get diagnosisSafety => 'Safety notes';
  @override
  String get diagnosisConfidence => 'Confidence';
  @override
  String get confidenceLow => 'Low';
  @override
  String get confidenceMedium => 'Medium';
  @override
  String get confidenceHigh => 'High';
  @override
  String get likelihoodLow => 'Low likelihood';
  @override
  String get likelihoodMedium => 'Medium likelihood';
  @override
  String get likelihoodHigh => 'High likelihood';
  @override
  String get needMoreInfo => 'I need a clearer image';
  @override
  String get notPlantRelated =>
      "This doesn't look plant-related. Try a photo of a plant, leaf, pest or soil.";
  @override
  String get poorImageQuality =>
      'The image is blurry or unclear. Try again in good light, filling the frame with the affected area.';
  @override
  String get saveDiagnosis => 'Save diagnosis';
  @override
  String get diagnosisSaved => 'Diagnosis saved';
  @override
  String get askFollowUp => 'Ask a follow-up';
  @override
  String get shareSummary => 'Share summary';
  @override
  String get diagnosisHistory => 'Diagnosis history';
  @override
  String get diagnosisHistoryEmpty => 'No saved diagnoses yet';
  @override
  String get diagnosisHistoryEmptyBody =>
      'Diagnose a plant to build your history.';
  @override
  String get aiDisclaimerLong =>
      'PlantSense AI provides suggestions, not guarantees. For serious plant disease, pesticide, edible-crop, toxicity or agricultural concerns, consult a qualified botanist, agronomist, horticulturist, veterinarian, poison-control service or local agricultural authority.';

  @override
  String get weatherTitle => 'Weather';
  @override
  String get currentWeather => 'Current weather';
  @override
  String feelsLike(String value) => 'Feels like $value';
  @override
  String get humidity => 'Humidity';
  @override
  String get uvIndex => 'UV index';
  @override
  String get precipitation => 'Precipitation';
  @override
  String get hourlyForecast => 'Hourly forecast';
  @override
  String get sevenDayForecast => '7-day forecast';
  @override
  String get plantCareTips => 'Plant-care tips';
  @override
  String rainChance(int value) => '$value% rain';
  @override
  String get weatherUnavailable => 'Weather is unavailable right now.';
  @override
  String get pullToRefresh => 'Pull to refresh';
  @override
  String get tipHighUv =>
      'UV is high today — move sensitive plants out of direct afternoon sun.';
  @override
  String get tipNoRain =>
      'No rain expected for several days — check container moisture more often.';
  @override
  String get tipHighHumidity =>
      'High humidity may raise fungal risk — improve airflow and avoid wetting leaves at night.';
  @override
  String get tipFreezing =>
      'Freezing temperatures possible — protect sensitive outdoor plants.';
  @override
  String get tipHot =>
      "It's hot — water early or late and provide shade for tender plants.";
  @override
  String get tipMild => 'Mild conditions — a good day for routine plant care.';

  @override
  String get locationTitle => 'Location';
  @override
  String get useMyLocation => 'Use my location';
  @override
  String get searchCity => 'Search for a city';
  @override
  String get locationRationale =>
      'Sharing your location lets PlantSense give accurate local weather and climate-aware plant-care advice.';
  @override
  String get locationDeniedBody =>
      'Location permission was denied. You can search for a city instead.';
  @override
  String get locationServicesOff =>
      'Location services are turned off. Turn them on or search for a city.';
  @override
  String get geocodeFailed =>
      "Couldn't determine your city. Try searching manually.";
  @override
  String get selectCity => 'Select a city';
  @override
  String get noResults => 'No matching places found';

  @override
  String get profileTitle => 'Profile';
  @override
  String get editProfile => 'Edit profile';
  @override
  String get language => 'Language';
  @override
  String get theme => 'Theme';
  @override
  String get themeSystem => 'System';
  @override
  String get themeLight => 'Light';
  @override
  String get themeDark => 'Dark';
  @override
  String get units => 'Units';
  @override
  String get unitsMetric => 'Metric (°C)';
  @override
  String get unitsImperial => 'Imperial (°F)';
  @override
  String get notifications => 'Notifications';
  @override
  String get imageRetention => 'Save my images';
  @override
  String get imageRetentionBody =>
      'When on, your diagnosis images are stored to your account. When off, images are deleted after analysis.';
  @override
  String get reminders => 'Plant-care reminders';
  @override
  String get privacyPolicy => 'Privacy policy';
  @override
  String get termsOfService => 'Terms of service';
  @override
  String get reportIssue => 'Send feedback';
  @override
  String appVersion(String version) => 'Version $version';
  @override
  String get logout => 'Log out';
  @override
  String get logoutConfirm => 'Log out of PlantSense?';
  @override
  String get deleteAccount => 'Delete account';
  @override
  String get deleteAccountConfirm =>
      'This permanently deletes your account and all data. This cannot be undone.';
  @override
  String get deleteAllData => 'Delete all my data';
  @override
  String get deleteAllDataConfirm =>
      'This deletes all your chats, diagnoses, reminders and stored images. This cannot be undone.';
  @override
  String get reauthRequired =>
      'Please log in again to confirm this action.';
  @override
  String get deleting => 'Deleting…';
  @override
  String get deleted => 'Deleted';

  @override
  String get remindersTitle => 'Reminders';
  @override
  String get addReminder => 'Add reminder';
  @override
  String get reminderPlantName => 'Plant name';
  @override
  String get reminderNote => 'Note';
  @override
  String get reminderType => 'Type';
  @override
  String get reminderWatering => 'Watering';
  @override
  String get reminderFertilizing => 'Fertilizing';
  @override
  String get reminderRepotting => 'Repotting';
  @override
  String get reminderInspection => 'Inspection';
  @override
  String get reminderFollowUp => 'Diagnosis follow-up';
  @override
  String get reminderDateTime => 'Date & time';
  @override
  String get reminderRecurrence => 'Repeat';
  @override
  String get recurrenceNone => 'Once';
  @override
  String get recurrenceDaily => 'Daily';
  @override
  String get recurrenceWeekly => 'Weekly';
  @override
  String get reminderPaused => 'Paused';
  @override
  String get reminderPause => 'Pause';
  @override
  String get reminderResume => 'Resume';
  @override
  String get remindersEmpty => 'No reminders yet';
  @override
  String get remindersEmptyBody =>
      'Add a reminder to stay on top of plant care.';
  @override
  String get notificationsPermissionBody =>
      'Allow notifications so we can remind you about plant care.';

  @override
  String get privacyTitle => 'Privacy & data';
  @override
  String get privacyIntro => "Here's how PlantSense handles your data.";
  @override
  String get privacyProfile =>
      'Your profile (name, email, preferences) is stored to your account.';
  @override
  String get privacyLocation =>
      'Location is opt-in and used only for weather and care advice. We never collect location in the background.';
  @override
  String get privacyImages =>
      "Images you submit are sent for AI analysis. They are retained only if you enable image saving; otherwise they're deleted after analysis.";
  @override
  String get privacyProviders =>
      'AI and infrastructure providers may process content you submit. AI answers may be inaccurate.';
  @override
  String get privacyControl =>
      'You can disable retention, delete chats and diagnoses, and delete your account and data at any time.';

  @override
  String get a11yError => 'Error';
  @override
  String get a11ySendMessage => 'Send message';
  @override
  String a11yWeatherIcon(String condition) =>
      'Weather condition: $condition';
  @override
  String a11yConfidence(String level) => 'Confidence level: $level';

  @override
  String get errorNoConnection =>
      'No internet connection. Check your network and try again.';
  @override
  String get errorTimeout => 'The request timed out. Please try again.';
  @override
  String get errorPermissionDenied => 'Permission was denied.';
  @override
  String get errorPermissionPermanentlyDenied =>
      'Permission is blocked. Enable it in Settings.';
  @override
  String get errorLocationServicesDisabled =>
      'Location services are turned off.';
  @override
  String get errorAuthExpired => 'Your session expired. Please log in again.';
  @override
  String get errorUnauthenticated => 'You need to be logged in to do that.';
  @override
  String get errorInvalidCredentials => 'Incorrect email or password.';
  @override
  String get errorRateLimited =>
      'Too many requests. Please wait a moment and try again.';
  @override
  String get errorInvalidInput =>
      "That input isn't valid. Please review and try again.";
  @override
  String get errorImageTooLarge => 'That image is too large. Try a smaller photo.';
  @override
  String get errorContentBlocked =>
      'That request was blocked for safety reasons.';
  @override
  String get errorModelUnavailable =>
      'The AI service is temporarily unavailable.';
  @override
  String get errorMalformedResponse =>
      "We couldn't read the response. Please try again.";
  @override
  String get errorProviderUnavailable =>
      'A service is temporarily unavailable. Please try again.';
  @override
  String get errorNotFound => 'Not found.';
  @override
  String get errorUnknown => 'Something went wrong. Please try again.';
  @override
  String get emailInUse => 'That email is already registered.';
  @override
  String get userDisabled => 'This account has been disabled.';
  @override
  String get userNotFound => 'No account found for that email.';

  @override
  String get demoModeBanner =>
      'Demo mode — using sample data. Configure Firebase & Groq for full features.';
}
