import 'package:flutter/material.dart';

class UnicornOutlineButton extends StatelessWidget {
  final _GradientPainter _painter;
  final Widget _child;
  final VoidCallback? _callback;
  final double _radius;

  UnicornOutlineButton({
    Key? key,
    required double strokeWidth,
    required double radius,
    required Color topBottomColor,
    required Color leftRightColor,
    required Widget child,
    VoidCallback? onPressed,
  }) : _painter = _GradientPainter(
         strokeWidth: strokeWidth,
         radius: radius,
         topBottomColor: topBottomColor,
         leftRightColor: leftRightColor,
       ),
       _child = child,
       _callback = onPressed,
       _radius = radius,
       super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _painter,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _callback,
        child: InkWell(
          borderRadius: BorderRadius.circular(_radius),
          onTap: _callback,
          child: Container(
            constraints: const BoxConstraints(minWidth: 88, minHeight: 48),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[_child],
            ),
          ),
        ),
      ),
    );
  }
}

class _GradientPainter extends CustomPainter {
  final Paint _paint = Paint();
  final double radius;
  final double strokeWidth;
  final Color topBottomColor;
  final Color leftRightColor;

  _GradientPainter({
    required this.strokeWidth,
    required this.radius,
    required this.topBottomColor,
    required this.leftRightColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // create outer rectangle equals size
    Rect outerRect = Offset.zero & size;
    var outerRRect = RRect.fromRectAndRadius(
      outerRect,
      Radius.circular(radius),
    );

    // create inner rectangle smaller by strokeWidth
    Rect innerRect = Rect.fromLTWH(
      strokeWidth,
      strokeWidth,
      size.width - strokeWidth * 2,
      size.height - strokeWidth * 2,
    );
    var innerRRect = RRect.fromRectAndRadius(
      innerRect,
      Radius.circular(radius - strokeWidth),
    );

    // Create a sweep gradient that matches the image pattern:
    // - Top and bottom: topBottomColor (grey in the image)
    // - Left AND right: leftRightColor (dark container color in the image)
    // - Corners: smooth mix between the two colors
    final gradient = SweepGradient(
      center: Alignment.center,
      startAngle: -3.14159 / 2, // Start from top (-90 degrees)
      endAngle: 3.14159 * 1.5, // End at top again (270 degrees, full circle)
      colors: [
        topBottomColor, // Top
        Color.lerp(
          topBottomColor,
          leftRightColor,
          0.4,
        )!, // Top-right corner mix
        leftRightColor, // Right side
        Color.lerp(
          leftRightColor,
          topBottomColor,
          0.1,
        )!, // Right-bottom corner mix
        topBottomColor, // Bottom
        Color.lerp(
          topBottomColor,
          leftRightColor,
          0.5,
        )!, // Bottom-left corner mix
        leftRightColor, // Left side
        Color.lerp(leftRightColor, topBottomColor, 0.5)!, // Left-top corner mix
        topBottomColor, // Back to top
      ],
      stops: const [0.0, 0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 0.875, 1.0],
    );

    // apply gradient shader
    _paint.shader = gradient.createShader(outerRect);

    // create difference between outer and inner paths and draw it
    Path path1 = Path()..addRRect(outerRRect);
    Path path2 = Path()..addRRect(innerRRect);
    var path = Path.combine(PathOperation.difference, path1, path2);
    canvas.drawPath(path, _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => oldDelegate != this;
}
