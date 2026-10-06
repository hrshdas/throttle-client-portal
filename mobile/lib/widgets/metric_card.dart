import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';
import 'glass_card.dart';

/// Inline metric display (inside Insights card): large value + small label.
class MetricCard extends StatelessWidget {
  final String value;
  final String label;

  const MetricCard({
    super.key,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 38,
            fontWeight: FontWeight.w700,
            color: AppTheme.primaryText,
            height: 1.0,
            letterSpacing: -1.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppTheme.secondaryText,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }
}

/// Standalone stat card (VIEWS / CONTENT).
/// Uses FittedBox so the number NEVER wraps regardless of screen width.
class StatCard extends StatelessWidget {
  final String title;
  final String value;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryText,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 14),
          // FittedBox auto-scales the font so it always fits on ONE line
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: GoogleFonts.inter(
                fontSize: 52,
                fontWeight: FontWeight.w800,
                color: AppTheme.primaryText,
                height: 1.0,
                letterSpacing: -2.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
