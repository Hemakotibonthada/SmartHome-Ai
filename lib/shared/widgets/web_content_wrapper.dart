import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smart_home_ai/core/utils/responsive.dart';

/// Wraps screen content with responsive max-width, padding, and
/// web-appropriate scroll physics. Use this as the outermost widget
/// inside any screen's `Scaffold.body`.
class WebContentWrapper extends StatelessWidget {
  final Widget child;

  /// If true, adds a subtle gradient background.
  final bool showBackground;

  /// Override the max content width.
  final double? maxWidth;

  const WebContentWrapper({
    super.key,
    required this.child,
    this.showBackground = false,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    final width = maxWidth ?? Responsive.contentWidth(context);
    final hPad = Responsive.horizontalPadding(context);

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: width),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: hPad),
          child: child,
        ),
      ),
    );
  }

  /// Returns platform-appropriate scroll physics:
  /// [ClampingScrollPhysics] for web, [BouncingScrollPhysics] for mobile.
  static ScrollPhysics get scrollPhysics =>
      kIsWeb ? const ClampingScrollPhysics() : const BouncingScrollPhysics();
}

/// A responsive grid that adapts columns based on screen width.
/// Uses [Responsive.gridColumns] to determine the number of columns.
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double childAspectRatio;
  final double spacing;
  final int? minColumns;
  final int? maxColumns;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.childAspectRatio = 1.0,
    this.spacing = 16,
    this.minColumns,
    this.maxColumns,
  });

  @override
  Widget build(BuildContext context) {
    int cols = Responsive.gridColumns(context);
    if (minColumns != null && cols < minColumns!) cols = minColumns!;
    if (maxColumns != null && cols > maxColumns!) cols = maxColumns!;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}

/// Arranges child widgets into a responsive multi-column flow layout.
/// On mobile: 1 column, on tablet: 2, on desktop: 2-3.
/// Unlike [ResponsiveGrid], children can have varying heights.
class ResponsiveColumns extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final int? desktopColumns;

  const ResponsiveColumns({
    super.key,
    required this.children,
    this.spacing = 16,
    this.desktopColumns,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    final isTablet = Responsive.isTablet(context);
    final cols = isDesktop
        ? (desktopColumns ?? 2)
        : isTablet
            ? 2
            : 1;

    if (cols == 1) {
      return Column(children: children);
    }

    // Distribute children across columns
    final columns = List.generate(cols, (_) => <Widget>[]);
    for (var i = 0; i < children.length; i++) {
      columns[i % cols].add(children[i]);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var c = 0; c < cols; c++) ...[
          if (c > 0) SizedBox(width: spacing),
          Expanded(
            child: Column(children: columns[c]),
          ),
        ],
      ],
    );
  }
}
