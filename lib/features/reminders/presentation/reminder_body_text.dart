import '../../../l10n/app_localizations.dart';
import '../domain/reminder_model.dart';

/// Resolves the default notification body for a reminder [type] in the app's
/// current locale. Used at the presentation layer (where a [BuildContext] and
/// therefore [AppLocalizations] is available) and threaded into
/// [ReminderController.add]/[ReminderController.update] so the StateNotifier
/// never has to reach for a global context.
String reminderDefaultBody(AppLocalizations l10n, ReminderType type) =>
    switch (type) {
      ReminderType.watering => l10n.reminderBodyWatering,
      ReminderType.fertilizing => l10n.reminderBodyFertilizing,
      ReminderType.repotting => l10n.reminderBodyRepotting,
      ReminderType.inspection => l10n.reminderBodyInspection,
      ReminderType.followUp => l10n.reminderBodyFollowUp,
    };
