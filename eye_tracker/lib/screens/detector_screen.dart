import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/camera_service.dart';
import '../services/face_detection_service.dart';
import '../theme/app_theme.dart';
import '../widgets/status_indicator.dart';
import '../widgets/eye_probability_bar.dart';
import '../widgets/camera_overlay.dart';
import '../widgets/stats_panel.dart';

class DetectorScreen extends StatefulWidget {
  const DetectorScreen({super.key});

  @override
  State<DetectorScreen> createState() => _DetectorScreenState();
}

class _DetectorScreenState extends State<DetectorScreen>
    with WidgetsBindingObserver {
  final CameraService _cameraService = CameraService();
  final FaceDetectionService _detectionService = FaceDetectionService();

  EyeDetectionResult _result = EyeDetectionResult.noFace;
  bool _isLoading = true;
  String? _errorMessage;

  // Stats tracking
  int _totalFrames = 0;
  int _openFrames = 0;
  int _blinkCount = 0;
  EyeState _prevState = EyeState.unknown;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      await _cameraService.initialize();
      await _cameraService.startImageStream(_onCameraImage);
      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Camera unavailable.\nGrant camera permission and restart.';
        });
      }
    }
  }

  void _onCameraImage(CameraImage image) async {
    final camera = _cameraService.currentCamera;
    if (camera == null) return;

    final result = await _detectionService.processImage(image, camera);

    if (!mounted) return;
    setState(() {
      _result = result;
      if (result.faceDetected) {
        _totalFrames++;
        if (result.overallState == EyeState.open) _openFrames++;
        if (result.overallState == EyeState.closed)

        // Detect blink: open → closed → open transition
        if (_prevState == EyeState.open && result.overallState == EyeState.closed) {
          _blinkCount++;
        }
        _prevState = result.overallState;
      }
    });
  }

  Future<void> _switchCamera() async {
    setState(() => _isLoading = true);
    await _cameraService.stopImageStream();
    await _cameraService.switchCamera();
    await _cameraService.startImageStream(_onCameraImage);
    if (mounted) setState(() => _isLoading = false);
  }

  double get _openPercent =>
      _totalFrames > 0 ? (_openFrames / _totalFrames * 100) : 0;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      _cameraService.stopImageStream();
    } else if (state == AppLifecycleState.resumed) {
      _cameraService.startImageStream(_onCameraImage);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraService.dispose();
    _detectionService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: _errorMessage != null
          ? _buildError()
          : _buildMain(),
    );
  }

  Widget _buildMain() {
    return Stack(
      children: [
        // Camera preview — full screen
        _buildCameraPreview(),

        // Dark gradient vignette — top and bottom
        _buildVignette(),

        // Top bar
        _buildTopBar(),

        // Bottom panel
        _buildBottomPanel(),

        // Center status glow
        _buildCenterStatus(),
      ],
    );
  }

  Widget _buildCameraPreview() {
    if (_isLoading || _cameraService.controller == null) {
      return Container(color: AppTheme.background);
    }

    return Positioned.fill(
      child: CameraPreview(_cameraService.controller!),
    );
  }

  Widget _buildVignette() {
    return Positioned.fill(
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.25, 0.65, 1.0],
              colors: [
                AppTheme.background.withOpacity(0.95),
                AppTheme.background.withOpacity(0.3),
                AppTheme.background.withOpacity(0.3),
                AppTheme.background.withOpacity(0.97),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'eye_tracker',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                      letterSpacing: 4,
                    ),
                  ),
                  Text(
                    'BLINK DETECTION v1.0',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 9,
                      color: AppTheme.textSecondary,
                      letterSpacing: 3,
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.1),

              // Live indicator + switch camera
              Row(
                children: [
                  if (!_isLoading) _LiveBadge(),
                  const SizedBox(width: 12),
                  _IconButton(
                    icon: Icons.flip_camera_ios_outlined,
                    onTap: _switchCamera,
                  ),
                ],
              ).animate().fadeIn(duration: 600.ms).slideX(begin: 0.1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCenterStatus() {
    if (_isLoading) return const SizedBox.shrink();

    return Positioned.fill(
      child: IgnorePointer(
        child: Column(
          children: [
            const Spacer(flex: 2),
            // Camera overlay frame
            CameraOverlay(
              state: _result.overallState,
              faceDetected: _result.faceDetected,
            ),
            const Spacer(flex: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomPanel() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Main status indicator
              StatusIndicator(result: _result)
                  .animate()
                  .fadeIn(delay: 400.ms, duration: 500.ms),

              const SizedBox(height: 16),

              // Eye probability bars
              if (_result.faceDetected) ...[
                EyeProbabilityBar(
                  label: 'LEFT EYE',
                  probability: _result.leftOpenProbability ?? 0,
                  state: _result.leftEye,
                ).animate().fadeIn(delay: 500.ms),
                const SizedBox(height: 8),
                EyeProbabilityBar(
                  label: 'RIGHT EYE',
                  probability: _result.rightOpenProbability ?? 0,
                  state: _result.rightEye,
                ).animate().fadeIn(delay: 600.ms),
                const SizedBox(height: 16),
              ],

              // Stats row
              StatsPanel(
                blinkCount: _blinkCount,
                openPercent: _openPercent,
                totalFrames: _totalFrames,
              ).animate().fadeIn(delay: 700.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.no_photography_outlined,
                size: 64, color: AppTheme.eyeClosed.withOpacity(0.7)),
            const SizedBox(height: 20),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: GoogleFonts.jetBrainsMono(
                color: AppTheme.textSecondary,
                fontSize: 14,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 32),
            _IconButton(
              icon: Icons.refresh,
              onTap: () {
                setState(() {
                  _errorMessage = null;
                  _isLoading = true;
                });
                _initCamera();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveBadge extends StatefulWidget {
  @override
  State<_LiveBadge> createState() => _LiveBadgeState();
}

class _LiveBadgeState extends State<_LiveBadge> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.eyeClosed.withOpacity(0.12),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppTheme.eyeClosed.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.eyeClosed.withOpacity(0.5 + 0.5 * _ctrl.value),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'LIVE',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: AppTheme.eyeClosed,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.border),
        ),
        child: Icon(icon, color: AppTheme.textSecondary, size: 20),
      ),
    );
  }
}
