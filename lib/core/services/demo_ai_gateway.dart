import 'dart:convert';
import 'dart:math';

import 'ai_gateway.dart';
import 'ai_prompts.dart';

/// Canned, deterministic AI responses used when no AI provider is configured
/// (demo mode) or in tests. Produces valid diagnosis JSON when [jsonMode] is
/// requested, and a helpful structured plant-care answer otherwise. This keeps
/// the app fully usable without any credentials.
///
/// The canned content is LOCALIZED from [AiRequest.locale]. Without that, demo
/// mode returned English text under Arabic labels — the app looked half
/// translated even though every UI string was correctly localized, because the
/// "AI" values were Dart literals rather than model output.
///
/// Arabic and English are provided; `fr`/`es` fall back to English, matching
/// their still-stubbed ARB files.
class DemoAiGateway extends AiGateway {
  DemoAiGateway([Random? random]) : _random = random ?? Random();

  final Random _random;

  @override
  Future<String> generate(AiRequest request) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));

    if (request.jsonMode) {
      if (_isSoilResearch(request)) {
        return _demoSoilReportJson(request);
      }
      return _demoDiagnosisJson(request);
    }
    return _demoChatAnswer(request);
  }

  /// Detects a GeoResearch (soil-research) structured request by the stable
  /// marker that [AiPrompts.soilResearchInstruction] embeds in the user text.
  bool _isSoilResearch(AiRequest request) {
    return request.userText.contains(AiPrompts.soilResearchMarker) ||
        request.systemPrompt.contains(AiPrompts.soilResearchMarker);
  }

  /// True when the canned content should be served in Arabic.
  bool _isArabic(AiRequest request) =>
      request.locale.trim().toLowerCase().startsWith('ar');

  @override
  Stream<String> generateStream(AiRequest request) async* {
    // Diagnosis (JSON) needs the whole document — emit once.
    if (request.jsonMode) {
      yield await generate(request);
      return;
    }
    // Simulate token-by-token streaming of the canned chat answer so the
    // streaming UI can be exercised in demo mode.
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final String full = _demoChatAnswer(request);
    final List<String> words = full.split(' ');
    final StringBuffer acc = StringBuffer();
    for (int i = 0; i < words.length; i++) {
      acc.write(i == 0 ? words[i] : ' ${words[i]}');
      yield acc.toString();
      await Future<void>.delayed(const Duration(milliseconds: 18));
    }
  }

  String _demoChatAnswer(AiRequest request) {
    final String q = request.userText.toLowerCase();
    final bool hasImage = request.image != null;
    final bool ar = _isArabic(request);
    String t(String en, String arText) => ar ? arText : en;

    if (hasImage && q.trim().isEmpty) {
      return t(
        "I can see the image you shared. Could you tell me what's "
            "concerning you about this plant? For example, are the leaves "
            "discoloured, spotted, or wilting?\n\n"
            "_(Demo response — configure Groq for full AI analysis.)_",
        'أرى الصورة التي شاركتها. هل يمكنك إخباري بما يقلقك في هذه النبتة؟ '
            'مثلًا، هل الأوراق متغيرة اللون أو مبقّعة أو ذابلة؟\n\n'
            '_(رد تجريبي — اضبط Groq للحصول على تحليل ذكاء اصطناعي كامل.)_',
      );
    }

    // Keyword branches are matched in both languages: an Arabic question could
    // never match the English keywords, so Arabic users always fell through to
    // the generic answer.
    final bool asksYellowing = q.contains('yellow') || q.contains('اصفرار') ||
        q.contains('أصفر') || q.contains('صفراء');
    final bool asksWatering = q.contains('water') || q.contains('basil') ||
        q.contains('ريّ') || q.contains('ري ') || q.contains('سقي') ||
        q.contains('حبق') || q.contains('ريحان');
    final bool asksSucculent = q.contains('succulent') || q.contains('soil') ||
        q.contains('عصاري') || q.contains('تربة');

    String assessment;
    if (asksYellowing) {
      assessment = t(
        'Yellowing leaves often point to overwatering, poor drainage, or a '
            'nitrogen deficiency. Check whether the soil stays soggy and whether '
            'lower or newer leaves are affected first.',
        'اصفرار الأوراق غالبًا ما يشير إلى الإفراط في الريّ أو سوء التصريف أو '
            'نقص النيتروجين. تحقّق مما إذا كانت التربة تبقى مشبعة بالماء، وما إذا '
            'كانت الأوراق السفلية أم الحديثة هي المتأثرة أولًا.',
      );
    } else if (asksWatering) {
      assessment = t(
        'Most herbs like basil prefer consistently moist (not soggy) soil. '
            'Water when the top 2–3 cm feels dry — often every 2–3 days in warm '
            'weather.',
        'معظم الأعشاب مثل الحبق تفضّل تربة رطبة باستمرار (وليست مشبعة بالماء). '
            'اسقِ النبتة عندما تجفّ الطبقة العلوية بمقدار 2–3 سم — غالبًا كل '
            '2–3 أيام في الجو الحار.',
      );
    } else if (asksSucculent) {
      assessment = t(
        'Succulents need fast-draining soil. A mix of potting soil with '
            'coarse sand or perlite (about 1:1) prevents root rot.',
        'النباتات العصارية تحتاج تربة سريعة التصريف. خلط تربة الأصص مع رمل خشن '
            'أو بيرلايت بنسبة 1:1 تقريبًا يمنع تعفّن الجذور.',
      );
    } else {
      assessment = t(
        'Thanks for your question. Based on general plant-care principles, '
            'here is some practical guidance you can adapt to your conditions.',
        'شكرًا على سؤالك. بناءً على المبادئ العامة للعناية بالنبات، هذه بعض '
            'الإرشادات العملية التي يمكنك تكييفها مع ظروفك.',
      );
    }

    final String ctx = request.context['temperature'] != null
        ? t(
            '\n\nYour local conditions (${request.context['city'] ?? 'your area'}, '
                '${request.context['temperature']}) are factored into this advice.',
            '\n\nتم أخذ ظروفك المحلية (${request.context['city'] ?? 'منطقتك'}، '
                '${request.context['temperature']}) في الحسبان في هذه النصيحة.',
          )
        : '';

    return t(
      '🌿 **Assessment**\n$assessment\n\n'
          '💊 **Recommended actions**\n'
          '- Adjust watering to match the plant\'s needs and your climate.\n'
          '- Ensure the pot drains freely and the plant gets appropriate light.\n\n'
          '🌱 **Prevention & ongoing care**\n'
          '- Check soil moisture before watering rather than on a fixed schedule.\n'
          '- Inspect leaves weekly for early signs of pests or disease.\n\n'
          '🛡️ **Safety notes**\n'
          '- Keep fertilizers and any treatments away from children and pets.$ctx\n\n'
          '_AI suggestions may be inaccurate. For serious issues, consult a '
          'qualified horticulturist or local agricultural authority._',
      '🌿 **التقييم**\n$assessment\n\n'
          '💊 **الإجراءات الموصى بها**\n'
          '- عدّل الريّ بما يناسب احتياجات النبتة ومناخك.\n'
          '- تأكّد من أن الأصيص يصرّف الماء بحرية وأن النبتة تحصل على ضوء مناسب.\n\n'
          '🌱 **الوقاية والعناية المستمرة**\n'
          '- تحقّق من رطوبة التربة قبل الريّ بدلًا من الاعتماد على جدول ثابت.\n'
          '- افحص الأوراق أسبوعيًا للكشف المبكر عن الآفات أو الأمراض.\n\n'
          '🛡️ **ملاحظات السلامة**\n'
          '- احفظ الأسمدة وأي معالجات بعيدًا عن الأطفال والحيوانات المنزلية.$ctx\n\n'
          '_قد تكون اقتراحات الذكاء الاصطناعي غير دقيقة. للمشكلات الخطيرة، '
          'راجع مهندسًا زراعيًا مؤهلًا أو الجهة الزراعية المحلية._',
    );
  }

  String _demoDiagnosisJson(AiRequest request) {
    final bool ar = _isArabic(request);
    String t(String en, String arText) => ar ? arText : en;

    // Occasionally simulate a poor-quality image to exercise that UI path.
    final bool poor = _random.nextInt(6) == 0;
    if (poor) {
      return const JsonEncoder.withIndent('  ').convert({
        'isPlantRelated': true,
        'imageQuality': 'poor',
        'plantName': null,
        'scientificName': null,
        'whatISee': t(
          'The image is a little blurry, so I can\'t be certain.',
          'الصورة غير واضحة قليلًا، لذا لا يمكنني الجزم.',
        ),
        'possibleIssues': [],
        'treatmentSteps': [],
        'preventionTips': [],
        'safetyNotes': [],
        'confidence': 'low',
        'needsMoreInformation': true,
        'followUpQuestions': [
          t(
            'Could you retake the photo in bright, indirect light?',
            'هل يمكنك إعادة التصوير في ضوء ساطع غير مباشر؟',
          ),
          t(
            'Please fill the frame with the affected leaf or area.',
            'يُرجى تقريب الكادر ليملأه الجزء أو الورقة المتأثرة.',
          ),
        ],
        'disclaimer': t(
          'AI suggestions may be inaccurate and do not replace a qualified '
              'botanist or agricultural professional.',
          'قد تكون اقتراحات الذكاء الاصطناعي غير دقيقة ولا تُغني عن عالم نبات '
              'أو مختص زراعي مؤهل.',
        ),
      });
    }

    return const JsonEncoder.withIndent('  ').convert({
      'isPlantRelated': true,
      'imageQuality': 'good',
      'plantName': t('Common houseplant (demo)', 'نبتة منزلية شائعة (تجريبي)'),
      'scientificName': null,
      'whatISee': t(
        'Several leaves show yellowing at the margins with a few small brown '
            'spots. Overall the plant looks otherwise upright.',
        'عدة أوراق تُظهر اصفرارًا على الحواف مع بضع بقع بنية صغيرة. وبخلاف ذلك '
            'تبدو النبتة منتصبة بشكل عام.',
      ),
      'possibleIssues': [
        {
          'name': t(
            'Overwatering / root stress',
            'إفراط في الريّ / إجهاد الجذور',
          ),
          'likelihood': 'medium',
          'reason': t(
            'Marginal yellowing is commonly linked to soggy soil.',
            'الاصفرار على الحواف يرتبط عادةً بتربة مشبعة بالماء.',
          ),
        },
        {
          'name': t('Nutrient deficiency', 'نقص العناصر الغذائية'),
          'likelihood': 'low',
          'reason': t(
            'Uniform yellowing can indicate low nitrogen.',
            'الاصفرار المنتظم قد يدل على انخفاض النيتروجين.',
          ),
        },
      ],
      'treatmentSteps': [
        t(
          'Let the top few centimetres of soil dry before watering again.',
          'اترك السنتيمترات العلوية من التربة تجفّ قبل الريّ مرة أخرى.',
        ),
        t(
          'Ensure the pot has drainage holes and empty any saucer.',
          'تأكّد من وجود فتحات تصريف في الأصيص وأفرغ الطبق السفلي.',
        ),
        t(
          'Remove severely affected leaves with clean scissors.',
          'أزل الأوراق المتأثرة بشدة بمقص نظيف.',
        ),
      ],
      'preventionTips': [
        t(
          'Water based on soil moisture, not a fixed schedule.',
          'اسقِ بناءً على رطوبة التربة، لا على جدول ثابت.',
        ),
        t(
          'Provide bright, indirect light and good airflow.',
          'وفّر ضوءًا ساطعًا غير مباشر وتهوية جيدة.',
        ),
      ],
      'safetyNotes': [
        t(
          'If using any fertilizer, follow label rates and keep away from pets.',
          'إذا استخدمت أي سماد، فاتبع الجرعات المذكورة على العبوة وأبعده عن '
              'الحيوانات المنزلية.',
        ),
      ],
      'confidence': 'medium',
      'needsMoreInformation': false,
      'followUpQuestions': [
        t(
          'How often are you currently watering this plant?',
          'كم مرة تسقي هذه النبتة حاليًا؟',
        ),
      ],
      'disclaimer': t(
        'AI suggestions may be inaccurate and do not replace a qualified '
            'botanist, horticulturist or local agricultural authority. This is '
            'a demo response.',
        'قد تكون اقتراحات الذكاء الاصطناعي غير دقيقة ولا تُغني عن عالم نبات أو '
            'مهندس زراعي مؤهل أو الجهة الزراعية المحلية. هذا رد تجريبي.',
      ),
    });
  }

  /// Deterministic, valid [SoilReport] JSON for the GeoResearch flow. Values
  /// are qualitative ESTIMATES only — the notes and disclaimer make clear that
  /// exact sodium/salinity/nutrient figures require a professional soil-lab
  /// test, and that the slope-stability section is a screening opinion rather
  /// than a geotechnical study. Parses cleanly via SoilReport.parse.
  String _demoSoilReportJson(AiRequest request) {
    final bool ar = _isArabic(request);
    String t(String en, String arText) => ar ? arText : en;

    final String? city = request.context['city'];
    final bool hasImage = request.image != null;
    final String locationSummary = city != null && city.trim().isNotEmpty
        ? t(
            'Estimated regional soil profile near $city (demo).',
            'مقطع تربة إقليمي تقديري قرب $city (تجريبي).',
          )
        : t(
            'Estimated regional soil profile for your area (demo).',
            'مقطع تربة إقليمي تقديري لمنطقتك (تجريبي).',
          );

    // Mirror the real flow's handling of user requirements and official data so
    // demo mode exercises both branches.
    final String purpose = request.context['surveyPurpose'] ?? 'general';
    final String? requirements = request.context['userRequirements'];
    final bool officialData =
        (request.context['landRecordAvailable'] ?? 'false') == 'true';

    return const JsonEncoder.withIndent('  ').convert({
      'isSoilRelated': true,
      'imageQuality': hasImage ? 'good' : 'unusable',
      'locationSummary': locationSummary,
      'purpose': purpose,
      'userRequirements': requirements,
      'dataSources': <String>[
        if (officialData)
          t(
            'Official Land Department record supplied by the user (authoritative)',
            'سجل رسمي من دائرة الأراضي قدّمه المستخدم (مرجعي)',
          )
        else
          t(
            'Estimated from location and regional context only — no official '
                'land record was provided',
            'تقدير من الموقع والسياق الإقليمي فقط — لم يُقدَّم سجل أراضٍ رسمي',
          ),
        if (hasImage)
          t(
            'Site/soil photo attached by the user',
            'صورة للموقع/التربة أرفقها المستخدم',
          ),
        t(
          'Regional climate and geology patterns (demo data)',
          'أنماط المناخ والجيولوجيا الإقليمية (بيانات تجريبية)',
        ),
      ],
      'soilType': t(
        'Sandy loam (estimated from regional context)',
        'تربة طميية رملية (تقدير من السياق الإقليمي)',
      ),
      'soilDepth': t(
        'Moderately deep (roughly 60–100 cm topsoil, estimate only)',
        'عميقة نسبيًا (نحو 60–100 سم تربة سطحية، تقدير فقط)',
      ),
      'salinity': {
        'level': 'low',
        'note': t(
          'Salinity appears low based on regional patterns. Exact salt '
              'content requires a professional soil-lab test.',
          'تبدو الملوحة منخفضة بناءً على الأنماط الإقليمية. تحديد نسبة الأملاح '
              'بدقة يتطلب فحص مختبر تربة معتمد.',
        ),
      },
      'sodium': {
        'level': 'low',
        'note': t(
          'Sodium is likely within a safe range for most plants. A lab test '
              'is needed to confirm exact sodium levels.',
          'يُرجّح أن الصوديوم ضمن نطاق آمن لمعظم النباتات. يلزم فحص مختبري '
              'لتأكيد المستويات الدقيقة.',
        ),
      },
      'phLevel': t(
        'Approximately neutral (around 6.5–7.5, estimate)',
        'متعادل تقريبًا (نحو 6.5–7.5، تقدير)',
      ),
      'organicMatter': t(
        'Moderate — typical of managed regional soils (estimate).',
        'متوسطة — معتادة في الترب الإقليمية المُدارة (تقدير).',
      ),
      'nutrients': [
        {
          'name': t('Nitrogen', 'النيتروجين'),
          'level': 'medium',
          'note': t(
            'Likely moderate; supplement for leafy growth. Lab test needed '
                'for exact values.',
            'يُرجّح أنه متوسط؛ أضف سمادًا للنمو الورقي. يلزم فحص مختبري للقيم '
                'الدقيقة.',
          ),
        },
        {
          'name': t('Phosphorus', 'الفوسفور'),
          'level': 'low',
          'note': t(
            'Often limited in sandy soils; a lab test confirms exact '
                'phosphorus levels.',
            'غالبًا محدود في الترب الرملية؛ الفحص المختبري يؤكد المستويات '
                'الدقيقة للفوسفور.',
          ),
        },
        {
          'name': t('Potassium', 'البوتاسيوم'),
          'level': 'medium',
          'note': t(
            'Estimated moderate. Confirm with a professional soil test.',
            'تقديره متوسط. أكّده بفحص تربة معتمد.',
          ),
        },
      ],
      'substances': [
        {
          'name': t('Carbonates (lime)', 'الكربونات (الجير)'),
          'concern': 'low',
          'note': t(
            'Common in the region; usually not a concern at low levels.',
            'شائعة في المنطقة؛ لا تمثل عادةً مشكلة عند المستويات المنخفضة.',
          ),
        },
        {
          'name': t('Clay minerals', 'معادن الطين'),
          'concern': 'low',
          'note': t(
            'A small clay fraction aids water retention. Estimate only.',
            'نسبة طين صغيرة تساعد في الاحتفاظ بالماء. تقدير فقط.',
          ),
        },
      ],
      'geometry': hasImage
          ? t(
              'Granular to fine-crumb structure visible in the photo, with '
                  'moderate aggregation (estimate).',
              'بناء حبيبي إلى كُتلي ناعم يظهر في الصورة، مع تجمّع متوسط '
                  '(تقدير).',
            )
          : t(
              'Structure not assessed — attach a soil/site photo to estimate '
                  'geometry (granular, blocky, or compacted).',
              'لم يُقيَّم البناء — أرفق صورة للتربة/الموقع لتقدير الشكل '
                  '(حبيبي أو كُتلي أو مرصوص).',
            ),
      // Deliberately NO 'landRecord' key: the official record shown in a report
      // is attached by the app from what the user entered, never echoed back by
      // the model. Mirrors the real prompt, whose schema omits it too. The same
      // applies to 'officialMap', which the app computes from the coordinates.
      'siteLocation': {
        'address': city,
        'elevation': t(
          'Approximately 300–450 m above sea level (estimate)',
          'نحو 300–450 م فوق مستوى سطح البحر (تقدير)',
        ),
        'areaEstimate': officialData
            ? request.context['landRegisteredArea']
            : t(
                'Not known — provide an official record or plot dimensions',
                'غير معروفة — قدّم سجلًا رسميًا أو أبعاد القطعة',
              ),
        'boundaryDescription': t(
          'Boundaries not surveyed in this demo. A licensed cadastral survey '
              'is required to fix the plot extent.',
          'لم تُمسح الحدود في هذا العرض التجريبي. يلزم مسح مساحي مُرخَّص لتحديد '
              'حدود القطعة.',
        ),
        'accessNotes': t(
          'Assumed reachable by a local road; verify machinery access on site.',
          'يُفترض الوصول إليها عبر طريق محلي؛ تحقّق ميدانيًا من إمكانية وصول '
              'الآليات.',
        ),
        'terrainSetting': t(
          'Gently undulating plain with scattered cultivation',
          'سهل متموّج قليلًا مع زراعات متفرقة',
        ),
      },
      'topography': {
        'summary': t(
          'Gently sloping ground with no major relief; suitable for most '
              'layouts with modest levelling (demo estimate).',
          'أرض ذات ميل بسيط دون تباين تضاريسي كبير؛ مناسبة لمعظم المخططات مع '
              'تسوية محدودة (تقدير تجريبي).',
        ),
        'elevationRange': t(
          'Roughly 8–12 m variation across the plot (estimate)',
          'فرق ارتفاع نحو 8–12 م على امتداد القطعة (تقدير)',
        ),
        'slope': t('Gentle', 'خفيف'),
        'slopePercent': 3.5,
        'aspect': t('South-facing', 'مواجه للجنوب'),
        'landform': t('Alluvial plain margin', 'حاشية سهل غِريني'),
        'relief': t('Low relief', 'تباين تضاريسي منخفض'),
        'contourSummary': t(
          'Contours would run broadly east–west; a 0.5 m interval is typical '
              'for plot-scale design.',
          'تمتد خطوط الكنتور عمومًا شرق–غرب؛ الفاصل 0.5 م معتاد للتصميم على '
              'مستوى القطعة.',
        ),
        'drainagePattern': t(
          'Surface water drains gently toward the south-east.',
          'المياه السطحية تُصرَّف بلطف نحو الجنوب الشرقي.',
        ),
        'runoffNotes': t(
          'Minor ponding possible in low corners after heavy rain.',
          'قد يحدث تجمّع بسيط للمياه في الزوايا المنخفضة بعد الأمطار الغزيرة.',
        ),
        'floodRisk': 'low',
        'erosionRisk': 'medium',
        'gradingNotes': t(
          'Expect light cut-and-fill to create level building or planting '
              'platforms.',
          'توقّع أعمال قطع وردم خفيفة لإنشاء مصاطب مستوية للبناء أو الزراعة.',
        ),
        'notes': [
          t(
            'Derived from regional terrain patterns, not from measured survey '
                'points.',
            'مستنتجة من أنماط التضاريس الإقليمية، وليست من نقاط مسح مقيسة.',
          ),
        ],
      },
      'groundwater': {
        'summary': t(
          'A moderately productive shallow aquifer is typical for this kind '
              'of setting (demo estimate).',
          'من المعتاد في مثل هذا الوسط وجود خزان جوفي ضحل متوسط الإنتاجية '
              '(تقدير تجريبي).',
        ),
        'waterTableDepth': t(
          'Roughly 15–30 m below ground level (estimate)',
          'نحو 15–30 م تحت سطح الأرض (تقدير)',
        ),
        'aquiferType': t(
          'Unconfined alluvial aquifer',
          'خزان جوفي غِريني حر (غير محصور)',
        ),
        'yieldPotential': 'medium',
        'waterQuality': t(
          'Likely usable for irrigation; test for salinity and nitrates '
              'before drinking use.',
          'يُرجّح صلاحيته للريّ؛ افحص الملوحة والنترات قبل الاستخدام للشرب.',
        ),
        'salinityRisk': 'low',
        'seasonalVariation': t(
          'Water table typically rises after the wet season and falls in late '
              'summer.',
          'يرتفع منسوب المياه عادةً بعد الموسم المطير وينخفض في أواخر الصيف.',
        ),
        'rechargeNotes': t(
          'Recharge mainly from seasonal rainfall infiltration.',
          'التغذية أساسًا من تسرّب الأمطار الموسمية.',
        ),
        'wellFeasibility': t(
          'A borehole appears feasible in principle, subject to a '
              'hydrogeological study and a drilling permit.',
          'يبدو حفر بئر ممكنًا من حيث المبدأ، رهنًا بدراسة هيدروجيولوجية '
              'وتصريح حفر.',
        ),
        'drillingDepthEstimate': t(
          'Commonly 40–60 m to ensure year-round supply',
          'عادةً 40–60 م لتأمين إمداد على مدار السنة',
        ),
        'contaminationRisk': 'low',
        'notes': [
          t(
            'No site-specific borehole data was available for this demo.',
            'لا تتوفر بيانات جسّات خاصة بالموقع في هذا العرض التجريبي.',
          ),
        ],
      },
      'buildingSuitability': {
        'summary': t(
          'Preliminary screening suggests generally workable ground for light '
              'to medium structures (demo estimate only).',
          'يشير الفحص المبدئي إلى أرض قابلة للعمل عمومًا لمنشآت خفيفة إلى '
              'متوسطة (تقدير تجريبي فقط).',
        ),
        'suitability': 'medium',
        'bearingCapacity': t(
          'Likely moderate for sandy loam over firmer substrata — '
              'qualitative only, no design value implied.',
          'يُرجّح أنها متوسطة لتربة طميية رملية فوق طبقات أكثر تماسكًا — وصف '
              'نوعي فقط، دون أي قيمة تصميمية.',
        ),
        'bedrockDepth': t(
          'Probably deeper than 10 m (estimate)',
          'يُرجّح أنه أعمق من 10 م (تقدير)',
        ),
        'foundationSuggestion': t(
          'Shallow strip or pad footings are a plausible starting hypothesis; '
              'a geotechnical engineer must confirm.',
          'الأساسات الشريطية أو المنفصلة الضحلة فرضية بداية معقولة؛ يجب أن '
              'يؤكدها مهندس جيوتقني.',
        ),
        'settlementRisk': 'medium',
        'expansiveSoilRisk': 'low',
        'seismicNotes': t(
          'Check the current national seismic zoning map and apply the local '
              'building code.',
          'راجع خريطة التقسيم الزلزالي الوطنية السارية وطبّق كود البناء '
              'المحلي.',
        ),
        'excavationNotes': t(
          'Sandy soils may need shoring for trenches deeper than about 1.2 m.',
          'قد تحتاج الترب الرملية إلى تدعيم جوانب الحفر للخنادق الأعمق من نحو '
              '1.2 م.',
        ),
        'drainageRequirements': t(
          'Provide perimeter drainage and grade surfaces away from '
              'foundations.',
          'وفّر تصريفًا محيطيًا وميّل الأسطح بعيدًا عن الأساسات.',
        ),
        'constraints': [
          t(
            'Erosion risk on the sloping margin during construction',
            'خطر انجراف على الحاشية المنحدرة أثناء الإنشاء',
          ),
          t(
            'Plot boundaries unverified without an official cadastral record',
            'حدود القطعة غير مؤكدة دون سجل مساحي رسمي',
          ),
        ],
        'requiredStudies': [
          t(
            'Geotechnical investigation with boreholes and bearing tests',
            'تحقيق جيوتقني بجسّات واختبارات تحمّل',
          ),
          t(
            'Licensed topographic survey for design-grade contours',
            'مسح طبوغرافي مُرخَّص لخطوط كنتور بدقة تصميمية',
          ),
          t(
            'Hydrogeological study if a well is planned',
            'دراسة هيدروجيولوجية إذا كان هناك تخطيط لبئر',
          ),
          t(
            'Local authority planning and zoning confirmation',
            'تأكيد التنظيم والتخطيط من الجهة المحلية',
          ),
        ],
      },
      'slopeStability': {
        'summary': t(
          'Screening only: the gentle gradient and low relief suggest no '
              'evidence of large-scale landsliding, but shallow creep on the '
              'sloping margin cannot be ruled out from a desk study (demo '
              'estimate).',
          'فحص مبدئي فقط: الميل الخفيف والتباين التضاريسي المنخفض يشيران إلى '
              'عدم وجود دلائل على انزلاق أرضي واسع، لكن لا يمكن استبعاد زحف '
              'سطحي على الحاشية المنحدرة عبر دراسة مكتبية (تقدير تجريبي).',
        ),
        'hazardLevel': 'low',
        'activityState': t(
          'No movement observed in the available context — status unverified '
              'without monitoring.',
          'لا حركة مرصودة في السياق المتاح — الحالة غير مؤكدة دون رصد ميداني.',
        ),
        'movementDirection': t(
          'Any movement would follow the steepest gradient, downslope toward '
              'the south-east.',
          'أي حركة ستتبع أشدّ انحدار، نزولًا نحو الجنوب الشرقي.',
        ),
        'movementAzimuth': 135,
        'slipSurfaceDepth': t(
          'If shallow creep exists, a plausible range is 1–3 m within the '
              'weathered soil above firmer substrata. The actual depth can only '
              'be measured with inclinometers installed in boreholes.',
          'إن وُجد زحف سطحي، فالنطاق المعقول 1–3 م داخل التربة المتحلّلة فوق '
              'طبقات أكثر تماسكًا. لا يمكن قياس العمق الفعلي إلا بمقاييس ميل '
              '(إنكلينومتر) تُركَّب في جسّات.',
        ),
        'slipSurfaceType': t(
          'Shallow translational sliding along the soil/substratum contact is '
              'the most plausible mechanism for this landform.',
          'الانزلاق الانسحابي السطحي على التقاء التربة بالطبقة الأصلب هو '
              'الآلية الأكثر ترجيحًا لهذا الشكل الأرضي.',
        ),
        'movementRate': t(
          'No rate can be stated without measurement. Extremely slow creep '
              '(a few millimetres per year) is the only regime consistent with '
              'this gradient; repeated GNSS or InSAR monitoring is required to '
              'quantify it.',
          'لا يمكن ذكر سرعة دون قياس. الزحف البطيء للغاية (بضعة مليمترات '
              'سنويًا) هو النظام الوحيد المتوافق مع هذا الميل؛ ويلزم رصد '
              'متكرر بالـ GNSS أو الرادار التداخلي (InSAR) لتحديدها.',
        ),
        'movementRateClass': 'low',
        'failureMechanism': t(
          'Rainfall-driven rise in pore-water pressure reducing shear '
              'strength at the soil/substratum contact.',
          'ارتفاع ضغط الماء المسامي بفعل الأمطار مما يقلّل مقاومة القصّ عند '
              'التقاء التربة بالطبقة الأصلب.',
        ),
        'indicators': [
          t(
            'Look for arc-shaped cracks or a small scarp at the top of the '
                'slope.',
            'ابحث عن شقوق قوسية أو جرف صغير في أعلى المنحدر.',
          ),
          t(
            'Look for tilted walls, fences, poles or trees leaning downslope.',
            'ابحث عن جدران أو أسوار أو أعمدة أو أشجار مائلة نزولًا مع '
                'المنحدر.',
          ),
          t(
            'Look for bulging or displaced ground near the foot of the slope.',
            'ابحث عن انتفاخ أو إزاحة في الأرض قرب أسفل المنحدر.',
          ),
          t(
            'Look for new seepage, wet patches or cracked drains and pipes.',
            'ابحث عن نزّ جديد أو بقع رطبة أو تشقّق في المصارف والأنابيب.',
          ),
        ],
        'triggers': [
          t(
            'Prolonged or intense rainfall raising the water table',
            'أمطار طويلة أو غزيرة ترفع منسوب المياه الجوفية',
          ),
          t(
            'Cutting into the foot of the slope, or loading its crown with '
                'fill or a structure',
            'القطع في أسفل المنحدر، أو تحميل تاجه بالردم أو بمنشأ',
          ),
          t(
            'Leaking pipes, irrigation or uncontrolled surface runoff',
            'تسرّب الأنابيب أو الريّ أو جريان سطحي غير مُتحكَّم به',
          ),
          t('Seismic shaking', 'الاهتزاز الزلزالي'),
        ],
        'atRiskStructures': [
          {
            'name': t(
              'Any structure on the upper edge (crown) of the sloping margin',
              'أي منشأ على الحافة العليا (التاج) للحاشية المنحدرة',
            ),
            'risk': 'medium',
            'reason': t(
              'The crown is where tension cracks appear first if the slope '
                  'starts to move, and added load there reduces stability.',
              'التاج هو أول ما تظهر فيه شقوق الشدّ إذا بدأ المنحدر بالحركة، '
                  'وزيادة الأحمال فيه تقلّل الاستقرار.',
            ),
            'recommendation': t(
              'Have a licensed geotechnical engineer inspect for cracks and '
                  'survey reference points before any extension or added load.',
              'اطلب من مهندس جيوتقني مُرخَّص فحص الشقوق ورصد نقاط مرجعية قبل '
                  'أي توسعة أو زيادة في الأحمال.',
            ),
          },
          {
            'name': t(
              'Boundary or retaining walls across the slope',
              'الجدران الحدودية أو الاستنادية العارضة للمنحدر',
            ),
            'risk': 'medium',
            'reason': t(
              'Unengineered walls are the first elements to tilt or crack '
                  'under even very slow ground movement.',
              'الجدران غير المصمَّمة هندسيًا هي أول ما يميل أو يتشقق حتى مع '
                  'حركة أرضية بطيئة جدًا.',
            ),
            'recommendation': t(
              'Check for tilt and new cracks, and confirm the wall has '
                  'drainage behind it; have any retaining wall verified by '
                  'design.',
              'تحقّق من الميل والشقوق الجديدة، وتأكّد من وجود تصريف خلف '
                  'الجدار؛ واطلب التحقق التصميمي لأي جدار استنادي.',
            ),
          },
          {
            'name': t(
              'Buried services and drains crossing the slope',
              'الخدمات المدفونة والمصارف العابرة للمنحدر',
            ),
            'risk': 'low',
            'reason': t(
              'Pipes are rigid and fail early under differential movement, '
                  'and a leak then feeds the very mechanism that moved them.',
              'الأنابيب صلبة وتنكسر مبكرًا مع الحركة التفاضلية، ثم يغذّي '
                  'التسرّب الآلية نفسها التي أزاحتها.',
            ),
            'recommendation': t(
              'Pressure-test and CCTV-survey the lines, and repair any leak '
                  'promptly.',
              'أجرِ اختبار ضغط وتصويرًا داخليًا للخطوط، وأصلح أي تسرّب فورًا.',
            ),
          },
        ],
        'zones': [
          {
            'name': t('Upper plateau (flatter part)', 'الهضبة العليا (الجزء الأكثر استواءً)'),
            'location': t(
              'The level ground set back from the sloping margin.',
              'الأرض المستوية المتراجعة عن الحاشية المنحدرة.',
            ),
            'buildability': 'high',
            'buildableAfterTreatment': true,
            'requiredTreatments': [
              t(
                'Keep a set-back from the slope crown as determined by a '
                    'stability analysis',
                'الحفاظ على مسافة ارتداد عن تاج المنحدر يحددها تحليل '
                    'الاستقرار',
              ),
              t(
                'Control surface water so runoff is not discharged over the '
                    'slope',
                'التحكم بالمياه السطحية بحيث لا يُصرَّف الجريان فوق المنحدر',
              ),
            ],
            'note': t(
              'Most favourable area in this screening, but the set-back '
                  'distance must come from an engineered stability analysis, '
                  'not from this report.',
              'أفضل منطقة في هذا الفحص المبدئي، لكن مسافة الارتداد يجب أن تأتي '
                  'من تحليل استقرار هندسي، لا من هذا التقرير.',
            ),
          },
          {
            'name': t('Sloping margin', 'الحاشية المنحدرة'),
            'location': t(
              'The graded band falling toward the south-east.',
              'الشريط المائل النازل نحو الجنوب الشرقي.',
            ),
            'buildability': 'low',
            'buildableAfterTreatment': false,
            'requiredTreatments': [
              t(
                'Instrumented investigation (boreholes, inclinometers, '
                    'piezometers) before considering any construction',
                'تحقيق مُجهَّز بالأجهزة (جسّات، مقاييس ميل، بيزومترات) قبل '
                    'التفكير بأي إنشاء',
              ),
              t(
                'Engineered slope stabilisation and subsurface drainage '
                    'designed and signed off by a licensed geotechnical '
                    'engineer',
                'تثبيت هندسي للمنحدر وتصريف جوفي مصمَّم ومعتمد من مهندس '
                    'جيوتقني مُرخَّص',
              ),
            ],
            'note': t(
              'Treat as not buildable until measurements exist. A desk study '
                  'cannot clear a slope for construction.',
              'اعتبرها غير قابلة للبناء حتى تتوفر قياسات. الدراسة المكتبية لا '
                  'تستطيع إجازة منحدر للبناء.',
            ),
          },
          {
            'name': t('Foot of the slope and drainage line', 'أسفل المنحدر وخط التصريف'),
            'location': t(
              'The low corner where surface water concentrates.',
              'الزاوية المنخفضة التي تتجمع فيها المياه السطحية.',
            ),
            'buildability': 'low',
            'buildableAfterTreatment': false,
            'requiredTreatments': [
              t(
                'Keep clear of structures; use for landscaping or a designed '
                    'drainage channel',
                'أبقِها خالية من المنشآت؛ استخدمها للتنسيق أو لقناة تصريف '
                    'مصمَّمة',
              ),
            ],
            'note': t(
              'Cutting here removes support from the slope above and is the '
                  'most common man-made trigger of failure.',
              'القطع هنا يزيل الدعم عن المنحدر الأعلى، وهو أكثر مسبّب بشري '
                  'شيوعًا للانهيار.',
            ),
          },
        ],
        'stabilisationOptions': [
          t(
            'Subsurface and surface drainage to lower pore-water pressure — '
                'usually the most effective single measure',
            'تصريف جوفي وسطحي لتقليل ضغط الماء المسامي — عادةً أكثر إجراء '
                'منفرد فعالية',
          ),
          t(
            'Regrading or benching to reduce the driving slope angle',
            'إعادة تشكيل الميل أو تدريجه لتقليل زاوية الانحدار الدافعة',
          ),
          t(
            'Engineered retaining structures, soil nails or anchors where '
                'geometry cannot be changed',
            'منشآت استنادية مصمَّمة أو مسامير تربة أو شدادات حيث لا يمكن تغيير '
                'الهيئة الهندسية',
          ),
          t(
            'Vegetation and erosion control on the slope face for shallow '
                'stability only',
            'غطاء نباتي ومكافحة انجراف على وجه المنحدر للاستقرار السطحي فقط',
          ),
        ],
        'monitoringPlan': [
          t(
            'Install inclinometers in boreholes to locate the slip surface '
                'and measure movement with depth.',
            'تركيب مقاييس ميل في جسّات لتحديد سطح الانزلاق وقياس الحركة مع '
                'العمق.',
          ),
          t(
            'Install piezometers to track pore-water pressure through the wet '
                'season.',
            'تركيب بيزومترات لمتابعة ضغط الماء المسامي خلال الموسم المطير.',
          ),
          t(
            'Establish survey reference points and re-observe them with GNSS '
                'or a total station on a fixed schedule.',
            'إنشاء نقاط رصد مرجعية وإعادة قياسها بالـ GNSS أو بالمحطة الشاملة '
                'وفق جدول ثابت.',
          ),
          t(
            'Record and date any new crack, tilt or seepage with photographs.',
            'توثيق أي شق أو ميل أو نزّ جديد بالصور مع التاريخ.',
          ),
        ],
        'requiredStudies': [
          t(
            'Instrumented geotechnical investigation (boreholes, sampling, '
                'shear-strength testing, inclinometers, piezometers)',
            'تحقيق جيوتقني مُجهَّز بالأجهزة (جسّات، أخذ عينات، اختبارات مقاومة '
                'القصّ، مقاييس ميل، بيزومترات)',
          ),
          t(
            'Slope-stability analysis by a licensed geotechnical engineer, '
                'including the factor of safety for each design case',
            'تحليل استقرار المنحدر بواسطة مهندس جيوتقني مُرخَّص، بما يشمل معامل '
                'الأمان لكل حالة تصميمية',
          ),
          t(
            'Engineering-geological mapping of the slope and its catchment',
            'خريطة جيولوجية هندسية للمنحدر وحوضه',
          ),
          t(
            'Structural condition survey of any building or wall on or near '
                'the slope',
            'مسح للحالة الإنشائية لأي مبنى أو جدار على المنحدر أو قربه',
          ),
        ],
        'notes': [
          t(
            'This section is a desk screening derived from terrain context '
                'only. It is NOT a slope-stability analysis and gives no '
                'factor of safety.',
            'هذا القسم فحص مكتبي مبدئي مستنتج من سياق التضاريس فقط. وهو ليس '
                'تحليل استقرار منحدر ولا يقدّم أي معامل أمان.',
          ),
          t(
            'If you see fresh cracks, tilting walls or displaced services, '
                'contact a licensed geotechnical engineer and your local '
                'authority without delay.',
            'إذا رأيت شقوقًا حديثة أو جدرانًا مائلة أو خدمات مُزاحة، فاتصل '
                'بمهندس جيوتقني مُرخَّص وبالجهة المحلية دون تأخير.',
          ),
        ],
      },
      'aerialImagery': {
        'interpretation': t(
          'An aerial view of this area typically shows a patchwork of '
              'cultivated plots separated by tracks, with scattered tree cover '
              'along field edges.',
          'يُظهر المنظر الجوي لهذه المنطقة عادةً رقعًا من القطع المزروعة '
              'تفصلها مسارات، مع غطاء شجري متفرق على حواف الحقول.',
        ),
        'landCover': t(
          'Mixed cultivation with scattered trees and bare ground',
          'زراعة مختلطة مع أشجار متفرقة وأرض جرداء',
        ),
        'visibleFeatures': [
          t(
            'Field boundaries and access tracks',
            'حدود الحقول ومسارات الوصول',
          ),
          t('Seasonal drainage lines', 'خطوط تصريف موسمية'),
          t(
            'Scattered built structures nearby',
            'منشآت مبنية متفرقة في الجوار',
          ),
        ],
      },
      'suitablePlants': [
        t('Tomatoes', 'الطماطم'),
        t('Peppers', 'الفلفل'),
        t('Rosemary', 'إكليل الجبل'),
        t('Lavender', 'الخزامى'),
        t('Olive', 'الزيتون'),
      ],
      'recommendations': [
        t(
          'Add organic compost to improve structure and nutrient retention.',
          'أضف سمادًا عضويًا لتحسين البناء والاحتفاظ بالعناصر الغذائية.',
        ),
        t(
          'Test drainage before planting moisture-sensitive species.',
          'اختبر التصريف قبل زراعة أنواع حساسة للرطوبة.',
        ),
        t(
          'Obtain a professional soil-lab test for exact nutrient, sodium and '
              'salinity values before major planting or building work.',
          'احصل على فحص مختبر تربة معتمد لقيم العناصر والصوديوم والملوحة '
              'الدقيقة قبل أي أعمال زراعة أو بناء كبيرة.',
        ),
        t(
          'Commission an instrumented geotechnical investigation and a '
              'slope-stability analysis before building on or near the slope.',
          'اطلب تحقيقًا جيوتقنيًا مُجهَّزًا بالأجهزة وتحليل استقرار منحدر قبل '
              'البناء على المنحدر أو قربه.',
        ),
      ],
      'safetyNotes': [
        t(
          'Do not rely on these estimates for construction, drainage or '
              'foundation decisions — commission a geotechnical/soil survey.',
          'لا تعتمد على هذه التقديرات في قرارات الإنشاء أو التصريف أو '
              'الأساسات — اطلب مسحًا جيوتقنيًا/للتربة.',
        ),
        t(
          'Land movement can be dangerous. Nothing here clears a slope as safe '
              'to build on, and no part of it supports an evacuation or '
              'occupancy decision — those need a licensed geotechnical engineer '
              'and your local authority.',
          'حركة الأرض قد تكون خطِرة. لا شيء هنا يجيز منحدرًا كآمن للبناء، ولا '
              'يدعم أي جزء منه قرار إخلاء أو إشغال — فهذه تحتاج مهندسًا '
              'جيوتقنيًا مُرخَّصًا والجهة المحلية.',
        ),
        t(
          'Keep any soil amendments and fertilizers away from children and pets.',
          'احفظ محسّنات التربة والأسمدة بعيدًا عن الأطفال والحيوانات المنزلية.',
        ),
      ],
      'confidence': 'low',
      'needsMoreInformation': !hasImage,
      'followUpQuestions': [
        t(
          'Could you attach a clear photo of the soil or site?',
          'هل يمكنك إرفاق صورة واضحة للتربة أو الموقع؟',
        ),
        t(
          'What do you plan to grow or build here?',
          'ما الذي تخطط لزراعته أو بنائه هنا؟',
        ),
        t(
          'Have you noticed any cracks, tilting walls or ground movement on '
              'the site?',
          'هل لاحظت أي شقوق أو جدران مائلة أو حركة في الأرض في الموقع؟',
        ),
      ],
      'disclaimer': t(
        'These are approximate, location-based ESTIMATES and not measured '
            'values. Exact soil depth, sodium, salinity and nutrient figures '
            'require a professional soil-lab test, and any statement about land '
            'movement, slip-surface depth or movement rate requires an '
            'instrumented geotechnical investigation and a slope-stability '
            'analysis. This is a demo response.',
        'هذه تقديرات تقريبية مبنية على الموقع وليست قيمًا مقيسة. تحديد عمق '
            'التربة والصوديوم والملوحة والعناصر الغذائية بدقة يتطلب فحص مختبر '
            'تربة معتمد، وأي قول عن حركة الأرض أو عمق سطح الانزلاق أو سرعة '
            'الحركة يتطلب تحقيقًا جيوتقنيًا مُجهَّزًا بالأجهزة وتحليل استقرار '
            'منحدر. هذا رد تجريبي.',
      ),
    });
  }
}
