import 'package:flutter/material.dart';

/// Renders a subtle, non-intrusive dot grid pattern reminiscent of architectural
/// chess boards, isolated on its own RepaintBoundary layer for zero scroll overhead.
class DotGridBackground extends StatelessWidget {
  final Widget child;
  final Color? dotColor;
  final double spacing;
  final double dotRadius;

  const DotGridBackground({
    super.key,
    required this.child,
    this.dotColor,
    this.spacing = 32.0,
    this.dotRadius = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final resolvedDotColor = dotColor ??
        (isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.04));

    return Stack(
      children: [
        Positioned.fill(
          child: RepaintBoundary(
            child: CustomPaint(
              painter: _DotGridPainter(
                color: resolvedDotColor,
                spacing: spacing,
                dotRadius: dotRadius,
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _DotGridPainter extends CustomPainter {
  final Color color;
  final double spacing;
  final double dotRadius;

  const _DotGridPainter({
    required this.color,
    required this.spacing,
    required this.dotRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (double x = spacing / 2; x < size.width; x += spacing) {
      for (double y = spacing / 2; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotGridPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.spacing != spacing ||
      oldDelegate.dotRadius != dotRadius;
}

