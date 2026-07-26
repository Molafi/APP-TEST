import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/application/auth_provider.dart';
import '../../diagnosis/presentation/diagnosis_history_screen.dart';
import '../../plants/presentation/my_plants_screen.dart';
import '../../reminders/presentation/reminders_screen.dart';
import '../../soil/presentation/land_screen.dart';
import '../application/data_export_provider.dart';
import '../application/profile_provider.dart';
import 'language_screen.dart';
import 'privacy_screen.dart';
import 'settings_screen.dart';

/// Package version, loaded once.
final _packageInfoProvider = FutureProvider<PackageInfo>((ref) {
  return PackageInfo.fromPlatform();
});

/// Profile tab body. The Home shell supplies the Scaffold + app bar.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final user = ref.watch(currentUserProvider);
    final version = ref.watch(_packageInfoProvider);

    return ListView(
      children: [
        const SizedBox(height: AppSpacing.lg),
        Center(
          child: CircleAvatar(
            radius: 40,
            child: Text(
              (user?.displayName?.isNotEmpty ?? false)
                  ? user!.displayName!.characters.first.toUpperCase()
                  : '🌿',
              style: const TextStyle(fontSize: 28),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Center(
          child: Text(user?.displayName ?? l10n.profileTitle,
              style: Theme.of(context).textTheme.titleLarge),
        ),
        Center(
          child: Text(user?.email ?? '',
              style: Theme.of(context).textTheme.bodyMedium),
        ),
        const SizedBox(height: AppSpacing.lg),
        _tile(context, Icons.settings_outlined, l10n.editProfile,
            () => _push(context, const SettingsScreen())),
        _tile(context, Icons.language, 'Language',
            () => _push(context, const LanguageScreen())),
        _tile(context, Icons.terrain_outlined, 'Land & Soil',
            () => _push(context, const LandScreen())),
        _tile(context, Icons.local_florist_outlined, l10n.myPlants,
            () => _push(context, const MyPlantsScreen())),
        _tile(context, Icons.history, l10n.diagnosisHistory,
            () => _push(context, const DiagnosisHistoryScreen())),
        _tile(context, Icons.alarm, l10n.reminders,
            () => _push(context, const RemindersScreen())),
        _tile(context, Icons.privacy_tip_outlined, l10n.privacyPolicy,
            () => _push(context, const PrivacyScreen())),
        _tile(context, Icons.description_outlined, l10n.termsOfService,
            () => _push(context, const PrivacyScreen())),
        _tile(context, Icons.feedback_outlined, l10n.reportIssue,
            () => _showFeedback(context, l10n)),
        const Divider(),
        _tile(context, Icons.download_outlined, l10n.exportData,
            () => _exportData(context, ref)),
        _tile(context, Icons.logout, l10n.logout,
            () => _confirmLogout(context, ref, l10n)),
        _tile(context, Icons.delete_sweep_outlined, l10n.deleteAllData,
            () => _confirmDeleteData(context, ref, l10n),
            danger: true),
        _tile(context, Icons.no_accounts_outlined, l10n.deleteAccount,
            () => _confirmDeleteAccount(context, ref, l10n),
            danger: true),
        const SizedBox(height: AppSpacing.lg),
        Center(
          child: version.when(
            data: (info) => Text(l10n.appVersion('${info.version}+${info.buildNumber}'),
                style: Theme.of(context).textTheme.bodySmall),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  Widget _tile(BuildContext context, IconData icon, String title,
      VoidCallback onTap,
      {bool danger = false}) {
    final Color? color = danger ? Theme.of(context).colorScheme.error : null;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  void _showFeedback(BuildContext context, AppLocalizations l10n) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.reportIssue),
        content: const Text('support@plantsense.example'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: Text(l10n.close)),
        ],
      ),
    );
  }

  Future<void> _exportData(BuildContext context, WidgetRef ref) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    try {
      final String json = await ref.read(dataExporterProvider).buildJson();
      final Directory dir = Directory.systemTemp;
      final File file = File(
          '${dir.path}/plantsense_export_${DateTime.now().millisecondsSinceEpoch}.json');
      await file.writeAsString(json, flush: true);
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/json')],
        subject: 'PlantSense AI data export',
      );
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(content: Text(l10n.somethingWentWrong)));
      }
    }
  }

  Future<void> _confirmLogout(
      BuildContext context, WidgetRef ref, AppLocalizations l10n) async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(l10n.logoutConfirm),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancel)),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.logout)),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(profileControllerProvider.notifier).logout();
    }
  }

  Future<void> _confirmDeleteData(
      BuildContext context, WidgetRef ref, AppLocalizations l10n) async {
    final bool? ok = await _dangerDialog(
        context, l10n, l10n.deleteAllData, l10n.deleteAllDataConfirm);
    if (ok != true) return;
    final result =
        await ref.read(profileControllerProvider.notifier).deleteAllData();
    if (!context.mounted) return;
    _showResult(context, l10n, result == DeletionResult.success);
  }

  Future<void> _confirmDeleteAccount(
      BuildContext context, WidgetRef ref, AppLocalizations l10n) async {
    final bool? ok = await _dangerDialog(
        context, l10n, l10n.deleteAccount, l10n.deleteAccountConfirm);
    if (ok != true) return;
    final result =
        await ref.read(profileControllerProvider.notifier).deleteAccount();
    if (!context.mounted) return;
    if (result == DeletionResult.reauthRequired) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(l10n.reauthRequired)));
      // The user will be routed to login after re-auth expiry; sign out to be safe.
      await ref.read(profileControllerProvider.notifier).logout();
      return;
    }
    _showResult(context, l10n, result == DeletionResult.success);
  }

  Future<bool?> _dangerDialog(BuildContext context, AppLocalizations l10n,
      String title, String message) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancel)),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(ctx).colorScheme.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  void _showResult(BuildContext context, AppLocalizations l10n, bool success) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
          content: Text(success ? l10n.deleted : l10n.somethingWentWrong)));
  }
}
