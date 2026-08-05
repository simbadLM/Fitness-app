import 'package:flutter/material.dart';

import '../domain/content.dart';

/// Pictogramme animé : bonhomme vectoriel minimaliste, vue de profil,
/// interpolé entre deux poses clés (aller-retour sinusoïdal).
class AnimatedPictogram extends StatefulWidget {
  const AnimatedPictogram({
    super.key,
    required this.type,
    this.size = 160,
    this.color,
  });

  final PictoType type;
  final double size;
  final Color? color;

  @override
  State<AnimatedPictogram> createState() => _AnimatedPictogramState();
}

class _AnimatedPictogramState extends State<AnimatedPictogram>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.primary;
    return SizedBox.square(
      dimension: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          painter: _StickFigurePainter(
            pose: _Pose.lerp(
              _poses[widget.type]!.$1,
              _poses[widget.type]!.$2,
              Curves.easeInOut.transform(_controller.value),
            ),
            color: color,
            showBar: widget.type == PictoType.pullup,
          ),
        ),
      ),
    );
  }
}

class _Pose {
  const _Pose({
    required this.head,
    required this.neck,
    required this.hip,
    required this.knee,
    required this.foot,
    required this.elbow,
    required this.hand,
  });

  final Offset head;
  final Offset neck;
  final Offset hip;
  final Offset knee;
  final Offset foot;
  final Offset elbow;
  final Offset hand;

  static _Pose lerp(_Pose a, _Pose b, double t) => _Pose(
        head: Offset.lerp(a.head, b.head, t)!,
        neck: Offset.lerp(a.neck, b.neck, t)!,
        hip: Offset.lerp(a.hip, b.hip, t)!,
        knee: Offset.lerp(a.knee, b.knee, t)!,
        foot: Offset.lerp(a.foot, b.foot, t)!,
        elbow: Offset.lerp(a.elbow, b.elbow, t)!,
        hand: Offset.lerp(a.hand, b.hand, t)!,
      );
}

class _StickFigurePainter extends CustomPainter {
  const _StickFigurePainter({
    required this.pose,
    required this.color,
    this.showBar = false,
  });

  final _Pose pose;
  final Color color;
  final bool showBar;

  @override
  void paint(Canvas canvas, Size size) {
    Offset at(Offset unit) => Offset(unit.dx * size.width, unit.dy * size.height);

    final stroke = Paint()
      ..color = color
      ..strokeWidth = size.width * 0.055
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    if (showBar) {
      canvas.drawLine(
        Offset(size.width * 0.2, size.height * 0.1),
        Offset(size.width * 0.85, size.height * 0.1),
        Paint()
          ..color = color.withValues(alpha: 0.35)
          ..strokeWidth = size.width * 0.035
          ..strokeCap = StrokeCap.round,
      );
    }

    // Torse, jambe, bras.
    canvas.drawLine(at(pose.neck), at(pose.hip), stroke);
    canvas.drawPath(
      Path()
        ..moveTo(at(pose.hip).dx, at(pose.hip).dy)
        ..lineTo(at(pose.knee).dx, at(pose.knee).dy)
        ..lineTo(at(pose.foot).dx, at(pose.foot).dy),
      stroke,
    );
    canvas.drawPath(
      Path()
        ..moveTo(at(pose.neck).dx, at(pose.neck).dy)
        ..lineTo(at(pose.elbow).dx, at(pose.elbow).dy)
        ..lineTo(at(pose.hand).dx, at(pose.hand).dy),
      stroke,
    );
    canvas.drawCircle(
      at(pose.head),
      size.width * 0.075,
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_StickFigurePainter oldDelegate) =>
      oldDelegate.pose != pose || oldDelegate.color != color;
}

/// Deux poses clés (départ, fin de mouvement) par famille d'exercice.
/// Coordonnées normalisées dans un carré unitaire, origine en haut à gauche.
final Map<PictoType, (_Pose, _Pose)> _poses = {
  PictoType.pushup: (
    const _Pose(
      head: Offset(0.85, 0.30),
      neck: Offset(0.73, 0.36),
      hip: Offset(0.45, 0.44),
      knee: Offset(0.28, 0.49),
      foot: Offset(0.10, 0.55),
      elbow: Offset(0.70, 0.52),
      hand: Offset(0.68, 0.70),
    ),
    const _Pose(
      head: Offset(0.83, 0.52),
      neck: Offset(0.71, 0.56),
      hip: Offset(0.44, 0.60),
      knee: Offset(0.27, 0.63),
      foot: Offset(0.10, 0.67),
      elbow: Offset(0.58, 0.66),
      hand: Offset(0.68, 0.72),
    ),
  ),
  PictoType.dip: (
    const _Pose(
      head: Offset(0.48, 0.16),
      neck: Offset(0.48, 0.28),
      hip: Offset(0.48, 0.52),
      knee: Offset(0.42, 0.68),
      foot: Offset(0.48, 0.84),
      elbow: Offset(0.62, 0.36),
      hand: Offset(0.64, 0.52),
    ),
    const _Pose(
      head: Offset(0.48, 0.30),
      neck: Offset(0.48, 0.42),
      hip: Offset(0.48, 0.62),
      knee: Offset(0.40, 0.76),
      foot: Offset(0.46, 0.90),
      elbow: Offset(0.66, 0.44),
      hand: Offset(0.64, 0.52),
    ),
  ),
  PictoType.curl: (
    const _Pose(
      head: Offset(0.50, 0.14),
      neck: Offset(0.50, 0.26),
      hip: Offset(0.50, 0.55),
      knee: Offset(0.50, 0.72),
      foot: Offset(0.50, 0.88),
      elbow: Offset(0.58, 0.40),
      hand: Offset(0.60, 0.56),
    ),
    const _Pose(
      head: Offset(0.50, 0.14),
      neck: Offset(0.50, 0.26),
      hip: Offset(0.50, 0.55),
      knee: Offset(0.50, 0.72),
      foot: Offset(0.50, 0.88),
      elbow: Offset(0.58, 0.40),
      hand: Offset(0.63, 0.26),
    ),
  ),
  PictoType.press: (
    const _Pose(
      head: Offset(0.50, 0.18),
      neck: Offset(0.50, 0.30),
      hip: Offset(0.50, 0.57),
      knee: Offset(0.50, 0.73),
      foot: Offset(0.50, 0.88),
      elbow: Offset(0.60, 0.34),
      hand: Offset(0.62, 0.24),
    ),
    const _Pose(
      head: Offset(0.50, 0.18),
      neck: Offset(0.50, 0.30),
      hip: Offset(0.50, 0.57),
      knee: Offset(0.50, 0.73),
      foot: Offset(0.50, 0.88),
      elbow: Offset(0.60, 0.20),
      hand: Offset(0.62, 0.06),
    ),
  ),
  PictoType.squat: (
    const _Pose(
      head: Offset(0.50, 0.12),
      neck: Offset(0.50, 0.24),
      hip: Offset(0.50, 0.52),
      knee: Offset(0.50, 0.70),
      foot: Offset(0.50, 0.88),
      elbow: Offset(0.60, 0.34),
      hand: Offset(0.66, 0.44),
    ),
    const _Pose(
      head: Offset(0.56, 0.32),
      neck: Offset(0.54, 0.42),
      hip: Offset(0.42, 0.64),
      knee: Offset(0.56, 0.73),
      foot: Offset(0.52, 0.88),
      elbow: Offset(0.68, 0.44),
      hand: Offset(0.80, 0.44),
    ),
  ),
  PictoType.lunge: (
    const _Pose(
      head: Offset(0.48, 0.14),
      neck: Offset(0.48, 0.26),
      hip: Offset(0.48, 0.54),
      knee: Offset(0.48, 0.71),
      foot: Offset(0.48, 0.88),
      elbow: Offset(0.56, 0.38),
      hand: Offset(0.58, 0.50),
    ),
    const _Pose(
      head: Offset(0.50, 0.24),
      neck: Offset(0.50, 0.36),
      hip: Offset(0.48, 0.60),
      knee: Offset(0.63, 0.74),
      foot: Offset(0.63, 0.88),
      elbow: Offset(0.58, 0.46),
      hand: Offset(0.60, 0.58),
    ),
  ),
  PictoType.bridge: (
    const _Pose(
      head: Offset(0.14, 0.72),
      neck: Offset(0.25, 0.71),
      hip: Offset(0.50, 0.70),
      knee: Offset(0.64, 0.55),
      foot: Offset(0.74, 0.72),
      elbow: Offset(0.30, 0.76),
      hand: Offset(0.38, 0.78),
    ),
    const _Pose(
      head: Offset(0.14, 0.72),
      neck: Offset(0.25, 0.69),
      hip: Offset(0.52, 0.50),
      knee: Offset(0.64, 0.52),
      foot: Offset(0.74, 0.72),
      elbow: Offset(0.30, 0.76),
      hand: Offset(0.38, 0.78),
    ),
  ),
  PictoType.swing: (
    const _Pose(
      head: Offset(0.40, 0.36),
      neck: Offset(0.45, 0.44),
      hip: Offset(0.60, 0.56),
      knee: Offset(0.55, 0.72),
      foot: Offset(0.50, 0.88),
      elbow: Offset(0.42, 0.56),
      hand: Offset(0.40, 0.70),
    ),
    const _Pose(
      head: Offset(0.52, 0.14),
      neck: Offset(0.52, 0.26),
      hip: Offset(0.54, 0.54),
      knee: Offset(0.52, 0.71),
      foot: Offset(0.50, 0.88),
      elbow: Offset(0.38, 0.28),
      hand: Offset(0.24, 0.28),
    ),
  ),
  PictoType.hinge: (
    const _Pose(
      head: Offset(0.52, 0.16),
      neck: Offset(0.52, 0.28),
      hip: Offset(0.52, 0.55),
      knee: Offset(0.51, 0.72),
      foot: Offset(0.50, 0.88),
      elbow: Offset(0.58, 0.40),
      hand: Offset(0.58, 0.52),
    ),
    const _Pose(
      head: Offset(0.34, 0.36),
      neck: Offset(0.40, 0.42),
      hip: Offset(0.58, 0.55),
      knee: Offset(0.54, 0.72),
      foot: Offset(0.50, 0.88),
      elbow: Offset(0.42, 0.52),
      hand: Offset(0.42, 0.66),
    ),
  ),
  PictoType.plank: (
    const _Pose(
      head: Offset(0.86, 0.48),
      neck: Offset(0.75, 0.52),
      hip: Offset(0.48, 0.56),
      knee: Offset(0.30, 0.59),
      foot: Offset(0.12, 0.62),
      elbow: Offset(0.72, 0.68),
      hand: Offset(0.83, 0.68),
    ),
    const _Pose(
      head: Offset(0.86, 0.46),
      neck: Offset(0.75, 0.50),
      hip: Offset(0.48, 0.53),
      knee: Offset(0.30, 0.57),
      foot: Offset(0.12, 0.61),
      elbow: Offset(0.72, 0.68),
      hand: Offset(0.83, 0.68),
    ),
  ),
  PictoType.crunch: (
    const _Pose(
      head: Offset(0.18, 0.62),
      neck: Offset(0.29, 0.65),
      hip: Offset(0.54, 0.68),
      knee: Offset(0.68, 0.52),
      foot: Offset(0.80, 0.68),
      elbow: Offset(0.32, 0.57),
      hand: Offset(0.40, 0.52),
    ),
    const _Pose(
      head: Offset(0.30, 0.48),
      neck: Offset(0.37, 0.56),
      hip: Offset(0.54, 0.68),
      knee: Offset(0.68, 0.52),
      foot: Offset(0.80, 0.68),
      elbow: Offset(0.40, 0.48),
      hand: Offset(0.48, 0.44),
    ),
  ),
  PictoType.pullup: (
    const _Pose(
      head: Offset(0.50, 0.32),
      neck: Offset(0.50, 0.42),
      hip: Offset(0.50, 0.64),
      knee: Offset(0.47, 0.77),
      foot: Offset(0.50, 0.90),
      elbow: Offset(0.59, 0.28),
      hand: Offset(0.58, 0.12),
    ),
    const _Pose(
      head: Offset(0.50, 0.18),
      neck: Offset(0.50, 0.28),
      hip: Offset(0.50, 0.52),
      knee: Offset(0.44, 0.66),
      foot: Offset(0.48, 0.80),
      elbow: Offset(0.62, 0.22),
      hand: Offset(0.58, 0.12),
    ),
  ),
  PictoType.row: (
    const _Pose(
      head: Offset(0.76, 0.28),
      neck: Offset(0.68, 0.34),
      hip: Offset(0.45, 0.46),
      knee: Offset(0.43, 0.66),
      foot: Offset(0.41, 0.86),
      elbow: Offset(0.62, 0.50),
      hand: Offset(0.64, 0.66),
    ),
    const _Pose(
      head: Offset(0.76, 0.28),
      neck: Offset(0.68, 0.34),
      hip: Offset(0.45, 0.46),
      knee: Offset(0.43, 0.66),
      foot: Offset(0.41, 0.86),
      elbow: Offset(0.58, 0.40),
      hand: Offset(0.62, 0.48),
    ),
  ),
  PictoType.handstand: (
    const _Pose(
      head: Offset(0.50, 0.66),
      neck: Offset(0.50, 0.56),
      hip: Offset(0.50, 0.34),
      knee: Offset(0.50, 0.20),
      foot: Offset(0.50, 0.06),
      elbow: Offset(0.60, 0.70),
      hand: Offset(0.60, 0.86),
    ),
    const _Pose(
      head: Offset(0.50, 0.74),
      neck: Offset(0.50, 0.64),
      hip: Offset(0.50, 0.40),
      knee: Offset(0.50, 0.24),
      foot: Offset(0.50, 0.08),
      elbow: Offset(0.64, 0.76),
      hand: Offset(0.60, 0.86),
    ),
  ),
  PictoType.march: (
    const _Pose(
      head: Offset(0.50, 0.14),
      neck: Offset(0.50, 0.26),
      hip: Offset(0.50, 0.54),
      knee: Offset(0.50, 0.71),
      foot: Offset(0.50, 0.88),
      elbow: Offset(0.58, 0.20),
      hand: Offset(0.56, 0.08),
    ),
    const _Pose(
      head: Offset(0.50, 0.14),
      neck: Offset(0.50, 0.26),
      hip: Offset(0.50, 0.54),
      knee: Offset(0.62, 0.52),
      foot: Offset(0.60, 0.68),
      elbow: Offset(0.58, 0.20),
      hand: Offset(0.56, 0.08),
    ),
  ),
  PictoType.superman: (
    const _Pose(
      head: Offset(0.15, 0.62),
      neck: Offset(0.27, 0.63),
      hip: Offset(0.52, 0.64),
      knee: Offset(0.68, 0.64),
      foot: Offset(0.85, 0.64),
      elbow: Offset(0.19, 0.65),
      hand: Offset(0.08, 0.65),
    ),
    const _Pose(
      head: Offset(0.15, 0.50),
      neck: Offset(0.27, 0.56),
      hip: Offset(0.52, 0.64),
      knee: Offset(0.68, 0.58),
      foot: Offset(0.85, 0.48),
      elbow: Offset(0.18, 0.56),
      hand: Offset(0.07, 0.48),
    ),
  ),
};
