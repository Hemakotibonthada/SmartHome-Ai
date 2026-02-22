import 'package:flutter/material.dart';
import 'package:smart_home_ai/core/theme/app_theme.dart';

class QuickActionCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isOn;
  final VoidCallback onTap;

  const QuickActionCard({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.isOn,
    required this.onTap,
  });

  @override
  State<QuickActionCard> createState() => _QuickActionCardState();
}

class _QuickActionCardState extends State<QuickActionCard> {
  bool _isOn = false;

  @override
  void initState() {
    super.initState();
    _isOn = widget.isOn;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() => _isOn = !_isOn);
        widget.onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: 85,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _isOn
              ? widget.color.withOpacity(0.15)
              : AppTheme.darkCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isOn
                ? widget.color.withOpacity(0.4)
                : Colors.white.withOpacity(0.05),
          ),
          boxShadow: _isOn
              ? [
                  BoxShadow(
                    color: widget.color.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _isOn
                    ? widget.color.withOpacity(0.2)
                    : Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.icon,
                color: _isOn ? widget.color : Colors.white38,
                size: 22,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: _isOn ? widget.color : Colors.white38,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
