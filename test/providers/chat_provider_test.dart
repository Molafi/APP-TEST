import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plantsense_ai/features/chat/application/chat_provider.dart';
import 'package:plantsense_ai/features/chat/domain/message_model.dart';

import '../mocks/mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<ProviderContainer> makeContainer({FakeAiGateway? gateway}) async {
    final overrides = await defaultOverrides(gateway: gateway);
    final container = ProviderContainer(overrides: overrides);
    addTearDown(container.dispose);
    // Allow the async message load in the controller to complete.
    container.read(chatControllerProvider);
    await Future<void>.delayed(const Duration(milliseconds: 10));
    return container;
  }

  test('starts empty then not loading', () async {
    final container = await makeContainer();
    final state = container.read(chatControllerProvider);
    expect(state.isLoading, isFalse);
    expect(state.messages, isEmpty);
  });

  test('sending a message appends user + assistant messages', () async {
    final gateway = FakeAiGateway(reply: 'Water less often.');
    final container = await makeContainer(gateway: gateway);

    await container.read(chatControllerProvider.notifier).send(text: 'Help');
    // Wait for the fake gateway + persistence.
    await Future<void>.delayed(const Duration(milliseconds: 20));

    final msgs = container.read(chatControllerProvider).messages;
    expect(msgs.length, 2);
    expect(msgs.first.role, MessageRole.user);
    expect(msgs.first.status, MessageStatus.sent);
    expect(msgs.last.role, MessageRole.assistant);
    expect(msgs.last.text, 'Water less often.');
    expect(gateway.calls, 1);
  });

  test('empty text with no image does not send', () async {
    final gateway = FakeAiGateway();
    final container = await makeContainer(gateway: gateway);
    await container.read(chatControllerProvider.notifier).send(text: '   ');
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(container.read(chatControllerProvider).messages, isEmpty);
    expect(gateway.calls, 0);
  });

  test('failed send marks the user message failed', () async {
    final gateway = FakeAiGateway(throwError: true);
    final container = await makeContainer(gateway: gateway);

    await container.read(chatControllerProvider.notifier).send(text: 'Hi');
    await Future<void>.delayed(const Duration(milliseconds: 20));

    final msgs = container.read(chatControllerProvider).messages;
    expect(msgs.single.status, MessageStatus.failed);
    expect(container.read(chatControllerProvider).error, isNotNull);
  });

  test('deleteConversation clears messages', () async {
    final container = await makeContainer();
    await container.read(chatControllerProvider.notifier).send(text: 'Hi');
    await Future<void>.delayed(const Duration(milliseconds: 20));
    await container.read(chatControllerProvider.notifier).deleteConversation();
    expect(container.read(chatControllerProvider).messages, isEmpty);
  });
}
