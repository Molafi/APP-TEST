import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/services/permission_service.dart';
import '../../../core/theme/locale_provider.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../application/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Locale? locale = ref.watch(localeProvider);
    final ThemeMode themeMode = ref.watch(themeModeProvider);
    final unit = ref.watch(unitSystemProvider);
    final bool retention = ref.watch(imageRetentionProvider);
    final bool notifications = ref.watch(notificationsEnabledProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.editProfile)),
      body: ListView(
        children: [
          _SectionHeader(title: l10n.language),
          RadioGroup<String>(
            groupValue: locale?.languageCode ?? 'system',
            onChanged: (v) => ref
                .read(localeProvider.notifier)
                .setLocale(v == 'system' ? null : Locale(v!)),
            child: Column(
              children: [
                RadioListTile<String>(
                    value: 'system', title: Text(l10n.themeSystem)),
                const RadioListTile<String>(
                    value: 'en', title: Text('English')),
                const RadioListTile<String>(
                    value: 'ar', title: Text('العربية')),
              ],
            ),
          ),
          const Divider(),
          _SectionHeader(title: l10n.theme),
          RadioGroup<ThemeMode>(
            groupValue: themeMode,
            onChanged: (v) =>
                ref.read(themeModeProvider.notifier).setMode(v ?? ThemeMode.system),
            child: Column(
              children: [
                RadioListTile<ThemeMode>(
                    value: ThemeMode.system, title: Text(l10n.themeSystem)),
                RadioListTile<ThemeMode>(
                    value: ThemeMode.light, title: Text(l10n.themeLight)),
                RadioListTile<ThemeMode>(
                    value: ThemeMode.dark, title: Text(l10n.themeDark)),
              ],
            ),
          ),
          const Divider(),
          _SectionHeader(title: l10n.units),
          RadioGroup<UnitSystem>(
            groupValue: unit,
            onChanged: (v) =>
                ref.read(unitSystemProvider.notifier).set(v ?? UnitSystem.metric),
            child: Column(
              children: [
                RadioListTile<UnitSystem>(
                    value: UnitSystem.metric, title: Text(l10n.unitsMetric)),
                RadioListTile<UnitSystem>(
                    value: UnitSystem.imperial, title: Text(l10n.unitsImperial)),
              ],
            ),
          ),
          const Divider(),
          SwitchListTile(
            title: Text(l10n.notifications),
            value: notifications,
            onChanged: (v) async {
              if (v) {
                final outcome = await ref
                    .read(permissionServiceProvider)
                    .requestNotifications();
                await ref
                    .read(notificationsEnabledProvider.notifier)
                    .set(outcome == PermissionOutcome.granted);
              } else {
                await ref.read(notificationsEnabledProvider.notifier).set(false);
              }
            },
          ),
          SwitchListTile(
            title: Text(l10n.imageRetention),
            subtitle: Text(l10n.imageRetentionBody),
            value: retention,
            onChanged: (v) =>
                ref.read(imageRetentionProvider.notifier).set(v),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xs),
      child: Text(title,
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(color: Theme.of(context).colorScheme.primary)),
    );
  }
}
