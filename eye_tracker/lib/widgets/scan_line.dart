import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ScanLine extends StatefulWidget {
  const ScanLine({super.key});

  @override
  State<ScanLine> createState() => _ScanLineState();
}

class _ScanLineState extends State<ScanLine>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.linear);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, _) {
        return CustomPaint(
          painter: _ScanLinePainter(position: _anim.value),
        );
      },
    );
  }
}

class _ScanLinePainter extends CustomPainter {
  final double position;

  _ScanLinePainter({required this.position});

  @override
  void paint(Canvas canvas, Size size) {
    final y = position * size.height;

    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          AppTheme.accent.withOpacity(0.35),
          AppTheme.accent.withOpacity(0.6),
          AppTheme.accent.withOpacity(0.35),
          Colors.transparent,
        ],
        stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
      ).createShader(Rect.fromLTWH(0, y - 30, size.width, 60))
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(0, y - 2, size.width, 4),
      paint,
    );
  }

  @override
  bool shouldRepaint(_ScanLinePainter oldDelegate) =>
      oldDelegate.position != position;
}
