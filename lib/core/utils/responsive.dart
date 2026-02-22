import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Breakpoints & helpers for responsive layouts.
class Responsive {
  // ---- Breakpoints ----
  static const double mobileBreak = 600;
  static const double tabletBreak = 1024;
  static const double desktopBreak = 1440;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileBreak;

  static bool isTablet(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return w >= mobileBreak && w < tabletBreak;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tabletBreak;

  static bool isWideDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktopBreak;

  /// Returns true when running on Web regardless of screen size.
  static bool get isWebPlatform => kIsWeb;

  /// Convenience: number of grid columns for the current width.
  static int gridColumns(BuildContext context) {
    if (isWideDesktop(context)) return 4;
    if (isDesktop(context)) return 3;
    if (isTablet(context)) return 2;
    return 1;
  }

  /// Max content width for centred layouts.
  static double contentWidth(BuildContext context) {
    if (isWideDesktop(context)) return 1320;
    if (isDesktop(context)) return 1100;
    return double.infinity;
  }

  /// Horizontal padding that grows with screen size.
  static double horizontalPadding(BuildContext context) {
    if (isWideDesktop(context)) return 48;
    if (isDesktop(context)) return 32;
    if (isTablet(context)) return 24;
    return 16;
  }
}

/// A widget that chooses between [mobile] and [desktop] layouts,
/// with an optional [tablet] override.
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= Responsive.tabletBreak) {
          return desktop;
        } else if (constraints.maxWidth >= Responsive.mobileBreak) {
          return tablet ?? mobile;
        }
        return mobile;
      },
    );
  }
}
