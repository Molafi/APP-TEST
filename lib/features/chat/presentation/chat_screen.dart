import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/environment.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/errors/error_mapper.dart';
import '../../../core/theme/locale_provider.dart';
import '../../../core/widgets/app_empty_view.dart';
import '../../../core/widgets/app_loading_view.dart';
import '../../../l10n/app_localizations.dart';
import '../../home/application/home_provider.dart';
import '../application/chat_provider.dart';
import '../domain/message_model.dart';
import 'widgets/message_bubble.dart';
import 'widgets/message_composer.dart';
import 'widgets/typing_indicator.dart';

/// Full conversational chat. Provided as a body widget; the Home shell supplies
/// the Scaffold, app bar (city/weather chip) and bottom navigation.
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, this.initialPrompt});

  /// Optional prompt injected when navigating from a diagnosis follow-up.
  final String? initialPrompt;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final ScrollController _scroll = ScrollController();
  bool _prefilled = false;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _maybeAutoScroll() {
    if (!_scroll.hasClients) return;
    final bool nearBottom = _scroll.position.pixels >=
        _scroll.position.maxScrollExtent - 120;
    if (nearBottom) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) {
          _scroll.animateTo(
            _scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  Future<void> _confirmDelete() async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteConversation),
        content: Text(l10n.deleteConversationConfirm),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancel)),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.delete)),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(chatControllerProvider.notifier).deleteConversation();
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ChatState state = ref.watch(chatControllerProvider);
    final String locale = ref.watch(localeProvider)?.languageCode ?? 'en';
    final ChatController controller =
        ref.read(chatControllerProvider.notifier);

    // Prefill an initial prompt from the constructor once.
    if (!_prefilled && widget.initialPrompt != null && !state.isLoading) {
      _prefilled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.setDraft(widget.initialPrompt!);
      });
    }

    // Consume a diagnosis follow-up handed via the shared provider.
    final String? followUp = ref.watch(chatFollowUpProvider);
    if (followUp != null && !state.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.setDraft(followUp);
        ref.read(chatFollowUpProvider.notifier).state = null;
      });
    }

    // Auto-scroll on new content.
    ref.listen(chatControllerProvider, (_, __) => _maybeAutoScroll());

    // Surface transient errors as snackbars (never raw exceptions).
    ref.listen(chatControllerProvider.select((s) => s.error), (prev, next) {
      if (next != null && next != prev) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
              SnackBar(content: Text(ErrorMapper.message(l10n, next))));
      }
    });

    return Column(
      children: [
        if (Environment.isDemo)
          _DemoBanner(text: l10n.demoModeBanner),
        if (!state.isEmpty)
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton.icon(
              onPressed: _confirmDelete,
              icon: const Icon(Icons.delete_outline, size: 18),
              label: Text(l10n.deleteConversation),
            ),
          ),
        Expanded(
          child: state.isLoading
              ? const AppLoadingView()
              : state.isEmpty
                  ? _EmptyChat(onStarter: (s) => controller.setDraft(s))
                  : ListView.builder(
                      controller: _scroll,
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                      itemCount: state.messages.length + (state.isTyping ? 1 : 0),
                      itemBuilder: (context, i) {
                        if (i >= state.messages.length) {
                          return const Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: TypingIndicator(),
                          );
                        }
                        final ChatMessage m = state.messages[i];
                        return MessageBubble(
                          message: m,
                          locale: locale,
                          onRetry: m.status == MessageStatus.failed
                              ? () => controller.retry(m)
                              : null,
                        );
                      },
                    ),
        ),
        MessageComposer(
          initialDraft: state.draft,
          enabled: !state.isTyping,
          onDraftChanged: controller.setDraft,
          onSend: ({String? text, Uint8List? imageBytes}) =>
              controller.send(text: text, imageBytes: imageBytes),
        ),
      ],
    );
  }
}

class _DemoBanner extends StatelessWidget {
  const _DemoBanner({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.secondaryContainer,
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
      child: Row(
        children: [
          const Icon(Icons.science_outlined, size: 16),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
              child: Text(text,
                  style: Theme.of(context).textTheme.bodySmall)),
        ],
      ),
    );
  }
}

class _EmptyChat extends StatelessWidget {
  const _EmptyChat({required this.onStarter});
  final ValueChanged<String> onStarter;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final List<String> starters = [
      l10n.starterYellowLeaves,
      l10n.starterWaterBasil,
      l10n.starterSucculentSoil,
      l10n.starterIdentifyPest,
      l10n.starterTransplant,
      l10n.starterClayDrainage,
    ];
    return AppEmptyView(
      icon: Icons.eco_outlined,
      title: l10n.chatEmptyTitle,
      message: l10n.chatEmptyBody,
      action: Wrap(
        alignment: WrapAlignment.center,
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          for (final String s in starters)
            ActionChip(
              label: Text(s),
              onPressed: () => onStarter(s),
            ),
        ],
      ),
    );
  }
}
