import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class StatsPanel extends StatelessWidget {
  final int blinkCount;
  final double openPercent;
  final int totalFrames;

  const StatsPanel({
    super.key,
    required this.blinkCount,
    required this.openPercent,
    required this.totalFrames,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          _Stat(label: 'BLINKS', value: blinkCount.toString()),
          _Divider(),
          _Stat(
            label: 'EYES OPEN',
            value: '${openPercent.toStringAsFixed(1)}%',
          ),
          _Divider(),
          _Stat(label: 'FRAMES', value: totalFrames.toString()),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;

  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 8,
              color: AppTheme.textMuted,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      color: AppTheme.border,
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}
