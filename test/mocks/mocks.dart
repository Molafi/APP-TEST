import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plantsense_ai/core/services/ai_gateway.dart';
import 'package:plantsense_ai/core/services/local_cache_service.dart';
import 'package:plantsense_ai/core/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Deterministic fake gateway used in provider/widget tests.
class FakeAiGateway extends AiGateway {
  FakeAiGateway({this.reply = 'Fake AI reply', this.throwError = false});

  final String reply;
  final bool throwError;
  int calls = 0;
  AiRequest? lastRequest;

  @override
  Future<String> generate(AiRequest request) async {
    calls++;
    lastRequest = request;
    if (throwError) throw Exception('boom');
    return reply;
  }
}

/// Fake [NotificationService] used in reminder tests. Records calls and can be
/// configured to reject scheduling so callers can verify failure handling.
class FakeNotificationService extends NotificationService {
  FakeNotificationService({this.throwOnSchedule = false});

  final bool throwOnSchedule;
  int scheduleCalls = 0;
  final List<int> cancelledIds = [];
  bool cancelledAll = false;

  @override
  Future<void> init() async {}

  @override
  Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledAt,
    bool repeatsDaily = false,
    bool repeatsWeekly = false,
  }) async {
    scheduleCalls++;
    if (throwOnSchedule) {
      throw Exception('scheduling rejected');
    }
  }

  @override
  Future<void> cancel(int id) async => cancelledIds.add(id);

  @override
  Future<void> cancelAll() async => cancelledAll = true;
}

/// Builds a real [LocalCacheService] backed by mocked SharedPreferences.
Future<LocalCacheService> makeTestCache([
  Map<String, Object> initial = const {},
]) async {
  SharedPreferences.setMockInitialValues(initial);
  final prefs = await SharedPreferences.getInstance();
  return LocalCacheService(prefs);
}

/// Common provider overrides for tests: mocked cache + fake AI gateway.
Future<List<Override>> defaultOverrides({
  FakeAiGateway? gateway,
  Map<String, Object> prefs = const {},
}) async {
  final cache = await makeTestCache(prefs);
  return [
    localCacheServiceProvider.overrideWithValue(cache),
    aiGatewayProvider.overrideWithValue(gateway ?? FakeAiGateway()),
  ];
}
