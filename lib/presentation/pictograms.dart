import 'package:flutter/material.dart';

import '../domain/content.dart';
import 'theme.dart';

/// Pictogramme animé : silhouette vectorielle vue de profil, deux bras et
/// deux jambes (membres arrière estompés pour la profondeur), tête pleine,
/// sol et accessoires dessinés (barre, barres parallèles, chaise, kettlebell).
/// Interpolation sinusoïdale entre deux poses clés.
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
    duration: const Duration(milliseconds: 1300),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.onSurface;
    final spec = _specs[widget.type]!;
    return SizedBox.square(
      dimension: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          painter: _FigurePainter(
            pose: _Pose.lerp(
              spec.a,
              spec.b,
              Curves.easeInOutSine.transform(_controller.value),
            ),
            spec: spec,
            color: color,
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
    this.farKnee,
    this.farFoot,
    this.farElbow,
    this.farHand,
  });

  final Offset head;
  final Offset neck;
  final Offset hip;
  final Offset knee;
  final Offset foot;
  final Offset elbow;
  final Offset hand;

  /// Membres arrière ; s'ils sont absents, ils sont dérivés du membre avant
  /// par un léger décalage (parallaxe).
  final Offset? farKnee;
  final Offset? farFoot;
  final Offset? farElbow;
  final Offset? farHand;

  static Offset? _l(Offset? a, Offset? b, double t) =>
      a == null || b == null ? null : Offset.lerp(a, b, t);

  static _Pose lerp(_Pose a, _Pose b, double t) => _Pose(
        head: Offset.lerp(a.head, b.head, t)!,
        neck: Offset.lerp(a.neck, b.neck, t)!,
        hip: Offset.lerp(a.hip, b.hip, t)!,
        knee: Offset.lerp(a.knee, b.knee, t)!,
        foot: Offset.lerp(a.foot, b.foot, t)!,
        elbow: Offset.lerp(a.elbow, b.elbow, t)!,
        hand: Offset.lerp(a.hand, b.hand, t)!,
        farKnee: _l(a.farKnee, b.farKnee, t),
        farFoot: _l(a.farFoot, b.farFoot, t),
        farElbow: _l(a.farElbow, b.farElbow, t),
        farHand: _l(a.farHand, b.farHand, t),
      );
}

/// Décor d'une famille de mouvement.
class _Spec {
  const _Spec(
    this.a,
    this.b, {
    this.ground = true,
    this.groundY = 0.88,
    this.bar = false,
    this.dipBars = false,
    this.kettlebell = false,
  });

  final _Pose a;
  final _Pose b;
  final bool ground;
  final double groundY;
  final bool bar;
  final bool dipBars;
  final bool kettlebell;
}

class _FigurePainter extends CustomPainter {
  const _FigurePainter({
    required this.pose,
    required this.spec,
    required this.color,
  });

  final _Pose pose;
  final _Spec spec;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    Offset at(Offset u) => Offset(u.dx * size.width, u.dy * size.height);
    final w = size.width;

    final limb = Paint()
      ..color = color
      ..strokeWidth = w * 0.062
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    final farLimb = Paint()
      ..color = color.withValues(alpha: 0.38)
      ..strokeWidth = w * 0.052
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    final propPaint = Paint()
      ..color = AppTheme.or.withValues(alpha: 0.9)
      ..strokeWidth = w * 0.028
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final groundPaint = Paint()
      ..color = color.withValues(alpha: 0.25)
      ..strokeWidth = w * 0.022
      ..strokeCap = StrokeCap.round;

    // --- Décor ---
    if (spec.ground) {
      canvas.drawLine(Offset(w * 0.06, size.height * spec.groundY),
          Offset(w * 0.94, size.height * spec.groundY), groundPaint);
    }
    if (spec.bar) {
      final y = size.height * 0.10;
      canvas.drawLine(Offset(w * 0.18, y), Offset(w * 0.82, y), propPaint);
      canvas.drawLine(Offset(w * 0.18, y), Offset(w * 0.18, y + w * 0.06), propPaint);
      canvas.drawLine(Offset(w * 0.82, y), Offset(w * 0.82, y + w * 0.06), propPaint);
    }
    if (spec.dipBars) {
      final y = at(pose.hand).dy;
      canvas.drawLine(Offset(w * 0.14, y), Offset(w * 0.38, y), propPaint);
      canvas.drawLine(Offset(w * 0.62, y), Offset(w * 0.86, y), propPaint);
      canvas.drawLine(Offset(w * 0.20, y), Offset(w * 0.20, size.height * spec.groundY), propPaint);
      canvas.drawLine(Offset(w * 0.80, y), Offset(w * 0.80, size.height * spec.groundY), propPaint);
    }

    Path path3(Offset a, Offset b, Offset c) => Path()
      ..moveTo(a.dx, a.dy)
      ..lineTo(b.dx, b.dy)
      ..lineTo(c.dx, c.dy);

    // --- Membres arrière (dessinés d'abord, estompés) ---
    const shift = Offset(0.045, -0.008);
    final farKnee = pose.farKnee ?? pose.knee + shift;
    final farFoot = pose.farFoot ?? pose.foot + shift;
    final farElbow = pose.farElbow ?? pose.elbow + shift;
    final farHand = pose.farHand ?? pose.hand + shift;
    canvas.drawPath(path3(at(pose.hip), at(farKnee), at(farFoot)), farLimb);
    canvas.drawPath(path3(at(pose.neck), at(farElbow), at(farHand)), farLimb);

    // --- Kettlebell dans la main arrière/avant ---
    if (spec.kettlebell) {
      final h = at(pose.hand);
      final r = w * 0.055;
      canvas.drawCircle(h + Offset(0, r * 1.4), r, Paint()..color = AppTheme.or);
      canvas.drawArc(
          Rect.fromCircle(center: h + Offset(0, r * 0.4), radius: r * 0.55),
          3.14, 3.14, false, propPaint);
    }

    // --- Corps avant ---
    canvas.drawLine(at(pose.neck), at(pose.hip), limb);
    canvas.drawPath(path3(at(pose.hip), at(pose.knee), at(pose.foot)), limb);
    canvas.drawPath(path3(at(pose.neck), at(pose.elbow), at(pose.hand)), limb);
    canvas.drawCircle(at(pose.head), w * 0.082, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_FigurePainter oldDelegate) =>
      oldDelegate.pose != pose || oldDelegate.color != color;
}

/// Poses clés par famille. Coordonnées normalisées (origine en haut à gauche),
/// figure vue de profil, orientée vers la droite quand le mouvement le permet.
final Map<PictoType, _Spec> _specs = {
  PictoType.pushup: _Spec(
    const _Pose(
      head: Offset(0.87, 0.42),
      neck: Offset(0.75, 0.47),
      hip: Offset(0.46, 0.54),
      knee: Offset(0.29, 0.59),
      foot: Offset(0.11, 0.65),
      elbow: Offset(0.73, 0.63),
      hand: Offset(0.71, 0.83),
    ),
    const _Pose(
      head: Offset(0.85, 0.66),
      neck: Offset(0.73, 0.70),
      hip: Offset(0.45, 0.73),
      knee: Offset(0.28, 0.76),
      foot: Offset(0.11, 0.80),
      elbow: Offset(0.58, 0.79),
      hand: Offset(0.71, 0.84),
    ),
    groundY: 0.86,
  ),
  PictoType.dip: _Spec(
    const _Pose(
      head: Offset(0.50, 0.14),
      neck: Offset(0.50, 0.26),
      hip: Offset(0.50, 0.50),
      knee: Offset(0.44, 0.65),
      foot: Offset(0.49, 0.80),
      elbow: Offset(0.63, 0.36),
      hand: Offset(0.65, 0.50),
    ),
    const _Pose(
      head: Offset(0.50, 0.28),
      neck: Offset(0.50, 0.40),
      hip: Offset(0.50, 0.61),
      knee: Offset(0.42, 0.73),
      foot: Offset(0.47, 0.86),
      elbow: Offset(0.68, 0.42),
      hand: Offset(0.65, 0.50),
    ),
    dipBars: true,
    ground: true,
  ),
  PictoType.curl: _Spec(
    const _Pose(
      head: Offset(0.48, 0.14),
      neck: Offset(0.48, 0.26),
      hip: Offset(0.48, 0.55),
      knee: Offset(0.48, 0.72),
      foot: Offset(0.48, 0.88),
      elbow: Offset(0.56, 0.40),
      hand: Offset(0.60, 0.55),
    ),
    const _Pose(
      head: Offset(0.48, 0.14),
      neck: Offset(0.48, 0.26),
      hip: Offset(0.48, 0.55),
      knee: Offset(0.48, 0.72),
      foot: Offset(0.48, 0.88),
      elbow: Offset(0.56, 0.40),
      hand: Offset(0.64, 0.27),
    ),
    kettlebell: true,
  ),
  PictoType.press: _Spec(
    const _Pose(
      head: Offset(0.48, 0.20),
      neck: Offset(0.48, 0.32),
      hip: Offset(0.48, 0.58),
      knee: Offset(0.48, 0.74),
      foot: Offset(0.48, 0.88),
      elbow: Offset(0.60, 0.36),
      hand: Offset(0.62, 0.25),
    ),
    const _Pose(
      head: Offset(0.48, 0.20),
      neck: Offset(0.48, 0.32),
      hip: Offset(0.48, 0.58),
      knee: Offset(0.48, 0.74),
      foot: Offset(0.48, 0.88),
      elbow: Offset(0.58, 0.20),
      hand: Offset(0.60, 0.07),
    ),
    kettlebell: true,
  ),
  PictoType.squat: _Spec(
    const _Pose(
      head: Offset(0.50, 0.12),
      neck: Offset(0.50, 0.24),
      hip: Offset(0.49, 0.52),
      knee: Offset(0.51, 0.70),
      foot: Offset(0.50, 0.88),
      elbow: Offset(0.60, 0.34),
      hand: Offset(0.64, 0.45),
    ),
    const _Pose(
      head: Offset(0.58, 0.34),
      neck: Offset(0.55, 0.45),
      hip: Offset(0.40, 0.66),
      knee: Offset(0.58, 0.72),
      foot: Offset(0.52, 0.88),
      elbow: Offset(0.70, 0.48),
      hand: Offset(0.82, 0.46),
    ),
  ),
  PictoType.lunge: _Spec(
    const _Pose(
      head: Offset(0.46, 0.14),
      neck: Offset(0.46, 0.26),
      hip: Offset(0.46, 0.54),
      knee: Offset(0.46, 0.71),
      foot: Offset(0.46, 0.88),
      elbow: Offset(0.54, 0.38),
      hand: Offset(0.56, 0.50),
      farKnee: Offset(0.50, 0.71),
      farFoot: Offset(0.50, 0.88),
    ),
    const _Pose(
      head: Offset(0.50, 0.26),
      neck: Offset(0.50, 0.38),
      hip: Offset(0.48, 0.62),
      knee: Offset(0.64, 0.75),
      foot: Offset(0.64, 0.88),
      elbow: Offset(0.58, 0.48),
      hand: Offset(0.60, 0.60),
      farKnee: Offset(0.34, 0.82),
      farFoot: Offset(0.26, 0.88),
    ),
  ),
  PictoType.bridge: _Spec(
    const _Pose(
      head: Offset(0.13, 0.70),
      neck: Offset(0.24, 0.72),
      hip: Offset(0.48, 0.74),
      knee: Offset(0.62, 0.58),
      foot: Offset(0.72, 0.76),
      elbow: Offset(0.30, 0.78),
      hand: Offset(0.38, 0.80),
    ),
    const _Pose(
      head: Offset(0.13, 0.70),
      neck: Offset(0.24, 0.70),
      hip: Offset(0.50, 0.52),
      knee: Offset(0.63, 0.54),
      foot: Offset(0.72, 0.76),
      elbow: Offset(0.30, 0.78),
      hand: Offset(0.38, 0.80),
    ),
    groundY: 0.82,
  ),
  PictoType.swing: _Spec(
    const _Pose(
      head: Offset(0.38, 0.34),
      neck: Offset(0.44, 0.42),
      hip: Offset(0.60, 0.54),
      knee: Offset(0.56, 0.71),
      foot: Offset(0.50, 0.88),
      elbow: Offset(0.44, 0.56),
      hand: Offset(0.44, 0.70),
    ),
    const _Pose(
      head: Offset(0.50, 0.13),
      neck: Offset(0.50, 0.25),
      hip: Offset(0.52, 0.53),
      knee: Offset(0.51, 0.71),
      foot: Offset(0.50, 0.88),
      elbow: Offset(0.36, 0.28),
      hand: Offset(0.22, 0.29),
    ),
    kettlebell: true,
  ),
  PictoType.hinge: _Spec(
    const _Pose(
      head: Offset(0.50, 0.15),
      neck: Offset(0.50, 0.27),
      hip: Offset(0.50, 0.55),
      knee: Offset(0.50, 0.72),
      foot: Offset(0.49, 0.88),
      elbow: Offset(0.56, 0.40),
      hand: Offset(0.56, 0.53),
    ),
    const _Pose(
      head: Offset(0.31, 0.36),
      neck: Offset(0.38, 0.42),
      hip: Offset(0.58, 0.55),
      knee: Offset(0.54, 0.73),
      foot: Offset(0.49, 0.88),
      elbow: Offset(0.40, 0.54),
      hand: Offset(0.40, 0.68),
    ),
    kettlebell: true,
  ),
  PictoType.plank: _Spec(
    const _Pose(
      head: Offset(0.88, 0.56),
      neck: Offset(0.76, 0.60),
      hip: Offset(0.48, 0.64),
      knee: Offset(0.30, 0.67),
      foot: Offset(0.11, 0.71),
      elbow: Offset(0.74, 0.77),
      hand: Offset(0.86, 0.77),
    ),
    const _Pose(
      head: Offset(0.88, 0.54),
      neck: Offset(0.76, 0.58),
      hip: Offset(0.48, 0.61),
      knee: Offset(0.30, 0.65),
      foot: Offset(0.11, 0.70),
      elbow: Offset(0.74, 0.77),
      hand: Offset(0.86, 0.77),
    ),
    groundY: 0.80,
  ),
  PictoType.crunch: _Spec(
    const _Pose(
      head: Offset(0.17, 0.68),
      neck: Offset(0.28, 0.71),
      hip: Offset(0.52, 0.74),
      knee: Offset(0.66, 0.56),
      foot: Offset(0.77, 0.74),
      elbow: Offset(0.30, 0.62),
      hand: Offset(0.38, 0.57),
    ),
    const _Pose(
      head: Offset(0.29, 0.52),
      neck: Offset(0.36, 0.60),
      hip: Offset(0.52, 0.74),
      knee: Offset(0.66, 0.56),
      foot: Offset(0.77, 0.74),
      elbow: Offset(0.40, 0.52),
      hand: Offset(0.48, 0.48),
    ),
    groundY: 0.80,
  ),
  PictoType.pullup: _Spec(
    const _Pose(
      head: Offset(0.50, 0.34),
      neck: Offset(0.50, 0.44),
      hip: Offset(0.50, 0.64),
      knee: Offset(0.46, 0.76),
      foot: Offset(0.49, 0.88),
      elbow: Offset(0.59, 0.28),
      hand: Offset(0.58, 0.12),
      farElbow: Offset(0.41, 0.28),
      farHand: Offset(0.42, 0.12),
    ),
    const _Pose(
      head: Offset(0.50, 0.17),
      neck: Offset(0.50, 0.27),
      hip: Offset(0.50, 0.49),
      knee: Offset(0.43, 0.62),
      foot: Offset(0.47, 0.75),
      elbow: Offset(0.62, 0.20),
      hand: Offset(0.58, 0.12),
      farElbow: Offset(0.38, 0.20),
      farHand: Offset(0.42, 0.12),
    ),
    bar: true,
    ground: false,
  ),
  PictoType.row: _Spec(
    const _Pose(
      head: Offset(0.78, 0.32),
      neck: Offset(0.70, 0.37),
      hip: Offset(0.46, 0.48),
      knee: Offset(0.44, 0.67),
      foot: Offset(0.42, 0.86),
      elbow: Offset(0.64, 0.52),
      hand: Offset(0.66, 0.68),
    ),
    const _Pose(
      head: Offset(0.78, 0.32),
      neck: Offset(0.70, 0.37),
      hip: Offset(0.46, 0.48),
      knee: Offset(0.44, 0.67),
      foot: Offset(0.42, 0.86),
      elbow: Offset(0.60, 0.40),
      hand: Offset(0.64, 0.48),
    ),
    kettlebell: true,
    groundY: 0.86,
  ),
  PictoType.handstand: _Spec(
    const _Pose(
      head: Offset(0.50, 0.62),
      neck: Offset(0.50, 0.52),
      hip: Offset(0.50, 0.32),
      knee: Offset(0.51, 0.19),
      foot: Offset(0.50, 0.06),
      elbow: Offset(0.60, 0.68),
      hand: Offset(0.60, 0.84),
      farElbow: Offset(0.40, 0.68),
      farHand: Offset(0.40, 0.84),
    ),
    const _Pose(
      head: Offset(0.50, 0.72),
      neck: Offset(0.50, 0.62),
      hip: Offset(0.50, 0.40),
      knee: Offset(0.51, 0.25),
      foot: Offset(0.50, 0.10),
      elbow: Offset(0.64, 0.74),
      hand: Offset(0.60, 0.84),
      farElbow: Offset(0.36, 0.74),
      farHand: Offset(0.40, 0.84),
    ),
    groundY: 0.86,
  ),
  PictoType.march: _Spec(
    const _Pose(
      head: Offset(0.48, 0.13),
      neck: Offset(0.48, 0.25),
      hip: Offset(0.48, 0.53),
      knee: Offset(0.48, 0.71),
      foot: Offset(0.48, 0.88),
      elbow: Offset(0.56, 0.19),
      hand: Offset(0.54, 0.07),
      farKnee: Offset(0.52, 0.71),
      farFoot: Offset(0.52, 0.88),
    ),
    const _Pose(
      head: Offset(0.48, 0.13),
      neck: Offset(0.48, 0.25),
      hip: Offset(0.48, 0.53),
      knee: Offset(0.62, 0.52),
      foot: Offset(0.60, 0.68),
      elbow: Offset(0.56, 0.19),
      hand: Offset(0.54, 0.07),
      farKnee: Offset(0.50, 0.71),
      farFoot: Offset(0.50, 0.88),
    ),
    kettlebell: true,
  ),
  PictoType.superman: _Spec(
    const _Pose(
      head: Offset(0.14, 0.68),
      neck: Offset(0.26, 0.70),
      hip: Offset(0.52, 0.71),
      knee: Offset(0.68, 0.71),
      foot: Offset(0.85, 0.71),
      elbow: Offset(0.18, 0.72),
      hand: Offset(0.07, 0.72),
    ),
    const _Pose(
      head: Offset(0.14, 0.55),
      neck: Offset(0.26, 0.61),
      hip: Offset(0.52, 0.70),
      knee: Offset(0.68, 0.64),
      foot: Offset(0.85, 0.54),
      elbow: Offset(0.17, 0.61),
      hand: Offset(0.06, 0.53),
    ),
    groundY: 0.78,
  ),
};
