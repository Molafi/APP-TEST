// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'بلانت سينس';

  @override
  String get tagline => 'مساعدك الذكي للنباتات والتربة';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get cancel => 'إلغاء';

  @override
  String get confirm => 'تأكيد';

  @override
  String get save => 'حفظ';

  @override
  String get delete => 'حذف';

  @override
  String get close => 'إغلاق';

  @override
  String get next => 'التالي';

  @override
  String get back => 'رجوع';

  @override
  String get skip => 'تخطٍّ';

  @override
  String get getStarted => 'لنبدأ';

  @override
  String get openSettings => 'فتح الإعدادات';

  @override
  String get loading => 'جارٍ التحميل…';

  @override
  String get somethingWentWrong => 'حدث خطأ ما';

  @override
  String get navChat => 'المحادثة';

  @override
  String get navDiagnose => 'التشخيص';

  @override
  String get navWeather => 'الطقس';

  @override
  String get navProfile => 'الملف الشخصي';

  @override
  String get offlineBanner =>
      'أنت غير متصل بالإنترنت. يتم عرض البيانات المخزنة إن وُجدت.';

  @override
  String lastUpdated(String time) {
    return 'آخر تحديث $time';
  }

  @override
  String get cachedData => 'بيانات مخزّنة';

  @override
  String get liveData => 'مباشر';

  @override
  String get onboardingTitle1 => 'اسأل عن أي نبات';

  @override
  String get onboardingBody1 =>
      'تحدث مع بلانت سينس حول النباتات والآفات والتربة باستخدام النص أو الصور.';

  @override
  String get onboardingTitle2 => 'التشخيص من صورة';

  @override
  String get onboardingBody2 =>
      'التقط صورة لورقة أو آفة أو مشكلة في التربة واحصل على إرشادات منظّمة وحذرة.';

  @override
  String get onboardingTitle3 => 'عناية تراعي الطقس';

  @override
  String get onboardingBody3 =>
      'شارك موقعك للحصول على طقس محلي ونصائح عناية مخصصة للنباتات.';

  @override
  String get onboardingTitle4 => 'أنت المتحكم';

  @override
  String get onboardingBody4 =>
      'قد تكون نتائج الذكاء الاصطناعي غير دقيقة. أنت تتحكم في الأذونات والاحتفاظ بالصور وبياناتك.';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get register => 'إنشاء حساب';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get displayName => 'الاسم المعروض';

  @override
  String get forgotPassword => 'هل نسيت كلمة المرور؟';

  @override
  String get continueWithGoogle => 'المتابعة عبر Google';

  @override
  String get noAccountPrompt => 'مستخدم جديد؟ أنشئ حسابًا';

  @override
  String get haveAccountPrompt => 'لديك حساب بالفعل؟ سجّل الدخول';

  @override
  String get sendResetLink => 'إرسال رابط إعادة التعيين';

  @override
  String get resetLinkSent =>
      'إذا كان هذا البريد مسجلًا، فسيصلك رابط إعادة التعيين.';

  @override
  String get verifyEmailNotice => 'يرجى تأكيد عنوان بريدك الإلكتروني.';

  @override
  String get showPassword => 'إظهار كلمة المرور';

  @override
  String get hidePassword => 'إخفاء كلمة المرور';

  @override
  String get emailRequired => 'يرجى إدخال بريدك الإلكتروني';

  @override
  String get emailInvalid => 'أدخل عنوان بريد إلكتروني صحيح';

  @override
  String get emailTooLong => 'البريد الإلكتروني طويل جدًا';

  @override
  String get passwordRequired => 'يرجى إدخال كلمة المرور';

  @override
  String get passwordTooShort => 'يجب أن تتكون كلمة المرور من 8 أحرف على الأقل';

  @override
  String get passwordTooLong => 'كلمة المرور طويلة جدًا';

  @override
  String get passwordWeak => 'استخدم حرفًا واحدًا ورقمًا واحدًا على الأقل';

  @override
  String get passwordMismatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get nameRequired => 'يرجى إدخال اسم معروض';

  @override
  String get nameTooLong => 'الاسم المعروض طويل جدًا';

  @override
  String get chatTitle => 'محادثة بلانت سينس';

  @override
  String get chatEmptyTitle => 'اطرح سؤالك الأول';

  @override
  String get chatEmptyBody => 'اختر أحد الاقتراحات أدناه أو اكتب سؤالك.';

  @override
  String get composerHint => 'اسأل عن نبتتك…';

  @override
  String get send => 'إرسال';

  @override
  String get attachImage => 'إرفاق صورة';

  @override
  String get removeImage => 'إزالة الصورة';

  @override
  String get voiceInput => 'إدخال صوتي';

  @override
  String get readAloud => 'قراءة بصوت عالٍ';

  @override
  String get stopAudio => 'إيقاف';

  @override
  String get fromCamera => 'التقاط صورة';

  @override
  String get fromGallery => 'الاختيار من المعرض';

  @override
  String get copy => 'نسخ';

  @override
  String get copied => 'تم النسخ';

  @override
  String get deleteConversation => 'حذف المحادثة';

  @override
  String get deleteConversationConfirm =>
      'هل تريد حذف هذه المحادثة؟ لا يمكن التراجع.';

  @override
  String get conversations => 'المحادثات';

  @override
  String get newChat => 'محادثة جديدة';

  @override
  String get rename => 'إعادة تسمية';

  @override
  String get messageFailed => 'فشل الإرسال. اضغط لإعادة المحاولة.';

  @override
  String get sending => 'جارٍ الإرسال…';

  @override
  String get typing => 'بلانت سينس يفكّر…';

  @override
  String charactersRemaining(int count) {
    return 'بقي $count حرفًا';
  }

  @override
  String get aiDisclaimerShort =>
      'قد تكون اقتراحات الذكاء الاصطناعي غير دقيقة.';

  @override
  String get contextUnavailable => 'سياق الموقع/الطقس غير متوفر';

  @override
  String get starterYellowLeaves => 'لماذا تتحول أوراق نبتتي إلى الأصفر؟';

  @override
  String get starterWaterBasil => 'كم مرة يجب أن أسقي الريحان؟';

  @override
  String get starterSucculentSoil => 'ما خليط التربة المناسب للعصاريات؟';

  @override
  String get starterIdentifyPest => 'هل يمكنك تحديد هذه الآفة؟';

  @override
  String get starterTransplant => 'هل طقس اليوم مناسب لإعادة الزراعة؟';

  @override
  String get starterClayDrainage => 'كيف أحسّن تصريف المياه في التربة الطينية؟';

  @override
  String get diagnoseTitle => 'التشخيص';

  @override
  String get cameraInitializing => 'جارٍ تشغيل الكاميرا…';

  @override
  String get cameraPermissionTitle => 'نحتاج إذن الكاميرا';

  @override
  String get cameraPermissionBody =>
      'يستخدم بلانت سينس الكاميرا لتصوير النباتات والتربة للتحليل. تُستخدم الصور فقط للتشخيص الذي تطلبه.';

  @override
  String get cameraPermissionDeniedBody =>
      'تم رفض إذن الكاميرا. لا يزال بإمكانك اختيار صورة من المعرض.';

  @override
  String get cameraUnavailable => 'لا توجد كاميرا متاحة على هذا الجهاز.';

  @override
  String get captureFailed => 'تعذّر التقاط الصورة. حاول مرة أخرى.';

  @override
  String get allowCamera => 'السماح للكاميرا';

  @override
  String get flashOn => 'الفلاش يعمل';

  @override
  String get flashOff => 'الفلاش متوقف';

  @override
  String get switchCamera => 'تبديل الكاميرا';

  @override
  String get capture => 'التقاط';

  @override
  String get retake => 'إعادة الالتقاط';

  @override
  String get cropImage => 'اقتصاص';

  @override
  String get confirmPhoto => 'استخدام هذه الصورة';

  @override
  String get analyzing => 'جارٍ تحليل صورتك…';

  @override
  String get cancelAnalysis => 'إلغاء التحليل';

  @override
  String get diagnosisPlant => 'النبات / الموضوع';

  @override
  String get diagnosisWhatISee => 'ما أراه';

  @override
  String get diagnosisIssue => 'المشكلات المكتشفة';

  @override
  String get diagnosisTreatment => 'خطوات العلاج';

  @override
  String get diagnosisPrevention => 'نصائح الوقاية';

  @override
  String get diagnosisSafety => 'ملاحظات السلامة';

  @override
  String get diagnosisConfidence => 'درجة الثقة';

  @override
  String get confidenceLow => 'منخفضة';

  @override
  String get confidenceMedium => 'متوسطة';

  @override
  String get confidenceHigh => 'عالية';

  @override
  String get likelihoodLow => 'احتمال منخفض';

  @override
  String get likelihoodMedium => 'احتمال متوسط';

  @override
  String get likelihoodHigh => 'احتمال مرتفع';

  @override
  String get needMoreInfo => 'أحتاج صورة أوضح';

  @override
  String get notPlantRelated =>
      'لا يبدو هذا متعلقًا بالنباتات. جرّب صورة لنبات أو ورقة أو آفة أو تربة.';

  @override
  String get poorImageQuality =>
      'الصورة غير واضحة. حاول مجددًا في إضاءة جيدة مع ملء الإطار بالمنطقة المصابة.';

  @override
  String get saveDiagnosis => 'حفظ التشخيص';

  @override
  String get diagnosisSaved => 'تم حفظ التشخيص';

  @override
  String get askFollowUp => 'طرح سؤال متابعة';

  @override
  String get shareSummary => 'مشاركة الملخص';

  @override
  String get diagnosisHistory => 'سجل التشخيص';

  @override
  String get diagnosisHistoryEmpty => 'لا توجد تشخيصات محفوظة بعد';

  @override
  String get diagnosisHistoryEmptyBody => 'شخّص نبتة لبناء سجلّك.';

  @override
  String get aiDisclaimerLong =>
      'يقدّم بلانت سينس اقتراحات وليست ضمانات. للحالات الخطيرة المتعلقة بأمراض النبات أو المبيدات أو المحاصيل الغذائية أو السميّة أو الزراعة، استشر مختصًا مؤهلًا في علم النبات أو الهندسة الزراعية أو البستنة أو الطب البيطري أو مركز مكافحة السموم أو الجهة الزراعية المحلية.';

  @override
  String get georesearchTitle => 'بحث جيولوجي';

  @override
  String get navGeoResearch => 'التربة';

  @override
  String get georesearchIntro =>
      'احصل على ملف تقديري للتربة في موقعك. يمكنك إضافة صورة للموقع لتقدير بنية التربة.';

  @override
  String get georesearchAddPhoto => 'أضف صورة للتربة/الموقع';

  @override
  String get georesearchChangePhoto => 'تغيير الصورة';

  @override
  String get georesearchRemovePhoto => 'إزالة الصورة';

  @override
  String get georesearchTakePhoto => 'التقاط صورة';

  @override
  String get georesearchChoosePhoto => 'اختر من المعرض';

  @override
  String get georesearchNoLocation =>
      'حدّد موقعك للحصول على تقدير للتربة مبني على الموقع.';

  @override
  String get georesearchAnalyze => 'تحليل التربة';

  @override
  String get georesearchAnalyzing => 'جارٍ بحث تربتك…';

  @override
  String get georesearchLocation => 'الموقع ونوع التربة';

  @override
  String get georesearchSoilType => 'نوع/قوام التربة';

  @override
  String get georesearchDepth => 'عمق/مقطع التربة';

  @override
  String get georesearchSalinitySodium => 'الملوحة والصوديوم';

  @override
  String get georesearchSalinity => 'الملوحة';

  @override
  String get georesearchSodium => 'الصوديوم';

  @override
  String get georesearchPhOrganic => 'الحموضة والمادة العضوية';

  @override
  String get georesearchPh => 'الحموضة';

  @override
  String get georesearchOrganicMatter => 'المادة العضوية';

  @override
  String get georesearchNutrients => 'العناصر الغذائية (N-P-K)';

  @override
  String get georesearchSubstances => 'مواد ملحوظة';

  @override
  String get georesearchGeometry => 'بنية/هندسة التربة';

  @override
  String get georesearchSuitablePlants => 'نباتات مناسبة';

  @override
  String get georesearchRecommendations => 'التوصيات';

  @override
  String get georesearchSafety => 'ملاحظات السلامة';

  @override
  String get georesearchNotSoilRelated =>
      'لا تبدو هذه الصورة متعلقة بالتربة أو الموقع. جرّب صورة للتربة أو الأرض.';

  @override
  String get georesearchEstimateNotice =>
      'هذه تقديرات مبنية على موقعك وصورتك. القيم الدقيقة للصوديوم والملوحة والعناصر الغذائية تتطلب فحصًا مخبريًا احترافيًا للتربة.';

  @override
  String get georesearchSave => 'حفظ التقرير';

  @override
  String get georesearchSaved => 'تم حفظ التقرير';

  @override
  String get georesearchHistory => 'تقارير التربة';

  @override
  String get georesearchHistoryEmpty => 'لا توجد تقارير تربة محفوظة بعد';

  @override
  String get georesearchHistoryEmptyBody => 'حلّل تربتك لبناء سجلّك.';

  @override
  String get georesearchPurpose => 'ما الغرض من هذا المسح؟';

  @override
  String get georesearchPurposeGeneral => 'عام';

  @override
  String get georesearchPurposeAgriculture => 'زراعة';

  @override
  String get georesearchPurposeBuilding => 'بناء';

  @override
  String get georesearchPurposeWellDrilling => 'بئر ماء';

  @override
  String get georesearchRequirements => 'متطلباتك';

  @override
  String get georesearchRequirementsHint =>
      'اشرح ما تخطط لفعله بهذه الأرض، مثل بناء منزل من طابقين، أو زراعة أشجار زيتون، أو حفر بئر.';

  @override
  String get georesearchLandRecordSection => 'بيانات دائرة الأراضي (اختياري)';

  @override
  String get georesearchLandRecordToggle => 'لدي بيانات رسمية من دائرة الأراضي';

  @override
  String get georesearchLandRecordHelp =>
      'إذا كانت السجلات الرسمية متوفرة، أدخلها وسيعتمدها المسح كمصدر موثوق بدلاً من التقدير.';

  @override
  String get georesearchLandRecordSource => 'الجهة المُصدِرة / السجل';

  @override
  String get georesearchLandParcelId => 'رقم القطعة / الحوض / سند الملكية';

  @override
  String get georesearchLandRegisteredArea => 'المساحة المسجلة';

  @override
  String get georesearchLandZoning => 'التنظيم / الاستخدام المسموح';

  @override
  String get georesearchLandClassification => 'تصنيف الأرض';

  @override
  String get georesearchLandOwnershipType => 'نوع الملكية';

  @override
  String get georesearchLandOfficialNotes => 'ملاحظات رسمية أخرى';

  @override
  String get georesearchLandRecordOfficial => 'سجل رسمي';

  @override
  String get georesearchAerial => 'صورة جوية / فضائية';

  @override
  String get georesearchAerialLandCover => 'الغطاء الأرضي';

  @override
  String get georesearchAerialFeatures => 'معالم ظاهرة';

  @override
  String get georesearchAerialUnavailable =>
      'حدّد موقعك لعرض صورة جوية للموقع.';

  @override
  String get georesearchAerialNotice =>
      'الصور الجوية للسياق فقط وغير مؤرخة، وليست مسحاً جوياً حديثاً.';

  @override
  String get georesearchSite => 'موقع الأرض';

  @override
  String get georesearchSiteAddress => 'العنوان';

  @override
  String get georesearchSiteElevation => 'الارتفاع';

  @override
  String get georesearchSiteArea => 'المساحة التقديرية';

  @override
  String get georesearchSiteBoundary => 'الحدود / الامتداد';

  @override
  String get georesearchSiteAccess => 'الوصول';

  @override
  String get georesearchSiteTerrain => 'طبيعة المحيط';

  @override
  String get georesearchTopography => 'المسح الطبوغرافي';

  @override
  String get georesearchTopoElevationRange => 'نطاق الارتفاع';

  @override
  String get georesearchTopoSlope => 'الانحدار';

  @override
  String get georesearchTopoAspect => 'اتجاه المنحدر';

  @override
  String get georesearchTopoLandform => 'شكل الأرض';

  @override
  String get georesearchTopoRelief => 'التضاريس';

  @override
  String get georesearchTopoContours => 'خطوط الكنتور';

  @override
  String get georesearchTopoDrainage => 'نمط التصريف';

  @override
  String get georesearchTopoRunoff => 'المياه السطحية';

  @override
  String get georesearchTopoFloodRisk => 'خطر الفيضان';

  @override
  String get georesearchTopoErosionRisk => 'خطر الانجراف';

  @override
  String get georesearchTopoGrading => 'التسوية / الأعمال الترابية';

  @override
  String get georesearchTopoNotice =>
      'تقدير مكتبي. تتطلب خطوط الكنتور الهندسية مسحاً معتمداً بالأجهزة أو بالطائرة المسيّرة.';

  @override
  String get georesearchGroundwater => 'المياه الجوفية';

  @override
  String get georesearchGwWaterTable => 'عمق منسوب المياه';

  @override
  String get georesearchGwAquifer => 'نوع الخزان الجوفي';

  @override
  String get georesearchGwYield => 'الغزارة المتوقعة';

  @override
  String get georesearchGwQuality => 'جودة المياه';

  @override
  String get georesearchGwSalinityRisk => 'خطر الملوحة';

  @override
  String get georesearchGwSeasonal => 'التغير الموسمي';

  @override
  String get georesearchGwRecharge => 'التغذية الجوفية';

  @override
  String get georesearchGwWellFeasibility => 'جدوى حفر بئر';

  @override
  String get georesearchGwDrillingDepth => 'عمق الحفر التقديري';

  @override
  String get georesearchGwContamination => 'خطر التلوث';

  @override
  String get georesearchGwNotice =>
      'تقدير إقليمي. يلزم إجراء دراسة هيدروجيولوجية والحصول على ترخيص حفر قبل البدء.';

  @override
  String get georesearchBuilding => 'ملاءمة البناء';

  @override
  String get georesearchBuildRating => 'تقييم أولي';

  @override
  String get georesearchBuildBearing => 'قدرة التحمل';

  @override
  String get georesearchBuildBedrock => 'عمق الصخر الأساسي';

  @override
  String get georesearchBuildFoundation => 'نظام الأساسات المحتمل';

  @override
  String get georesearchBuildSettlement => 'خطر الهبوط';

  @override
  String get georesearchBuildExpansive => 'خطر التربة الانتفاخية';

  @override
  String get georesearchBuildSeismic => 'السياق الزلزالي';

  @override
  String get georesearchBuildExcavation => 'الحفر';

  @override
  String get georesearchBuildDrainage => 'تصريف الموقع';

  @override
  String get georesearchBuildConstraints => 'القيود';

  @override
  String get georesearchBuildRequiredStudies => 'الدراسات المهنية المطلوبة';

  @override
  String get georesearchBuildNotice =>
      'تقييم أولي فقط. هذا ليس تقريراً جيوتقنياً ولا يجوز استخدامه لتصميم الأساسات. اطلب فحصاً جيوتقنياً معتمداً قبل البناء.';

  @override
  String get georesearchDataSources => 'مصادر البيانات';

  @override
  String get concernLow => 'خطورة منخفضة';

  @override
  String get concernMedium => 'خطورة متوسطة';

  @override
  String get concernHigh => 'خطورة عالية';

  @override
  String get levelLow => 'منخفض';

  @override
  String get levelMedium => 'متوسط';

  @override
  String get levelHigh => 'مرتفع';

  @override
  String get weatherTitle => 'الطقس';

  @override
  String get currentWeather => 'الطقس الحالي';

  @override
  String feelsLike(String value) {
    return 'الإحساس كـ $value';
  }

  @override
  String get humidity => 'الرطوبة';

  @override
  String get uvIndex => 'مؤشر الأشعة';

  @override
  String get precipitation => 'الهطول';

  @override
  String get hourlyForecast => 'التوقعات الساعية';

  @override
  String get sevenDayForecast => 'توقعات 7 أيام';

  @override
  String get plantCareTips => 'نصائح العناية بالنبات';

  @override
  String rainChance(int value) {
    return 'احتمال مطر $value%';
  }

  @override
  String get weatherUnavailable => 'الطقس غير متاح حاليًا.';

  @override
  String get pullToRefresh => 'اسحب للتحديث';

  @override
  String get tipHighUv =>
      'مؤشر الأشعة مرتفع اليوم — أبعد النباتات الحساسة عن شمس الظهيرة المباشرة.';

  @override
  String get tipNoRain =>
      'لا يُتوقع مطر لعدة أيام — تحقق من رطوبة الأصص بشكل أكثر تكرارًا.';

  @override
  String get tipHighHumidity =>
      'قد تزيد الرطوبة العالية من خطر الفطريات — حسّن التهوية وتجنب بلل الأوراق ليلًا.';

  @override
  String get tipFreezing => 'احتمال تجمّد — احمِ النباتات الخارجية الحساسة.';

  @override
  String get tipHot =>
      'الجو حار — اسقِ مبكرًا أو متأخرًا ووفّر الظل للنباتات الرقيقة.';

  @override
  String get tipMild => 'الأجواء معتدلة — يوم مناسب للعناية الروتينية بالنبات.';

  @override
  String get locationTitle => 'الموقع';

  @override
  String get useMyLocation => 'استخدام موقعي';

  @override
  String get searchCity => 'ابحث عن مدينة';

  @override
  String get locationRationale =>
      'مشاركة موقعك تتيح لبلانت سينس تقديم طقس محلي دقيق ونصائح عناية تراعي المناخ.';

  @override
  String get locationDeniedBody =>
      'تم رفض إذن الموقع. يمكنك البحث عن مدينة بدلًا من ذلك.';

  @override
  String get locationServicesOff =>
      'خدمات الموقع متوقفة. شغّلها أو ابحث عن مدينة.';

  @override
  String get geocodeFailed => 'تعذّر تحديد مدينتك. حاول البحث يدويًا.';

  @override
  String get selectCity => 'اختر مدينة';

  @override
  String get noResults => 'لا توجد أماكن مطابقة';

  @override
  String get profileTitle => 'الملف الشخصي';

  @override
  String get editProfile => 'تعديل الملف';

  @override
  String get language => 'اللغة';

  @override
  String get theme => 'المظهر';

  @override
  String get themeSystem => 'النظام';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get units => 'الوحدات';

  @override
  String get unitsMetric => 'متري (°م)';

  @override
  String get unitsImperial => 'إمبراطوري (°ف)';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get imageRetention => 'حفظ صوري';

  @override
  String get imageRetentionBody =>
      'عند التفعيل، تُحفظ صور التشخيص في حسابك. عند الإيقاف، تُحذف الصور بعد التحليل.';

  @override
  String get analytics => 'تحليلات الاستخدام وتقارير الأعطال';

  @override
  String get analyticsBody =>
      'شارك بيانات استخدام وأعطال مجهولة لتحسين التطبيق. لا تتضمن رسائلك أو صورك أو موقعك الدقيق أبدًا.';

  @override
  String get reminders => 'تذكيرات العناية بالنبات';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get termsOfService => 'شروط الخدمة';

  @override
  String get reportIssue => 'إرسال ملاحظات';

  @override
  String appVersion(String version) {
    return 'الإصدار $version';
  }

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get logoutConfirm => 'تسجيل الخروج من بلانت سينس؟';

  @override
  String get deleteAccount => 'حذف الحساب';

  @override
  String get deleteAccountConfirm =>
      'سيؤدي هذا إلى حذف حسابك وجميع بياناتك نهائيًا. لا يمكن التراجع.';

  @override
  String get deleteAllData => 'حذف كل بياناتي';

  @override
  String get deleteAllDataConfirm =>
      'سيؤدي هذا إلى حذف جميع محادثاتك وتشخيصاتك وتذكيراتك وصورك المخزنة. لا يمكن التراجع.';

  @override
  String get exportData => 'تنزيل بياناتي';

  @override
  String get reauthRequired => 'يرجى تسجيل الدخول مجددًا لتأكيد هذا الإجراء.';

  @override
  String get deleting => 'جارٍ الحذف…';

  @override
  String get deleted => 'تم الحذف';

  @override
  String get remindersTitle => 'التذكيرات';

  @override
  String get addReminder => 'إضافة تذكير';

  @override
  String get reminderPlantName => 'اسم النبات';

  @override
  String get reminderNote => 'ملاحظة';

  @override
  String get reminderType => 'النوع';

  @override
  String get reminderWatering => 'الري';

  @override
  String get reminderFertilizing => 'التسميد';

  @override
  String get reminderRepotting => 'إعادة التأصيص';

  @override
  String get reminderInspection => 'الفحص';

  @override
  String get reminderFollowUp => 'متابعة التشخيص';

  @override
  String get reminderDateTime => 'التاريخ والوقت';

  @override
  String get reminderRecurrence => 'التكرار';

  @override
  String get recurrenceNone => 'مرة واحدة';

  @override
  String get recurrenceDaily => 'يوميًا';

  @override
  String get recurrenceWeekly => 'أسبوعيًا';

  @override
  String get reminderPaused => 'متوقف';

  @override
  String get reminderPause => 'إيقاف مؤقت';

  @override
  String get reminderResume => 'استئناف';

  @override
  String get reminderBodyWatering => 'حان وقت سقي نبتتك.';

  @override
  String get reminderBodyFertilizing => 'حان وقت تسميد نبتتك.';

  @override
  String get reminderBodyRepotting => 'حان وقت إعادة زراعة نبتتك.';

  @override
  String get reminderBodyInspection => 'حان وقت فحص نبتتك.';

  @override
  String get reminderBodyFollowUp => 'تابع تشخيص نبتتك.';

  @override
  String get remindersEmpty => 'لا توجد تذكيرات بعد';

  @override
  String get remindersEmptyBody => 'أضف تذكيرًا لتبقى على اطلاع بعناية النبات.';

  @override
  String get notificationsPermissionBody =>
      'اسمح بالإشعارات لنذكّرك بعناية النبات.';

  @override
  String get myPlants => 'نباتاتي';

  @override
  String get addPlant => 'إضافة نبات';

  @override
  String get editPlant => 'تعديل النبات';

  @override
  String get plantSpecies => 'النوع (اختياري)';

  @override
  String get plantNotes => 'ملاحظات';

  @override
  String get plantsEmpty => 'لا توجد نباتات بعد';

  @override
  String get plantsEmptyBody => 'أضف نبتة لتتبّع عنايتها وسجلّها.';

  @override
  String get askAboutPlant => 'اسأل عن هذه النبتة';

  @override
  String get plantLocation => 'الموقع';

  @override
  String get plantIndoor => 'داخلي';

  @override
  String get plantOutdoor => 'خارجي';

  @override
  String get markWatered => 'تحديد كمسقية';

  @override
  String get wateringInterval => 'الري كل (أيام)';

  @override
  String get generateWateringSchedule => 'إنشاء جدول ري';

  @override
  String get wateringScheduleCreated => 'تم جدولة تذكير الري';

  @override
  String get privacyTitle => 'الخصوصية والبيانات';

  @override
  String get privacyIntro => 'إليك كيفية تعامل بلانت سينس مع بياناتك.';

  @override
  String get privacyProfile =>
      'يُحفظ ملفك الشخصي (الاسم والبريد والتفضيلات) في حسابك.';

  @override
  String get privacyLocation =>
      'الموقع اختياري ويُستخدم فقط للطقس ونصائح العناية. لا نجمع الموقع في الخلفية أبدًا.';

  @override
  String get privacyImages =>
      'تُرسل الصور التي تقدّمها لتحليل الذكاء الاصطناعي. تُحتفظ بها فقط إذا فعّلت حفظ الصور؛ وإلا تُحذف بعد التحليل.';

  @override
  String get privacyProviders =>
      'قد تعالج جهات الذكاء الاصطناعي والبنية التحتية المحتوى الذي تقدّمه. وقد تكون إجابات الذكاء الاصطناعي غير دقيقة.';

  @override
  String get privacyControl =>
      'يمكنك تعطيل الاحتفاظ وحذف المحادثات والتشخيصات وحذف حسابك وبياناتك في أي وقت.';

  @override
  String get a11yError => 'خطأ';

  @override
  String get a11ySendMessage => 'إرسال الرسالة';

  @override
  String a11yWeatherIcon(String condition) {
    return 'حالة الطقس: $condition';
  }

  @override
  String a11yConfidence(String level) {
    return 'مستوى الثقة: $level';
  }

  @override
  String get errorNoConnection =>
      'لا يوجد اتصال بالإنترنت. تحقق من شبكتك وحاول مجددًا.';

  @override
  String get errorTimeout => 'انتهت مهلة الطلب. حاول مرة أخرى.';

  @override
  String get errorPermissionDenied => 'تم رفض الإذن.';

  @override
  String get errorPermissionPermanentlyDenied =>
      'الإذن محظور. فعّله من الإعدادات.';

  @override
  String get errorLocationServicesDisabled => 'خدمات الموقع متوقفة.';

  @override
  String get errorAuthExpired => 'انتهت جلستك. يرجى تسجيل الدخول مجددًا.';

  @override
  String get errorUnauthenticated => 'يجب تسجيل الدخول للقيام بذلك.';

  @override
  String get errorInvalidCredentials =>
      'البريد الإلكتروني أو كلمة المرور غير صحيحة.';

  @override
  String get errorRateLimited => 'طلبات كثيرة جدًا. انتظر لحظة وحاول مجددًا.';

  @override
  String get errorInvalidInput => 'هذا الإدخال غير صالح. راجعه وحاول مجددًا.';

  @override
  String get errorImageTooLarge => 'هذه الصورة كبيرة جدًا. جرّب صورة أصغر.';

  @override
  String get errorContentBlocked => 'تم حظر هذا الطلب لأسباب تتعلق بالسلامة.';

  @override
  String get errorModelUnavailable => 'خدمة الذكاء الاصطناعي غير متاحة مؤقتًا.';

  @override
  String get errorMalformedResponse => 'تعذّر قراءة الاستجابة. حاول مجددًا.';

  @override
  String get errorProviderUnavailable =>
      'إحدى الخدمات غير متاحة مؤقتًا. حاول مجددًا.';

  @override
  String get errorNotFound => 'غير موجود.';

  @override
  String get errorUnknown => 'حدث خطأ ما. حاول مجددًا.';

  @override
  String get emailInUse => 'هذا البريد مسجّل بالفعل.';

  @override
  String get userDisabled => 'تم تعطيل هذا الحساب.';

  @override
  String get userNotFound => 'لا يوجد حساب لهذا البريد.';

  @override
  String get demoModeBanner =>
      'الوضع التجريبي — بيانات نموذجية. اضبط Firebase وGroq للميزات الكاملة.';

  @override
  String get georesearchPurposeSlopeStability => 'استقرار الأرض';

  @override
  String get georesearchPurposeHelp =>
      'اختيارك يحدد محور المسح: النباتات وعناصر التربة، أو المياه الجوفية والآبار، أو الأساسات والبناء، أو حركة الأرض واستقرار المنحدرات.';

  @override
  String get georesearchPurposeSection => 'الغرض من المسح';

  @override
  String get georesearchPurposeValue => 'طُلب من أجل';

  @override
  String get georesearchSlope => 'استقرار الأرض وحركتها';

  @override
  String get georesearchSlopeHazard => 'تقدير الخطورة';

  @override
  String get georesearchSlopeActivity => 'حالة النشاط';

  @override
  String get georesearchSlopeDirection => 'اتجاه حركة الأرض';

  @override
  String get georesearchSlopeAzimuth => 'الاتجاه التقريبي';

  @override
  String get georesearchSlopeSlipDepth => 'عمق سطح الانزلاق';

  @override
  String get georesearchSlopeSlipType => 'هيئة الانهيار';

  @override
  String get georesearchSlopeRate => 'سرعة الحركة';

  @override
  String get georesearchSlopeRateClass => 'تصنيف سرعة الحركة';

  @override
  String get georesearchSlopeMechanism => 'آلية الانهيار';

  @override
  String get georesearchSlopeIndicators =>
      'علامات تحذيرية يجب البحث عنها في الموقع';

  @override
  String get georesearchSlopeTriggers => 'المسببات المحتملة';

  @override
  String get georesearchSlopeAtRisk => 'المنشآت المعرضة للحركة';

  @override
  String get georesearchSlopeAtRiskNotice =>
      'التعرّض مستنتج من الموقع على المنحدر، لا من حالة أي مبنى بعينه. لا شيء هنا يدعم قرار إشغال أو إخلاء — فهذا يحتاج مهندسًا جيوتقنيًا مُرخَّصًا والجهة المحلية.';

  @override
  String get georesearchSlopeZones =>
      'المناطق التي يمكن البناء فيها بعد المعالجة';

  @override
  String get georesearchSlopeZoneAfterTreatment =>
      'قابلة للبناء بعد المعالجة فقط';

  @override
  String get georesearchSlopeZoneNotBuildable =>
      'غير قابلة للبناء بالمعطيات الحالية';

  @override
  String get georesearchSlopeZoneTreatments => 'المعالجات المطلوبة';

  @override
  String get georesearchSlopeZonesNotice =>
      '\"قابلة للبناء بعد المعالجة\" شرطية: لا تسري إلا إذا نُفِّذت المعالجات المذكورة وصمّم الأعمال واعتمدها مهندس جيوتقني مُرخَّص. لا يجيز هذا التقرير أي منطقة كآمنة.';

  @override
  String get georesearchSlopeStabilisation => 'إجراءات التثبيت الممكنة';

  @override
  String get georesearchSlopeMonitoring => 'الرصد والأجهزة';

  @override
  String get georesearchSlopeRequiredStudies => 'الدراسات المهنية المطلوبة';

  @override
  String get georesearchSlopeMeasureNotice =>
      'لا يمكن قياس اتجاه الحركة وعمق سطح الانزلاق وسرعة الحركة من الهاتف. القيم أعلاه نطاقات فحص مبدئي فقط: القياس الفعلي يتم بمقاييس الميل (إنكلينومتر) والبيزومترات المركّبة في جسّات، مع رصد متكرر بالـ GNSS أو الرادار التداخلي (InSAR).';

  @override
  String get georesearchSlopeNotice =>
      'فحص مكتبي مبدئي فقط. هذا ليس تحليل استقرار منحدر ولا يحمل أي معامل أمان. إذا رأيت شقوقًا حديثة أو جدرانًا مائلة أو أنابيب مُزاحة، فاتصل بمهندس جيوتقني مُرخَّص وبالجهة المحلية دون تأخير.';

  @override
  String get georesearchOfficialMap => 'الخرائط الرسمية والشبكة الوطنية';

  @override
  String get georesearchOfficialMapAuthority => 'جهة المساحة والخرائط';

  @override
  String get georesearchOfficialMapGrid => 'الشبكة الوطنية';

  @override
  String get georesearchOfficialMapEasting => 'الإحداثي الشرقي (E)';

  @override
  String get georesearchOfficialMapNorthing => 'الإحداثي الشمالي (N)';

  @override
  String get georesearchOfficialMapWgs => 'إحداثيات GPS (WGS84)';

  @override
  String get georesearchOfficialMapPortal => 'افتح البوابة الجغرافية';

  @override
  String get georesearchOfficialMapOrder => 'اطلب خرائط رسمية وصورًا جوية';

  @override
  String get georesearchOfficialMapCopy => 'انسخ المرجع الشبكي';

  @override
  String get georesearchOfficialMapCopied => 'تم نسخ المرجع الشبكي';

  @override
  String get georesearchOfficialMapUnshifted =>
      'تحويل غير رسمي: لم يُطبَّق تحويل مرجعي (Datum)، لذا قد يختلف عن قيمة شبكية ممسوحة بعشرات الأمتار. اطلب من الجهة الرسمية معاملات التحويل المعتمدة قبل الاعتماد عليه.';

  @override
  String get georesearchOfficialMapShifted =>
      'حُوِّل باستخدام معاملات التحويل المرجعي المهيّأة لهذه النسخة. ويبقى مرجعًا للتحديد الموقعي وليس موقعًا ممسوحًا.';

  @override
  String get georesearchOfficialMapNotice =>
      'تُقدَّم القيم الشبكية لتحديد موقع الأرض ولطلب لوحات الخرائط الرسمية والصور الجوية. أعمال الحدود والملكية والتصميم تتطلب مسحًا مساحيًا مُرخَّصًا.';

  @override
  String get georesearchOfficialMapTileUnavailable =>
      'طبقة الخريطة الأساس الرسمية للجهة غير مفعّلة في هذه النسخة (تتطلب اتفاقية مع المركز). المرجع الشبكي والروابط أدناه تعمل كما هي.';

  @override
  String get demoModeBannerAiReady =>
      'الوضع التجريبي — بياناتك محفوظة على هذا الجهاز. الذكاء الاصطناعي متصل ويجيب فعليًا؛ اضبط Firebase للمزامنة بين الأجهزة.';
}
