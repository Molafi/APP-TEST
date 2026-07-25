import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plantsense_ai/core/services/ai_gateway.dart';
import 'package:plantsense_ai/core/services/local_cache_service.dart';
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

/// Builds a real [LocalCacheService] backed by mocked SharedPreferences.
Future<LocalCacheService> makeTestCache(
    [Map<String, Object> initial = const {}]) async {
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
