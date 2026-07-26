import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/services/local_cache_service.dart';
import '../../../core/theme/locale_provider.dart';

/// A friendly language picker.
///
/// Shown automatically once after the first login (see HomeScreen) and also
/// reachable any time from Profile. Selecting a language applies it instantly
/// (including right-to-left layout for Arabic) and records that the user has
/// made a choice so the first-run prompt does not appear again.
class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key, this.isFirstRun = false});

  /// When true the screen is being shown as the one-time post-login prompt and
  /// gets a title/skip affordance suited to that context.
  final bool isFirstRun;

  static const List<_Lang> _languages = [
    _Lang('en', 'English', 'English'),
    _Lang('ar', 'العربية', 'Arabic'),
    _Lang('fr', 'Français', 'French'),
    _Lang('es', 'Español', 'Spanish'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Locale? current = ref.watch(localeProvider);
    final String? currentCode = current?.languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(isFirstRun ? 'Choose your language' : 'Language'),
        automaticallyImplyLeading: !isFirstRun,
        actions: [
          if (isFirstRun)
            TextButton(
              onPressed: () => _finish(context, ref),
              child: const Text('Skip'),
            ),
        ],
      ),
      body: ListView(
        children: [
          if (isFirstRun)
            const Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Text(
                'Select the language you would like to use. You can change this '
                'any time in your profile settings.',
              ),
            ),
          for (final lang in _languages)
            ListTile(
              title: Text(lang.nativeName,
                  style: Theme.of(context).textTheme.titleMedium),
              subtitle: Text(lang.englishName),
              trailing: currentCode == lang.code
                  ? Icon(Icons.check_circle,
                      color: Theme.of(context).colorScheme.primary)
                  : const Icon(Icons.circle_outlined),
              onTap: () => _select(context, ref, lang.code),
            ),
          const Divider(),
          ListTile(
            title: const Text('Use device language'),
            leading: const Icon(Icons.smartphone_outlined),
            trailing: currentCode == null
                ? Icon(Icons.check_circle,
                    color: Theme.of(context).colorScheme.primary)
                : const Icon(Icons.circle_outlined),
            onTap: () => _select(context, ref, null),
          ),
          if (isFirstRun)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: FilledButton(
                onPressed: () => _finish(context, ref),
                child: const Text('Continue'),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _select(BuildContext context, WidgetRef ref, String? code) async {
    await ref
        .read(localeProvider.notifier)
        .setLocale(code == null ? null : Locale(code));
    if (isFirstRun && context.mounted) {
      // Give a beat for the selection to reflect, then continue.
      await _finish(context, ref);
    }
  }

  Future<void> _finish(BuildContext context, WidgetRef ref) async {
    await ref
        .read(localCacheServiceProvider)
        .setBool(AppConstants.prefLanguageChosen, true);
    if (context.mounted) Navigator.of(context).maybePop();
  }
}

class _Lang {
  const _Lang(this.code, this.nativeName, this.englishName);
  final String code;
  final String nativeName;
  final String englishName;
}
