import 'dart:ui';

import 'package:flutter/material.dart';

class DashedLinePainter extends CustomPainter {
  final Offset start;
  final Offset end;
  final int completedDays;
  final int totalDays;

  DashedLinePainter({
    required this.start,
    required this.end,
    required this.completedDays,
    required this.totalDays,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Paint 설정
    final Paint completedPaint = Paint()
      ..color = Colors.yellow
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final Paint remainingPaint = Paint()
      ..color = Color(0xFF45548E)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Path 생성
    final Path path = Path();
    path.moveTo(start.dx, start.dy);

    // Control Point 계산
    final controlPoint = Offset(
      (start.dx + end.dx) / 2,
      (start.dy + end.dy) / 2 - 100,
    );
    path.quadraticBezierTo(
      controlPoint.dx,
      controlPoint.dy,
      end.dx,
      end.dy,
    );

    // PathMetrics 검증
    final PathMetrics pathMetrics = path.computeMetrics();
    if (pathMetrics.isEmpty) {
      print('Error: Path is empty or invalid.');
      return;
    }

    // PathMetric 추출
    final PathMetric pathMetric = pathMetrics.first;
    final totalLength = pathMetric.length;

    // 진행률 계산
    final double completedLength = totalLength * (completedDays / totalDays);

    // 점선 그리기
    const double dashLength = 5.0;
    const double gapLength = 3.0;
    double currentLength = 0.0;

    print('Total Length: $totalLength, Completed Length: $completedLength');

    while (currentLength < totalLength) {
      final isCompleted = currentLength < completedLength;
      final nextLength = (currentLength + dashLength).clamp(0, totalLength);
      final Paint paint = isCompleted ? completedPaint : remainingPaint;

      final Path extractPath = pathMetric.extractPath(
        currentLength,
        nextLength.toDouble(),
      );
      canvas.drawPath(extractPath, paint);

      currentLength = nextLength + gapLength;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
