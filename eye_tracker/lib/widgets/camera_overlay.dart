import 'package:flutter/material.dart';
import '../services/face_detection_service.dart';
import '../theme/app_theme.dart';

class CameraOverlay extends StatefulWidget {
  final EyeState state;
  final bool faceDetected;

  const CameraOverlay({
    super.key,
    required this.state,
    required this.faceDetected,
  });

  @override
  State<CameraOverlay> createState() => _CameraOverlayState();
}

class _CameraOverlayState extends State<CameraOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnim = CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  Color get _frameColor {
    if (!widget.faceDetected) return AppTheme.textMuted;
    switch (widget.state) {
      case EyeState.open:
        return AppTheme.eyeOpen;
      case EyeState.closed:
        return AppTheme.eyeClosed;
      case EyeState.unknown:
        return AppTheme.accent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (_, _) {
        final color = _frameColor;
        final opacity = widget.faceDetected
            ? 0.5 + 0.5 * _pulseAnim.value
            : 0.25;

        return SizedBox(
          width: 220,
          height: 280,
          child: CustomPaint(
            painter: _CornerFramePainter(
              color: color.withOpacity(opacity),
              cornerLength: 28,
              strokeWidth: 2.5,
            ),
          ),
        );
      },
    );
  }
}

class _CornerFramePainter extends CustomPainter {
  final Color color;
  final double cornerLength;
  final double strokeWidth;

  _CornerFramePainter({
    required this.color,
    required this.cornerLength,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final w = size.width;
    final h = size.height;
    final cl = cornerLength;

    // Top-left
    canvas.drawLine(Offset(0, cl), Offset(0, 0), paint);
    canvas.drawLine(Offset(0, 0), Offset(cl, 0), paint);

    // Top-right
    canvas.drawLine(Offset(w - cl, 0), Offset(w, 0), paint);
    canvas.drawLine(Offset(w, 0), Offset(w, cl), paint);

    // Bottom-left
    canvas.drawLine(Offset(0, h - cl), Offset(0, h), paint);
    canvas.drawLine(Offset(0, h), Offset(cl, h), paint);

    // Bottom-right
    canvas.drawLine(Offset(w - cl, h), Offset(w, h), paint);
    canvas.drawLine(Offset(w, h - cl), Offset(w, h), paint);
  }

  @override
  bool shouldRepaint(_CornerFramePainter oldDelegate) =>
      oldDelegate.color != color;
}
