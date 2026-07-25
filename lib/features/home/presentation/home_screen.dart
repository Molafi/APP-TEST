import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/environment.dart';
import '../../../core/services/home_widget_service.dart';
import '../../../core/widgets/offline_banner.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/application/auth_provider.dart';
import '../../chat/presentation/chat_screen.dart';
import '../../diagnosis/presentation/diagnosis_screen.dart';
import '../../location/application/location_provider.dart';
import '../../profile/application/profile_provider.dart';
import '../../profile/application/settings_provider.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../weather/application/weather_provider.dart';
import '../../weather/domain/weather_model.dart';
import '../../weather/presentation/weather_screen.dart';
import '../../../models/user_profile.dart';
import '../application/home_provider.dart';
import 'widgets/home_app_bar.dart';

/// Authenticated home shell hosting the four persistent tabs. An IndexedStack
/// preserves each tab's state (scroll position, camera, forms). The shared app
/// bar shows the city and weather chip.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Seed weather (in demo mode this resolves the sample location). Runs once.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(weatherBootstrapProvider);
      _ensureProfile();
    });
  }

  Future<void> _ensureProfile() async {
    if (Environment.isDemo) return;
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    await ref.read(profileRepositoryProvider).ensureProfile(
          UserProfile(uid: user.uid, email: user.email, displayName: user.displayName),
        );
  }

  String _titleFor(AppLocalizations l10n, int tab) => switch (tab) {
        HomeTab.chat => l10n.chatTitle,
        HomeTab.diagnose => l10n.diagnoseTitle,
        HomeTab.weather => l10n.weatherTitle,
        _ => l10n.profileTitle,
      };

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final int tab = ref.watch(homeTabProvider);

    // Keep the home-screen widget in sync when weather changes.
    ref.listen<WeatherData?>(currentWeatherDataProvider, (prev, next) {
      if (next?.current.temperatureC == null) return;
      final unit = ref.read(unitSystemProvider);
      final location = ref.read(selectedLocationProvider);
      ref.read(homeWidgetServiceProvider).update(
            city: location?.city ?? '',
            temperature:
                TemperatureFormat.format(next!.current.temperatureC, unit),
          );
    });

    return PopScope(
      // Android back: return to the Chat tab first instead of exiting.
      canPop: tab == HomeTab.chat,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) ref.read(homeTabProvider.notifier).state = HomeTab.chat;
      },
      child: Scaffold(
        appBar: HomeAppBar(title: _titleFor(l10n, tab)),
        body: Column(
          children: [
            const OfflineBanner(),
            Expanded(
              child: IndexedStack(
                index: tab,
                children: const [
                  ChatScreen(),
                  DiagnosisScreen(),
                  WeatherScreen(),
                  ProfileScreen(),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: tab,
          onDestinationSelected: (i) =>
              ref.read(homeTabProvider.notifier).state = i,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.forum_outlined),
              selectedIcon: const Icon(Icons.forum),
              label: l10n.navChat,
            ),
            NavigationDestination(
              icon: const Icon(Icons.camera_alt_outlined),
              selectedIcon: const Icon(Icons.camera_alt),
              label: l10n.navDiagnose,
            ),
            NavigationDestination(
              icon: const Icon(Icons.wb_sunny_outlined),
              selectedIcon: const Icon(Icons.wb_sunny),
              label: l10n.navWeather,
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline),
              selectedIcon: const Icon(Icons.person),
              label: l10n.navProfile,
            ),
          ],
        ),
      ),
    );
  }
}
