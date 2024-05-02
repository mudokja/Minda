import 'package:flutter/material.dart';

class DottedLinePainter extends CustomPainter {
  final double dashWidth;
  final double dashHeight;
  final Paint dashPaint;

  DottedLinePainter({
    this.dashWidth = 4.0, 
    this.dashHeight = 1.0, 
    Color color = Colors.black
  }) : dashPaint = Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = dashHeight;

  @override
  void paint(Canvas canvas, Size size) {
    int dashCount = (size.width / (2 * dashWidth)).floor();
    double startX = 0;
    for (int i = 0; i < dashCount; ++i) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), dashPaint);
      startX += 2 * dashWidth;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
