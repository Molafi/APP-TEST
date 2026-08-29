import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/local_cache_service.dart';
import '../../../core/services/notification_service.dart';
import '../domain/reminder_model.dart';

/// Manages local plant-care reminders and their notifications. Notifications
/// are only scheduled when a reminder is enabled; nothing is scheduled without
/// the user first enabling reminders (and granting permission).
class ReminderController extends StateNotifier<List<Reminder>> {
  ReminderController(this._cache, this._notifications)
    : super(Reminder.decodeList(_cache.getString(AppConstants.prefReminders)));

  final LocalCacheService _cache;
  final NotificationService _notifications;
  final Uuid _uuid = const Uuid();

  Future<void> add({
    required String plantName,
    required ReminderType type,
    String? note,
    required DateTime scheduledAt,
    Recurrence recurrence = Recurrence.none,
    String? localizedBody,
  }) async {
    final Reminder reminder = Reminder(
      id: _uuid.v4(),
      plantName: plantName,
      type: type,
      note: note,
      scheduledAt: scheduledAt,
      recurrence: recurrence,
      createdAt: DateTime.now(),
    );
    state = [...state, reminder]
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    await _persist();
    await _schedule(reminder, localizedBody: localizedBody);
  }

  Future<void> update(Reminder reminder, {String? localizedBody}) async {
    state = [for (final r in state) r.id == reminder.id ? reminder : r]
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    await _persist();
    await _notifications.cancel(reminder.notificationId);
    if (reminder.enabled) {
      await _schedule(reminder, localizedBody: localizedBody);
    }
  }

  Future<void> toggle(Reminder reminder) async =>
      update(reminder.copyWith(enabled: !reminder.enabled));

  Future<void> remove(Reminder reminder) async {
    state = state.where((r) => r.id != reminder.id).toList();
    await _persist();
    await _notifications.cancel(reminder.notificationId);
  }

  /// Cancels all scheduled notifications (e.g. when the user disables reminders
  /// globally) without deleting the reminder data.
  Future<void> cancelAllNotifications() => _notifications.cancelAll();

  Future<void> _schedule(Reminder r, {String? localizedBody}) async {
    if (!r.enabled) return;
    try {
      await _notifications.scheduleReminder(
        id: r.notificationId,
        title: r.plantName,
        body: r.note ?? localizedBody ?? _defaultBody(r.type),
        scheduledAt: r.scheduledAt,
        repeatsDaily: r.recurrence == Recurrence.daily,
        repeatsWeekly: r.recurrence == Recurrence.weekly,
      );
    } catch (_) {
      // Scheduling was rejected (e.g. permission revoked or an OS limit). Do
      // not leave the reminder presenting as enabled when nothing is actually
      // scheduled: revert the toggle and persist so the UI matches reality.
      state = [
        for (final existing in state)
          existing.id == r.id ? existing.copyWith(enabled: false) : existing,
      ];
      await _persist();
    }
  }

  /// English fallback bodies. User-facing reminders are localized at the call
  /// site (see [add]/[update] `localizedBody`); this is only used when no
  /// localized string was threaded in.
  String _defaultBody(ReminderType type) => switch (type) {
    ReminderType.watering => 'Time to water your plant.',
    ReminderType.fertilizing => 'Time to fertilize your plant.',
    ReminderType.repotting => 'Time to repot your plant.',
    ReminderType.inspection => 'Time to inspect your plant.',
    ReminderType.followUp => 'Follow up on your plant diagnosis.',
  };

  Future<void> _persist() =>
      _cache.setString(AppConstants.prefReminders, Reminder.encodeList(state));
}

final reminderControllerProvider =
    StateNotifierProvider<ReminderController, List<Reminder>>((ref) {
      return ReminderController(
        ref.watch(localCacheServiceProvider),
        ref.watch(notificationServiceProvider),
      );
    });
