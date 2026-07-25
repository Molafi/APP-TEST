import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

/// Publishes a small snapshot (city, temperature, next watering) to the native
/// home-screen widget. All calls are guarded so platforms/devices without the
/// widget configured never crash. The native widget layouts must be added in
/// the android/ and ios/ projects — see the README "Home-screen widget" section.
class HomeWidgetService {
  const HomeWidgetService();

  static const String _androidProvider = 'PlantSenseWidgetProvider';
  static const String _iOSName = 'PlantSenseWidget';

  Future<void> update({
    required String city,
    required String temperature,
    String? condition,
    String? nextWatering,
  }) async {
    if (kIsWeb) return;
    try {
      await HomeWidget.saveWidgetData<String>('city', city);
      await HomeWidget.saveWidgetData<String>('temperature', temperature);
      if (condition != null) {
        await HomeWidget.saveWidgetData<String>('condition', condition);
      }
      await HomeWidget.saveWidgetData<String>(
          'nextWatering', nextWatering ?? '');
      await HomeWidget.updateWidget(
        androidName: _androidProvider,
        iOSName: _iOSName,
      );
    } catch (_) {
      // Widget not configured on this platform/device — ignore.
    }
  }
}

final homeWidgetServiceProvider =
    Provider<HomeWidgetService>((ref) => const HomeWidgetService());
