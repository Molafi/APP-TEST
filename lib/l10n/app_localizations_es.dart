// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'PlantSense AI';

  @override
  String get tagline => 'Tu asistente inteligente de plantas y suelo';

  @override
  String get retry => 'Reintentar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get save => 'Guardar';

  @override
  String get delete => 'Eliminar';

  @override
  String get close => 'Cerrar';

  @override
  String get next => 'Siguiente';

  @override
  String get back => 'Atrás';

  @override
  String get skip => 'Omitir';

  @override
  String get getStarted => 'Empezar';

  @override
  String get openSettings => 'Open settings';

  @override
  String get loading => 'Cargando…';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get navChat => 'Chat';

  @override
  String get navDiagnose => 'Diagnóstico';

  @override
  String get navWeather => 'Clima';

  @override
  String get navProfile => 'Perfil';

  @override
  String get offlineBanner =>
      'You\'re offline. Showing cached data where available.';

  @override
  String lastUpdated(String time) {
    return 'Last updated $time';
  }

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
  String get onboardingTitle4 => 'You\'re in control';

  @override
  String get onboardingBody4 =>
      'AI results may be inaccurate. You control permissions, image retention and your data.';

  @override
  String get login => 'Iniciar sesión';

  @override
  String get register => 'Crear cuenta';

  @override
  String get email => 'Correo electrónico';

  @override
  String get password => 'Contraseña';

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
  String get chatEmptyTitle => 'Haz tu primera pregunta';

  @override
  String get chatEmptyBody =>
      'Tap a suggestion below or type your own question.';

  @override
  String get composerHint => 'Pregunta sobre tu planta…';

  @override
  String get send => 'Enviar';

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
  String get conversations => 'Conversaciones';

  @override
  String get newChat => 'Nuevo chat';

  @override
  String get rename => 'Rename';

  @override
  String get messageFailed => 'Failed to send. Tap to retry.';

  @override
  String get sending => 'Sending…';

  @override
  String get typing => 'PlantSense is thinking…';

  @override
  String charactersRemaining(int count) {
    return '$count characters left';
  }

  @override
  String get aiDisclaimerShort => 'AI suggestions may be inaccurate.';

  @override
  String get contextUnavailable => 'Location/weather context unavailable';

  @override
  String get starterYellowLeaves =>
      'Why are my plant\'s leaves turning yellow?';

  @override
  String get starterWaterBasil => 'How often should I water my basil?';

  @override
  String get starterSucculentSoil =>
      'What soil mix should I use for succulents?';

  @override
  String get starterIdentifyPest => 'Can you identify this pest?';

  @override
  String get starterTransplant => 'Is today\'s weather safe for transplanting?';

  @override
  String get starterClayDrainage => 'How can I improve drainage in clay soil?';

  @override
  String get diagnoseTitle => 'Diagnóstico';

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
  String get captureFailed => 'Couldn\'t capture the photo. Please try again.';

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
      'This doesn\'t look plant-related. Try a photo of a plant, leaf, pest or soil.';

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
  String get georesearchTitle => 'GeoInvestigación';

  @override
  String get navGeoResearch => 'Suelo';

  @override
  String get georesearchIntro =>
      'Get an estimated soil profile for your location. Optionally add a site photo to estimate soil structure.';

  @override
  String get georesearchAddPhoto => 'Add a soil/site photo';

  @override
  String get georesearchChangePhoto => 'Change photo';

  @override
  String get georesearchRemovePhoto => 'Remove photo';

  @override
  String get georesearchTakePhoto => 'Take photo';

  @override
  String get georesearchChoosePhoto => 'Choose from gallery';

  @override
  String get georesearchNoLocation =>
      'Set your location to get a location-aware soil estimate.';

  @override
  String get georesearchAnalyze => 'Analyze soil';

  @override
  String get georesearchAnalyzing => 'Researching your soil…';

  @override
  String get georesearchLocation => 'Location & soil type';

  @override
  String get georesearchSoilType => 'Soil type / texture';

  @override
  String get georesearchDepth => 'Soil depth / profile';

  @override
  String get georesearchSalinitySodium => 'Salinity & sodium';

  @override
  String get georesearchSalinity => 'Salinity (salt)';

  @override
  String get georesearchSodium => 'Sodium';

  @override
  String get georesearchPhOrganic => 'pH & organic matter';

  @override
  String get georesearchPh => 'pH';

  @override
  String get georesearchOrganicMatter => 'Organic matter';

  @override
  String get georesearchNutrients => 'Nutrients (N-P-K)';

  @override
  String get georesearchSubstances => 'Notable substances';

  @override
  String get georesearchGeometry => 'Soil structure / geometry';

  @override
  String get georesearchSuitablePlants => 'Suitable plants';

  @override
  String get georesearchRecommendations => 'Recommendations';

  @override
  String get georesearchSafety => 'Safety notes';

  @override
  String get georesearchNotSoilRelated =>
      'This doesn\'t look soil or site related. Try a photo of soil or the ground/site.';

  @override
  String get georesearchEstimateNotice =>
      'Estas son estimaciones basadas en su ubicación y su foto. Los valores exactos de sodio, salinidad y nutrientes requieren un análisis de suelo en laboratorio.';

  @override
  String get georesearchSave => 'Save report';

  @override
  String get georesearchSaved => 'Report saved';

  @override
  String get georesearchHistory => 'Soil reports';

  @override
  String get georesearchHistoryEmpty => 'No saved soil reports yet';

  @override
  String get georesearchHistoryEmptyBody =>
      'Analyze your soil to build your history.';

  @override
  String get georesearchPurpose => 'What do you need this survey for?';

  @override
  String get georesearchPurposeGeneral => 'General';

  @override
  String get georesearchPurposeAgriculture => 'Farming';

  @override
  String get georesearchPurposeBuilding => 'Building';

  @override
  String get georesearchPurposeWellDrilling => 'Water well';

  @override
  String get georesearchRequirements => 'Your requirements';

  @override
  String get georesearchRequirementsHint =>
      'Describe what you plan to do with this land, e.g. build a two-storey house, plant olive trees, drill a well.';

  @override
  String get georesearchLandRecordSection => 'Land Department data (optional)';

  @override
  String get georesearchLandRecordToggle =>
      'I have official Land Department data';

  @override
  String get georesearchLandRecordHelp =>
      'If official records are available, enter them and the survey will use them as authoritative instead of estimating.';

  @override
  String get georesearchLandRecordSource => 'Issuing authority / registry';

  @override
  String get georesearchLandParcelId => 'Parcel / plot / deed number';

  @override
  String get georesearchLandRegisteredArea => 'Registered area';

  @override
  String get georesearchLandZoning => 'Zoning / permitted use';

  @override
  String get georesearchLandClassification => 'Land classification';

  @override
  String get georesearchLandOwnershipType => 'Ownership type';

  @override
  String get georesearchLandOfficialNotes => 'Other official notes';

  @override
  String get georesearchLandRecordOfficial => 'Official record';

  @override
  String get georesearchAerial => 'Aerial / satellite view';

  @override
  String get georesearchAerialLandCover => 'Land cover';

  @override
  String get georesearchAerialFeatures => 'Visible features';

  @override
  String get georesearchAerialUnavailable =>
      'Set a location to see an aerial view of the site.';

  @override
  String get georesearchAerialNotice =>
      'Las imágenes aéreas son solo contexto y no están fechadas; no son un levantamiento aéreo actual.';

  @override
  String get georesearchSite => 'Site location';

  @override
  String get georesearchSiteAddress => 'Address';

  @override
  String get georesearchSiteElevation => 'Elevation';

  @override
  String get georesearchSiteArea => 'Approximate area';

  @override
  String get georesearchSiteBoundary => 'Boundaries / extent';

  @override
  String get georesearchSiteAccess => 'Access';

  @override
  String get georesearchSiteTerrain => 'Setting';

  @override
  String get georesearchTopography => 'Topographic survey';

  @override
  String get georesearchTopoElevationRange => 'Elevation range';

  @override
  String get georesearchTopoSlope => 'Slope';

  @override
  String get georesearchTopoAspect => 'Aspect';

  @override
  String get georesearchTopoLandform => 'Landform';

  @override
  String get georesearchTopoRelief => 'Relief';

  @override
  String get georesearchTopoContours => 'Contours';

  @override
  String get georesearchTopoDrainage => 'Drainage pattern';

  @override
  String get georesearchTopoRunoff => 'Runoff';

  @override
  String get georesearchTopoFloodRisk => 'Flood risk';

  @override
  String get georesearchTopoErosionRisk => 'Erosion risk';

  @override
  String get georesearchTopoGrading => 'Grading / earthworks';

  @override
  String get georesearchTopoNotice =>
      'Estimación de gabinete. Las curvas de nivel para diseño requieren un levantamiento topográfico autorizado con instrumentos o dron.';

  @override
  String get georesearchGroundwater => 'Groundwater';

  @override
  String get georesearchGwWaterTable => 'Water table depth';

  @override
  String get georesearchGwAquifer => 'Aquifer type';

  @override
  String get georesearchGwYield => 'Yield potential';

  @override
  String get georesearchGwQuality => 'Water quality';

  @override
  String get georesearchGwSalinityRisk => 'Salinity risk';

  @override
  String get georesearchGwSeasonal => 'Seasonal variation';

  @override
  String get georesearchGwRecharge => 'Recharge';

  @override
  String get georesearchGwWellFeasibility => 'Well feasibility';

  @override
  String get georesearchGwDrillingDepth => 'Estimated drilling depth';

  @override
  String get georesearchGwContamination => 'Contamination risk';

  @override
  String get georesearchGwNotice =>
      'Estimación regional. Se requiere un estudio hidrogeológico y un permiso de perforación antes de perforar.';

  @override
  String get georesearchBuilding => 'Building suitability';

  @override
  String get georesearchBuildRating => 'Screening rating';

  @override
  String get georesearchBuildBearing => 'Bearing capacity';

  @override
  String get georesearchBuildBedrock => 'Depth to bedrock';

  @override
  String get georesearchBuildFoundation => 'Possible foundation approach';

  @override
  String get georesearchBuildSettlement => 'Settlement risk';

  @override
  String get georesearchBuildExpansive => 'Expansive soil risk';

  @override
  String get georesearchBuildSeismic => 'Seismic context';

  @override
  String get georesearchBuildExcavation => 'Excavation';

  @override
  String get georesearchBuildDrainage => 'Site drainage';

  @override
  String get georesearchBuildConstraints => 'Constraints';

  @override
  String get georesearchBuildRequiredStudies => 'Required professional studies';

  @override
  String get georesearchBuildNotice =>
      'Solo es una evaluación preliminar. NO es un informe geotécnico y no debe usarse para el diseño de cimentaciones. Encargue un estudio geotécnico autorizado antes de construir.';

  @override
  String get georesearchDataSources => 'Data sources';

  @override
  String get concernLow => 'Low concern';

  @override
  String get concernMedium => 'Medium concern';

  @override
  String get concernHigh => 'High concern';

  @override
  String get levelLow => 'Low';

  @override
  String get levelMedium => 'Medium';

  @override
  String get levelHigh => 'High';

  @override
  String get weatherTitle => 'Clima';

  @override
  String get currentWeather => 'Current weather';

  @override
  String feelsLike(String value) {
    return 'Feels like $value';
  }

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
  String rainChance(int value) {
    return '$value% rain';
  }

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
      'It\'s hot — water early or late and provide shade for tender plants.';

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
      'Couldn\'t determine your city. Try searching manually.';

  @override
  String get selectCity => 'Select a city';

  @override
  String get noResults => 'No matching places found';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get language => 'Idioma';

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
  String get analytics => 'Usage analytics & crash reports';

  @override
  String get analyticsBody =>
      'Share anonymous usage and crash data to help improve the app. Never includes your messages, images or exact location.';

  @override
  String get reminders => 'Plant-care reminders';

  @override
  String get privacyPolicy => 'Privacy policy';

  @override
  String get termsOfService => 'Terms of service';

  @override
  String get reportIssue => 'Send feedback';

  @override
  String appVersion(String version) {
    return 'Version $version';
  }

  @override
  String get logout => 'Cerrar sesión';

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
  String get exportData => 'Descargar mis datos';

  @override
  String get reauthRequired => 'Please log in again to confirm this action.';

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
  String get reminderBodyWatering => 'Time to water your plant.';

  @override
  String get reminderBodyFertilizing => 'Time to fertilize your plant.';

  @override
  String get reminderBodyRepotting => 'Time to repot your plant.';

  @override
  String get reminderBodyInspection => 'Time to inspect your plant.';

  @override
  String get reminderBodyFollowUp => 'Follow up on your plant diagnosis.';

  @override
  String get remindersEmpty => 'No reminders yet';

  @override
  String get remindersEmptyBody =>
      'Add a reminder to stay on top of plant care.';

  @override
  String get notificationsPermissionBody =>
      'Allow notifications so we can remind you about plant care.';

  @override
  String get myPlants => 'Mis plantas';

  @override
  String get addPlant => 'Add plant';

  @override
  String get editPlant => 'Edit plant';

  @override
  String get plantSpecies => 'Species (optional)';

  @override
  String get plantNotes => 'Notes';

  @override
  String get plantsEmpty => 'No plants yet';

  @override
  String get plantsEmptyBody => 'Add a plant to track its care and history.';

  @override
  String get askAboutPlant => 'Ask about this plant';

  @override
  String get plantLocation => 'Location';

  @override
  String get plantIndoor => 'Indoor';

  @override
  String get plantOutdoor => 'Outdoor';

  @override
  String get markWatered => 'Mark watered';

  @override
  String get wateringInterval => 'Water every (days)';

  @override
  String get generateWateringSchedule => 'Create watering schedule';

  @override
  String get wateringScheduleCreated => 'Watering reminder scheduled';

  @override
  String get privacyTitle => 'Privacy & data';

  @override
  String get privacyIntro => 'Here\'s how PlantSense handles your data.';

  @override
  String get privacyProfile =>
      'Your profile (name, email, preferences) is stored to your account.';

  @override
  String get privacyLocation =>
      'Location is opt-in and used only for weather and care advice. We never collect location in the background.';

  @override
  String get privacyImages =>
      'Images you submit are sent for AI analysis. They are retained only if you enable image saving; otherwise they\'re deleted after analysis.';

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
  String a11yWeatherIcon(String condition) {
    return 'Weather condition: $condition';
  }

  @override
  String a11yConfidence(String level) {
    return 'Confidence level: $level';
  }

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
      'That input isn\'t valid. Please review and try again.';

  @override
  String get errorImageTooLarge =>
      'That image is too large. Try a smaller photo.';

  @override
  String get errorContentBlocked =>
      'That request was blocked for safety reasons.';

  @override
  String get errorModelUnavailable =>
      'The AI service is temporarily unavailable.';

  @override
  String get errorMalformedResponse =>
      'We couldn\'t read the response. Please try again.';

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
      'Modo demo: datos de ejemplo. Configura Firebase y Groq para todas las funciones.';

  @override
  String get georesearchPurposeSlopeStability => 'Land stability';

  @override
  String get georesearchPurposeHelp =>
      'Your choice decides what the survey focuses on: plants and soil nutrients, groundwater and wells, foundations and building, or land movement and slope stability.';

  @override
  String get georesearchPurposeSection => 'Survey purpose';

  @override
  String get georesearchPurposeValue => 'Requested for';

  @override
  String get georesearchSlope => 'Slope stability & land movement';

  @override
  String get georesearchSlopeHazard => 'Hazard rating';

  @override
  String get georesearchSlopeActivity => 'Activity state';

  @override
  String get georesearchSlopeDirection => 'Direction of land movement';

  @override
  String get georesearchSlopeAzimuth => 'Approximate bearing';

  @override
  String get georesearchSlopeSlipDepth => 'Depth of the slip surface';

  @override
  String get georesearchSlopeSlipType => 'Failure geometry';

  @override
  String get georesearchSlopeRate => 'Rate of movement';

  @override
  String get georesearchSlopeRateClass => 'Movement rate class';

  @override
  String get georesearchSlopeMechanism => 'Failure mechanism';

  @override
  String get georesearchSlopeIndicators => 'Warning signs to look for on site';

  @override
  String get georesearchSlopeTriggers => 'Possible triggers';

  @override
  String get georesearchSlopeAtRisk => 'Structures exposed to movement';

  @override
  String get georesearchSlopeAtRiskNotice =>
      'Exposure is inferred from position on the slope, not from the condition of any specific building. Nothing here supports an occupancy or evacuation decision — that needs a licensed geotechnical engineer and your local authority.';

  @override
  String get georesearchSlopeZones =>
      'Areas that could be built on after treatment';

  @override
  String get georesearchSlopeZoneAfterTreatment =>
      'Buildable ONLY after treatment';

  @override
  String get georesearchSlopeZoneNotBuildable =>
      'Not buildable on current evidence';

  @override
  String get georesearchSlopeZoneTreatments => 'Required treatments';

  @override
  String get georesearchSlopeZonesNotice =>
      '"Buildable after treatment" is conditional: it holds only if the listed treatments are carried out and a licensed geotechnical engineer designs and signs off the works. No area is cleared as safe by this report.';

  @override
  String get georesearchSlopeStabilisation => 'Possible stabilisation measures';

  @override
  String get georesearchSlopeMonitoring => 'Monitoring & instrumentation';

  @override
  String get georesearchSlopeRequiredStudies => 'Required professional studies';

  @override
  String get georesearchSlopeMeasureNotice =>
      'Direction, slip-surface depth and movement rate cannot be measured from a phone. The values above are screening ranges only: inclinometers and piezometers installed in boreholes, plus repeated GNSS or InSAR observation, are what actually measure them.';

  @override
  String get georesearchSlopeNotice =>
      'Preliminary desk screening only. This is NOT a slope-stability analysis and carries no factor of safety. If you see fresh cracks, tilting walls or displaced pipes, contact a licensed geotechnical engineer and your local authority without delay.';

  @override
  String get georesearchOfficialMap => 'Official maps & national grid';

  @override
  String get georesearchOfficialMapAuthority => 'Mapping authority';

  @override
  String get georesearchOfficialMapGrid => 'National grid';

  @override
  String get georesearchOfficialMapEasting => 'Easting (E)';

  @override
  String get georesearchOfficialMapNorthing => 'Northing (N)';

  @override
  String get georesearchOfficialMapWgs => 'GPS coordinates (WGS84)';

  @override
  String get georesearchOfficialMapPortal => 'Open the geoportal';

  @override
  String get georesearchOfficialMapOrder =>
      'Order official maps & aerial photos';

  @override
  String get georesearchOfficialMapCopy => 'Copy grid reference';

  @override
  String get georesearchOfficialMapCopied => 'Grid reference copied';

  @override
  String get georesearchOfficialMapUnshifted =>
      'Unofficial conversion: no datum transformation was applied, so this can differ from a surveyed grid value by tens of metres. Ask the authority for the official transformation parameters before relying on it.';

  @override
  String get georesearchOfficialMapShifted =>
      'Converted using the datum parameters configured for this build. Still a locating reference, not a surveyed position.';

  @override
  String get georesearchOfficialMapNotice =>
      'Grid values are provided for locating the site and for ordering official map sheets and aerial photographs. Boundary, ownership and design work requires a licensed cadastral survey.';

  @override
  String get georesearchOfficialMapTileUnavailable =>
      'The authority\'s official basemap layer is not enabled for this build (it requires an agreement with the Centre). The grid reference and the links below still work.';
}
