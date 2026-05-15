import 'package:camera/camera.dart';

class CameraService {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  int _currentCameraIndex = 0;

  CameraController? get controller => _controller;
  bool get isInitialized => _controller?.value.isInitialized ?? false;

  Future<void> initialize() async {
    _cameras = await availableCameras();
    if (_cameras.isEmpty) throw Exception('No cameras available on this device.');

    // Prefer front camera for eye detection
    _currentCameraIndex = _cameras.indexWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
    );
    if (_currentCameraIndex == -1) _currentCameraIndex = 0;

    await _initController(_cameras[_currentCameraIndex]);
  }

  Future<void> _initController(CameraDescription camera) async {
    await _controller?.dispose();

    _controller = CameraController(
      camera,
      ResolutionPreset.medium, // Balanced for ML speed vs. quality
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.nv21, // Android-friendly for ML Kit
    );

    await _controller!.initialize();
  }

  Future<void> startImageStream(Function(CameraImage) onImage) async {
    if (_controller == null || !isInitialized) return;
    if (_controller!.value.isStreamingImages) return;
    await _controller!.startImageStream(onImage);
  }

  Future<void> stopImageStream() async {
    if (_controller?.value.isStreamingImages ?? false) {
      await _controller!.stopImageStream();
    }
  }

  Future<void> switchCamera() async {
    if (_cameras.length < 2) return;
    _currentCameraIndex = (_currentCameraIndex + 1) % _cameras.length;
    await _initController(_cameras[_currentCameraIndex]);
  }

  CameraDescription? get currentCamera =>
      _cameras.isNotEmpty ? _cameras[_currentCameraIndex] : null;

  Future<void> dispose() async {
    await _controller?.dispose();
    _controller = null;
  }
}
