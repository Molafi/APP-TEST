import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plantsense_ai/core/services/demo_ai_gateway.dart';
import 'package:plantsense_ai/features/georesearch/data/soil_research_service.dart';
import 'package:plantsense_ai/features/georesearch/domain/soil_report_model.dart';
import 'package:plantsense_ai/features/georesearch/presentation/widgets/official_map_card.dart';
import 'package:plantsense_ai/features/georesearch/presentation/widgets/soil_report_card.dart';

import 'test_app.dart';

void main() {
  /// The demo gateway delays before replying, and `testWidgets` runs inside a
  /// fake-async zone where a real timer never fires — so the report has to be
  /// built via [WidgetTester.runAsync].
  Future<SoilReport> demoReport(WidgetTester tester, String locale) async {
    final report = await tester.runAsync(
      () => SoilResearchService(DemoAiGateway()).analyze(
        locale: locale,
        purpose: SurveyPurpose.slopeStability,
        requirements: 'Check the slope',
      ),
    );
    return report!;
  }

  group('SoilReportCard slope-stability section', () {
    testWidgets('renders the movement answers with their measurement caveat',
        (tester) async {
      final report = await demoReport(tester, 'en');
      await pumpApp(
        tester,
        SingleChildScrollView(child: SoilReportCard(report: report)),
      );

      // The three questions users ask first.
      expect(
        find.textContaining('Direction of land movement', findRichText: true),
        findsOneWidget,
      );
      expect(
        find.textContaining('Depth of the slip surface', findRichText: true),
        findsOneWidget,
      );
      expect(
        find.textContaining('Rate of movement', findRichText: true),
        findsOneWidget,
      );
      // The caveat that keeps them honest sits with them, not buried in a footer.
      expect(
        find.textContaining('cannot be measured from a phone'),
        findsOneWidget,
      );
      // Screening framing appears (both the section notice and the model's own
      // note say it, so more than one match is expected).
      expect(
        find.textContaining('NOT a slope-stability analysis'),
        findsWidgets,
      );
    });

    testWidgets('every zone states whether it is buildable, and on what terms',
        (tester) async {
      final report = await demoReport(tester, 'en');
      await pumpApp(
        tester,
        SingleChildScrollView(child: SoilReportCard(report: report)),
      );

      final zones = report.slopeStability!.zones;
      final int conditional =
          zones.where((z) => z.buildableAfterTreatment).length;
      final int blocked = zones.length - conditional;
      expect(conditional, greaterThan(0));
      expect(blocked, greaterThan(0));

      expect(
        find.text('Buildable ONLY after treatment'),
        findsNWidgets(conditional),
      );
      expect(
        find.text('Not buildable on current evidence'),
        findsNWidgets(blocked),
      );
      // An unqualified "buildable" badge must never appear.
      expect(find.text('Buildable'), findsNothing);
      expect(find.textContaining('is conditional'), findsOneWidget);
    });

    testWidgets('exposed structures carry the no-verdict notice',
        (tester) async {
      final report = await demoReport(tester, 'en');
      await pumpApp(
        tester,
        SingleChildScrollView(child: SoilReportCard(report: report)),
      );

      expect(find.text('Structures exposed to movement'), findsOneWidget);
      expect(
        find.textContaining('not from the condition of any specific building'),
        findsOneWidget,
      );
    });

    testWidgets('the purpose the user picked is shown back to them',
        (tester) async {
      final report = await demoReport(tester, 'en');
      await pumpApp(
        tester,
        SingleChildScrollView(child: SoilReportCard(report: report)),
      );

      expect(find.text('🎯  Survey purpose'), findsOneWidget);
      expect(
        find.textContaining('Land stability', findRichText: true),
        findsWidgets,
      );
      expect(
        find.textContaining('Check the slope', findRichText: true),
        findsOneWidget,
      );
    });

    testWidgets('under Arabic both the labels AND the values are Arabic',
        (tester) async {
      // The reported bug in one assertion pair: Arabic labels, English values.
      final report = await demoReport(tester, 'ar');
      await pumpApp(
        tester,
        SingleChildScrollView(child: SoilReportCard(report: report)),
        locale: const Locale('ar'),
      );

      // Localized label…
      expect(find.text('🪨  استقرار الأرض وحركتها'), findsOneWidget);
      // …and a localized VALUE from the gateway.
      expect(
        find.textContaining('نزولًا نحو الجنوب الشرقي', findRichText: true),
        findsWidgets,
      );
      // The English that used to appear here must be gone.
      expect(
        find.textContaining('Downslope toward', findRichText: true),
        findsNothing,
      );
      expect(
        find.textContaining('Approximately', findRichText: true),
        findsNothing,
      );
    });
  });

  group('OfficialMapCard', () {
    const reference = OfficialMapReference(
      authority: 'Royal Jordanian Geographic Centre (RJGC)',
      gridName: 'Jordan Transverse Mercator (JTM)',
      gridCode: 'EPSG:3066',
      easting: 397021.1,
      northing: 536604.5,
      latitude: 31.9539,
      longitude: 35.9106,
      portalUrl: 'https://rjgc.gov.jo/',
      orderUrl: 'https://rjgc.gov.jo/eservices/',
    );

    testWidgets('shows the grid reference and the unofficial-conversion caveat',
        (tester) async {
      await pumpApp(
        tester,
        const SingleChildScrollView(child: OfficialMapCard(info: reference)),
      );

      expect(find.textContaining('EPSG:3066'), findsOneWidget);
      expect(find.text('397021.1 m'), findsOneWidget);
      expect(find.text('536604.5 m'), findsOneWidget);
      // No datum parameters are configured, so the caveat must be visible.
      expect(
        find.textContaining('no datum transformation was applied'),
        findsOneWidget,
      );
      // The authority basemap is unlicensed by default: explain rather than
      // render a broken image.
      expect(find.textContaining('not enabled for this build'), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('the grid reference can be copied', (tester) async {
      await pumpApp(
        tester,
        const SingleChildScrollView(child: OfficialMapCard(info: reference)),
      );

      await tester.tap(find.text('Copy grid reference'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Grid reference copied'), findsOneWidget);
    });

    testWidgets('renders in Arabic without mangling the LTR coordinates',
        (tester) async {
      await pumpApp(
        tester,
        const SingleChildScrollView(child: OfficialMapCard(info: reference)),
        locale: const Locale('ar'),
      );

      expect(find.text('🗺️  الخرائط الرسمية والشبكة الوطنية'), findsOneWidget);
      expect(find.text('الإحداثي الشرقي (E): '), findsOneWidget);
      // A coordinate reordered by the bidi algorithm and handed to a surveyor is
      // worse than no coordinate, so the value is pinned to LTR.
      final Text easting = tester.widget<Text>(find.text('397021.1 m'));
      expect(easting.textDirection, TextDirection.ltr);
    });
  });
}
