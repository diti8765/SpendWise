import 'package:flutter/material.dart';

/// Animation utilities that respect the user's reduce-motion preference.
/// Always check [shouldAnimate] before running non-essential animations.
class Motion {
  /// Standard curve for page transitions.
  static const Curve standardCurve = Curves.easeInOutCubicEmphasized;

  /// Standard duration for most animations.
  static const Duration standardDuration = Duration(milliseconds: 300);

  /// Short duration for micro-interactions (e.g. icon changes).
  static const Duration shortDuration = Duration(milliseconds: 150);

  /// Long duration for complex transitions.
  static const Duration longDuration = Duration(milliseconds: 500);

  /// Returns true if animations should play.
  /// Returns false when the user has enabled "Reduce Motion" in system settings.
  static bool shouldAnimate(BuildContext context) {
    return !MediaQuery.of(context).disableAnimations;
  }

  /// Returns the appropriate duration — either the given duration or zero
  /// if reduce motion is enabled.
  static Duration resolve(BuildContext context, [Duration? duration]) {
    if (!shouldAnimate(context)) return Duration.zero;
    return duration ?? standardDuration;
  }
}
