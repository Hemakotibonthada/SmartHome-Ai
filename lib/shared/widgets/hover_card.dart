import 'package:flutter/material.dart';
import 'package:smart_home_ai/core/theme/app_theme.dart';

/// A card widget with hover effects for web.
/// Provides elevation lift, border highlight, and slight scale on hover.
class HoverCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? borderColor;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final double hoverElevation;

  const HoverCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.borderColor,
    this.backgroundColor,
    this.borderRadius,
    this.padding,
    this.hoverElevation = 8,
  });

  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final br = widget.borderRadius ?? BorderRadius.circular(20);
    final bgColor = widget.backgroundColor ?? AppTheme.darkCard;
    final border = widget.borderColor;

    return MouseRegion(
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: _isHovered
            ? (Matrix4.identity()..scale(1.01))
            : Matrix4.identity(),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: _isHovered
              ? Color.lerp(bgColor, Colors.white, 0.03)
              : bgColor,
          borderRadius: br,
          border: Border.all(
            color: _isHovered
                ? (border ?? AppTheme.primaryColor).withValues(alpha: 0.4)
                : (border ?? Colors.white).withValues(alpha: 0.06),
            width: _isHovered ? 1.5 : 1,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: (border ?? AppTheme.primaryColor)
                        .withValues(alpha: 0.12),
                    blurRadius: widget.hoverElevation,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: br,
          child: InkWell(
            borderRadius: br,
            onTap: widget.onTap,
            onLongPress: widget.onLongPress,
            hoverColor: Colors.transparent,
            splashColor: AppTheme.primaryColor.withValues(alpha: 0.08),
            highlightColor: AppTheme.primaryColor.withValues(alpha: 0.04),
            child: widget.padding != null
                ? Padding(padding: widget.padding!, child: widget.child)
                : widget.child,
          ),
        ),
      ),
    );
  }
}

/// A section card with hover effects, used throughout hub screens.
class HoverSectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Widget content;
  final VoidCallback? onTap;

  const HoverSectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.content,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return HoverCard(
      onTap: onTap,
      borderColor: color.withValues(alpha: 0.2),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.white.withValues(alpha: 0.2),
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }
}
