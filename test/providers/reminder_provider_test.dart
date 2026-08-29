import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plantsense_ai/core/services/local_cache_service.dart';
import 'package:plantsense_ai/core/services/notification_service.dart';
import 'package:plantsense_ai/features/reminders/application/reminder_provider.dart';
import 'package:plantsense_ai/features/reminders/domain/reminder_model.dart';

import '../mocks/mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<ProviderContainer> makeContainer(
    FakeNotificationService notifications,
  ) async {
    final cache = await makeTestCache();
    final container = ProviderContainer(
      overrides: [
        localCacheServiceProvider.overrideWithValue(cache),
        notificationServiceProvider.overrideWithValue(notifications),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('successful schedule leaves the reminder enabled', () async {
    final notifications = FakeNotificationService();
    final container = await makeContainer(notifications);

    await container.read(reminderControllerProvider.notifier).add(
          plantName: 'Fern',
          type: ReminderType.watering,
          scheduledAt: DateTime.now().add(const Duration(hours: 1)),
          localizedBody: 'Water the fern.',
        );

    final reminders = container.read(reminderControllerProvider);
    expect(reminders, hasLength(1));
    expect(reminders.single.enabled, isTrue);
    expect(notifications.scheduleCalls, 1);
  });

  test('a scheduling failure leaves the reminder NOT enabled', () async {
    final notifications = FakeNotificationService(throwOnSchedule: true);
    final container = await makeContainer(notifications);

    await container.read(reminderControllerProvider.notifier).add(
          plantName: 'Cactus',
          type: ReminderType.watering,
          scheduledAt: DateTime.now().add(const Duration(hours: 1)),
          localizedBody: 'Water the cactus.',
        );

    final reminders = container.read(reminderControllerProvider);
    expect(reminders, hasLength(1));
    expect(
      reminders.single.enabled,
      isFalse,
      reason: 'a rejected schedule must not present as enabled',
    );
    expect(notifications.scheduleCalls, 1);
  });

  test('reverted reminder is persisted as disabled', () async {
    final notifications = FakeNotificationService(throwOnSchedule: true);
    final cache = await makeTestCache();
    final container = ProviderContainer(
      overrides: [
        localCacheServiceProvider.overrideWithValue(cache),
        notificationServiceProvider.overrideWithValue(notifications),
      ],
    );
    addTearDown(container.dispose);

    await container.read(reminderControllerProvider.notifier).add(
          plantName: 'Basil',
          type: ReminderType.watering,
          scheduledAt: DateTime.now().add(const Duration(hours: 1)),
          localizedBody: 'Water the basil.',
        );

    // Re-decode from the same cache to confirm the disabled state persisted.
    final restored = ReminderController(cache, notifications);
    addTearDown(restored.dispose);
    expect(restored.state, hasLength(1));
    expect(restored.state.single.enabled, isFalse);
  });
}
