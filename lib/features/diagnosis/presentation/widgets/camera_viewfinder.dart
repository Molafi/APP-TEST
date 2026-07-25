import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/services/permission_service.dart';
import '../../../../core/widgets/app_loading_view.dart';
import '../../../../core/widgets/permission_rationale.dart';
import '../../../../l10n/app_localizations.dart';

/// Live camera viewfinder with flash toggle, camera switch, capture and a
/// gallery fallback. Handles all camera states: initializing, permission
/// rationale, denied, permanently denied (Open Settings), unsupported and
/// capture failure. Resources are disposed on lifecycle changes.
class CameraViewfinder extends ConsumerStatefulWidget {
  const CameraViewfinder({super.key, required this.onImage});

  final ValueChanged<Uint8List> onImage;

  @override
  ConsumerState<CameraViewfinder> createState() => _CameraViewfinderState();
}

enum _CamState { initializing, rationale, denied, permanentlyDenied, unsupported, ready }

class _CameraViewfinderState extends ConsumerState<CameraViewfinder>
    with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription> _cameras = const [];
  int _cameraIndex = 0;
  _CamState _stateEnum = _CamState.rationale;
  bool _flashOn = false;
  bool _capturing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycle) {
    final CameraController? c = _controller;
    if (c == null || !c.value.isInitialized) return;
    if (lifecycle == AppLifecycleState.inactive ||
        lifecycle == AppLifecycleState.paused) {
      c.dispose();
      _controller = null;
    } else if (lifecycle == AppLifecycleState.resumed &&
        _stateEnum == _CamState.ready) {
      _initController(_cameraIndex);
    }
  }

  Future<void> _requestAndStart() async {
    setState(() => _stateEnum = _CamState.initializing);
    final PermissionOutcome outcome =
        await ref.read(permissionServiceProvider).requestCamera();
    if (!mounted) return;
    switch (outcome) {
      case PermissionOutcome.granted:
        await _startCamera();
      case PermissionOutcome.permanentlyDenied:
        setState(() => _stateEnum = _CamState.permanentlyDenied);
      case PermissionOutcome.restricted:
      case PermissionOutcome.denied:
        setState(() => _stateEnum = _CamState.denied);
    }
  }

  Future<void> _startCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() => _stateEnum = _CamState.unsupported);
        return;
      }
      await _initController(0);
    } catch (_) {
      if (mounted) setState(() => _stateEnum = _CamState.unsupported);
    }
  }

  Future<void> _initController(int index) async {
    try {
      await _controller?.dispose();
      final CameraController controller = CameraController(
        _cameras[index],
        ResolutionPreset.high,
        enableAudio: false,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _cameraIndex = index;
        _stateEnum = _CamState.ready;
      });
    } catch (_) {
      if (mounted) setState(() => _stateEnum = _CamState.unsupported);
    }
  }

  Future<void> _toggleFlash() async {
    final CameraController? c = _controller;
    if (c == null) return;
    _flashOn = !_flashOn;
    try {
      await c.setFlashMode(_flashOn ? FlashMode.torch : FlashMode.off);
      setState(() {});
    } catch (_) {
      _flashOn = !_flashOn; // revert on failure
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;
    await _initController((_cameraIndex + 1) % _cameras.length);
  }

  Future<void> _capture() async {
    final CameraController? c = _controller;
    if (c == null || !c.value.isInitialized || _capturing) return;
    setState(() => _capturing = true);
    try {
      final XFile file = await c.takePicture();
      final Uint8List bytes = await file.readAsBytes();
      widget.onImage(bytes);
    } catch (_) {
      if (mounted) {
        final AppLocalizations l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(content: Text(l10n.captureFailed)));
      }
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? file =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (file == null) return;
      widget.onImage(await file.readAsBytes());
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    switch (_stateEnum) {
      case _CamState.initializing:
        return AppLoadingView(label: l10n.cameraInitializing);
      case _CamState.rationale:
        return PermissionRationale(
          icon: Icons.camera_alt_outlined,
          title: l10n.cameraPermissionTitle,
          message: l10n.cameraPermissionBody,
          primaryLabel: l10n.allowCamera,
          onPrimary: _requestAndStart,
          secondaryLabel: l10n.fromGallery,
          onSecondary: _pickFromGallery,
        );
      case _CamState.denied:
        return PermissionRationale(
          icon: Icons.no_photography_outlined,
          title: l10n.cameraPermissionTitle,
          message: l10n.cameraPermissionDeniedBody,
          primaryLabel: l10n.fromGallery,
          onPrimary: _pickFromGallery,
          secondaryLabel: l10n.allowCamera,
          onSecondary: _requestAndStart,
        );
      case _CamState.permanentlyDenied:
        return PermissionRationale(
          icon: Icons.no_photography_outlined,
          title: l10n.cameraPermissionTitle,
          message: l10n.cameraPermissionDeniedBody,
          primaryLabel: l10n.openSettings,
          onPrimary: () => ref.read(permissionServiceProvider).openSettings(),
          secondaryLabel: l10n.fromGallery,
          onSecondary: _pickFromGallery,
        );
      case _CamState.unsupported:
        return PermissionRationale(
          icon: Icons.videocam_off_outlined,
          title: l10n.cameraUnavailable,
          message: l10n.cameraPermissionDeniedBody,
          primaryLabel: l10n.fromGallery,
          onPrimary: _pickFromGallery,
        );
      case _CamState.ready:
        return _buildPreview(l10n);
    }
  }

  Widget _buildPreview(AppLocalizations l10n) {
    final CameraController? c = _controller;
    if (c == null || !c.value.isInitialized) {
      return AppLoadingView(label: l10n.cameraInitializing);
    }
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Positioned.fill(child: CameraPreview(c)),
        Positioned(
          top: AppSpacing.lg,
          right: AppSpacing.lg,
          child: Column(
            children: [
              IconButton.filledTonal(
                tooltip: _flashOn ? l10n.flashOff : l10n.flashOn,
                onPressed: _toggleFlash,
                icon: Icon(_flashOn ? Icons.flash_on : Icons.flash_off),
              ),
              if (_cameras.length > 1) ...[
                const SizedBox(height: AppSpacing.sm),
                IconButton.filledTonal(
                  tooltip: l10n.switchCamera,
                  onPressed: _switchCamera,
                  icon: const Icon(Icons.cameraswitch),
                ),
              ],
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton.filledTonal(
                tooltip: l10n.fromGallery,
                onPressed: _pickFromGallery,
                icon: const Icon(Icons.photo_library_outlined),
              ),
              GestureDetector(
                onTap: _capturing ? null : _capture,
                child: Semantics(
                  button: true,
                  label: l10n.capture,
                  child: Container(
                    height: 72,
                    width: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: Colors.white70, width: 4),
                    ),
                    child: _capturing
                        ? const Padding(
                            padding: EdgeInsets.all(18),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.camera, size: 36),
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),
      ],
    );
  }
}
