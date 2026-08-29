import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'PlantSense AI'**
  String get appTitle;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Your intelligent plant & soil assistant'**
  String get tagline;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get getStarted;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get openSettings;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @navChat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get navChat;

  /// No description provided for @navDiagnose.
  ///
  /// In en, this message translates to:
  /// **'Diagnose'**
  String get navDiagnose;

  /// No description provided for @navWeather.
  ///
  /// In en, this message translates to:
  /// **'Weather'**
  String get navWeather;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @offlineBanner.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline. Showing cached data where available.'**
  String get offlineBanner;

  /// No description provided for @lastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated {time}'**
  String lastUpdated(String time);

  /// No description provided for @cachedData.
  ///
  /// In en, this message translates to:
  /// **'Cached data'**
  String get cachedData;

  /// No description provided for @liveData.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get liveData;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Ask about any plant'**
  String get onboardingTitle1;

  /// No description provided for @onboardingBody1.
  ///
  /// In en, this message translates to:
  /// **'Chat with PlantSense AI about plants, pests and soil — using text or photos.'**
  String get onboardingBody1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Diagnose from a photo'**
  String get onboardingTitle2;

  /// No description provided for @onboardingBody2.
  ///
  /// In en, this message translates to:
  /// **'Photograph a leaf, pest or soil issue and get structured, cautious guidance.'**
  String get onboardingBody2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Weather-aware care'**
  String get onboardingTitle3;

  /// No description provided for @onboardingBody3.
  ///
  /// In en, this message translates to:
  /// **'Share your location to get local weather and tailored plant-care tips.'**
  String get onboardingBody3;

  /// No description provided for @onboardingTitle4.
  ///
  /// In en, this message translates to:
  /// **'You\'re in control'**
  String get onboardingTitle4;

  /// No description provided for @onboardingBody4.
  ///
  /// In en, this message translates to:
  /// **'AI results may be inaccurate. You control permissions, image retention and your data.'**
  String get onboardingBody4;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get register;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @displayName.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get displayName;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @noAccountPrompt.
  ///
  /// In en, this message translates to:
  /// **'New here? Create an account'**
  String get noAccountPrompt;

  /// No description provided for @haveAccountPrompt.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Log in'**
  String get haveAccountPrompt;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get sendResetLink;

  /// No description provided for @resetLinkSent.
  ///
  /// In en, this message translates to:
  /// **'If that email exists, a reset link has been sent.'**
  String get resetLinkSent;

  /// No description provided for @verifyEmailNotice.
  ///
  /// In en, this message translates to:
  /// **'Please verify your email address.'**
  String get verifyEmailNotice;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get emailRequired;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get emailInvalid;

  /// No description provided for @emailTooLong.
  ///
  /// In en, this message translates to:
  /// **'Email is too long'**
  String get emailTooLong;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a password'**
  String get passwordRequired;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordTooShort;

  /// No description provided for @passwordTooLong.
  ///
  /// In en, this message translates to:
  /// **'Password is too long'**
  String get passwordTooLong;

  /// No description provided for @passwordWeak.
  ///
  /// In en, this message translates to:
  /// **'Use at least one letter and one number'**
  String get passwordWeak;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordMismatch;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a display name'**
  String get nameRequired;

  /// No description provided for @nameTooLong.
  ///
  /// In en, this message translates to:
  /// **'Display name is too long'**
  String get nameTooLong;

  /// No description provided for @chatTitle.
  ///
  /// In en, this message translates to:
  /// **'PlantSense chat'**
  String get chatTitle;

  /// No description provided for @chatEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Ask your first question'**
  String get chatEmptyTitle;

  /// No description provided for @chatEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Tap a suggestion below or type your own question.'**
  String get chatEmptyBody;

  /// No description provided for @composerHint.
  ///
  /// In en, this message translates to:
  /// **'Ask about your plant…'**
  String get composerHint;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @attachImage.
  ///
  /// In en, this message translates to:
  /// **'Attach image'**
  String get attachImage;

  /// No description provided for @removeImage.
  ///
  /// In en, this message translates to:
  /// **'Remove image'**
  String get removeImage;

  /// No description provided for @voiceInput.
  ///
  /// In en, this message translates to:
  /// **'Voice input'**
  String get voiceInput;

  /// No description provided for @readAloud.
  ///
  /// In en, this message translates to:
  /// **'Read aloud'**
  String get readAloud;

  /// No description provided for @stopAudio.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stopAudio;

  /// No description provided for @fromCamera.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get fromCamera;

  /// No description provided for @fromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get fromGallery;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copied;

  /// No description provided for @deleteConversation.
  ///
  /// In en, this message translates to:
  /// **'Delete conversation'**
  String get deleteConversation;

  /// No description provided for @deleteConversationConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this conversation? This cannot be undone.'**
  String get deleteConversationConfirm;

  /// No description provided for @conversations.
  ///
  /// In en, this message translates to:
  /// **'Conversations'**
  String get conversations;

  /// No description provided for @newChat.
  ///
  /// In en, this message translates to:
  /// **'New chat'**
  String get newChat;

  /// No description provided for @rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// No description provided for @messageFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send. Tap to retry.'**
  String get messageFailed;

  /// No description provided for @sending.
  ///
  /// In en, this message translates to:
  /// **'Sending…'**
  String get sending;

  /// No description provided for @typing.
  ///
  /// In en, this message translates to:
  /// **'PlantSense is thinking…'**
  String get typing;

  /// No description provided for @charactersRemaining.
  ///
  /// In en, this message translates to:
  /// **'{count} characters left'**
  String charactersRemaining(int count);

  /// No description provided for @aiDisclaimerShort.
  ///
  /// In en, this message translates to:
  /// **'AI suggestions may be inaccurate.'**
  String get aiDisclaimerShort;

  /// No description provided for @contextUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Location/weather context unavailable'**
  String get contextUnavailable;

  /// No description provided for @starterYellowLeaves.
  ///
  /// In en, this message translates to:
  /// **'Why are my plant\'s leaves turning yellow?'**
  String get starterYellowLeaves;

  /// No description provided for @starterWaterBasil.
  ///
  /// In en, this message translates to:
  /// **'How often should I water my basil?'**
  String get starterWaterBasil;

  /// No description provided for @starterSucculentSoil.
  ///
  /// In en, this message translates to:
  /// **'What soil mix should I use for succulents?'**
  String get starterSucculentSoil;

  /// No description provided for @starterIdentifyPest.
  ///
  /// In en, this message translates to:
  /// **'Can you identify this pest?'**
  String get starterIdentifyPest;

  /// No description provided for @starterTransplant.
  ///
  /// In en, this message translates to:
  /// **'Is today\'s weather safe for transplanting?'**
  String get starterTransplant;

  /// No description provided for @starterClayDrainage.
  ///
  /// In en, this message translates to:
  /// **'How can I improve drainage in clay soil?'**
  String get starterClayDrainage;

  /// No description provided for @diagnoseTitle.
  ///
  /// In en, this message translates to:
  /// **'Diagnose'**
  String get diagnoseTitle;

  /// No description provided for @cameraInitializing.
  ///
  /// In en, this message translates to:
  /// **'Starting camera…'**
  String get cameraInitializing;

  /// No description provided for @cameraPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Camera access needed'**
  String get cameraPermissionTitle;

  /// No description provided for @cameraPermissionBody.
  ///
  /// In en, this message translates to:
  /// **'PlantSense uses your camera to photograph plants and soil for analysis. Photos are only used for the diagnosis you request.'**
  String get cameraPermissionBody;

  /// No description provided for @cameraPermissionDeniedBody.
  ///
  /// In en, this message translates to:
  /// **'Camera permission was denied. You can still pick a photo from your gallery.'**
  String get cameraPermissionDeniedBody;

  /// No description provided for @cameraUnavailable.
  ///
  /// In en, this message translates to:
  /// **'No camera is available on this device.'**
  String get cameraUnavailable;

  /// No description provided for @captureFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t capture the photo. Please try again.'**
  String get captureFailed;

  /// No description provided for @allowCamera.
  ///
  /// In en, this message translates to:
  /// **'Allow camera'**
  String get allowCamera;

  /// No description provided for @flashOn.
  ///
  /// In en, this message translates to:
  /// **'Flash on'**
  String get flashOn;

  /// No description provided for @flashOff.
  ///
  /// In en, this message translates to:
  /// **'Flash off'**
  String get flashOff;

  /// No description provided for @switchCamera.
  ///
  /// In en, this message translates to:
  /// **'Switch camera'**
  String get switchCamera;

  /// No description provided for @capture.
  ///
  /// In en, this message translates to:
  /// **'Capture'**
  String get capture;

  /// No description provided for @retake.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get retake;

  /// No description provided for @cropImage.
  ///
  /// In en, this message translates to:
  /// **'Crop'**
  String get cropImage;

  /// No description provided for @confirmPhoto.
  ///
  /// In en, this message translates to:
  /// **'Use this photo'**
  String get confirmPhoto;

  /// No description provided for @analyzing.
  ///
  /// In en, this message translates to:
  /// **'Analyzing your photo…'**
  String get analyzing;

  /// No description provided for @cancelAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Cancel analysis'**
  String get cancelAnalysis;

  /// No description provided for @diagnosisPlant.
  ///
  /// In en, this message translates to:
  /// **'Plant / subject'**
  String get diagnosisPlant;

  /// No description provided for @diagnosisWhatISee.
  ///
  /// In en, this message translates to:
  /// **'What I see'**
  String get diagnosisWhatISee;

  /// No description provided for @diagnosisIssue.
  ///
  /// In en, this message translates to:
  /// **'Issues detected'**
  String get diagnosisIssue;

  /// No description provided for @diagnosisTreatment.
  ///
  /// In en, this message translates to:
  /// **'Step-by-step treatment'**
  String get diagnosisTreatment;

  /// No description provided for @diagnosisPrevention.
  ///
  /// In en, this message translates to:
  /// **'Prevention tips'**
  String get diagnosisPrevention;

  /// No description provided for @diagnosisSafety.
  ///
  /// In en, this message translates to:
  /// **'Safety notes'**
  String get diagnosisSafety;

  /// No description provided for @diagnosisConfidence.
  ///
  /// In en, this message translates to:
  /// **'Confidence'**
  String get diagnosisConfidence;

  /// No description provided for @confidenceLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get confidenceLow;

  /// No description provided for @confidenceMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get confidenceMedium;

  /// No description provided for @confidenceHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get confidenceHigh;

  /// No description provided for @likelihoodLow.
  ///
  /// In en, this message translates to:
  /// **'Low likelihood'**
  String get likelihoodLow;

  /// No description provided for @likelihoodMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium likelihood'**
  String get likelihoodMedium;

  /// No description provided for @likelihoodHigh.
  ///
  /// In en, this message translates to:
  /// **'High likelihood'**
  String get likelihoodHigh;

  /// No description provided for @needMoreInfo.
  ///
  /// In en, this message translates to:
  /// **'I need a clearer image'**
  String get needMoreInfo;

  /// No description provided for @notPlantRelated.
  ///
  /// In en, this message translates to:
  /// **'This doesn\'t look plant-related. Try a photo of a plant, leaf, pest or soil.'**
  String get notPlantRelated;

  /// No description provided for @poorImageQuality.
  ///
  /// In en, this message translates to:
  /// **'The image is blurry or unclear. Try again in good light, filling the frame with the affected area.'**
  String get poorImageQuality;

  /// No description provided for @saveDiagnosis.
  ///
  /// In en, this message translates to:
  /// **'Save diagnosis'**
  String get saveDiagnosis;

  /// No description provided for @diagnosisSaved.
  ///
  /// In en, this message translates to:
  /// **'Diagnosis saved'**
  String get diagnosisSaved;

  /// No description provided for @askFollowUp.
  ///
  /// In en, this message translates to:
  /// **'Ask a follow-up'**
  String get askFollowUp;

  /// No description provided for @shareSummary.
  ///
  /// In en, this message translates to:
  /// **'Share summary'**
  String get shareSummary;

  /// No description provided for @diagnosisHistory.
  ///
  /// In en, this message translates to:
  /// **'Diagnosis history'**
  String get diagnosisHistory;

  /// No description provided for @diagnosisHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No saved diagnoses yet'**
  String get diagnosisHistoryEmpty;

  /// No description provided for @diagnosisHistoryEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Diagnose a plant to build your history.'**
  String get diagnosisHistoryEmptyBody;

  /// No description provided for @aiDisclaimerLong.
  ///
  /// In en, this message translates to:
  /// **'PlantSense AI provides suggestions, not guarantees. For serious plant disease, pesticide, edible-crop, toxicity or agricultural concerns, consult a qualified botanist, agronomist, horticulturist, veterinarian, poison-control service or local agricultural authority.'**
  String get aiDisclaimerLong;

  /// No description provided for @weatherTitle.
  ///
  /// In en, this message translates to:
  /// **'Weather'**
  String get weatherTitle;

  /// No description provided for @currentWeather.
  ///
  /// In en, this message translates to:
  /// **'Current weather'**
  String get currentWeather;

  /// No description provided for @feelsLike.
  ///
  /// In en, this message translates to:
  /// **'Feels like {value}'**
  String feelsLike(String value);

  /// No description provided for @humidity.
  ///
  /// In en, this message translates to:
  /// **'Humidity'**
  String get humidity;

  /// No description provided for @uvIndex.
  ///
  /// In en, this message translates to:
  /// **'UV index'**
  String get uvIndex;

  /// No description provided for @precipitation.
  ///
  /// In en, this message translates to:
  /// **'Precipitation'**
  String get precipitation;

  /// No description provided for @hourlyForecast.
  ///
  /// In en, this message translates to:
  /// **'Hourly forecast'**
  String get hourlyForecast;

  /// No description provided for @sevenDayForecast.
  ///
  /// In en, this message translates to:
  /// **'7-day forecast'**
  String get sevenDayForecast;

  /// No description provided for @plantCareTips.
  ///
  /// In en, this message translates to:
  /// **'Plant-care tips'**
  String get plantCareTips;

  /// No description provided for @rainChance.
  ///
  /// In en, this message translates to:
  /// **'{value}% rain'**
  String rainChance(int value);

  /// No description provided for @weatherUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Weather is unavailable right now.'**
  String get weatherUnavailable;

  /// No description provided for @pullToRefresh.
  ///
  /// In en, this message translates to:
  /// **'Pull to refresh'**
  String get pullToRefresh;

  /// No description provided for @tipHighUv.
  ///
  /// In en, this message translates to:
  /// **'UV is high today — move sensitive plants out of direct afternoon sun.'**
  String get tipHighUv;

  /// No description provided for @tipNoRain.
  ///
  /// In en, this message translates to:
  /// **'No rain expected for several days — check container moisture more often.'**
  String get tipNoRain;

  /// No description provided for @tipHighHumidity.
  ///
  /// In en, this message translates to:
  /// **'High humidity may raise fungal risk — improve airflow and avoid wetting leaves at night.'**
  String get tipHighHumidity;

  /// No description provided for @tipFreezing.
  ///
  /// In en, this message translates to:
  /// **'Freezing temperatures possible — protect sensitive outdoor plants.'**
  String get tipFreezing;

  /// No description provided for @tipHot.
  ///
  /// In en, this message translates to:
  /// **'It\'s hot — water early or late and provide shade for tender plants.'**
  String get tipHot;

  /// No description provided for @tipMild.
  ///
  /// In en, this message translates to:
  /// **'Mild conditions — a good day for routine plant care.'**
  String get tipMild;

  /// No description provided for @locationTitle.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationTitle;

  /// No description provided for @useMyLocation.
  ///
  /// In en, this message translates to:
  /// **'Use my location'**
  String get useMyLocation;

  /// No description provided for @searchCity.
  ///
  /// In en, this message translates to:
  /// **'Search for a city'**
  String get searchCity;

  /// No description provided for @locationRationale.
  ///
  /// In en, this message translates to:
  /// **'Sharing your location lets PlantSense give accurate local weather and climate-aware plant-care advice.'**
  String get locationRationale;

  /// No description provided for @locationDeniedBody.
  ///
  /// In en, this message translates to:
  /// **'Location permission was denied. You can search for a city instead.'**
  String get locationDeniedBody;

  /// No description provided for @locationServicesOff.
  ///
  /// In en, this message translates to:
  /// **'Location services are turned off. Turn them on or search for a city.'**
  String get locationServicesOff;

  /// No description provided for @geocodeFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t determine your city. Try searching manually.'**
  String get geocodeFailed;

  /// No description provided for @selectCity.
  ///
  /// In en, this message translates to:
  /// **'Select a city'**
  String get selectCity;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No matching places found'**
  String get noResults;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @units.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get units;

  /// No description provided for @unitsMetric.
  ///
  /// In en, this message translates to:
  /// **'Metric (°C)'**
  String get unitsMetric;

  /// No description provided for @unitsImperial.
  ///
  /// In en, this message translates to:
  /// **'Imperial (°F)'**
  String get unitsImperial;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @imageRetention.
  ///
  /// In en, this message translates to:
  /// **'Save my images'**
  String get imageRetention;

  /// No description provided for @imageRetentionBody.
  ///
  /// In en, this message translates to:
  /// **'When on, your diagnosis images are stored to your account. When off, images are deleted after analysis.'**
  String get imageRetentionBody;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Usage analytics & crash reports'**
  String get analytics;

  /// No description provided for @analyticsBody.
  ///
  /// In en, this message translates to:
  /// **'Share anonymous usage and crash data to help improve the app. Never includes your messages, images or exact location.'**
  String get analyticsBody;

  /// No description provided for @reminders.
  ///
  /// In en, this message translates to:
  /// **'Plant-care reminders'**
  String get reminders;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of service'**
  String get termsOfService;

  /// No description provided for @reportIssue.
  ///
  /// In en, this message translates to:
  /// **'Send feedback'**
  String get reportIssue;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String appVersion(String version);

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Log out of PlantSense?'**
  String get logoutConfirm;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes your account and all data. This cannot be undone.'**
  String get deleteAccountConfirm;

  /// No description provided for @deleteAllData.
  ///
  /// In en, this message translates to:
  /// **'Delete all my data'**
  String get deleteAllData;

  /// No description provided for @deleteAllDataConfirm.
  ///
  /// In en, this message translates to:
  /// **'This deletes all your chats, diagnoses, reminders and stored images. This cannot be undone.'**
  String get deleteAllDataConfirm;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Download my data'**
  String get exportData;

  /// No description provided for @reauthRequired.
  ///
  /// In en, this message translates to:
  /// **'Please log in again to confirm this action.'**
  String get reauthRequired;

  /// No description provided for @deleting.
  ///
  /// In en, this message translates to:
  /// **'Deleting…'**
  String get deleting;

  /// No description provided for @deleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get deleted;

  /// No description provided for @remindersTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get remindersTitle;

  /// No description provided for @addReminder.
  ///
  /// In en, this message translates to:
  /// **'Add reminder'**
  String get addReminder;

  /// No description provided for @reminderPlantName.
  ///
  /// In en, this message translates to:
  /// **'Plant name'**
  String get reminderPlantName;

  /// No description provided for @reminderNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get reminderNote;

  /// No description provided for @reminderType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get reminderType;

  /// No description provided for @reminderWatering.
  ///
  /// In en, this message translates to:
  /// **'Watering'**
  String get reminderWatering;

  /// No description provided for @reminderFertilizing.
  ///
  /// In en, this message translates to:
  /// **'Fertilizing'**
  String get reminderFertilizing;

  /// No description provided for @reminderRepotting.
  ///
  /// In en, this message translates to:
  /// **'Repotting'**
  String get reminderRepotting;

  /// No description provided for @reminderInspection.
  ///
  /// In en, this message translates to:
  /// **'Inspection'**
  String get reminderInspection;

  /// No description provided for @reminderFollowUp.
  ///
  /// In en, this message translates to:
  /// **'Diagnosis follow-up'**
  String get reminderFollowUp;

  /// No description provided for @reminderDateTime.
  ///
  /// In en, this message translates to:
  /// **'Date & time'**
  String get reminderDateTime;

  /// No description provided for @reminderRecurrence.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get reminderRecurrence;

  /// No description provided for @recurrenceNone.
  ///
  /// In en, this message translates to:
  /// **'Once'**
  String get recurrenceNone;

  /// No description provided for @recurrenceDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get recurrenceDaily;

  /// No description provided for @recurrenceWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get recurrenceWeekly;

  /// No description provided for @reminderPaused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get reminderPaused;

  /// No description provided for @reminderPause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get reminderPause;

  /// No description provided for @reminderResume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get reminderResume;

  /// Default notification body for a watering reminder.
  ///
  /// In en, this message translates to:
  /// **'Time to water your plant.'**
  String get reminderBodyWatering;

  /// Default notification body for a fertilizing reminder.
  ///
  /// In en, this message translates to:
  /// **'Time to fertilize your plant.'**
  String get reminderBodyFertilizing;

  /// Default notification body for a repotting reminder.
  ///
  /// In en, this message translates to:
  /// **'Time to repot your plant.'**
  String get reminderBodyRepotting;

  /// Default notification body for an inspection reminder.
  ///
  /// In en, this message translates to:
  /// **'Time to inspect your plant.'**
  String get reminderBodyInspection;

  /// Default notification body for a diagnosis follow-up reminder.
  ///
  /// In en, this message translates to:
  /// **'Follow up on your plant diagnosis.'**
  String get reminderBodyFollowUp;

  /// No description provided for @remindersEmpty.
  ///
  /// In en, this message translates to:
  /// **'No reminders yet'**
  String get remindersEmpty;

  /// No description provided for @remindersEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add a reminder to stay on top of plant care.'**
  String get remindersEmptyBody;

  /// No description provided for @notificationsPermissionBody.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications so we can remind you about plant care.'**
  String get notificationsPermissionBody;

  /// No description provided for @myPlants.
  ///
  /// In en, this message translates to:
  /// **'My plants'**
  String get myPlants;

  /// No description provided for @addPlant.
  ///
  /// In en, this message translates to:
  /// **'Add plant'**
  String get addPlant;

  /// No description provided for @editPlant.
  ///
  /// In en, this message translates to:
  /// **'Edit plant'**
  String get editPlant;

  /// No description provided for @plantSpecies.
  ///
  /// In en, this message translates to:
  /// **'Species (optional)'**
  String get plantSpecies;

  /// No description provided for @plantNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get plantNotes;

  /// No description provided for @plantsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No plants yet'**
  String get plantsEmpty;

  /// No description provided for @plantsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add a plant to track its care and history.'**
  String get plantsEmptyBody;

  /// No description provided for @askAboutPlant.
  ///
  /// In en, this message translates to:
  /// **'Ask about this plant'**
  String get askAboutPlant;

  /// No description provided for @plantLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get plantLocation;

  /// No description provided for @plantIndoor.
  ///
  /// In en, this message translates to:
  /// **'Indoor'**
  String get plantIndoor;

  /// No description provided for @plantOutdoor.
  ///
  /// In en, this message translates to:
  /// **'Outdoor'**
  String get plantOutdoor;

  /// No description provided for @markWatered.
  ///
  /// In en, this message translates to:
  /// **'Mark watered'**
  String get markWatered;

  /// No description provided for @wateringInterval.
  ///
  /// In en, this message translates to:
  /// **'Water every (days)'**
  String get wateringInterval;

  /// No description provided for @generateWateringSchedule.
  ///
  /// In en, this message translates to:
  /// **'Create watering schedule'**
  String get generateWateringSchedule;

  /// No description provided for @wateringScheduleCreated.
  ///
  /// In en, this message translates to:
  /// **'Watering reminder scheduled'**
  String get wateringScheduleCreated;

  /// No description provided for @privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy & data'**
  String get privacyTitle;

  /// No description provided for @privacyIntro.
  ///
  /// In en, this message translates to:
  /// **'Here\'s how PlantSense handles your data.'**
  String get privacyIntro;

  /// No description provided for @privacyProfile.
  ///
  /// In en, this message translates to:
  /// **'Your profile (name, email, preferences) is stored to your account.'**
  String get privacyProfile;

  /// No description provided for @privacyLocation.
  ///
  /// In en, this message translates to:
  /// **'Location is opt-in and used only for weather and care advice. We never collect location in the background.'**
  String get privacyLocation;

  /// No description provided for @privacyImages.
  ///
  /// In en, this message translates to:
  /// **'Images you submit are sent for AI analysis. They are retained only if you enable image saving; otherwise they\'re deleted after analysis.'**
  String get privacyImages;

  /// No description provided for @privacyProviders.
  ///
  /// In en, this message translates to:
  /// **'AI and infrastructure providers may process content you submit. AI answers may be inaccurate.'**
  String get privacyProviders;

  /// No description provided for @privacyControl.
  ///
  /// In en, this message translates to:
  /// **'You can disable retention, delete chats and diagnoses, and delete your account and data at any time.'**
  String get privacyControl;

  /// No description provided for @a11yError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get a11yError;

  /// No description provided for @a11ySendMessage.
  ///
  /// In en, this message translates to:
  /// **'Send message'**
  String get a11ySendMessage;

  /// No description provided for @a11yWeatherIcon.
  ///
  /// In en, this message translates to:
  /// **'Weather condition: {condition}'**
  String a11yWeatherIcon(String condition);

  /// No description provided for @a11yConfidence.
  ///
  /// In en, this message translates to:
  /// **'Confidence level: {level}'**
  String a11yConfidence(String level);

  /// No description provided for @errorNoConnection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Check your network and try again.'**
  String get errorNoConnection;

  /// No description provided for @errorTimeout.
  ///
  /// In en, this message translates to:
  /// **'The request timed out. Please try again.'**
  String get errorTimeout;

  /// No description provided for @errorPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission was denied.'**
  String get errorPermissionDenied;

  /// No description provided for @errorPermissionPermanentlyDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission is blocked. Enable it in Settings.'**
  String get errorPermissionPermanentlyDenied;

  /// No description provided for @errorLocationServicesDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location services are turned off.'**
  String get errorLocationServicesDisabled;

  /// No description provided for @errorAuthExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session expired. Please log in again.'**
  String get errorAuthExpired;

  /// No description provided for @errorUnauthenticated.
  ///
  /// In en, this message translates to:
  /// **'You need to be logged in to do that.'**
  String get errorUnauthenticated;

  /// No description provided for @errorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password.'**
  String get errorInvalidCredentials;

  /// No description provided for @errorRateLimited.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Please wait a moment and try again.'**
  String get errorRateLimited;

  /// No description provided for @errorInvalidInput.
  ///
  /// In en, this message translates to:
  /// **'That input isn\'t valid. Please review and try again.'**
  String get errorInvalidInput;

  /// No description provided for @errorImageTooLarge.
  ///
  /// In en, this message translates to:
  /// **'That image is too large. Try a smaller photo.'**
  String get errorImageTooLarge;

  /// No description provided for @errorContentBlocked.
  ///
  /// In en, this message translates to:
  /// **'That request was blocked for safety reasons.'**
  String get errorContentBlocked;

  /// No description provided for @errorModelUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The AI service is temporarily unavailable.'**
  String get errorModelUnavailable;

  /// No description provided for @errorMalformedResponse.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t read the response. Please try again.'**
  String get errorMalformedResponse;

  /// No description provided for @errorProviderUnavailable.
  ///
  /// In en, this message translates to:
  /// **'A service is temporarily unavailable. Please try again.'**
  String get errorProviderUnavailable;

  /// No description provided for @errorNotFound.
  ///
  /// In en, this message translates to:
  /// **'Not found.'**
  String get errorNotFound;

  /// No description provided for @errorUnknown.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorUnknown;

  /// No description provided for @emailInUse.
  ///
  /// In en, this message translates to:
  /// **'That email is already registered.'**
  String get emailInUse;

  /// No description provided for @userDisabled.
  ///
  /// In en, this message translates to:
  /// **'This account has been disabled.'**
  String get userDisabled;

  /// No description provided for @userNotFound.
  ///
  /// In en, this message translates to:
  /// **'No account found for that email.'**
  String get userNotFound;

  /// No description provided for @demoModeBanner.
  ///
  /// In en, this message translates to:
  /// **'Demo mode — using sample data. Configure Firebase & Groq for full features.'**
  String get demoModeBanner;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'es', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
