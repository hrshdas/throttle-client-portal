import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_constants.dart';

/// Premium card — solid white, layered shadow, real blur.
/// Shadow is on an outer wrapper OUTSIDE ClipRRect so it always renders.
class GlassCard extends StatelessWidget {
  final Widget child;
  final double? borderRadius;
  final double blurAmount;
  final double opacity;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final Border? border;
  final List<BoxShadow>? shadows;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius,
    this.blurAmount = 20,
    this.opacity = 1.0,
    this.backgroundColor,
    this.padding,
    this.border,
    this.shadows,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(
        borderRadius ?? AppConstants.cardRadius);

    Widget inner = Container(
      decoration: BoxDecoration(
        borderRadius: r,
        boxShadow: shadows ?? AppTheme.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: r,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor ?? AppTheme.card,
              borderRadius: r,
              // Thin 0.5px border gives cards a clean, precise edge
              border: border ??
                  Border.all(
                    color: const Color(0xFFE4E4E8),
                    width: 0.5,
                  ),
            ),
            padding: padding ??
                const EdgeInsets.all(AppConstants.cardPadding),
            child: child,
          ),
        ),
      ),
    );

    return onTap != null
        ? GestureDetector(onTap: onTap, child: inner)
        : inner;
  }
}
