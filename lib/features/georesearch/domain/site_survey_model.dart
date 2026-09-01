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

/// ---------------------------------------------------------------------------
/// User requirements
/// ---------------------------------------------------------------------------

/// What the user intends to do with the site. The survey is driven by this:
/// the prompt tailors which findings matter (e.g. bearing capacity and
/// foundation notes for [building], irrigation and nutrients for [agriculture],
/// aquifer yield for [wellDrilling]).
enum SurveyPurpose { general, agriculture, building, wellDrilling }

SurveyPurpose surveyPurposeFrom(String? s) => switch (s?.toLowerCase()) {
  'agriculture' => SurveyPurpose.agriculture,
  'building' => SurveyPurpose.building,
  'welldrilling' || 'well_drilling' => SurveyPurpose.wellDrilling,
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

  factory AerialImageryInfo.fromMap(Map<String, dynamic> m) => AerialImageryInfo(
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
