import 'package:flutter/material.dart';

/// Helper utilities and widgets for making Learn Kannada fully responsive
/// across all device form factors (small phones, large phones, foldables,
/// tablets, iPads, and landscape orientations).
class Responsive {
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 1024.0;
  static const double maxContentWidth = 760.0;

  /// Whether current window width is in phone/mobile range (< 600dp)
  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < mobileBreakpoint;

  /// Whether current window width is in tablet/iPad range (600dp - 1024dp)
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  /// Whether current window width is desktop or ultra-wide (>= 1024dp)
  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tabletBreakpoint;

  /// Whether current orientation is landscape
  static bool isLandscape(BuildContext context) =>
      MediaQuery.orientationOf(context) == Orientation.landscape;

  /// Whether current screen is a compact phone (< 360dp width)
  static bool isCompact(BuildContext context) =>
      MediaQuery.sizeOf(context).width < 360;

  /// Responsive horizontal page padding based on screen size
  static double horizontalPadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 360) return 14.0;
    if (width < 600) return 20.0;
    if (width < 1024) return 28.0;
    return 36.0;
  }
}

/// A wrapper widget that constrains content to a comfortable reading/touch
/// width on wide devices (tablets, iPads, desktops) while centering it.
class ResponsiveContentWrapper extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry alignment;

  const ResponsiveContentWrapper({
    super.key,
    required this.child,
    this.maxWidth = Responsive.maxContentWidth,
    this.padding,
    this.alignment = Alignment.topCenter,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );

    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }

    return content;
  }
}
