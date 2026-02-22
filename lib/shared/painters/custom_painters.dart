import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedWaveBackground extends StatefulWidget {
  final Widget child;
  final Color color;
  final double height;

  const AnimatedWaveBackground({
    super.key,
    required this.child,
    this.color = const Color(0xFF6C63FF),
    this.height = 200,
  });

  @override
  State<AnimatedWaveBackground> createState() => _AnimatedWaveBackgroundState();
}

class _AnimatedWaveBackgroundState extends State<AnimatedWaveBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomPaint(
              size: Size(double.infinity, widget.height),
              painter: _WavePainter(
                animation: _controller.value,
                color: widget.color,
              ),
            );
          },
        ),
        widget.child,
      ],
    );
  }
}

class _WavePainter extends CustomPainter {
  final double animation;
  final Color color;

  _WavePainter({required this.animation, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final paint2 = Paint()
      ..color = color.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    final path1 = Path();
    final path2 = Path();

    path1.moveTo(0, size.height * 0.5);
    path2.moveTo(0, size.height * 0.6);

    for (double i = 0; i <= size.width; i++) {
      path1.lineTo(
        i,
        size.height * 0.5 +
            math.sin((i / size.width * 2 * math.pi) + (animation * 2 * math.pi)) * 20,
      );
      path2.lineTo(
        i,
        size.height * 0.6 +
            math.sin((i / size.width * 2 * math.pi) + (animation * 2 * math.pi) + 1) * 15,
      );
    }

    path1.lineTo(size.width, size.height);
    path1.lineTo(0, size.height);
    path1.close();

    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();

    canvas.drawPath(path2, paint2);
    canvas.drawPath(path1, paint1);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) =>
      oldDelegate.animation != animation;
}

class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;

  CircularProgressPainter({
    required this.progress,
    required this.color,
    this.backgroundColor = const Color(0xFF1A1F3A),
    this.strokeWidth = 8,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background arc
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: 3 * math.pi / 2,
        colors: [color.withOpacity(0.3), color],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );

    // Glow dot at end
    final dotAngle = -math.pi / 2 + 2 * math.pi * progress;
    final dotX = center.dx + radius * math.cos(dotAngle);
    final dotY = center.dy + radius * math.sin(dotAngle);

    final dotPaint = Paint()
      ..color = color
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawCircle(Offset(dotX, dotY), strokeWidth / 2 + 2, dotPaint);
    canvas.drawCircle(
      Offset(dotX, dotY),
      strokeWidth / 2,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant CircularProgressPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

class SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color color;
  final bool filled;

  SparklinePainter({
    required this.data,
    required this.color,
    this.filled = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final maxVal = data.reduce(math.max);
    final minVal = data.reduce(math.min);
    final range = maxVal - minVal == 0 ? 1.0 : maxVal - minVal;

    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final y = size.height - ((data[i] - minVal) / range) * size.height * 0.8 - size.height * 0.1;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    if (filled) {
      fillPath.lineTo(size.width, size.height);
      fillPath.close();

      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withOpacity(0.2), color.withOpacity(0.0)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

      canvas.drawPath(fillPath, fillPaint);
    }

    final linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant SparklinePainter oldDelegate) =>
      oldDelegate.data != data || oldDelegate.color != color;
}
