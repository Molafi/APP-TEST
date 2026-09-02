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

  /// No description provided for @georesearchTitle.
  ///
  /// In en, this message translates to:
  /// **'GeoResearch'**
  String get georesearchTitle;

  /// No description provided for @navGeoResearch.
  ///
  /// In en, this message translates to:
  /// **'Soil'**
  String get navGeoResearch;

  /// No description provided for @georesearchIntro.
  ///
  /// In en, this message translates to:
  /// **'Get an estimated soil profile for your location. Optionally add a site photo to estimate soil structure.'**
  String get georesearchIntro;

  /// No description provided for @georesearchAddPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add a soil/site photo'**
  String get georesearchAddPhoto;

  /// No description provided for @georesearchChangePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get georesearchChangePhoto;

  /// No description provided for @georesearchRemovePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get georesearchRemovePhoto;

  /// No description provided for @georesearchTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get georesearchTakePhoto;

  /// No description provided for @georesearchChoosePhoto.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get georesearchChoosePhoto;

  /// No description provided for @georesearchNoLocation.
  ///
  /// In en, this message translates to:
  /// **'Set your location to get a location-aware soil estimate.'**
  String get georesearchNoLocation;

  /// No description provided for @georesearchAnalyze.
  ///
  /// In en, this message translates to:
  /// **'Analyze soil'**
  String get georesearchAnalyze;

  /// No description provided for @georesearchAnalyzing.
  ///
  /// In en, this message translates to:
  /// **'Researching your soil…'**
  String get georesearchAnalyzing;

  /// No description provided for @georesearchLocation.
  ///
  /// In en, this message translates to:
  /// **'Location & soil type'**
  String get georesearchLocation;

  /// No description provided for @georesearchSoilType.
  ///
  /// In en, this message translates to:
  /// **'Soil type / texture'**
  String get georesearchSoilType;

  /// No description provided for @georesearchDepth.
  ///
  /// In en, this message translates to:
  /// **'Soil depth / profile'**
  String get georesearchDepth;

  /// No description provided for @georesearchSalinitySodium.
  ///
  /// In en, this message translates to:
  /// **'Salinity & sodium'**
  String get georesearchSalinitySodium;

  /// No description provided for @georesearchSalinity.
  ///
  /// In en, this message translates to:
  /// **'Salinity (salt)'**
  String get georesearchSalinity;

  /// No description provided for @georesearchSodium.
  ///
  /// In en, this message translates to:
  /// **'Sodium'**
  String get georesearchSodium;

  /// No description provided for @georesearchPhOrganic.
  ///
  /// In en, this message translates to:
  /// **'pH & organic matter'**
  String get georesearchPhOrganic;

  /// No description provided for @georesearchPh.
  ///
  /// In en, this message translates to:
  /// **'pH'**
  String get georesearchPh;

  /// No description provided for @georesearchOrganicMatter.
  ///
  /// In en, this message translates to:
  /// **'Organic matter'**
  String get georesearchOrganicMatter;

  /// No description provided for @georesearchNutrients.
  ///
  /// In en, this message translates to:
  /// **'Nutrients (N-P-K)'**
  String get georesearchNutrients;

  /// No description provided for @georesearchSubstances.
  ///
  /// In en, this message translates to:
  /// **'Notable substances'**
  String get georesearchSubstances;

  /// No description provided for @georesearchGeometry.
  ///
  /// In en, this message translates to:
  /// **'Soil structure / geometry'**
  String get georesearchGeometry;

  /// No description provided for @georesearchSuitablePlants.
  ///
  /// In en, this message translates to:
  /// **'Suitable plants'**
  String get georesearchSuitablePlants;

  /// No description provided for @georesearchRecommendations.
  ///
  /// In en, this message translates to:
  /// **'Recommendations'**
  String get georesearchRecommendations;

  /// No description provided for @georesearchSafety.
  ///
  /// In en, this message translates to:
  /// **'Safety notes'**
  String get georesearchSafety;

  /// No description provided for @georesearchNotSoilRelated.
  ///
  /// In en, this message translates to:
  /// **'This doesn\'t look soil or site related. Try a photo of soil or the ground/site.'**
  String get georesearchNotSoilRelated;

  /// No description provided for @georesearchEstimateNotice.
  ///
  /// In en, this message translates to:
  /// **'These are estimates based on your location and photo. Exact sodium, salinity and nutrient values require a professional soil-lab test.'**
  String get georesearchEstimateNotice;

  /// No description provided for @georesearchSave.
  ///
  /// In en, this message translates to:
  /// **'Save report'**
  String get georesearchSave;

  /// No description provided for @georesearchSaved.
  ///
  /// In en, this message translates to:
  /// **'Report saved'**
  String get georesearchSaved;

  /// No description provided for @georesearchHistory.
  ///
  /// In en, this message translates to:
  /// **'Soil reports'**
  String get georesearchHistory;

  /// No description provided for @georesearchHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No saved soil reports yet'**
  String get georesearchHistoryEmpty;

  /// No description provided for @georesearchHistoryEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Analyze your soil to build your history.'**
  String get georesearchHistoryEmptyBody;

  /// No description provided for @georesearchPurpose.
  ///
  /// In en, this message translates to:
  /// **'What do you need this survey for?'**
  String get georesearchPurpose;

  /// No description provided for @georesearchPurposeGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get georesearchPurposeGeneral;

  /// No description provided for @georesearchPurposeAgriculture.
  ///
  /// In en, this message translates to:
  /// **'Farming'**
  String get georesearchPurposeAgriculture;

  /// No description provided for @georesearchPurposeBuilding.
  ///
  /// In en, this message translates to:
  /// **'Building'**
  String get georesearchPurposeBuilding;

  /// No description provided for @georesearchPurposeWellDrilling.
  ///
  /// In en, this message translates to:
  /// **'Water well'**
  String get georesearchPurposeWellDrilling;

  /// No description provided for @georesearchRequirements.
  ///
  /// In en, this message translates to:
  /// **'Your requirements'**
  String get georesearchRequirements;

  /// No description provided for @georesearchRequirementsHint.
  ///
  /// In en, this message translates to:
  /// **'Describe what you plan to do with this land, e.g. build a two-storey house, plant olive trees, drill a well.'**
  String get georesearchRequirementsHint;

  /// No description provided for @georesearchLandRecordSection.
  ///
  /// In en, this message translates to:
  /// **'Land Department data (optional)'**
  String get georesearchLandRecordSection;

  /// No description provided for @georesearchLandRecordToggle.
  ///
  /// In en, this message translates to:
  /// **'I have official Land Department data'**
  String get georesearchLandRecordToggle;

  /// No description provided for @georesearchLandRecordHelp.
  ///
  /// In en, this message translates to:
  /// **'If official records are available, enter them and the survey will use them as authoritative instead of estimating.'**
  String get georesearchLandRecordHelp;

  /// No description provided for @georesearchLandRecordSource.
  ///
  /// In en, this message translates to:
  /// **'Issuing authority / registry'**
  String get georesearchLandRecordSource;

  /// No description provided for @georesearchLandParcelId.
  ///
  /// In en, this message translates to:
  /// **'Parcel / plot / deed number'**
  String get georesearchLandParcelId;

  /// No description provided for @georesearchLandRegisteredArea.
  ///
  /// In en, this message translates to:
  /// **'Registered area'**
  String get georesearchLandRegisteredArea;

  /// No description provided for @georesearchLandZoning.
  ///
  /// In en, this message translates to:
  /// **'Zoning / permitted use'**
  String get georesearchLandZoning;

  /// No description provided for @georesearchLandClassification.
  ///
  /// In en, this message translates to:
  /// **'Land classification'**
  String get georesearchLandClassification;

  /// No description provided for @georesearchLandOwnershipType.
  ///
  /// In en, this message translates to:
  /// **'Ownership type'**
  String get georesearchLandOwnershipType;

  /// No description provided for @georesearchLandOfficialNotes.
  ///
  /// In en, this message translates to:
  /// **'Other official notes'**
  String get georesearchLandOfficialNotes;

  /// No description provided for @georesearchLandRecordOfficial.
  ///
  /// In en, this message translates to:
  /// **'Official record'**
  String get georesearchLandRecordOfficial;

  /// No description provided for @georesearchAerial.
  ///
  /// In en, this message translates to:
  /// **'Aerial / satellite view'**
  String get georesearchAerial;

  /// No description provided for @georesearchAerialLandCover.
  ///
  /// In en, this message translates to:
  /// **'Land cover'**
  String get georesearchAerialLandCover;

  /// No description provided for @georesearchAerialFeatures.
  ///
  /// In en, this message translates to:
  /// **'Visible features'**
  String get georesearchAerialFeatures;

  /// No description provided for @georesearchAerialUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Set a location to see an aerial view of the site.'**
  String get georesearchAerialUnavailable;

  /// No description provided for @georesearchAerialNotice.
  ///
  /// In en, this message translates to:
  /// **'Aerial imagery is undated context only, not a current aerial survey.'**
  String get georesearchAerialNotice;

  /// No description provided for @georesearchSite.
  ///
  /// In en, this message translates to:
  /// **'Site location'**
  String get georesearchSite;

  /// No description provided for @georesearchSiteAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get georesearchSiteAddress;

  /// No description provided for @georesearchSiteElevation.
  ///
  /// In en, this message translates to:
  /// **'Elevation'**
  String get georesearchSiteElevation;

  /// No description provided for @georesearchSiteArea.
  ///
  /// In en, this message translates to:
  /// **'Approximate area'**
  String get georesearchSiteArea;

  /// No description provided for @georesearchSiteBoundary.
  ///
  /// In en, this message translates to:
  /// **'Boundaries / extent'**
  String get georesearchSiteBoundary;

  /// No description provided for @georesearchSiteAccess.
  ///
  /// In en, this message translates to:
  /// **'Access'**
  String get georesearchSiteAccess;

  /// No description provided for @georesearchSiteTerrain.
  ///
  /// In en, this message translates to:
  /// **'Setting'**
  String get georesearchSiteTerrain;

  /// No description provided for @georesearchTopography.
  ///
  /// In en, this message translates to:
  /// **'Topographic survey'**
  String get georesearchTopography;

  /// No description provided for @georesearchTopoElevationRange.
  ///
  /// In en, this message translates to:
  /// **'Elevation range'**
  String get georesearchTopoElevationRange;

  /// No description provided for @georesearchTopoSlope.
  ///
  /// In en, this message translates to:
  /// **'Slope'**
  String get georesearchTopoSlope;

  /// No description provided for @georesearchTopoAspect.
  ///
  /// In en, this message translates to:
  /// **'Aspect'**
  String get georesearchTopoAspect;

  /// No description provided for @georesearchTopoLandform.
  ///
  /// In en, this message translates to:
  /// **'Landform'**
  String get georesearchTopoLandform;

  /// No description provided for @georesearchTopoRelief.
  ///
  /// In en, this message translates to:
  /// **'Relief'**
  String get georesearchTopoRelief;

  /// No description provided for @georesearchTopoContours.
  ///
  /// In en, this message translates to:
  /// **'Contours'**
  String get georesearchTopoContours;

  /// No description provided for @georesearchTopoDrainage.
  ///
  /// In en, this message translates to:
  /// **'Drainage pattern'**
  String get georesearchTopoDrainage;

  /// No description provided for @georesearchTopoRunoff.
  ///
  /// In en, this message translates to:
  /// **'Runoff'**
  String get georesearchTopoRunoff;

  /// No description provided for @georesearchTopoFloodRisk.
  ///
  /// In en, this message translates to:
  /// **'Flood risk'**
  String get georesearchTopoFloodRisk;

  /// No description provided for @georesearchTopoErosionRisk.
  ///
  /// In en, this message translates to:
  /// **'Erosion risk'**
  String get georesearchTopoErosionRisk;

  /// No description provided for @georesearchTopoGrading.
  ///
  /// In en, this message translates to:
  /// **'Grading / earthworks'**
  String get georesearchTopoGrading;

  /// No description provided for @georesearchTopoNotice.
  ///
  /// In en, this message translates to:
  /// **'Desk-study estimate. Design-grade contours require a licensed instrument or drone survey.'**
  String get georesearchTopoNotice;

  /// No description provided for @georesearchGroundwater.
  ///
  /// In en, this message translates to:
  /// **'Groundwater'**
  String get georesearchGroundwater;

  /// No description provided for @georesearchGwWaterTable.
  ///
  /// In en, this message translates to:
  /// **'Water table depth'**
  String get georesearchGwWaterTable;

  /// No description provided for @georesearchGwAquifer.
  ///
  /// In en, this message translates to:
  /// **'Aquifer type'**
  String get georesearchGwAquifer;

  /// No description provided for @georesearchGwYield.
  ///
  /// In en, this message translates to:
  /// **'Yield potential'**
  String get georesearchGwYield;

  /// No description provided for @georesearchGwQuality.
  ///
  /// In en, this message translates to:
  /// **'Water quality'**
  String get georesearchGwQuality;

  /// No description provided for @georesearchGwSalinityRisk.
  ///
  /// In en, this message translates to:
  /// **'Salinity risk'**
  String get georesearchGwSalinityRisk;

  /// No description provided for @georesearchGwSeasonal.
  ///
  /// In en, this message translates to:
  /// **'Seasonal variation'**
  String get georesearchGwSeasonal;

  /// No description provided for @georesearchGwRecharge.
  ///
  /// In en, this message translates to:
  /// **'Recharge'**
  String get georesearchGwRecharge;

  /// No description provided for @georesearchGwWellFeasibility.
  ///
  /// In en, this message translates to:
  /// **'Well feasibility'**
  String get georesearchGwWellFeasibility;

  /// No description provided for @georesearchGwDrillingDepth.
  ///
  /// In en, this message translates to:
  /// **'Estimated drilling depth'**
  String get georesearchGwDrillingDepth;

  /// No description provided for @georesearchGwContamination.
  ///
  /// In en, this message translates to:
  /// **'Contamination risk'**
  String get georesearchGwContamination;

  /// No description provided for @georesearchGwNotice.
  ///
  /// In en, this message translates to:
  /// **'Regional estimate. A hydrogeological study and a drilling permit are required before drilling.'**
  String get georesearchGwNotice;

  /// No description provided for @georesearchBuilding.
  ///
  /// In en, this message translates to:
  /// **'Building suitability'**
  String get georesearchBuilding;

  /// No description provided for @georesearchBuildRating.
  ///
  /// In en, this message translates to:
  /// **'Screening rating'**
  String get georesearchBuildRating;

  /// No description provided for @georesearchBuildBearing.
  ///
  /// In en, this message translates to:
  /// **'Bearing capacity'**
  String get georesearchBuildBearing;

  /// No description provided for @georesearchBuildBedrock.
  ///
  /// In en, this message translates to:
  /// **'Depth to bedrock'**
  String get georesearchBuildBedrock;

  /// No description provided for @georesearchBuildFoundation.
  ///
  /// In en, this message translates to:
  /// **'Possible foundation approach'**
  String get georesearchBuildFoundation;

  /// No description provided for @georesearchBuildSettlement.
  ///
  /// In en, this message translates to:
  /// **'Settlement risk'**
  String get georesearchBuildSettlement;

  /// No description provided for @georesearchBuildExpansive.
  ///
  /// In en, this message translates to:
  /// **'Expansive soil risk'**
  String get georesearchBuildExpansive;

  /// No description provided for @georesearchBuildSeismic.
  ///
  /// In en, this message translates to:
  /// **'Seismic context'**
  String get georesearchBuildSeismic;

  /// No description provided for @georesearchBuildExcavation.
  ///
  /// In en, this message translates to:
  /// **'Excavation'**
  String get georesearchBuildExcavation;

  /// No description provided for @georesearchBuildDrainage.
  ///
  /// In en, this message translates to:
  /// **'Site drainage'**
  String get georesearchBuildDrainage;

  /// No description provided for @georesearchBuildConstraints.
  ///
  /// In en, this message translates to:
  /// **'Constraints'**
  String get georesearchBuildConstraints;

  /// No description provided for @georesearchBuildRequiredStudies.
  ///
  /// In en, this message translates to:
  /// **'Required professional studies'**
  String get georesearchBuildRequiredStudies;

  /// No description provided for @georesearchBuildNotice.
  ///
  /// In en, this message translates to:
  /// **'Preliminary screening only. This is NOT a geotechnical report and must not be used for foundation design. Commission a licensed geotechnical investigation before building.'**
  String get georesearchBuildNotice;

  /// No description provided for @georesearchDataSources.
  ///
  /// In en, this message translates to:
  /// **'Data sources'**
  String get georesearchDataSources;

  /// No description provided for @concernLow.
  ///
  /// In en, this message translates to:
  /// **'Low concern'**
  String get concernLow;

  /// No description provided for @concernMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium concern'**
  String get concernMedium;

  /// No description provided for @concernHigh.
  ///
  /// In en, this message translates to:
  /// **'High concern'**
  String get concernHigh;

  /// No description provided for @levelLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get levelLow;

  /// No description provided for @levelMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get levelMedium;

  /// No description provided for @levelHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get levelHigh;

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

  /// No description provided for @georesearchPurposeSlopeStability.
  ///
  /// In en, this message translates to:
  /// **'Land stability'**
  String get georesearchPurposeSlopeStability;

  /// No description provided for @georesearchPurposeHelp.
  ///
  /// In en, this message translates to:
  /// **'Your choice decides what the survey focuses on: plants and soil nutrients, groundwater and wells, foundations and building, or land movement and slope stability.'**
  String get georesearchPurposeHelp;

  /// No description provided for @georesearchPurposeSection.
  ///
  /// In en, this message translates to:
  /// **'Survey purpose'**
  String get georesearchPurposeSection;

  /// No description provided for @georesearchPurposeValue.
  ///
  /// In en, this message translates to:
  /// **'Requested for'**
  String get georesearchPurposeValue;

  /// No description provided for @georesearchSlope.
  ///
  /// In en, this message translates to:
  /// **'Slope stability & land movement'**
  String get georesearchSlope;

  /// No description provided for @georesearchSlopeHazard.
  ///
  /// In en, this message translates to:
  /// **'Hazard rating'**
  String get georesearchSlopeHazard;

  /// No description provided for @georesearchSlopeActivity.
  ///
  /// In en, this message translates to:
  /// **'Activity state'**
  String get georesearchSlopeActivity;

  /// No description provided for @georesearchSlopeDirection.
  ///
  /// In en, this message translates to:
  /// **'Direction of land movement'**
  String get georesearchSlopeDirection;

  /// No description provided for @georesearchSlopeAzimuth.
  ///
  /// In en, this message translates to:
  /// **'Approximate bearing'**
  String get georesearchSlopeAzimuth;

  /// No description provided for @georesearchSlopeSlipDepth.
  ///
  /// In en, this message translates to:
  /// **'Depth of the slip surface'**
  String get georesearchSlopeSlipDepth;

  /// No description provided for @georesearchSlopeSlipType.
  ///
  /// In en, this message translates to:
  /// **'Failure geometry'**
  String get georesearchSlopeSlipType;

  /// No description provided for @georesearchSlopeRate.
  ///
  /// In en, this message translates to:
  /// **'Rate of movement'**
  String get georesearchSlopeRate;

  /// No description provided for @georesearchSlopeRateClass.
  ///
  /// In en, this message translates to:
  /// **'Movement rate class'**
  String get georesearchSlopeRateClass;

  /// No description provided for @georesearchSlopeMechanism.
  ///
  /// In en, this message translates to:
  /// **'Failure mechanism'**
  String get georesearchSlopeMechanism;

  /// No description provided for @georesearchSlopeIndicators.
  ///
  /// In en, this message translates to:
  /// **'Warning signs to look for on site'**
  String get georesearchSlopeIndicators;

  /// No description provided for @georesearchSlopeTriggers.
  ///
  /// In en, this message translates to:
  /// **'Possible triggers'**
  String get georesearchSlopeTriggers;

  /// No description provided for @georesearchSlopeAtRisk.
  ///
  /// In en, this message translates to:
  /// **'Structures exposed to movement'**
  String get georesearchSlopeAtRisk;

  /// No description provided for @georesearchSlopeAtRiskNotice.
  ///
  /// In en, this message translates to:
  /// **'Exposure is inferred from position on the slope, not from the condition of any specific building. Nothing here supports an occupancy or evacuation decision — that needs a licensed geotechnical engineer and your local authority.'**
  String get georesearchSlopeAtRiskNotice;

  /// No description provided for @georesearchSlopeZones.
  ///
  /// In en, this message translates to:
  /// **'Areas that could be built on after treatment'**
  String get georesearchSlopeZones;

  /// No description provided for @georesearchSlopeZoneAfterTreatment.
  ///
  /// In en, this message translates to:
  /// **'Buildable ONLY after treatment'**
  String get georesearchSlopeZoneAfterTreatment;

  /// No description provided for @georesearchSlopeZoneNotBuildable.
  ///
  /// In en, this message translates to:
  /// **'Not buildable on current evidence'**
  String get georesearchSlopeZoneNotBuildable;

  /// No description provided for @georesearchSlopeZoneTreatments.
  ///
  /// In en, this message translates to:
  /// **'Required treatments'**
  String get georesearchSlopeZoneTreatments;

  /// No description provided for @georesearchSlopeZonesNotice.
  ///
  /// In en, this message translates to:
  /// **'\"Buildable after treatment\" is conditional: it holds only if the listed treatments are carried out and a licensed geotechnical engineer designs and signs off the works. No area is cleared as safe by this report.'**
  String get georesearchSlopeZonesNotice;

  /// No description provided for @georesearchSlopeStabilisation.
  ///
  /// In en, this message translates to:
  /// **'Possible stabilisation measures'**
  String get georesearchSlopeStabilisation;

  /// No description provided for @georesearchSlopeMonitoring.
  ///
  /// In en, this message translates to:
  /// **'Monitoring & instrumentation'**
  String get georesearchSlopeMonitoring;

  /// No description provided for @georesearchSlopeRequiredStudies.
  ///
  /// In en, this message translates to:
  /// **'Required professional studies'**
  String get georesearchSlopeRequiredStudies;

  /// No description provided for @georesearchSlopeMeasureNotice.
  ///
  /// In en, this message translates to:
  /// **'Direction, slip-surface depth and movement rate cannot be measured from a phone. The values above are screening ranges only: inclinometers and piezometers installed in boreholes, plus repeated GNSS or InSAR observation, are what actually measure them.'**
  String get georesearchSlopeMeasureNotice;

  /// No description provided for @georesearchSlopeNotice.
  ///
  /// In en, this message translates to:
  /// **'Preliminary desk screening only. This is NOT a slope-stability analysis and carries no factor of safety. If you see fresh cracks, tilting walls or displaced pipes, contact a licensed geotechnical engineer and your local authority without delay.'**
  String get georesearchSlopeNotice;

  /// No description provided for @georesearchOfficialMap.
  ///
  /// In en, this message translates to:
  /// **'Official maps & national grid'**
  String get georesearchOfficialMap;

  /// No description provided for @georesearchOfficialMapAuthority.
  ///
  /// In en, this message translates to:
  /// **'Mapping authority'**
  String get georesearchOfficialMapAuthority;

  /// No description provided for @georesearchOfficialMapGrid.
  ///
  /// In en, this message translates to:
  /// **'National grid'**
  String get georesearchOfficialMapGrid;

  /// No description provided for @georesearchOfficialMapEasting.
  ///
  /// In en, this message translates to:
  /// **'Easting (E)'**
  String get georesearchOfficialMapEasting;

  /// No description provided for @georesearchOfficialMapNorthing.
  ///
  /// In en, this message translates to:
  /// **'Northing (N)'**
  String get georesearchOfficialMapNorthing;

  /// No description provided for @georesearchOfficialMapWgs.
  ///
  /// In en, this message translates to:
  /// **'GPS coordinates (WGS84)'**
  String get georesearchOfficialMapWgs;

  /// No description provided for @georesearchOfficialMapPortal.
  ///
  /// In en, this message translates to:
  /// **'Open the geoportal'**
  String get georesearchOfficialMapPortal;

  /// No description provided for @georesearchOfficialMapOrder.
  ///
  /// In en, this message translates to:
  /// **'Order official maps & aerial photos'**
  String get georesearchOfficialMapOrder;

  /// No description provided for @georesearchOfficialMapCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy grid reference'**
  String get georesearchOfficialMapCopy;

  /// No description provided for @georesearchOfficialMapCopied.
  ///
  /// In en, this message translates to:
  /// **'Grid reference copied'**
  String get georesearchOfficialMapCopied;

  /// No description provided for @georesearchOfficialMapUnshifted.
  ///
  /// In en, this message translates to:
  /// **'Unofficial conversion: no datum transformation was applied, so this can differ from a surveyed grid value by tens of metres. Ask the authority for the official transformation parameters before relying on it.'**
  String get georesearchOfficialMapUnshifted;

  /// No description provided for @georesearchOfficialMapShifted.
  ///
  /// In en, this message translates to:
  /// **'Converted using the datum parameters configured for this build. Still a locating reference, not a surveyed position.'**
  String get georesearchOfficialMapShifted;

  /// No description provided for @georesearchOfficialMapNotice.
  ///
  /// In en, this message translates to:
  /// **'Grid values are provided for locating the site and for ordering official map sheets and aerial photographs. Boundary, ownership and design work requires a licensed cadastral survey.'**
  String get georesearchOfficialMapNotice;

  /// No description provided for @georesearchOfficialMapTileUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The authority\'s official basemap layer is not enabled for this build (it requires an agreement with the Centre). The grid reference and the links below still work.'**
  String get georesearchOfficialMapTileUnavailable;
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
