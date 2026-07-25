import 'package:flutter_test/flutter_test.dart';
import 'package:plantsense_ai/l10n/app_localizations_en.dart';

// Minimal smoke test. Replaces the default Flutter counter template so
// `flutter create .` won't regenerate a test that references a non-existent
// `MyApp`. Feature behaviour is covered under test/unit, test/providers,
// test/widgets and integration_test/.
void main() {
  test('English localization exposes the app title', () {
    final l10n = AppLocalizationsEn();
    expect(l10n.appTitle, 'PlantSense AI');
    expect(l10n.navChat, isNotEmpty);
  });
}
