import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/face_detection_service.dart';
import '../theme/app_theme.dart';

class StatusIndicator extends StatefulWidget {
  final EyeDetectionResult result;

  const StatusIndicator({super.key, required this.result});

  @override
  State<StatusIndicator> createState() => _StatusIndicatorState();
}

class _StatusIndicatorState extends State<StatusIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulseAnim = CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  _StatusConfig get _config {
    if (!widget.result.faceDetected) {
      return _StatusConfig(
        label: 'NO FACE DETECTED',
        sublabel: 'Position your face in frame',
        color: AppTheme.textSecondary,
        glowColor: AppTheme.textSecondary,
        icon: Icons.person_search_outlined,
      );
    }

    switch (widget.result.overallState) {
      case EyeState.open:
        return _StatusConfig(
          label: 'EYES OPEN',
          sublabel: 'Subject is alert',
          color: AppTheme.eyeOpen,
          glowColor: AppTheme.eyeOpenGlow,
          icon: Icons.remove_red_eye,
        );
      case EyeState.closed:
        return _StatusConfig(
          label: 'EYES CLOSED',
          sublabel: 'Blink detected',
          color: AppTheme.eyeClosed,
          glowColor: AppTheme.eyeClosedGlow,
          icon: Icons.visibility_off,
        );
      case EyeState.unknown:
        return _StatusConfig(
          label: 'ANALYZING...',
          sublabel: 'Processing face data',
          color: AppTheme.accent,
          glowColor: AppTheme.accent,
          icon: Icons.blur_on,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cfg = _config;
    final isActive = widget.result.faceDetected &&
        widget.result.overallState != EyeState.unknown;

    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (_, _) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: cfg.color.withOpacity(0.07),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: cfg.color.withOpacity(isActive ? 0.35 + 0.15 * _pulseAnim.value : 0.2),
              width: 1.5,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: cfg.glowColor.withOpacity(0.12 * _pulseAnim.value),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              // Animated icon container
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: cfg.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: cfg.glowColor
                                .withOpacity(0.2 + 0.15 * _pulseAnim.value),
                            blurRadius: 12,
                          ),
                        ]
                      : null,
                ),
                child: Icon(cfg.icon, color: cfg.color, size: 24),
              ),

              const SizedBox(width: 16),

              // Labels
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: cfg.color,
                        letterSpacing: 2,
                      ),
                      child: Text(cfg.label),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      cfg.sublabel,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        color: AppTheme.textMuted,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),

              // State dot
              if (isActive)
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: cfg.glowColor
                        .withOpacity(0.6 + 0.4 * _pulseAnim.value),
                    boxShadow: [
                      BoxShadow(
                        color: cfg.glowColor.withOpacity(0.5),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _StatusConfig {
  final String label;
  final String sublabel;
  final Color color;
  final Color glowColor;
  final IconData icon;

  const _StatusConfig({
    required this.label,
    required this.sublabel,
    required this.color,
    required this.glowColor,
    required this.icon,
  });
}
