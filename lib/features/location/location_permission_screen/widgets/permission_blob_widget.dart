import 'dart:math' as math;
import 'package:flutter/material.dart';

class PermissionBlobWidget extends StatelessWidget {
  final AnimationController controller;

  const PermissionBlobWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return AnimatedBuilder(
      animation: controller,
      builder: (_, _) {
        return CustomPaint(
          size: size,
          painter: _BlobPainter(progress: controller.value),
        );
      },
    );
  }
}

class _BlobPainter extends CustomPainter {
  final double progress;

  _BlobPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    // Background gradient
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFF97316), Color(0xFFEF4444)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Morphing blob — primary blob
    final blobPaint = Paint()
      ..color = Colors.white.withAlpha(20)
      ..style = PaintingStyle.fill;

    final cx = size.width * 0.5;
    final cy = size.height * 0.38;
    final r = size.width * 0.55;

    final path = Path();
    final points = 8;
    for (int i = 0; i <= points; i++) {
      final angle = (i / points) * 2 * math.pi;
      final wave = math.sin(angle * 3 + progress * 2 * math.pi) * 0.12;
      final radius = r * (1 + wave);
      final x = cx + radius * math.cos(angle);
      final y = cy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, blobPaint);

    // Secondary blob
    final blob2Paint = Paint()
      ..color = Colors.white.withAlpha(13)
      ..style = PaintingStyle.fill;

    final path2 = Path();
    final cx2 = size.width * 0.8;
    final cy2 = size.height * 0.75;
    final r2 = size.width * 0.4;
    for (int i = 0; i <= points; i++) {
      final angle = (i / points) * 2 * math.pi;
      final wave = math.sin(angle * 4 + (1 - progress) * 2 * math.pi) * 0.15;
      final radius = r2 * (1 + wave);
      final x = cx2 + radius * math.cos(angle);
      final y = cy2 + radius * math.sin(angle);
      if (i == 0) {
        path2.moveTo(x, y);
      } else {
        path2.lineTo(x, y);
      }
    }
    path2.close();
    canvas.drawPath(path2, blob2Paint);

    // Bottom white wave
    final wavePaint = Paint()
      ..color = const Color(0xFFF8FAFC)
      ..style = PaintingStyle.fill;

    final wavePath = Path();
    wavePath.moveTo(0, size.height);
    wavePath.lineTo(0, size.height * 0.72);
    final cp1x = size.width * 0.25;
    final cp1y =
        size.height * 0.65 + math.sin(progress * math.pi) * size.height * 0.03;
    final cp2x = size.width * 0.75;
    final cp2y =
        size.height * 0.68 + math.cos(progress * math.pi) * size.height * 0.03;
    wavePath.cubicTo(cp1x, cp1y, cp2x, cp2y, size.width, size.height * 0.72);
    wavePath.lineTo(size.width, size.height);
    wavePath.close();
    canvas.drawPath(wavePath, wavePaint);
  }

  @override
  bool shouldRepaint(_BlobPainter old) => old.progress != progress;
}
