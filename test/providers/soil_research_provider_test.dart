import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plantsense_ai/features/georesearch/application/soil_research_provider.dart';
import 'package:plantsense_ai/features/georesearch/domain/soil_report_model.dart';
import 'package:plantsense_ai/features/location/application/location_provider.dart';
import 'package:plantsense_ai/features/location/domain/location_model.dart';

import '../mocks/mocks.dart';

/// A model reply that TRIES to supply app-owned fields. The controller must not
/// trust any of them: `landRecord` would otherwise be badged "Official record",
/// `aerialImagery` would caption an image that was never fetched, and
/// `userRequirements` would attribute a requirement the user never typed.
const String _overreachingReply = '''
{
  "isSoilRelated": true,
  "imageQuality": "good",
  "nutrients": [],
  "substances": [],
  "suitablePlants": [],
  "recommendations": [],
  "safetyNotes": [],
  "confidence": "low",
  "needsMoreInformation": false,
  "followUpQuestions": [],
  "disclaimer": "d",
  "userRequirements": "requirement the user never typed",
  "landRecord": {
    "available": true,
    "source": "Land Department",
    "parcelId": "MODEL-INVENTED-999",
    "zoning": "Industrial"
  },
  "aerialImagery": {
    "interpretation": "Narrative about imagery that was never fetched",
    "landCover": "Cropland",
    "visibleFeatures": ["Tracks"]
  }
}''';

/// A reply that fabricates an `officialMap` object. The prompt forbids it, but
/// a model can always ignore the prompt — the controller must overwrite it with
/// the app's own conversion rather than badge invented numbers as authority data.
const String _fabricatedOfficialMapReply = '''
{
  "isSoilRelated": true,
  "imageQuality": "good",
  "nutrients": [],
  "substances": [],
  "suitablePlants": [],
  "recommendations": [],
  "safetyNotes": [],
  "confidence": "low",
  "needsMoreInformation": false,
  "followUpQuestions": [],
  "disclaimer": "d",
  "officialMap": {
    "authority": "Totally Official Authority",
    "gridName": "Invented Grid",
    "easting": 111111.0,
    "northing": 222222.0,
    "portalUrl": "https://evil.example/fake-portal",
    "datumShiftApplied": true
  }
}''';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<ProviderContainer> makeContainer({
    FakeAiGateway? gateway,
    PlantLocation? location,
  }) async {
    final overrides = await defaultOverrides(gateway: gateway);
    final container = ProviderContainer(
      overrides: [
        ...overrides,
        if (location != null)
          selectedLocationProvider.overrideWith((ref) => location),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('official land record provenance', () {
    test('the report carries the record the USER entered', () async {
      final container = await makeContainer(
        gateway: FakeAiGateway(reply: _overreachingReply),
      );
      final controller = container.read(
        soilResearchControllerProvider.notifier,
      );

      controller.setLandRecord(
        const LandRecordInfo(
          available: true,
          source: 'Land Department',
          parcelId: 'USER-P-1',
          zoning: 'Residential',
        ),
      );
      await controller.analyze();

      final report = container.read(soilResearchControllerProvider).result!;
      expect(report.landRecord, isNotNull);
      expect(report.landRecord!.parcelId, 'USER-P-1');
      expect(report.landRecord!.zoning, 'Residential');
    });

    test('a model-invented record is discarded, not badged official', () async {
      final container = await makeContainer(
        gateway: FakeAiGateway(reply: _overreachingReply),
      );
      final controller = container.read(
        soilResearchControllerProvider.notifier,
      );

      // The user supplied nothing, but the model volunteered a record.
      await controller.analyze();

      final report = container.read(soilResearchControllerProvider).result!;
      expect(report.landRecord, isNull);
    });

    test(
      'a record is withheld when the user has not marked it available',
      () async {
        final container = await makeContainer(
          gateway: FakeAiGateway(reply: _overreachingReply),
        );
        final controller = container.read(
          soilResearchControllerProvider.notifier,
        );

        controller.setLandRecord(
          const LandRecordInfo(parcelId: 'TYPED-BUT-OFF'),
        );
        await controller.analyze();

        final report = container.read(soilResearchControllerProvider).result!;
        expect(report.landRecord, isNull);
      },
    );
  });

  group('aerial imagery provenance', () {
    test('no coordinates clears the model imagery stub', () async {
      final container = await makeContainer(
        gateway: FakeAiGateway(reply: _overreachingReply),
      );
      final controller = container.read(
        soilResearchControllerProvider.notifier,
      );

      await controller.analyze();

      // Without coordinates there is no tile, so the card must not render a
      // narrative about imagery that does not exist.
      final report = container.read(soilResearchControllerProvider).result!;
      expect(report.aerialImagery, isNull);
    });

    test(
      'with coordinates the URL is local and the narrative is merged',
      () async {
        final container = await makeContainer(
          gateway: FakeAiGateway(reply: _overreachingReply),
          location: const PlantLocation(
            latitude: 24.7136,
            longitude: 46.6753,
            city: 'Riyadh',
          ),
        );
        final controller = container.read(
          soilResearchControllerProvider.notifier,
        );

        await controller.analyze();

        final info = container
            .read(soilResearchControllerProvider)
            .result!
            .aerialImagery!;
        expect(info.url, contains('World_Imagery'));
        expect(info.url, endsWith('/16/28122/41264'));
        expect(info.attribution, isNotEmpty);
        // Narrative fields still come from the model.
        expect(info.landCover, 'Cropland');
        expect(info.visibleFeatures, ['Tracks']);
      },
    );
  });

  group('official map / national grid provenance', () {
    test('a Jordanian location gets a JTM grid reference', () async {
      final container = await makeContainer(
        gateway: FakeAiGateway(reply: _overreachingReply),
        location: const PlantLocation(
          latitude: 31.9539,
          longitude: 35.9106,
          city: 'Amman',
        ),
      );
      final controller = container.read(
        soilResearchControllerProvider.notifier,
      );

      await controller.analyze();

      final map = container
          .read(soilResearchControllerProvider)
          .result!
          .officialMap!;
      expect(map.authority, contains('RJGC'));
      expect(map.gridCode, 'EPSG:3066');
      expect(map.easting, closeTo(397021.1, 0.5));
      expect(map.northing, closeTo(536604.5, 0.5));
      // No official datum parameters are configured, so the caveat flag is set.
      expect(map.datumShiftApplied, isFalse);
    });

    test('a location outside Jordan gets no national grid', () async {
      final container = await makeContainer(
        gateway: FakeAiGateway(reply: _overreachingReply),
        location: const PlantLocation(
          latitude: 24.7136,
          longitude: 46.6753,
          city: 'Riyadh',
        ),
      );
      final controller = container.read(
        soilResearchControllerProvider.notifier,
      );

      await controller.analyze();

      // Quoting a Jordanian grid reference for Riyadh would be misleading.
      expect(
        container.read(soilResearchControllerProvider).result!.officialMap,
        isNull,
      );
    });

    test('a model-invented official map is discarded', () async {
      final container = await makeContainer(
        gateway: FakeAiGateway(reply: _fabricatedOfficialMapReply),
        location: const PlantLocation(
          latitude: 31.9539,
          longitude: 35.9106,
          city: 'Amman',
        ),
      );
      final controller = container.read(
        soilResearchControllerProvider.notifier,
      );

      await controller.analyze();

      final map = container
          .read(soilResearchControllerProvider)
          .result!
          .officialMap!;
      // The app's own conversion must win: an authority-badged grid reference
      // can never originate in model output.
      expect(map.easting, isNot(111111.0));
      expect(map.easting, closeTo(397021.1, 0.5));
      expect(map.portalUrl, isNot('https://evil.example/fake-portal'));
    });

    test('no coordinates means no official map at all', () async {
      final container = await makeContainer(
        gateway: FakeAiGateway(reply: _fabricatedOfficialMapReply),
      );
      final controller = container.read(
        soilResearchControllerProvider.notifier,
      );

      await controller.analyze();

      expect(
        container.read(soilResearchControllerProvider).result!.officialMap,
        isNull,
      );
    });
  });

  group('requirements state', () {
    test('clearing the field clears the stored requirement', () async {
      final container = await makeContainer();
      final controller = container.read(
        soilResearchControllerProvider.notifier,
      );

      controller.setRequirements('Build a house');
      expect(
        container.read(soilResearchControllerProvider).requirements,
        'Build a house',
      );

      // Emptying the box must not leave the stale value behind.
      controller.setRequirements('');
      expect(
        container.read(soilResearchControllerProvider).requirements,
        isNull,
      );
    });

    test('a cleared requirement is not sent on the next analysis', () async {
      final gateway = FakeAiGateway(reply: _overreachingReply);
      final container = await makeContainer(gateway: gateway);
      final controller = container.read(
        soilResearchControllerProvider.notifier,
      );

      controller.setRequirements('stale requirement');
      controller.setRequirements('   ');
      await controller.analyze();

      expect(
        gateway.lastRequest!.context.containsKey('userRequirements'),
        isFalse,
      );
      // And the model's invented requirement must not be attributed to the user.
      final report = container.read(soilResearchControllerProvider).result!;
      expect(report.userRequirements, isNull);
    });

    test('purpose and requirements are echoed from user state', () async {
      final container = await makeContainer(
        gateway: FakeAiGateway(reply: _overreachingReply),
      );
      final controller = container.read(
        soilResearchControllerProvider.notifier,
      );

      controller.setPurpose(SurveyPurpose.wellDrilling);
      controller.setRequirements('Drill a well');
      await controller.analyze();

      final report = container.read(soilResearchControllerProvider).result!;
      expect(report.purpose, SurveyPurpose.wellDrilling);
      expect(report.userRequirements, 'Drill a well');
    });
  });

  group('reset', () {
    test('preserves inputs so the user need not retype them', () async {
      final container = await makeContainer(
        gateway: FakeAiGateway(reply: _overreachingReply),
      );
      final controller = container.read(
        soilResearchControllerProvider.notifier,
      );

      controller.setPurpose(SurveyPurpose.building);
      controller.setRequirements('Build a house');
      controller.setLandRecord(
        const LandRecordInfo(available: true, parcelId: 'P-9'),
      );
      await controller.analyze();
      controller.reset();

      final state = container.read(soilResearchControllerProvider);
      expect(state.stage, SoilResearchStage.input);
      expect(state.result, isNull);
      expect(state.purpose, SurveyPurpose.building);
      expect(state.requirements, 'Build a house');
      expect(state.landRecord.parcelId, 'P-9');
    });
  });

  group('land-record editing', () {
    test('emptying a field clears it instead of storing a blank', () async {
      final container = await makeContainer();
      final controller = container.read(
        soilResearchControllerProvider.notifier,
      );

      controller.setLandRecord(
        const LandRecordInfo(available: true, parcelId: 'P-1'),
      );
      final record = container.read(soilResearchControllerProvider).landRecord;
      controller.setLandRecord(record.copyWith(parcelId: ''));

      final updated = container.read(soilResearchControllerProvider).landRecord;
      expect(updated.parcelId, isNull);
      expect(updated.hasData, isFalse);
    });
  });
}
