import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

/// Application localizations. This file mirrors the output of Flutter's
/// `gen-l10n` tool for the ARB files in this directory. Running
/// `flutter gen-l10n` regenerates an equivalent file, so it is safe to keep it
/// committed for environments where codegen has not yet run.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ar'),
  ];

  // Common
  String get appTitle;
  String get tagline;
  String get retry;
  String get cancel;
  String get confirm;
  String get save;
  String get delete;
  String get close;
  String get next;
  String get back;
  String get skip;
  String get getStarted;
  String get openSettings;
  String get loading;
  String get somethingWentWrong;

  // Navigation
  String get navChat;
  String get navDiagnose;
  String get navWeather;
  String get navProfile;

  // Connectivity
  String get offlineBanner;
  String lastUpdated(String time);
  String get cachedData;
  String get liveData;

  // Onboarding
  String get onboardingTitle1;
  String get onboardingBody1;
  String get onboardingTitle2;
  String get onboardingBody2;
  String get onboardingTitle3;
  String get onboardingBody3;
  String get onboardingTitle4;
  String get onboardingBody4;

  // Auth
  String get login;
  String get register;
  String get email;
  String get password;
  String get confirmPassword;
  String get displayName;
  String get forgotPassword;
  String get continueWithGoogle;
  String get noAccountPrompt;
  String get haveAccountPrompt;
  String get sendResetLink;
  String get resetLinkSent;
  String get verifyEmailNotice;
  String get showPassword;
  String get hidePassword;

  // Validation
  String get emailRequired;
  String get emailInvalid;
  String get emailTooLong;
  String get passwordRequired;
  String get passwordTooShort;
  String get passwordTooLong;
  String get passwordWeak;
  String get passwordMismatch;
  String get nameRequired;
  String get nameTooLong;

  // Chat
  String get chatTitle;
  String get chatEmptyTitle;
  String get chatEmptyBody;
  String get composerHint;
  String get send;
  String get attachImage;
  String get removeImage;
  String get voiceInput;
  String get readAloud;
  String get stopAudio;
  String get fromCamera;
  String get fromGallery;
  String get copy;
  String get copied;
  String get deleteConversation;
  String get deleteConversationConfirm;
  String get conversations;
  String get newChat;
  String get rename;
  String get messageFailed;
  String get sending;
  String get typing;
  String charactersRemaining(int count);
  String get aiDisclaimerShort;
  String get contextUnavailable;

  // Chat starters
  String get starterYellowLeaves;
  String get starterWaterBasil;
  String get starterSucculentSoil;
  String get starterIdentifyPest;
  String get starterTransplant;
  String get starterClayDrainage;

  // Diagnosis
  String get diagnoseTitle;
  String get cameraInitializing;
  String get cameraPermissionTitle;
  String get cameraPermissionBody;
  String get cameraPermissionDeniedBody;
  String get cameraUnavailable;
  String get captureFailed;
  String get allowCamera;
  String get flashOn;
  String get flashOff;
  String get switchCamera;
  String get capture;
  String get retake;
  String get cropImage;
  String get confirmPhoto;
  String get analyzing;
  String get cancelAnalysis;
  String get diagnosisPlant;
  String get diagnosisWhatISee;
  String get diagnosisIssue;
  String get diagnosisTreatment;
  String get diagnosisPrevention;
  String get diagnosisSafety;
  String get diagnosisConfidence;
  String get confidenceLow;
  String get confidenceMedium;
  String get confidenceHigh;
  String get likelihoodLow;
  String get likelihoodMedium;
  String get likelihoodHigh;
  String get needMoreInfo;
  String get notPlantRelated;
  String get poorImageQuality;
  String get saveDiagnosis;
  String get diagnosisSaved;
  String get askFollowUp;
  String get shareSummary;
  String get diagnosisHistory;
  String get diagnosisHistoryEmpty;
  String get diagnosisHistoryEmptyBody;
  String get aiDisclaimerLong;

  // Weather
  String get weatherTitle;
  String get currentWeather;
  String feelsLike(String value);
  String get humidity;
  String get uvIndex;
  String get precipitation;
  String get hourlyForecast;
  String get sevenDayForecast;
  String get plantCareTips;
  String rainChance(int value);
  String get weatherUnavailable;
  String get pullToRefresh;
  String get tipHighUv;
  String get tipNoRain;
  String get tipHighHumidity;
  String get tipFreezing;
  String get tipHot;
  String get tipMild;

  // Location
  String get locationTitle;
  String get useMyLocation;
  String get searchCity;
  String get locationRationale;
  String get locationDeniedBody;
  String get locationServicesOff;
  String get geocodeFailed;
  String get selectCity;
  String get noResults;

  // Profile / settings
  String get profileTitle;
  String get editProfile;
  String get language;
  String get theme;
  String get themeSystem;
  String get themeLight;
  String get themeDark;
  String get units;
  String get unitsMetric;
  String get unitsImperial;
  String get notifications;
  String get imageRetention;
  String get imageRetentionBody;
  String get reminders;
  String get privacyPolicy;
  String get termsOfService;
  String get reportIssue;
  String appVersion(String version);
  String get logout;
  String get logoutConfirm;
  String get deleteAccount;
  String get deleteAccountConfirm;
  String get deleteAllData;
  String get deleteAllDataConfirm;
  String get reauthRequired;
  String get deleting;
  String get deleted;

  // Reminders
  String get remindersTitle;
  String get addReminder;
  String get reminderPlantName;
  String get reminderNote;
  String get reminderType;
  String get reminderWatering;
  String get reminderFertilizing;
  String get reminderRepotting;
  String get reminderInspection;
  String get reminderFollowUp;
  String get reminderDateTime;
  String get reminderRecurrence;
  String get recurrenceNone;
  String get recurrenceDaily;
  String get recurrenceWeekly;
  String get reminderPaused;
  String get reminderPause;
  String get reminderResume;
  String get remindersEmpty;
  String get remindersEmptyBody;
  String get notificationsPermissionBody;

  // My Plants
  String get myPlants;
  String get addPlant;
  String get editPlant;
  String get plantSpecies;
  String get plantNotes;
  String get plantsEmpty;
  String get plantsEmptyBody;
  String get askAboutPlant;
  String get plantLocation;
  String get plantIndoor;
  String get plantOutdoor;
  String get markWatered;
  String get wateringInterval;
  String get generateWateringSchedule;
  String get wateringScheduleCreated;

  // Privacy
  String get privacyTitle;
  String get privacyIntro;
  String get privacyProfile;
  String get privacyLocation;
  String get privacyImages;
  String get privacyProviders;
  String get privacyControl;

  // Accessibility
  String get a11yError;
  String get a11ySendMessage;
  String a11yWeatherIcon(String condition);
  String a11yConfidence(String level);

  // Errors
  String get errorNoConnection;
  String get errorTimeout;
  String get errorPermissionDenied;
  String get errorPermissionPermanentlyDenied;
  String get errorLocationServicesDisabled;
  String get errorAuthExpired;
  String get errorUnauthenticated;
  String get errorInvalidCredentials;
  String get errorRateLimited;
  String get errorInvalidInput;
  String get errorImageTooLarge;
  String get errorContentBlocked;
  String get errorModelUnavailable;
  String get errorMalformedResponse;
  String get errorProviderUnavailable;
  String get errorNotFound;
  String get errorUnknown;
  String get emailInUse;
  String get userDisabled;
  String get userNotFound;

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
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }
  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale".',
  );
}
