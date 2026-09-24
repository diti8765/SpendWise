import 'package:flutter/material.dart';

/// A beautifully rendered vector logo for SpendWise.
/// Renders using pure Canvas drawing so it is 100% resilient,
/// crystal sharp at any resolution, and never fails due to missing fonts or assets.
class SpendWiseLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final String? subtitle;

  const SpendWiseLogo({
    super.key,
    this.size = 64,
    this.showText = false,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final logoIcon = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2E7D32), // Vibrant Forest Green
            Color(0xFF1B5E20), // Deep Finance Green
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B5E20).withValues(alpha: 0.35),
            blurRadius: size * 0.25,
            offset: Offset(0, size * 0.08),
          ),
        ],
      ),
      child: Center(
        child: CustomPaint(
          size: Size(size * 0.6, size * 0.6),
          painter: _SpendWiseEmblemPainter(),
        ),
      ),
    );

    if (!showText) {
      return logoIcon;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        logoIcon,
        SizedBox(height: size * 0.22),
        Text(
          'SpendWise',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(
            subtitle!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

/// Custom painter for the SpendWise finance emblem:
/// Draws an elegant stylized wallet crest with an upward financial growth curve & coin.
class _SpendWiseEmblemPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Draw wallet / card pouch outline
    final cardPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.95)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.09
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final cardRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.05, h * 0.2, w * 0.9, h * 0.7),
      Radius.circular(w * 0.16),
    );
    canvas.drawRRect(cardRect, cardPaint);

    // 2. Draw wallet flap fold / divider
    final foldPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.06
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(w * 0.05, h * 0.48),
      Offset(w * 0.95, h * 0.48),
      foldPaint,
    );

    // 3. Draw upward trending growth stroke (finance sparkline)
    final trendPaint = Paint()
      ..color =
          const Color(0xFFFFD54F) // Gold accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.1
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final trendPath = Path()
      ..moveTo(w * 0.2, h * 0.78)
      ..lineTo(w * 0.45, h * 0.6)
      ..lineTo(w * 0.62, h * 0.68)
      ..lineTo(w * 0.82, h * 0.35);

    canvas.drawPath(trendPath, trendPaint);

    // 4. Draw trending growth arrow head or coin dot
    final coinPaint = Paint()
      ..color = const Color(0xFFFFD54F)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(w * 0.82, h * 0.35), w * 0.09, coinPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
