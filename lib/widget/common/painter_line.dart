import 'package:flutter/material.dart';

class PainterLine extends CustomPainter {
  Color lineColor;
  double strokeWidth;

  PainterLine({this.lineColor, this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    Paint _paint = new Paint()
      ..color = lineColor
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true
      ..strokeWidth = strokeWidth ?? 1.0
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(0.0, size.height / 2), Offset(size.width, size.height / 2), _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
