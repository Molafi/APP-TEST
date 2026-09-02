import 'soil_level.dart';

/// ---------------------------------------------------------------------------
/// Shared tolerant parsing helpers.
///
/// Every model in this file follows the same contract as the existing soil
/// models: parsing NEVER throws on missing/mistyped fields, empty strings
/// collapse to null, and unknown enum values degrade to a safe default. This
/// keeps older persisted reports (saved before these fields existed) loadable.
/// ---------------------------------------------------------------------------

String? _str(Object? v) {
  if (v == null) return null;
  final String s = v is String ? v.trim() : v.toString().trim();
  return s.isEmpty ? null : s;
}

List<String> _strList(Object? v) => (v is List)
    ? v
          .whereType<Object>()
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList()
    : const <String>[];

double? _num(Object? v) {
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v.trim());
  return null;
}

bool _bool(Object? v, {bool orElse = false}) {
  if (v is bool) return v;
  if (v is String) {
    final String s = v.trim().toLowerCase();
    if (s == 'true' || s == 'yes') return true;
    if (s == 'false' || s == 'no') return false;
  }
  return orElse;
}

/// Parses a JSON list of objects with [build], skipping anything that is not a
/// map. Accepts `Map<dynamic, dynamic>` too, which is what a decoded Firestore
/// document can contain.
List<T> _mapList<T>(Object? v, T Function(Map<String, dynamic>) build) {
  if (v is! List) return <T>[];
  return v
      .whereType<Map>()
      .map((e) => build(Map<String, dynamic>.from(e)))
      .toList();
}

/// ---------------------------------------------------------------------------
/// User requirements
/// ---------------------------------------------------------------------------

/// What the user intends to do with the site. The survey is driven by this:
/// the prompt tailors which findings matter (e.g. bearing capacity and
/// foundation notes for [building], irrigation and nutrients for [agriculture],
/// aquifer yield for [wellDrilling], land-movement screening for
/// [slopeStability]).
enum SurveyPurpose {
  general,
  agriculture,
  building,
  wellDrilling,
  slopeStability,
}

SurveyPurpose surveyPurposeFrom(String? s) => switch (s?.toLowerCase()) {
  'agriculture' => SurveyPurpose.agriculture,
  'building' => SurveyPurpose.building,
  'welldrilling' || 'well_drilling' => SurveyPurpose.wellDrilling,
  'slopestability' ||
  'slope_stability' ||
  'landslide' => SurveyPurpose.slopeStability,
  _ => SurveyPurpose.general,
};

/// Optional official land-registry ("Land Department") record supplied by the
/// user. When [available] is true the survey treats these values as
/// AUTHORITATIVE and must not contradict or re-estimate them; when false the
/// report falls back to AI estimates and says so explicitly.
class LandRecordInfo {
  const LandRecordInfo({
    this.available = false,
    this.source,
    this.parcelId,
    this.registeredArea,
    this.zoning,
    this.classification,
    this.ownershipType,
    this.officialNotes,
  });

  /// True when the user actually provided Land Department data.
  final bool available;

  /// Which authority/registry the data came from.
  final String? source;

  /// Parcel / plot / deed identifier.
  final String? parcelId;

  /// Registered area as recorded officially (free text so any unit works).
  final String? registeredArea;

  /// Permitted land use / zoning designation.
  final String? zoning;

  /// Official land classification (e.g. agricultural, residential, industrial).
  final String? classification;

  /// Ownership type (e.g. freehold, leasehold, state land).
  final String? ownershipType;

  /// Any other official remarks, survey references or restrictions.
  final String? officialNotes;

  /// Non-blank fields only. Guards against a blank value being treated as an
  /// official figure anywhere downstream.
  Iterable<String> get _values => <String?>[
    source,
    parcelId,
    registeredArea,
    zoning,
    classification,
    ownershipType,
    officialNotes,
  ].whereType<String>().where((s) => s.trim().isNotEmpty);

  /// True when at least one substantive field carries data.
  bool get hasData => _values.isNotEmpty;

  /// Updates individual fields. Passing an EMPTY/whitespace string clears that
  /// field (rather than storing a blank that [hasData] and [toContext] would
  /// then treat as official data); passing null leaves it unchanged.
  LandRecordInfo copyWith({
    bool? available,
    String? source,
    String? parcelId,
    String? registeredArea,
    String? zoning,
    String? classification,
    String? ownershipType,
    String? officialNotes,
  }) {
    // Distinguishes "not supplied" (null -> keep) from "cleared" ('' -> null).
    String? resolve(String? incoming, String? current) =>
        incoming == null ? current : _str(incoming);

    return LandRecordInfo(
      available: available ?? this.available,
      source: resolve(source, this.source),
      parcelId: resolve(parcelId, this.parcelId),
      registeredArea: resolve(registeredArea, this.registeredArea),
      zoning: resolve(zoning, this.zoning),
      classification: resolve(classification, this.classification),
      ownershipType: resolve(ownershipType, this.ownershipType),
      officialNotes: resolve(officialNotes, this.officialNotes),
    );
  }

  Map<String, dynamic> toMap() => {
    'available': available,
    'source': source,
    'parcelId': parcelId,
    'registeredArea': registeredArea,
    'zoning': zoning,
    'classification': classification,
    'ownershipType': ownershipType,
    'officialNotes': officialNotes,
  };

  factory LandRecordInfo.fromMap(Map<String, dynamic> m) => LandRecordInfo(
    available: _bool(m['available']),
    source: _str(m['source']),
    parcelId: _str(m['parcelId']),
    registeredArea: _str(m['registeredArea']),
    zoning: _str(m['zoning']),
    classification: _str(m['classification']),
    ownershipType: _str(m['ownershipType']),
    officialNotes: _str(m['officialNotes']),
  );

  /// Flattened key/value pairs handed to the AI as context. Only non-empty
  /// values are included so the model never sees blank placeholders.
  ///
  /// Values are sanitised because context is flattened into a single
  /// `key: value, …` line: commas and newlines in free text could otherwise
  /// forge additional `land*` keys that the prompt treats as AUTHORITATIVE.
  /// Length is capped for the same reason.
  Map<String, String> toContext() {
    String? clean(String? v) {
      if (v == null) return null;
      final String s = v
          .replaceAll(RegExp(r'[\r\n]+'), ' ')
          .replaceAll(',', ';')
          .trim();
      if (s.isEmpty) return null;
      return s.length > 200 ? '${s.substring(0, 200)}…' : s;
    }

    final String? src = clean(source);
    final String? pid = clean(parcelId);
    final String? area = clean(registeredArea);
    final String? zone = clean(zoning);
    final String? cls = clean(classification);
    final String? own = clean(ownershipType);
    final String? notes = clean(officialNotes);

    return {
      if (src != null) 'landRecordSource': src,
      if (pid != null) 'landParcelId': pid,
      if (area != null) 'landRegisteredArea': area,
      if (zone != null) 'landZoning': zone,
      if (cls != null) 'landClassification': cls,
      if (own != null) 'landOwnershipType': own,
      if (notes != null) 'landOfficialNotes': notes,
    };
  }
}

/// ---------------------------------------------------------------------------
/// Site location
/// ---------------------------------------------------------------------------

/// Where the surveyed site is and how it is laid out.
class SiteLocation {
  const SiteLocation({
    this.address,
    this.latitude,
    this.longitude,
    this.elevation,
    this.areaEstimate,
    this.boundaryDescription,
    this.accessNotes,
    this.terrainSetting,
  });

  final String? address;
  final double? latitude;
  final double? longitude;

  /// Approximate elevation above sea level, e.g. "420 m (estimate)".
  final String? elevation;

  /// Approximate site area. Free text so any unit is accepted.
  final String? areaEstimate;

  /// Shape / extent / neighbouring-feature description of the plot.
  final String? boundaryDescription;

  /// Road access, machinery access, distance to services.
  final String? accessNotes;

  /// Surrounding setting, e.g. "valley floor", "coastal plain", "hillside".
  final String? terrainSetting;

  bool get isEmpty =>
      address == null &&
      latitude == null &&
      longitude == null &&
      elevation == null &&
      areaEstimate == null &&
      boundaryDescription == null &&
      accessNotes == null &&
      terrainSetting == null;

  Map<String, dynamic> toMap() => {
    'address': address,
    'latitude': latitude,
    'longitude': longitude,
    'elevation': elevation,
    'areaEstimate': areaEstimate,
    'boundaryDescription': boundaryDescription,
    'accessNotes': accessNotes,
    'terrainSetting': terrainSetting,
  };

  factory SiteLocation.fromMap(Map<String, dynamic> m) => SiteLocation(
    address: _str(m['address']),
    latitude: _num(m['latitude']),
    longitude: _num(m['longitude']),
    elevation: _str(m['elevation']),
    areaEstimate: _str(m['areaEstimate']),
    boundaryDescription: _str(m['boundaryDescription']),
    accessNotes: _str(m['accessNotes']),
    terrainSetting: _str(m['terrainSetting']),
  );
}

/// ---------------------------------------------------------------------------
/// Topographic survey
/// ---------------------------------------------------------------------------

/// Estimated topographic survey of the site. This is a DESK STUDY derived from
/// location, regional context and any attached imagery — it is NOT a substitute
/// for an instrument survey by a licensed surveyor.
class TopographySurvey {
  const TopographySurvey({
    this.summary,
    this.elevationRange,
    this.slope,
    this.slopePercent,
    this.aspect,
    this.landform,
    this.relief,
    this.contourSummary,
    this.drainagePattern,
    this.runoffNotes,
    this.floodRisk,
    this.erosionRisk,
    this.gradingNotes,
    this.notes = const <String>[],
  });

  /// One-line plain-language overview of the terrain.
  final String? summary;

  /// Elevation range across the plot, e.g. "412–427 m".
  final String? elevationRange;

  /// Qualitative slope descriptor, e.g. "gentle", "moderately steep".
  final String? slope;

  /// Approximate gradient as a percentage when it can be estimated.
  final double? slopePercent;

  /// Dominant slope direction, e.g. "south-facing".
  final String? aspect;

  /// Landform classification, e.g. "alluvial fan", "ridge", "plateau".
  final String? landform;

  /// Relief description, e.g. "low relief, < 5 m variation".
  final String? relief;

  /// What contour lines would show, and a suggested contour interval.
  final String? contourSummary;

  /// Natural drainage pattern, e.g. "dendritic, draining to the south-east".
  final String? drainagePattern;

  /// Surface-runoff / ponding behaviour.
  final String? runoffNotes;

  final SoilLevel? floodRisk;
  final SoilLevel? erosionRisk;

  /// Cut/fill, levelling and earthworks considerations.
  final String? gradingNotes;

  final List<String> notes;

  bool get isEmpty =>
      summary == null &&
      elevationRange == null &&
      slope == null &&
      slopePercent == null &&
      aspect == null &&
      landform == null &&
      relief == null &&
      contourSummary == null &&
      drainagePattern == null &&
      runoffNotes == null &&
      floodRisk == null &&
      erosionRisk == null &&
      gradingNotes == null &&
      notes.isEmpty;

  Map<String, dynamic> toMap() => {
    'summary': summary,
    'elevationRange': elevationRange,
    'slope': slope,
    'slopePercent': slopePercent,
    'aspect': aspect,
    'landform': landform,
    'relief': relief,
    'contourSummary': contourSummary,
    'drainagePattern': drainagePattern,
    'runoffNotes': runoffNotes,
    'floodRisk': floodRisk?.name,
    'erosionRisk': erosionRisk?.name,
    'gradingNotes': gradingNotes,
    'notes': notes,
  };

  factory TopographySurvey.fromMap(Map<String, dynamic> m) => TopographySurvey(
    summary: _str(m['summary']),
    elevationRange: _str(m['elevationRange']),
    slope: _str(m['slope']),
    slopePercent: _num(m['slopePercent']),
    aspect: _str(m['aspect']),
    landform: _str(m['landform']),
    relief: _str(m['relief']),
    contourSummary: _str(m['contourSummary']),
    drainagePattern: _str(m['drainagePattern']),
    runoffNotes: _str(m['runoffNotes']),
    floodRisk: soilLevelOrNull(_str(m['floodRisk'])),
    erosionRisk: soilLevelOrNull(_str(m['erosionRisk'])),
    gradingNotes: _str(m['gradingNotes']),
    notes: _strList(m['notes']),
  );
}

/// ---------------------------------------------------------------------------
/// Groundwater
/// ---------------------------------------------------------------------------

/// Estimated groundwater assessment. Driven by user requirements: when the user
/// asks about wells/irrigation this section carries the yield and feasibility
/// detail. Values are regional estimates unless official data is supplied —
/// a hydrogeological study is required before drilling.
class GroundwaterAssessment {
  const GroundwaterAssessment({
    this.summary,
    this.waterTableDepth,
    this.aquiferType,
    this.yieldPotential,
    this.waterQuality,
    this.salinityRisk,
    this.seasonalVariation,
    this.rechargeNotes,
    this.wellFeasibility,
    this.drillingDepthEstimate,
    this.contaminationRisk,
    this.notes = const <String>[],
  });

  final String? summary;

  /// Estimated depth to the water table, e.g. "12–20 m below ground".
  final String? waterTableDepth;

  /// Aquifer character, e.g. "unconfined alluvial aquifer".
  final String? aquiferType;

  /// Likely extractable yield.
  final SoilLevel? yieldPotential;

  /// Expected water quality for the intended use.
  final String? waterQuality;

  /// Risk that groundwater is brackish/saline.
  final SoilLevel? salinityRisk;

  /// How the water table moves between wet and dry seasons.
  final String? seasonalVariation;

  /// Recharge sources and sustainability considerations.
  final String? rechargeNotes;

  /// Whether a well/borehole looks viable, and with what caveats.
  final String? wellFeasibility;

  /// Rough drilling depth that would likely be required.
  final String? drillingDepthEstimate;

  final SoilLevel? contaminationRisk;

  final List<String> notes;

  bool get isEmpty =>
      summary == null &&
      waterTableDepth == null &&
      aquiferType == null &&
      yieldPotential == null &&
      waterQuality == null &&
      salinityRisk == null &&
      seasonalVariation == null &&
      rechargeNotes == null &&
      wellFeasibility == null &&
      drillingDepthEstimate == null &&
      contaminationRisk == null &&
      notes.isEmpty;

  Map<String, dynamic> toMap() => {
    'summary': summary,
    'waterTableDepth': waterTableDepth,
    'aquiferType': aquiferType,
    'yieldPotential': yieldPotential?.name,
    'waterQuality': waterQuality,
    'salinityRisk': salinityRisk?.name,
    'seasonalVariation': seasonalVariation,
    'rechargeNotes': rechargeNotes,
    'wellFeasibility': wellFeasibility,
    'drillingDepthEstimate': drillingDepthEstimate,
    'contaminationRisk': contaminationRisk?.name,
    'notes': notes,
  };

  factory GroundwaterAssessment.fromMap(Map<String, dynamic> m) =>
      GroundwaterAssessment(
        summary: _str(m['summary']),
        waterTableDepth: _str(m['waterTableDepth']),
        aquiferType: _str(m['aquiferType']),
        yieldPotential: soilLevelOrNull(_str(m['yieldPotential'])),
        waterQuality: _str(m['waterQuality']),
        salinityRisk: soilLevelOrNull(_str(m['salinityRisk'])),
        seasonalVariation: _str(m['seasonalVariation']),
        rechargeNotes: _str(m['rechargeNotes']),
        wellFeasibility: _str(m['wellFeasibility']),
        drillingDepthEstimate: _str(m['drillingDepthEstimate']),
        contaminationRisk: soilLevelOrNull(_str(m['contaminationRisk'])),
        notes: _strList(m['notes']),
      );
}

/// ---------------------------------------------------------------------------
/// Building / construction suitability
/// ---------------------------------------------------------------------------

/// Preliminary construction-suitability screening for the "for building" use
/// case. Explicitly NOT a geotechnical report: a licensed geotechnical
/// investigation (boreholes, plate load tests) is required before any
/// foundation design. [suitability] is a screening rating only.
class BuildingSuitability {
  const BuildingSuitability({
    this.summary,
    this.suitability,
    this.bearingCapacity,
    this.bedrockDepth,
    this.foundationSuggestion,
    this.settlementRisk,
    this.expansiveSoilRisk,
    this.seismicNotes,
    this.excavationNotes,
    this.drainageRequirements,
    this.constraints = const <String>[],
    this.requiredStudies = const <String>[],
  });

  final String? summary;

  /// Screening rating: high = generally favourable, low = significant concerns.
  final SoilLevel? suitability;

  /// Qualitative bearing-capacity expectation, never a precise kPa figure.
  final String? bearingCapacity;

  /// Estimated depth to bedrock / refusal.
  final String? bedrockDepth;

  /// Likely appropriate foundation approach, framed as a starting hypothesis.
  final String? foundationSuggestion;

  final SoilLevel? settlementRisk;

  /// Shrink/swell (expansive clay) risk.
  final SoilLevel? expansiveSoilRisk;

  /// Regional seismic context.
  final String? seismicNotes;

  /// Digging/trenching/shoring considerations.
  final String? excavationNotes;

  /// Site drainage and waterproofing needs.
  final String? drainageRequirements;

  /// Site constraints that could limit or complicate construction.
  final List<String> constraints;

  /// Professional studies that must be commissioned before building.
  final List<String> requiredStudies;

  bool get isEmpty =>
      summary == null &&
      suitability == null &&
      bearingCapacity == null &&
      bedrockDepth == null &&
      foundationSuggestion == null &&
      settlementRisk == null &&
      expansiveSoilRisk == null &&
      seismicNotes == null &&
      excavationNotes == null &&
      drainageRequirements == null &&
      constraints.isEmpty &&
      requiredStudies.isEmpty;

  Map<String, dynamic> toMap() => {
    'summary': summary,
    'suitability': suitability?.name,
    'bearingCapacity': bearingCapacity,
    'bedrockDepth': bedrockDepth,
    'foundationSuggestion': foundationSuggestion,
    'settlementRisk': settlementRisk?.name,
    'expansiveSoilRisk': expansiveSoilRisk?.name,
    'seismicNotes': seismicNotes,
    'excavationNotes': excavationNotes,
    'drainageRequirements': drainageRequirements,
    'constraints': constraints,
    'requiredStudies': requiredStudies,
  };

  factory BuildingSuitability.fromMap(Map<String, dynamic> m) =>
      BuildingSuitability(
        summary: _str(m['summary']),
        suitability: soilLevelOrNull(_str(m['suitability'])),
        bearingCapacity: _str(m['bearingCapacity']),
        bedrockDepth: _str(m['bedrockDepth']),
        foundationSuggestion: _str(m['foundationSuggestion']),
        settlementRisk: soilLevelOrNull(_str(m['settlementRisk'])),
        expansiveSoilRisk: soilLevelOrNull(_str(m['expansiveSoilRisk'])),
        seismicNotes: _str(m['seismicNotes']),
        excavationNotes: _str(m['excavationNotes']),
        drainageRequirements: _str(m['drainageRequirements']),
        constraints: _strList(m['constraints']),
        requiredStudies: _strList(m['requiredStudies']),
      );
}

/// ---------------------------------------------------------------------------
/// Slope stability / land movement
/// ---------------------------------------------------------------------------

/// A structure exposed to land movement.
///
/// [risk] uses the STRICT parser so an unrecognised value renders as "no level
/// shown" rather than a reassuring "Low" chip — understating exposure for a
/// building is the worst failure mode this feature has.
///
/// Structures are described generically by position and type (e.g. "houses on
/// the upper crown of the slope") unless the user named them, and every entry
/// carries the verification step that would actually establish its condition.
/// Nothing here supports an occupancy or evacuation decision.
class StructureRisk {
  const StructureRisk({
    required this.name,
    this.risk,
    this.reason,
    this.recommendation,
  });

  /// What the structure is and where it sits relative to the slope.
  final String name;

  /// Exposure implied by position — never a verdict on the building itself.
  final SoilLevel? risk;

  /// Why that position is exposed.
  final String? reason;

  /// The check or action that would establish the real condition.
  final String? recommendation;

  Map<String, dynamic> toMap() => {
    'name': name,
    'risk': risk?.name,
    'reason': reason,
    'recommendation': recommendation,
  };

  factory StructureRisk.fromMap(Map<String, dynamic> m) => StructureRisk(
    name: _str(m['name']) ?? '',
    risk: soilLevelOrNull(_str(m['risk'])),
    reason: _str(m['reason']),
    recommendation: _str(m['recommendation']),
  );
}

/// A described part of the plot and whether it could be built on.
///
/// [buildableAfterTreatment] is a CONDITIONAL hypothesis: true means "only if
/// the listed [requiredTreatments] are carried out and a licensed geotechnical
/// engineer designs and signs off the works". It never means the zone is
/// currently safe. It defaults to false so a missing/mistyped value cannot read
/// as permission to build.
class PlotZone {
  const PlotZone({
    required this.name,
    this.location,
    this.buildability,
    this.buildableAfterTreatment = false,
    this.requiredTreatments = const <String>[],
    this.note,
  });

  final String name;

  /// Where the zone is within the plot.
  final String? location;

  /// Screening rating: high = most favourable. Strict parser, so an
  /// unrecognised value hides the chip instead of inventing a rating.
  final SoilLevel? buildability;

  /// Conditional on [requiredTreatments] plus engineered sign-off.
  final bool buildableAfterTreatment;

  /// What must be done before any construction is considered.
  final List<String> requiredTreatments;

  final String? note;

  Map<String, dynamic> toMap() => {
    'name': name,
    'location': location,
    'buildability': buildability?.name,
    'buildableAfterTreatment': buildableAfterTreatment,
    'requiredTreatments': requiredTreatments,
    'note': note,
  };

  factory PlotZone.fromMap(Map<String, dynamic> m) => PlotZone(
    name: _str(m['name']) ?? '',
    location: _str(m['location']),
    buildability: soilLevelOrNull(_str(m['buildability'])),
    buildableAfterTreatment: _bool(m['buildableAfterTreatment']),
    requiredTreatments: _strList(m['requiredTreatments']),
    note: _str(m['note']),
  );
}

/// Preliminary screening of land movement (landslide / creep) potential.
///
/// Explicitly NOT a slope-stability analysis and it carries no factor of
/// safety. The three questions users ask first — which way the ground is
/// moving, how deep the slip surface is, and how fast it moves — cannot be
/// answered without instrumentation, so those fields hold qualitative ranges
/// paired with the instrument that measures them (inclinometers and piezometers
/// in boreholes, repeated GNSS/InSAR observation).
class SlopeStabilityAssessment {
  const SlopeStabilityAssessment({
    this.summary,
    this.hazardLevel,
    this.activityState,
    this.movementDirection,
    this.movementAzimuth,
    this.slipSurfaceDepth,
    this.slipSurfaceType,
    this.movementRate,
    this.movementRateClass,
    this.failureMechanism,
    this.indicators = const <String>[],
    this.triggers = const <String>[],
    this.atRiskStructures = const <StructureRisk>[],
    this.zones = const <PlotZone>[],
    this.stabilisationOptions = const <String>[],
    this.monitoringPlan = const <String>[],
    this.requiredStudies = const <String>[],
    this.notes = const <String>[],
  });

  final String? summary;

  /// Overall screening hazard rating. Strict parser — an unrecognised value
  /// hides the chip rather than displaying "Low".
  final SoilLevel? hazardLevel;

  /// Whether movement appears active, dormant or absent — always unverified
  /// without monitoring.
  final String? activityState;

  /// Direction of any movement in plain words, e.g. "downslope toward the
  /// south-east, following the steepest gradient".
  final String? movementDirection;

  /// Approximate compass bearing of that direction in degrees, when the
  /// terrain context supports one.
  final double? movementAzimuth;

  /// Plausible depth RANGE to the slip (failure) surface, always with the
  /// measurement caveat. Never a single precise figure.
  final String? slipSurfaceDepth;

  /// Likely failure geometry, e.g. "shallow translational", "rotational".
  final String? slipSurfaceType;

  /// Movement rate as a qualitative range plus what would measure it.
  final String? movementRate;

  /// Coarse rate class for the chip. Strict parser.
  final SoilLevel? movementRateClass;

  /// The mechanism that would drive failure, e.g. rainfall-driven pore-water
  /// pressure reducing shear strength.
  final String? failureMechanism;

  /// Field signs the user can look for themselves (cracks, tilt, seepage).
  final List<String> indicators;

  /// What could set movement off (rainfall, cutting the toe, leaking pipes).
  final List<String> triggers;

  /// Structures exposed by their position on or near the slope.
  final List<StructureRisk> atRiskStructures;

  /// Parts of the plot and what each would need before construction.
  final List<PlotZone> zones;

  /// Candidate engineering measures (drainage, regrading, retention).
  final List<String> stabilisationOptions;

  /// Instrumentation and observation programme that would answer the
  /// unanswerable fields above.
  final List<String> monitoringPlan;

  /// Professional studies this screening cannot replace.
  final List<String> requiredStudies;

  final List<String> notes;

  bool get isEmpty =>
      summary == null &&
      hazardLevel == null &&
      activityState == null &&
      movementDirection == null &&
      movementAzimuth == null &&
      slipSurfaceDepth == null &&
      slipSurfaceType == null &&
      movementRate == null &&
      movementRateClass == null &&
      failureMechanism == null &&
      indicators.isEmpty &&
      triggers.isEmpty &&
      atRiskStructures.isEmpty &&
      zones.isEmpty &&
      stabilisationOptions.isEmpty &&
      monitoringPlan.isEmpty &&
      requiredStudies.isEmpty &&
      notes.isEmpty;

  Map<String, dynamic> toMap() => {
    'summary': summary,
    'hazardLevel': hazardLevel?.name,
    'activityState': activityState,
    'movementDirection': movementDirection,
    'movementAzimuth': movementAzimuth,
    'slipSurfaceDepth': slipSurfaceDepth,
    'slipSurfaceType': slipSurfaceType,
    'movementRate': movementRate,
    'movementRateClass': movementRateClass?.name,
    'failureMechanism': failureMechanism,
    'indicators': indicators,
    'triggers': triggers,
    'atRiskStructures': atRiskStructures.map((e) => e.toMap()).toList(),
    'zones': zones.map((e) => e.toMap()).toList(),
    'stabilisationOptions': stabilisationOptions,
    'monitoringPlan': monitoringPlan,
    'requiredStudies': requiredStudies,
    'notes': notes,
  };

  factory SlopeStabilityAssessment.fromMap(Map<String, dynamic> m) =>
      SlopeStabilityAssessment(
        summary: _str(m['summary']),
        hazardLevel: soilLevelOrNull(_str(m['hazardLevel'])),
        activityState: _str(m['activityState']),
        movementDirection: _str(m['movementDirection']),
        movementAzimuth: _num(m['movementAzimuth']),
        slipSurfaceDepth: _str(m['slipSurfaceDepth']),
        slipSurfaceType: _str(m['slipSurfaceType']),
        movementRate: _str(m['movementRate']),
        movementRateClass: soilLevelOrNull(_str(m['movementRateClass'])),
        failureMechanism: _str(m['failureMechanism']),
        indicators: _strList(m['indicators']),
        triggers: _strList(m['triggers']),
        // Nameless entries are dropped: an unlabelled risk row would show a
        // level chip with nothing to attach it to.
        atRiskStructures: _mapList(
          m['atRiskStructures'],
          StructureRisk.fromMap,
        ).where((e) => e.name.isNotEmpty).toList(),
        zones: _mapList(
          m['zones'],
          PlotZone.fromMap,
        ).where((e) => e.name.isNotEmpty).toList(),
        stabilisationOptions: _strList(m['stabilisationOptions']),
        monitoringPlan: _strList(m['monitoringPlan']),
        requiredStudies: _strList(m['requiredStudies']),
        notes: _strList(m['notes']),
      );
}

/// ---------------------------------------------------------------------------
/// Official (national mapping authority) map reference
/// ---------------------------------------------------------------------------

/// A reference into the national mapping authority's products for this site —
/// for Jordan, the Royal Jordanian Geographic Centre (RJGC).
///
/// Everything here is computed by the app from the coordinates (grid maths and
/// configured service URLs); the AI never supplies any of it, exactly like the
/// aerial tile URL. That keeps a model from inventing an official-looking grid
/// reference.
///
/// The grid values are an unofficial CONVERSION for locating and ordering maps,
/// not a surveyed position: a licensed cadastral survey is still required for
/// any boundary or legal purpose.
class OfficialMapReference {
  const OfficialMapReference({
    required this.authority,
    required this.gridName,
    this.gridCode,
    this.easting,
    this.northing,
    this.latitude,
    this.longitude,
    this.tileUrl,
    this.tileAttribution,
    this.portalUrl,
    this.orderUrl,
    this.datumShiftApplied = false,
  });

  /// Mapping authority name, e.g. "Royal Jordanian Geographic Centre (RJGC)".
  final String authority;

  /// Projected grid the easting/northing belong to, e.g. "Jordan Transverse
  /// Mercator (JTM)".
  final String gridName;

  /// CRS identifier, e.g. "EPSG:3066".
  final String? gridCode;

  /// Grid easting in metres.
  final double? easting;

  /// Grid northing in metres.
  final double? northing;

  /// The WGS84 coordinates the grid values were converted from.
  final double? latitude;
  final double? longitude;

  /// Authority basemap tile URL, only when a service has been configured for
  /// the build (official services usually require an agreement).
  final String? tileUrl;
  final String? tileAttribution;

  /// The authority's geoportal / map viewer.
  final String? portalUrl;

  /// Where official maps, aerial photos and cadastral extracts are ordered.
  final String? orderUrl;

  /// Whether an official datum transformation was applied to the grid values.
  ///
  /// Stored as a flag rather than a sentence so the caveat can be rendered in
  /// the user's language — the whole point of this change — instead of being
  /// baked into an English string at conversion time.
  final bool datumShiftApplied;

  bool get hasGrid => easting != null && northing != null;

  /// "Nothing worth showing the user". Deliberately ignores [authority] and
  /// [gridName], which are always-present constants — including them would make
  /// this permanently false and the card would render an empty shell.
  bool get isEmpty =>
      !hasGrid && tileUrl == null && portalUrl == null && orderUrl == null;

  /// One-line grid reference in the form a surveyor or the mapping authority's
  /// counter staff expects, or null when there is no grid to describe.
  ///
  /// The CRS is always included: a bare pair of numbers with no coordinate
  /// system is ambiguous, and the two Jordanian grids in common use (JTM and the
  /// older Palestine grid) give very different values for the same point.
  ///
  /// The unofficial-conversion caveat is part of the same string on purpose, so
  /// the numbers cannot be copied or shared without it travelling along.
  String? gridReferenceLine() {
    if (!hasGrid) return null;
    final StringBuffer b = StringBuffer(gridName);
    if (gridCode != null) b.write(' $gridCode');
    b.write(': E ${easting!.toStringAsFixed(1)} m');
    b.write(', N ${northing!.toStringAsFixed(1)} m');
    if (latitude != null && longitude != null) {
      b.write(
        ' (WGS84 ${latitude!.toStringAsFixed(5)}, '
        '${longitude!.toStringAsFixed(5)})',
      );
    }
    if (!datumShiftApplied) {
      b.write(' — unofficial conversion, no datum transformation applied');
    }
    return b.toString();
  }

  Map<String, dynamic> toMap() => {
    'authority': authority,
    'gridName': gridName,
    'gridCode': gridCode,
    'easting': easting,
    'northing': northing,
    'latitude': latitude,
    'longitude': longitude,
    'tileUrl': tileUrl,
    'tileAttribution': tileAttribution,
    'portalUrl': portalUrl,
    'orderUrl': orderUrl,
    'datumShiftApplied': datumShiftApplied,
  };

  factory OfficialMapReference.fromMap(Map<String, dynamic> m) =>
      OfficialMapReference(
        authority: _str(m['authority']) ?? '',
        gridName: _str(m['gridName']) ?? '',
        gridCode: _str(m['gridCode']),
        easting: _num(m['easting']),
        northing: _num(m['northing']),
        latitude: _num(m['latitude']),
        longitude: _num(m['longitude']),
        tileUrl: _str(m['tileUrl']),
        tileAttribution: _str(m['tileAttribution']),
        portalUrl: _str(m['portalUrl']),
        orderUrl: _str(m['orderUrl']),
        datumShiftApplied: _bool(m['datumShiftApplied']),
      );
}

/// ---------------------------------------------------------------------------
/// Aerial imagery
/// ---------------------------------------------------------------------------

/// A reference to an aerial/satellite view of the site. The URL is built
/// locally from coordinates by `AerialImageryService` — the AI never invents
/// image URLs, it only describes what aerial context implies.
class AerialImageryInfo {
  const AerialImageryInfo({
    required this.url,
    required this.provider,
    required this.attribution,
    required this.zoom,
    this.interpretation,
    this.landCover,
    this.visibleFeatures = const <String>[],
  });

  /// Tile/static-image URL for display.
  final String url;
  final String provider;
  final String attribution;
  final int zoom;

  /// AI narrative of what an aerial view of this area typically shows.
  final String? interpretation;

  /// Dominant land cover, e.g. "irrigated cropland with scattered trees".
  final String? landCover;

  /// Notable features an aerial view would reveal.
  final List<String> visibleFeatures;

  Map<String, dynamic> toMap() => {
    'url': url,
    'provider': provider,
    'attribution': attribution,
    'zoom': zoom,
    'interpretation': interpretation,
    'landCover': landCover,
    'visibleFeatures': visibleFeatures,
  };

  factory AerialImageryInfo.fromMap(Map<String, dynamic> m) =>
      AerialImageryInfo(
        url: _str(m['url']) ?? '',
        provider: _str(m['provider']) ?? '',
        attribution: _str(m['attribution']) ?? '',
        zoom: (_num(m['zoom']) ?? 0).round(),
        interpretation: _str(m['interpretation']),
        landCover: _str(m['landCover']),
        visibleFeatures: _strList(m['visibleFeatures']),
      );

  /// Merges AI-provided narrative fields onto a locally built image reference.
  AerialImageryInfo withNarrative({
    String? interpretation,
    String? landCover,
    List<String>? visibleFeatures,
  }) {
    return AerialImageryInfo(
      url: url,
      provider: provider,
      attribution: attribution,
      zoom: zoom,
      interpretation: interpretation ?? this.interpretation,
      landCover: landCover ?? this.landCover,
      visibleFeatures: visibleFeatures ?? this.visibleFeatures,
    );
  }
}
