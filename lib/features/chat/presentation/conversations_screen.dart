import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/app_empty_view.dart';
import '../../../l10n/app_localizations.dart';
import '../application/conversations_provider.dart';
import '../domain/chat_model.dart';

/// Lists the user's conversations with create / open / rename / delete.
class ConversationsScreen extends ConsumerWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String locale = Localizations.localeOf(context).languageCode;
    final List<Chat> conversations = ref.watch(conversationsControllerProvider);
    final String currentId = ref.watch(currentChatIdProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.conversations)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await ref
              .read(conversationsControllerProvider.notifier)
              .create(title: l10n.newChat);
          if (context.mounted) Navigator.of(context).maybePop();
        },
        icon: const Icon(Icons.add_comment_outlined),
        label: Text(l10n.newChat),
      ),
      body: conversations.isEmpty
          ? AppEmptyView(
              icon: Icons.forum_outlined,
              title: l10n.conversations,
              message: l10n.chatEmptyBody,
            )
          : ListView.separated(
              padding: const EdgeInsets.only(bottom: 96),
              itemCount: conversations.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final Chat c = conversations[i];
                final bool active = c.id == currentId;
                return ListTile(
                  selected: active,
                  leading: Icon(
                      active ? Icons.chat : Icons.chat_bubble_outline),
                  title: Text(c.title,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(
                    c.lastMessagePreview ??
                        DateFormatter.relativeUpdated(c.updatedAt, locale),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) async {
                      if (v == 'rename') await _rename(context, ref, l10n, c);
                      if (v == 'delete') await _delete(context, ref, l10n, c);
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(value: 'rename', child: Text(l10n.rename)),
                      PopupMenuItem(value: 'delete', child: Text(l10n.delete)),
                    ],
                  ),
                  onTap: () async {
                    await ref
                        .read(conversationsControllerProvider.notifier)
                        .open(c.id);
                    if (context.mounted) Navigator.of(context).maybePop();
                  },
                );
              },
            ),
    );
  }

  Future<void> _rename(BuildContext context, WidgetRef ref,
      AppLocalizations l10n, Chat c) async {
    final controller = TextEditingController(text: c.title);
    final String? title = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.rename),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              child: Text(l10n.save)),
        ],
      ),
    );
    if (title != null && title.isNotEmpty) {
      await ref
          .read(conversationsControllerProvider.notifier)
          .rename(c.id, title);
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref,
      AppLocalizations l10n, Chat c) async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
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
      await ref.read(conversationsControllerProvider.notifier).delete(c);
    }
  }
}
