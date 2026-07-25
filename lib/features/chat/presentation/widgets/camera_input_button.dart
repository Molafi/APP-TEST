import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';

/// Attachment button that opens a bottom sheet offering camera or gallery.
/// image_picker requests OS-level permissions itself; if the user cancels or
/// denies, no image is returned and nothing crashes.
class CameraInputButton extends StatelessWidget {
  const CameraInputButton({super.key, required this.onImage, this.enabled = true});

  final ValueChanged<Uint8List> onImage;
  final bool enabled;

  Future<void> _pick(BuildContext context, ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? file = await picker.pickImage(
        source: source,
        maxWidth: 2000,
        imageQuality: 90,
      );
      if (file == null) return;
      final Uint8List bytes = await file.readAsBytes();
      onImage(bytes);
    } catch (_) {
      // Permission denial / cancellation — silently ignore, UI stays usable.
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return IconButton(
      tooltip: l10n.attachImage,
      icon: const Icon(Icons.add_a_photo_outlined),
      onPressed: enabled
          ? () => showModalBottomSheet<void>(
                context: context,
                showDragHandle: true,
                builder: (sheetContext) => SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.photo_camera_outlined),
                        title: Text(l10n.fromCamera),
                        onTap: () {
                          Navigator.of(sheetContext).pop();
                          _pick(context, ImageSource.camera);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.photo_library_outlined),
                        title: Text(l10n.fromGallery),
                        onTap: () {
                          Navigator.of(sheetContext).pop();
                          _pick(context, ImageSource.gallery);
                        },
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                  ),
                ),
              )
          : null,
    );
  }
}
