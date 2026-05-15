import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/face_detection_service.dart';
import '../theme/app_theme.dart';

class EyeProbabilityBar extends StatelessWidget {
  final String label;
  final double probability;
  final EyeState state;

  const EyeProbabilityBar({
    super.key,
    required this.label,
    required this.probability,
    required this.state,
  });

  Color get _barColor {
    switch (state) {
      case EyeState.open:
        return AppTheme.eyeOpen;
      case EyeState.closed:
        return AppTheme.eyeClosed;
      case EyeState.unknown:
        return AppTheme.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pct = probability.clamp(0.0, 1.0);

    return Row(
      children: [
        // Label
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 9,
              color: AppTheme.textMuted,
              letterSpacing: 1.5,
            ),
          ),
        ),

        // Bar
        Expanded(
          child: Stack(
            children: [
              // Background track
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Animated fill
              AnimatedFractionallySizedBox(
                duration: const Duration(milliseconds: 120),
                widthFactor: pct,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: _barColor,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: _barColor.withOpacity(0.6),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 10),

        // Percentage
        SizedBox(
          width: 36,
          child: Text(
            '${(pct * 100).toStringAsFixed(0)}%',
            textAlign: TextAlign.right,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 10,
              color: _barColor,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }
}
