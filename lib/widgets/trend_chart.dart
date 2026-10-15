import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A lightweight, dependency-free line/area chart used for monthly trends.
class TrendChart extends StatelessWidget {
  final List<double> values;
  final List<String> labels;
  final Color color;
  final double height;

  const TrendChart({
    super.key,
    required this.values,
    required this.labels,
    this.color = AppColors.primary,
    this.height = 140,
  });

  @override
  Widget build(BuildContext context) {
    final hasData = values.any((v) => v > 0);

    return Column(
      children: [
        SizedBox(
          height: height,
          width: double.infinity,
          child: hasData
              ? CustomPaint(
                  painter: _TrendPainter(values: values, color: color),
                )
              : Center(
                  child: Text('No data yet', style: AppText.caption),
                ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            for (var i = 0; i < labels.length; i++)
              Expanded(
                child: Text(
                  labels[i],
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.label.copyWith(letterSpacing: 0),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _TrendPainter extends CustomPainter {
  final List<double> values;
  final Color color;

  _TrendPainter({required this.values, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty || size.width <= 0) return;

    final maxValue = values.reduce(math.max);
    final scale = maxValue <= 0 ? 1.0 : maxValue;
    const topPad = 12.0;
    const bottomPad = 10.0;
    final usableHeight = size.height - topPad - bottomPad;
    final n = values.length;

    Offset pointAt(int i) {
      final x = n == 1 ? size.width / 2 : (size.width * i) / (n - 1);
      final y = topPad + usableHeight * (1 - values[i] / scale);
      return Offset(x, y);
    }

    final line = Path()..moveTo(pointAt(0).dx, pointAt(0).dy);
    for (var i = 1; i < n; i++) {
      final p = pointAt(i);
      line.lineTo(p.dx, p.dy);
    }

    final fill = Path.from(line)
      ..lineTo(pointAt(n - 1).dx, size.height)
      ..lineTo(pointAt(0).dx, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withValues(alpha: 0.32), color.withValues(alpha: 0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(fill, fillPaint);
    canvas.drawPath(line, linePaint);

    final dotOuter = Paint()..color = color;
    final dotInner = Paint()..color = AppColors.surface;
    for (var i = 0; i < n; i++) {
      final p = pointAt(i);
      canvas.drawCircle(p, 3.8, dotOuter);
      canvas.drawCircle(p, 1.8, dotInner);
    }
  }

  @override
  bool shouldRepaint(_TrendPainter old) =>
      old.color != color ||
      old.values.length != values.length ||
      !_sameValues(old.values, values);

  bool _sameValues(List<double> a, List<double> b) {
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
