import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/services/speech_service.dart';
import '../../../../l10n/app_localizations.dart';
import 'camera_input_button.dart';

/// Keyboard-safe message composer with attachment preview, voice dictation,
/// character counter near the limit, and disabled states while sending.
class MessageComposer extends ConsumerStatefulWidget {
  const MessageComposer({
    super.key,
    required this.initialDraft,
    required this.onDraftChanged,
    required this.onSend,
    this.enabled = true,
  });

  final String initialDraft;
  final ValueChanged<String> onDraftChanged;
  final void Function({String? text, Uint8List? imageBytes}) onSend;
  final bool enabled;

  @override
  ConsumerState<MessageComposer> createState() => _MessageComposerState();
}

class _MessageComposerState extends ConsumerState<MessageComposer> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialDraft);
  Uint8List? _pendingImage;
  bool _listening = false;
  String _baseText = '';

  @override
  void didUpdateWidget(MessageComposer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync only when the draft was changed externally (e.g. a starter chip or
    // diagnosis follow-up) — never while the user is typing, so the cursor is
    // preserved.
    if (widget.initialDraft != oldWidget.initialDraft &&
        widget.initialDraft != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.initialDraft,
        selection:
            TextSelection.collapsed(offset: widget.initialDraft.length),
      );
    }
  }

  @override
  void dispose() {
    // Stop any in-progress dictation when the composer goes away.
    ref.read(speechServiceProvider).stop();
    _controller.dispose();
    super.dispose();
  }

  bool get _canSend =>
      widget.enabled &&
      (_controller.text.trim().isNotEmpty || _pendingImage != null) &&
      _controller.text.length <= AppConfig.maxInputChars;

  void _send() {
    if (!_canSend) return;
    widget.onSend(text: _controller.text, imageBytes: _pendingImage);
    _controller.clear();
    setState(() => _pendingImage = null);
    widget.onDraftChanged('');
  }

  Future<void> _toggleMic() async {
    final SpeechService speech = ref.read(speechServiceProvider);
    if (_listening) {
      await speech.stop();
      setState(() => _listening = false);
      return;
    }
    _baseText = _controller.text;
    final String localeId = Localizations.localeOf(context).languageCode;
    final bool started = await speech.start(
      localeId: localeId,
      onResult: (words) {
        final String combined =
            _baseText.isEmpty ? words : '${_baseText.trimRight()} $words';
        _controller.value = TextEditingValue(
          text: combined,
          selection: TextSelection.collapsed(offset: combined.length),
        );
        widget.onDraftChanged(combined);
        setState(() {});
      },
    );
    if (mounted) setState(() => _listening = started);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final int remaining = AppConfig.maxInputChars - _controller.text.length;
    final bool nearLimit = remaining <= 200;

    return Material(
      elevation: 8,
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_pendingImage != null)
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusSm),
                          child: Image.memory(_pendingImage!,
                              height: 72, width: 72, fit: BoxFit.cover),
                        ),
                        Positioned(
                          top: -6,
                          right: -6,
                          child: IconButton(
                            tooltip: l10n.removeImage,
                            icon: const CircleAvatar(
                              radius: 12,
                              backgroundColor: AppColors.errorRed,
                              child: Icon(Icons.close,
                                  size: 14, color: Colors.white),
                            ),
                            onPressed: () =>
                                setState(() => _pendingImage = null),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  CameraInputButton(
                    enabled: widget.enabled,
                    onImage: (bytes) => setState(() => _pendingImage = bytes),
                  ),
                  IconButton(
                    tooltip: _listening ? l10n.stopAudio : l10n.voiceInput,
                    onPressed: widget.enabled ? _toggleMic : null,
                    color: _listening
                        ? Theme.of(context).colorScheme.error
                        : null,
                    icon: Icon(_listening ? Icons.mic : Icons.mic_none),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      enabled: widget.enabled,
                      minLines: 1,
                      maxLines: 5,
                      textInputAction: TextInputAction.newline,
                      onChanged: (v) {
                        widget.onDraftChanged(v);
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        hintText: l10n.composerHint,
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusXl),
                        ),
                        counterText: '',
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  IconButton.filled(
                    tooltip: l10n.send,
                    onPressed: _canSend ? _send : null,
                    icon: Icon(Icons.send, semanticLabel: l10n.a11ySendMessage),
                  ),
                ],
              ),
              if (nearLimit)
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Text(
                    l10n.charactersRemaining(remaining),
                    style: TextStyle(
                      fontSize: 11,
                      color: remaining < 0
                          ? AppColors.errorRed
                          : AppColors.mossGray,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
