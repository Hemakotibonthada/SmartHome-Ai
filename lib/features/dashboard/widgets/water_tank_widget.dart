import 'dart:math';
import 'package:flutter/material.dart';
import 'package:smart_home_ai/core/theme/app_theme.dart';

class WaterTankWidget extends StatefulWidget {
  final double level;

  const WaterTankWidget({super.key, required this.level});

  @override
  State<WaterTankWidget> createState() => _WaterTankWidgetState();
}

class _WaterTankWidgetState extends State<WaterTankWidget>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _levelController;
  late Animation<double> _levelAnimation;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _levelController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..forward();

    _levelAnimation = Tween<double>(begin: 0, end: widget.level).animate(
      CurvedAnimation(parent: _levelController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void didUpdateWidget(WaterTankWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.level != widget.level) {
      _levelAnimation = Tween<double>(
        begin: _levelAnimation.value,
        end: widget.level,
      ).animate(
        CurvedAnimation(parent: _levelController, curve: Curves.easeInOut),
      );
      _levelController.reset();
      _levelController.forward();
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    _levelController.dispose();
    super.dispose();
  }

  Color _getLevelColor(double level) {
    if (level < 20) return AppTheme.errorColor;
    if (level < 40) return AppTheme.warningColor;
    return AppTheme.secondaryColor;
  }

  String _getLevelStatus(double level) {
    if (level < 15) return 'Critical';
    if (level < 30) return 'Low';
    if (level < 60) return 'Moderate';
    if (level < 85) return 'Good';
    return 'Full';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _getLevelColor(widget.level).withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Tank visualization
              AnimatedBuilder(
                animation: Listenable.merge([_waveController, _levelController]),
                builder: (context, child) {
                  return CustomPaint(
                    size: const Size(100, 140),
                    painter: WaterTankPainter(
                      level: _levelAnimation.value / 100,
                      wavePhase: _waveController.value * 2 * pi,
                      color: _getLevelColor(_levelAnimation.value),
                    ),
                  );
                },
              ),
              const SizedBox(width: 24),
              // Info
              Expanded(
                child: AnimatedBuilder(
                  animation: _levelController,
                  builder: (context, child) {
                    final level = _levelAnimation.value;
                    final color = _getLevelColor(level);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Water Level',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              level.toStringAsFixed(0),
                              style: TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                '%',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  color: color.withOpacity(0.7),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _getLevelStatus(level),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Ultrasonic distance reading
                        Row(
                          children: [
                            Icon(Icons.sensors, size: 14, color: Colors.white38),
                            const SizedBox(width: 6),
                            Text(
                              'Distance: ${(100 - level).toStringAsFixed(0)} cm',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.4),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.water, size: 14, color: Colors.white38),
                            const SizedBox(width: 6),
                            Text(
                              'Volume: ~${(level * 10).toStringAsFixed(0)}L',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.4),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class WaterTankPainter extends CustomPainter {
  final double level;
  final double wavePhase;
  final Color color;

  WaterTankPainter({
    required this.level,
    required this.wavePhase,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final tankRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(16),
    );

    // Tank border
    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(tankRect, borderPaint);

    // Clip to tank shape
    canvas.save();
    canvas.clipRRect(tankRect);

    // Water level
    final waterHeight = size.height * level;
    final waterTop = size.height - waterHeight;

    // Wave path
    final wavePath = Path();
    wavePath.moveTo(0, size.height);

    for (double x = 0; x <= size.width; x++) {
      final y = waterTop +
          sin((x / size.width * 2 * pi) + wavePhase) * 4 +
          cos((x / size.width * 3 * pi) + wavePhase * 1.5) * 2;
      wavePath.lineTo(x, y);
    }

    wavePath.lineTo(size.width, size.height);
    wavePath.close();

    // Water gradient
    final waterPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withOpacity(0.3),
          color.withOpacity(0.6),
        ],
      ).createShader(Rect.fromLTWH(0, waterTop, size.width, waterHeight));

    canvas.drawPath(wavePath, waterPaint);

    // Second wave (lighter)
    final wave2Path = Path();
    wave2Path.moveTo(0, size.height);

    for (double x = 0; x <= size.width; x++) {
      final y = waterTop +
          sin((x / size.width * 2 * pi) + wavePhase + pi / 4) * 3 +
          cos((x / size.width * 4 * pi) + wavePhase * 0.8) * 2 +
          5;
      wave2Path.lineTo(x, y);
    }

    wave2Path.lineTo(size.width, size.height);
    wave2Path.close();

    final wave2Paint = Paint()
      ..color = color.withOpacity(0.15);

    canvas.drawPath(wave2Path, wave2Paint);

    canvas.restore();

    // Level lines
    for (int i = 1; i <= 4; i++) {
      final y = size.height * (1 - i / 5);
      canvas.drawLine(
        Offset(4, y),
        Offset(12, y),
        Paint()
          ..color = Colors.white.withOpacity(0.2)
          ..strokeWidth = 1,
      );
    }
  }

  @override
  bool shouldRepaint(covariant WaterTankPainter oldDelegate) {
    return oldDelegate.level != level ||
        oldDelegate.wavePhase != wavePhase ||
        oldDelegate.color != color;
  }
}
