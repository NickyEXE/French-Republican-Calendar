import 'package:flutter/material.dart';
import 'dart:math';
import 'decimal_time.dart';

class RepublicanClockPainter extends CustomPainter {
  final DecimalTime decimalTime;

  RepublicanClockPainter(this.decimalTime);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()..color = Colors.white;

    // Draw clock face
    canvas.drawCircle(center, radius, paint..color = Colors.black);
    canvas.drawCircle(center, radius * 0.97, paint..color = Colors.white);

    // Draw hour numbers (1-10)
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    const romanNumerals = ['I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X'];
    for (int i = 1; i <= 10; i++) {
      final angle = (i * 36) * pi / 180 - pi / 2;
      final offset = Offset(
      center.dx + cos(angle) * radius * 0.75,
      center.dy + sin(angle) * radius * 0.75,
      );

      textPainter.text = TextSpan(
      text: romanNumerals[i - 1],
      style: const TextStyle(color: Colors.black, fontSize: 20),
      );
      textPainter.layout();
      textPainter.paint(canvas, offset - Offset(textPainter.width / 2, textPainter.height / 2));
    }

    // Draw minute/second ticks
    final tickPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1;
    for (int i = 0; i < 100; i++) {
      final angle = (i * 3.6) * pi / 180 - pi / 2;
      final start = Offset(center.dx + cos(angle) * radius * 0.9, center.dy + sin(angle) * radius * 0.9);
      final end = Offset(center.dx + cos(angle) * radius * 0.95, center.dy + sin(angle) * radius * 0.95);
      canvas.drawLine(start, end, tickPaint);
    }

    // Draw hour hand
    // The hour hand moves 1/100th of the way around the clock for each minute
    drawHand(canvas, center, radius * 0.5, ((decimalTime.hour + decimalTime.minute/100)  * 36), Colors.black, 6);

    // Draw minute hand
    drawHand(canvas, center, radius * 0.7, decimalTime.minute * 3.6, Colors.red, 4);

    // Draw second hand
    drawHand(canvas, center, radius * 0.8, decimalTime.second * 3.6, Colors.blue, 2);
  }

  void drawHand(Canvas canvas, Offset center, double length, double angleDegrees, Color color, double width) {
    final angle = (angleDegrees - 90) * pi / 180; // Rotate to start at the top
    final handPaint = Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;
    final end = Offset(center.dx + cos(angle) * length, center.dy + sin(angle) * length);
    canvas.drawLine(center, end, handPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}