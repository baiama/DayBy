import 'dart:math' as math;

import 'package:flutter/material.dart';

/// The lotus mark from the Figma «иконка» frame, rebuilt from its petal
/// geometry so it stays crisp at any size.
class DayByLogo extends StatelessWidget {
  const DayByLogo({super.key, this.width = 213, this.color});

  final double width;

  /// Solid fill (as on the registration screen). Null uses the gradient petals.
  final Color? color;

  static const _frame = Size(212.88, 198);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: width * _frame.height / _frame.width,
      child: FittedBox(
        child: SizedBox.fromSize(
          size: _frame,
          child: Stack(
            clipBehavior: Clip.none,
            children: [for (final p in _petals) _buildPetal(p)],
          ),
        ),
      ),
    );
  }

  Widget _buildPetal(_Petal p) {
    final angle = p.gradientDeg * math.pi / 180;
    final dir = Alignment(math.sin(angle), -math.cos(angle));
    final decoration = BoxDecoration(
      color: color,
      gradient: color != null
          ? null
          : LinearGradient(
              begin: -dir,
              end: dir,
              stops: p.reversed ? const [0.003, 1] : const [0.139, 0.908],
              colors: p.reversed
                  ? const [Color(0xFFFFE9DB), Color(0xFFDC837F)]
                  : const [Color(0xFFDC837F), Color(0xFFFFE9DB)],
            ),
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(p.radius),
        topRight: Radius.circular(p.radius),
      ),
    );
    final transform = Matrix4.rotationZ(p.rotationDeg * math.pi / 180);
    if (p.flipY) transform.multiply(Matrix4.diagonal3Values(1, -1, 1));
    return Positioned(
      left: p.box.left,
      top: p.box.top,
      width: p.box.width,
      height: p.box.height,
      child: OverflowBox(
        maxWidth: double.infinity,
        maxHeight: double.infinity,
        child: Transform(
          alignment: Alignment.center,
          transform: transform,
          child: Container(
            width: p.size.width,
            height: p.size.height,
            decoration: decoration,
          ),
        ),
      ),
    );
  }
}

class _Petal {
  const _Petal(this.box, this.size, this.rotationDeg, this.gradientDeg,
      {this.flipY = false, this.radius = 290, this.reversed = false});

  final Rect box;
  final Size size;
  final double rotationDeg;
  final double gradientDeg;
  final bool flipY;
  final double radius;
  final bool reversed;
}

const _petals = <_Petal>[
  _Petal(Rect.fromLTWH(2.96, 30.4, 135.26, 115.13), Size(116.67, 68.96), 27.54,
      106.63),
  _Petal(Rect.fromLTWH(74.6, 30.4, 135.26, 115.13), Size(116.67, 68.96), 152.46,
      106.63,
      flipY: true),
  _Petal(Rect.fromLTWH(30.19, 0, 145.3, 145.53), Size(102.75, 103.07), -137.3,
      107.34,
      radius: 328, reversed: true),
  _Petal(Rect.fromLTWH(0, 94.92, 106.44, 50.61), Size(106.44, 50.61), 0, 110.37),
  _Petal(Rect.fromLTWH(106.44, 94.92, 106.44, 50.61), Size(106.44, 50.61), 180,
      110.37,
      flipY: true),
  _Petal(Rect.fromLTWH(27.58, 127.55, 78.77, 70.45), Size(54.46, 66.56), -74.35,
      98.22),
  _Petal(Rect.fromLTWH(106.44, 127.55, 78.77, 70.45), Size(54.46, 66.56),
      -105.65, 98.22,
      flipY: true),
  _Petal(Rect.fromLTWH(86.63, 145.35, 39.06, 39.67), Size(25.74, 30.16), -39.93,
      98.57,
      flipY: true, radius: 433),
];
