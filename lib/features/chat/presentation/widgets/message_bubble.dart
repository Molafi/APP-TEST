import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/simple_markdown.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/message_model.dart';
import 'context_strip.dart';

/// A single chat bubble. User bubbles use soil amber; AI bubbles use a
/// parchment surface with a green border. Text keeps accessible contrast.
class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.locale,
    this.onRetry,
  });

  final ChatMessage message;
  final String locale;
  final VoidCallback? onRetry;

  bool get _isUser => message.role == MessageRole.user;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool dark = Theme.of(context).brightness == Brightness.dark;

    final Color bubbleColor = _isUser
        ? AppColors.soilAmber
        : (dark ? AppColors.darkSurfaceAlt : AppColors.parchment);
    final Color textColor =
        _isUser ? Colors.white : (dark ? AppColors.parchment : AppColors.forestGreen);

    return Align(
      alignment:
          _isUser ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
        ),
        margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: _isUser
              ? null
              : Border.all(color: AppColors.leafGreen.withValues(alpha: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_isUser && message.weatherContext != null)
              ContextStrip(text: message.weatherContext!),
            if (message.hasImage)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    color: Colors.black12,
                    child: const Icon(Icons.image_outlined, size: 40),
                  ),
                ),
              ),
            SimpleMarkdown(
              message.text,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: textColor),
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormatter.messageTimestamp(message.createdAt, locale),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: textColor.withValues(alpha: 0.7),
                        fontSize: 11,
                      ),
                ),
                const SizedBox(width: AppSpacing.sm),
                _StatusOrActions(
                  message: message,
                  textColor: textColor,
                  onRetry: onRetry,
                  isUser: _isUser,
                  l10n: l10n,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusOrActions extends StatelessWidget {
  const _StatusOrActions({
    required this.message,
    required this.textColor,
    required this.onRetry,
    required this.isUser,
    required this.l10n,
  });

  final ChatMessage message;
  final Color textColor;
  final VoidCallback? onRetry;
  final bool isUser;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    if (isUser) {
      switch (message.status) {
        case MessageStatus.sending:
          return Semantics(
            label: l10n.sending,
            child: Icon(Icons.schedule,
                size: 13, color: textColor.withValues(alpha: 0.7)),
          );
        case MessageStatus.sent:
          return Icon(Icons.check,
              size: 13, color: textColor.withValues(alpha: 0.7));
        case MessageStatus.failed:
          return InkWell(
            onTap: onRetry,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 13, color: Colors.white),
                const SizedBox(width: 2),
                Text(l10n.retry,
                    style: const TextStyle(color: Colors.white, fontSize: 11)),
              ],
            ),
          );
      }
    }
    // AI message: offer copy.
    return InkWell(
      onTap: () async {
        await Clipboard.setData(ClipboardData(text: message.text));
        if (context.mounted) {
          ScaffoldMessenger.of(context)
            ..clearSnackBars()
            ..showSnackBar(SnackBar(content: Text(l10n.copied)));
        }
      },
      child: Icon(Icons.copy,
          size: 13,
          color: textColor.withValues(alpha: 0.7),
          semanticLabel: l10n.copy),
    );
  }
}
