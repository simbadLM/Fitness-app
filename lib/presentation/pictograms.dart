import 'package:flutter/material.dart';

import '../domain/content.dart';
import 'theme.dart';

/// Pictogramme animé : silhouette vectorielle vue de profil, deux bras et
/// deux jambes (membres arrière estompés), tête pleine, sol et accessoires
/// (barre, barres parallèles, box, kettlebell). Chaque famille de mouvement
/// est une **animation multi-images** (2 à 3 poses clés) parcourue en
/// aller-retour, avec une durée propre au rythme du mouvement.
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
    duration: _specs[widget.type]!.duration,
  )..repeat(reverse: true);

  @override
  void didUpdateWidget(AnimatedPictogram oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.type != widget.type) {
      _controller.duration = _specs[widget.type]!.duration;
    }
  }

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
            pose: spec.poseAt(
                Curves.easeInOutSine.transform(_controller.value)),
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

  /// Membres arrière ; dérivés du membre avant par un léger décalage si absents.
  final Offset? farKnee;
  final Offset? farFoot;
  final Offset? farElbow;
  final Offset? farHand;

  static Offset? _l(Offset? a, Offset? b, double t) =>
      Offset.lerp(a ?? b, b ?? a, t);

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

/// Animation d'une famille : poses clés + décor + tempo.
class _Spec {
  const _Spec(
    this.frames, {
    this.duration = const Duration(milliseconds: 1200),
    this.ground = true,
    this.groundY = 0.88,
    this.bar = false,
    this.dipBars = false,
    this.box = false,
    this.kettlebell = false,
  });

  final List<_Pose> frames;
  final Duration duration;
  final bool ground;
  final double groundY;
  final bool bar;
  final bool dipBars;
  final bool box;
  final bool kettlebell;

  /// Interpole la pose au temps t ∈ [0,1] à travers les poses clés.
  _Pose poseAt(double t) {
    final segments = frames.length - 1;
    if (segments == 0) return frames.first;
    final position = (t * segments).clamp(0.0, segments.toDouble());
    final index = position.floor().clamp(0, segments - 1);
    return _Pose.lerp(frames[index], frames[index + 1], position - index);
  }
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
      ..color = AppTheme.turquoise.withValues(alpha: 0.9)
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
    if (spec.box) {
      canvas.drawRect(
        Rect.fromLTRB(w * 0.58, size.height * 0.70, w * 0.90,
            size.height * spec.groundY),
        propPaint,
      );
    }

    Path path3(Offset a, Offset b, Offset c) => Path()
      ..moveTo(a.dx, a.dy)
      ..lineTo(b.dx, b.dy)
      ..lineTo(c.dx, c.dy);

    // --- Membres arrière (estompés) ---
    const shift = Offset(0.045, -0.008);
    final farKnee = pose.farKnee ?? pose.knee + shift;
    final farFoot = pose.farFoot ?? pose.foot + shift;
    final farElbow = pose.farElbow ?? pose.elbow + shift;
    final farHand = pose.farHand ?? pose.hand + shift;
    canvas.drawPath(path3(at(pose.hip), at(farKnee), at(farFoot)), farLimb);
    canvas.drawPath(path3(at(pose.neck), at(farElbow), at(farHand)), farLimb);

    // --- Kettlebell dans la main avant ---
    if (spec.kettlebell) {
      final h = at(pose.hand);
      final r = w * 0.055;
      canvas.drawCircle(
          h + Offset(0, r * 1.4), r, Paint()..color = AppTheme.turquoise);
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

/// Poses clés par famille. Coordonnées normalisées, figure vue de profil.
final Map<PictoType, _Spec> _specs = {
  PictoType.pushup: _Spec(
    const [
      _Pose(
        head: Offset(0.87, 0.42),
        neck: Offset(0.75, 0.47),
        hip: Offset(0.46, 0.54),
        knee: Offset(0.29, 0.59),
        foot: Offset(0.11, 0.65),
        elbow: Offset(0.73, 0.63),
        hand: Offset(0.71, 0.83),
      ),
      _Pose(
        head: Offset(0.85, 0.66),
        neck: Offset(0.73, 0.70),
        hip: Offset(0.45, 0.73),
        knee: Offset(0.28, 0.76),
        foot: Offset(0.11, 0.80),
        elbow: Offset(0.58, 0.79),
        hand: Offset(0.71, 0.84),
      ),
    ],
    groundY: 0.86,
  ),
  PictoType.dip: _Spec(
    const [
      _Pose(
        head: Offset(0.50, 0.14),
        neck: Offset(0.50, 0.26),
        hip: Offset(0.50, 0.50),
        knee: Offset(0.44, 0.65),
        foot: Offset(0.49, 0.80),
        elbow: Offset(0.63, 0.36),
        hand: Offset(0.65, 0.50),
      ),
      _Pose(
        head: Offset(0.50, 0.28),
        neck: Offset(0.50, 0.40),
        hip: Offset(0.50, 0.61),
        knee: Offset(0.42, 0.73),
        foot: Offset(0.47, 0.86),
        elbow: Offset(0.68, 0.42),
        hand: Offset(0.65, 0.50),
      ),
    ],
    dipBars: true,
  ),
  PictoType.curl: _Spec(
    const [
      _Pose(
        head: Offset(0.48, 0.14),
        neck: Offset(0.48, 0.26),
        hip: Offset(0.48, 0.55),
        knee: Offset(0.48, 0.72),
        foot: Offset(0.48, 0.88),
        elbow: Offset(0.56, 0.40),
        hand: Offset(0.60, 0.55),
      ),
      _Pose(
        head: Offset(0.48, 0.14),
        neck: Offset(0.48, 0.26),
        hip: Offset(0.48, 0.55),
        knee: Offset(0.48, 0.72),
        foot: Offset(0.48, 0.88),
        elbow: Offset(0.56, 0.40),
        hand: Offset(0.64, 0.27),
      ),
    ],
    kettlebell: true,
    duration: const Duration(milliseconds: 1000),
  ),
  PictoType.press: _Spec(
    const [
      _Pose(
        head: Offset(0.48, 0.20),
        neck: Offset(0.48, 0.32),
        hip: Offset(0.48, 0.58),
        knee: Offset(0.48, 0.74),
        foot: Offset(0.48, 0.88),
        elbow: Offset(0.60, 0.36),
        hand: Offset(0.62, 0.25),
      ),
      _Pose(
        head: Offset(0.48, 0.20),
        neck: Offset(0.48, 0.32),
        hip: Offset(0.48, 0.58),
        knee: Offset(0.48, 0.74),
        foot: Offset(0.48, 0.88),
        elbow: Offset(0.58, 0.20),
        hand: Offset(0.60, 0.07),
      ),
    ],
    kettlebell: true,
  ),
  PictoType.squat: _Spec(
    const [
      _Pose(
        head: Offset(0.50, 0.12),
        neck: Offset(0.50, 0.24),
        hip: Offset(0.49, 0.52),
        knee: Offset(0.51, 0.70),
        foot: Offset(0.50, 0.88),
        elbow: Offset(0.60, 0.34),
        hand: Offset(0.64, 0.45),
      ),
      _Pose(
        head: Offset(0.58, 0.34),
        neck: Offset(0.55, 0.45),
        hip: Offset(0.40, 0.66),
        knee: Offset(0.58, 0.72),
        foot: Offset(0.52, 0.88),
        elbow: Offset(0.70, 0.48),
        hand: Offset(0.82, 0.46),
      ),
    ],
  ),
  // Squat sauté : descente → extension aérienne, pieds décollés.
  PictoType.jumpsquat: _Spec(
    const [
      _Pose(
        head: Offset(0.56, 0.36),
        neck: Offset(0.54, 0.46),
        hip: Offset(0.42, 0.66),
        knee: Offset(0.56, 0.73),
        foot: Offset(0.50, 0.88),
        elbow: Offset(0.66, 0.48),
        hand: Offset(0.76, 0.46),
      ),
      _Pose(
        head: Offset(0.50, 0.05),
        neck: Offset(0.50, 0.16),
        hip: Offset(0.50, 0.42),
        knee: Offset(0.52, 0.57),
        foot: Offset(0.54, 0.70),
        elbow: Offset(0.58, 0.26),
        hand: Offset(0.62, 0.37),
      ),
    ],
    duration: const Duration(milliseconds: 800),
  ),
  // Mollets : extension sur pointes, le corps monte, les talons décollent.
  PictoType.calfraise: _Spec(
    const [
      _Pose(
        head: Offset(0.48, 0.14),
        neck: Offset(0.48, 0.26),
        hip: Offset(0.48, 0.55),
        knee: Offset(0.48, 0.72),
        foot: Offset(0.48, 0.88),
        elbow: Offset(0.55, 0.38),
        hand: Offset(0.53, 0.50),
      ),
      _Pose(
        head: Offset(0.48, 0.09),
        neck: Offset(0.48, 0.21),
        hip: Offset(0.48, 0.50),
        knee: Offset(0.48, 0.67),
        foot: Offset(0.51, 0.87),
        elbow: Offset(0.55, 0.33),
        hand: Offset(0.53, 0.45),
      ),
    ],
    duration: const Duration(milliseconds: 1000),
  ),
  PictoType.lunge: _Spec(
    const [
      _Pose(
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
      _Pose(
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
    ],
  ),
  // Step-up sur box : pied posé → extension complète sur la box.
  PictoType.stepup: _Spec(
    const [
      _Pose(
        head: Offset(0.36, 0.20),
        neck: Offset(0.36, 0.32),
        hip: Offset(0.36, 0.58),
        knee: Offset(0.50, 0.62),
        foot: Offset(0.64, 0.70),
        elbow: Offset(0.42, 0.44),
        hand: Offset(0.44, 0.54),
        farKnee: Offset(0.36, 0.74),
        farFoot: Offset(0.36, 0.88),
      ),
      _Pose(
        head: Offset(0.68, 0.08),
        neck: Offset(0.68, 0.19),
        hip: Offset(0.68, 0.43),
        knee: Offset(0.68, 0.57),
        foot: Offset(0.68, 0.70),
        elbow: Offset(0.74, 0.31),
        hand: Offset(0.76, 0.42),
        farKnee: Offset(0.60, 0.58),
        farFoot: Offset(0.57, 0.74),
      ),
    ],
    box: true,
    duration: const Duration(milliseconds: 1100),
  ),
  PictoType.bridge: _Spec(
    const [
      _Pose(
        head: Offset(0.13, 0.70),
        neck: Offset(0.24, 0.72),
        hip: Offset(0.48, 0.74),
        knee: Offset(0.62, 0.58),
        foot: Offset(0.72, 0.76),
        elbow: Offset(0.30, 0.78),
        hand: Offset(0.38, 0.80),
      ),
      _Pose(
        head: Offset(0.13, 0.70),
        neck: Offset(0.24, 0.70),
        hip: Offset(0.50, 0.52),
        knee: Offset(0.63, 0.54),
        foot: Offset(0.72, 0.76),
        elbow: Offset(0.30, 0.78),
        hand: Offset(0.38, 0.80),
      ),
    ],
    groundY: 0.82,
  ),
  PictoType.swing: _Spec(
    const [
      _Pose(
        head: Offset(0.38, 0.34),
        neck: Offset(0.44, 0.42),
        hip: Offset(0.60, 0.54),
        knee: Offset(0.56, 0.71),
        foot: Offset(0.50, 0.88),
        elbow: Offset(0.44, 0.56),
        hand: Offset(0.44, 0.70),
      ),
      _Pose(
        head: Offset(0.50, 0.13),
        neck: Offset(0.50, 0.25),
        hip: Offset(0.52, 0.53),
        knee: Offset(0.51, 0.71),
        foot: Offset(0.50, 0.88),
        elbow: Offset(0.36, 0.28),
        hand: Offset(0.22, 0.29),
      ),
    ],
    kettlebell: true,
    duration: const Duration(milliseconds: 900),
  ),
  PictoType.hinge: _Spec(
    const [
      _Pose(
        head: Offset(0.50, 0.15),
        neck: Offset(0.50, 0.27),
        hip: Offset(0.50, 0.55),
        knee: Offset(0.50, 0.72),
        foot: Offset(0.49, 0.88),
        elbow: Offset(0.56, 0.40),
        hand: Offset(0.56, 0.53),
      ),
      _Pose(
        head: Offset(0.31, 0.36),
        neck: Offset(0.38, 0.42),
        hip: Offset(0.58, 0.55),
        knee: Offset(0.54, 0.73),
        foot: Offset(0.49, 0.88),
        elbow: Offset(0.40, 0.54),
        hand: Offset(0.40, 0.68),
      ),
    ],
    kettlebell: true,
  ),
  PictoType.plank: _Spec(
    const [
      _Pose(
        head: Offset(0.88, 0.56),
        neck: Offset(0.76, 0.60),
        hip: Offset(0.48, 0.64),
        knee: Offset(0.30, 0.67),
        foot: Offset(0.11, 0.71),
        elbow: Offset(0.74, 0.77),
        hand: Offset(0.86, 0.77),
      ),
      _Pose(
        head: Offset(0.88, 0.54),
        neck: Offset(0.76, 0.58),
        hip: Offset(0.48, 0.61),
        knee: Offset(0.30, 0.65),
        foot: Offset(0.11, 0.70),
        elbow: Offset(0.74, 0.77),
        hand: Offset(0.86, 0.77),
      ),
    ],
    groundY: 0.80,
    duration: const Duration(milliseconds: 1800),
  ),
  // Mountain climbers : planche haute, genoux alternés vers la poitrine.
  PictoType.climber: _Spec(
    const [
      _Pose(
        head: Offset(0.87, 0.42),
        neck: Offset(0.76, 0.46),
        hip: Offset(0.50, 0.52),
        knee: Offset(0.62, 0.62),
        foot: Offset(0.60, 0.74),
        elbow: Offset(0.73, 0.60),
        hand: Offset(0.75, 0.78),
        farKnee: Offset(0.30, 0.58),
        farFoot: Offset(0.12, 0.68),
      ),
      _Pose(
        head: Offset(0.87, 0.42),
        neck: Offset(0.76, 0.46),
        hip: Offset(0.50, 0.52),
        knee: Offset(0.30, 0.58),
        foot: Offset(0.12, 0.70),
        elbow: Offset(0.73, 0.60),
        hand: Offset(0.75, 0.78),
        farKnee: Offset(0.62, 0.62),
        farFoot: Offset(0.60, 0.74),
      ),
    ],
    groundY: 0.82,
    duration: const Duration(milliseconds: 600),
  ),
  PictoType.crunch: _Spec(
    const [
      _Pose(
        head: Offset(0.17, 0.68),
        neck: Offset(0.28, 0.71),
        hip: Offset(0.52, 0.74),
        knee: Offset(0.66, 0.56),
        foot: Offset(0.77, 0.74),
        elbow: Offset(0.30, 0.62),
        hand: Offset(0.38, 0.57),
      ),
      _Pose(
        head: Offset(0.29, 0.52),
        neck: Offset(0.36, 0.60),
        hip: Offset(0.52, 0.74),
        knee: Offset(0.66, 0.56),
        foot: Offset(0.77, 0.74),
        elbow: Offset(0.40, 0.52),
        hand: Offset(0.48, 0.48),
      ),
    ],
    groundY: 0.80,
  ),
  // Dead bug : allongé sur le dos, jambes en table, bras verticaux ;
  // extension simultanée jambe avant + bras arrière opposé.
  PictoType.deadbug: _Spec(
    const [
      _Pose(
        head: Offset(0.13, 0.70),
        neck: Offset(0.24, 0.72),
        hip: Offset(0.50, 0.74),
        knee: Offset(0.54, 0.58),
        foot: Offset(0.66, 0.60),
        elbow: Offset(0.26, 0.62),
        hand: Offset(0.27, 0.50),
        farKnee: Offset(0.58, 0.58),
        farFoot: Offset(0.70, 0.60),
        farElbow: Offset(0.30, 0.62),
        farHand: Offset(0.31, 0.50),
      ),
      _Pose(
        head: Offset(0.13, 0.70),
        neck: Offset(0.24, 0.72),
        hip: Offset(0.50, 0.74),
        knee: Offset(0.66, 0.68),
        foot: Offset(0.83, 0.72),
        elbow: Offset(0.26, 0.62),
        hand: Offset(0.27, 0.50),
        farKnee: Offset(0.58, 0.58),
        farFoot: Offset(0.70, 0.60),
        farElbow: Offset(0.14, 0.64),
        farHand: Offset(0.04, 0.60),
      ),
    ],
    groundY: 0.80,
  ),
  // Relevé de jambes au sol : jambes tendues montent à la verticale.
  PictoType.legraise: _Spec(
    const [
      _Pose(
        head: Offset(0.13, 0.74),
        neck: Offset(0.24, 0.75),
        hip: Offset(0.48, 0.76),
        knee: Offset(0.64, 0.76),
        foot: Offset(0.80, 0.76),
        elbow: Offset(0.32, 0.78),
        hand: Offset(0.40, 0.79),
      ),
      _Pose(
        head: Offset(0.13, 0.74),
        neck: Offset(0.24, 0.75),
        hip: Offset(0.48, 0.76),
        knee: Offset(0.50, 0.58),
        foot: Offset(0.52, 0.42),
        elbow: Offset(0.32, 0.78),
        hand: Offset(0.40, 0.79),
      ),
    ],
    groundY: 0.82,
  ),
  // V-up : allongé bras derrière la tête → fermeture en V mains vers pieds.
  PictoType.vup: _Spec(
    const [
      _Pose(
        head: Offset(0.16, 0.72),
        neck: Offset(0.27, 0.73),
        hip: Offset(0.50, 0.74),
        knee: Offset(0.66, 0.74),
        foot: Offset(0.82, 0.74),
        elbow: Offset(0.16, 0.75),
        hand: Offset(0.06, 0.74),
      ),
      _Pose(
        head: Offset(0.30, 0.42),
        neck: Offset(0.36, 0.52),
        hip: Offset(0.52, 0.72),
        knee: Offset(0.62, 0.56),
        foot: Offset(0.70, 0.44),
        elbow: Offset(0.46, 0.52),
        hand: Offset(0.58, 0.48),
      ),
    ],
    groundY: 0.80,
  ),
  // Russian twist : assis en V, buste incliné, les mains balaient
  // de devant les genoux jusqu'au sol derrière la hanche.
  PictoType.twist: _Spec(
    const [
      _Pose(
        head: Offset(0.33, 0.42),
        neck: Offset(0.38, 0.51),
        hip: Offset(0.50, 0.70),
        knee: Offset(0.63, 0.58),
        foot: Offset(0.72, 0.66),
        elbow: Offset(0.48, 0.54),
        hand: Offset(0.58, 0.56),
      ),
      _Pose(
        head: Offset(0.33, 0.42),
        neck: Offset(0.38, 0.51),
        hip: Offset(0.50, 0.70),
        knee: Offset(0.63, 0.58),
        foot: Offset(0.72, 0.66),
        elbow: Offset(0.38, 0.60),
        hand: Offset(0.32, 0.68),
      ),
    ],
    groundY: 0.76,
    duration: const Duration(milliseconds: 800),
  ),
  // Sit-up + press : allongé → assis → kettlebell pressée au-dessus de la tête.
  PictoType.situp: _Spec(
    const [
      _Pose(
        head: Offset(0.14, 0.72),
        neck: Offset(0.25, 0.73),
        hip: Offset(0.50, 0.75),
        knee: Offset(0.62, 0.62),
        foot: Offset(0.70, 0.74),
        elbow: Offset(0.30, 0.62),
        hand: Offset(0.32, 0.53),
      ),
      _Pose(
        head: Offset(0.36, 0.42),
        neck: Offset(0.40, 0.51),
        hip: Offset(0.50, 0.74),
        knee: Offset(0.62, 0.62),
        foot: Offset(0.70, 0.74),
        elbow: Offset(0.46, 0.58),
        hand: Offset(0.50, 0.50),
      ),
      _Pose(
        head: Offset(0.36, 0.42),
        neck: Offset(0.40, 0.50),
        hip: Offset(0.50, 0.74),
        knee: Offset(0.62, 0.62),
        foot: Offset(0.70, 0.74),
        elbow: Offset(0.44, 0.38),
        hand: Offset(0.44, 0.26),
      ),
    ],
    kettlebell: true,
    groundY: 0.80,
    duration: const Duration(milliseconds: 1600),
  ),
  PictoType.pullup: _Spec(
    const [
      _Pose(
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
      _Pose(
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
    ],
    bar: true,
    ground: false,
  ),
  // Relevés de genoux/jambes suspendu : bras tendus fixes, genoux montent.
  PictoType.hangraise: _Spec(
    const [
      _Pose(
        head: Offset(0.50, 0.30),
        neck: Offset(0.50, 0.40),
        hip: Offset(0.50, 0.62),
        knee: Offset(0.49, 0.75),
        foot: Offset(0.50, 0.87),
        elbow: Offset(0.57, 0.26),
        hand: Offset(0.57, 0.12),
        farElbow: Offset(0.43, 0.26),
        farHand: Offset(0.43, 0.12),
      ),
      _Pose(
        head: Offset(0.50, 0.30),
        neck: Offset(0.50, 0.40),
        hip: Offset(0.49, 0.61),
        knee: Offset(0.63, 0.60),
        foot: Offset(0.61, 0.74),
        elbow: Offset(0.57, 0.26),
        hand: Offset(0.57, 0.12),
        farElbow: Offset(0.43, 0.26),
        farHand: Offset(0.43, 0.12),
      ),
    ],
    bar: true,
    ground: false,
  ),
  PictoType.row: _Spec(
    const [
      _Pose(
        head: Offset(0.78, 0.32),
        neck: Offset(0.70, 0.37),
        hip: Offset(0.46, 0.48),
        knee: Offset(0.44, 0.67),
        foot: Offset(0.42, 0.86),
        elbow: Offset(0.64, 0.52),
        hand: Offset(0.66, 0.68),
      ),
      _Pose(
        head: Offset(0.78, 0.32),
        neck: Offset(0.70, 0.37),
        hip: Offset(0.46, 0.48),
        knee: Offset(0.44, 0.67),
        foot: Offset(0.42, 0.86),
        elbow: Offset(0.60, 0.40),
        hand: Offset(0.64, 0.48),
      ),
    ],
    kettlebell: true,
    groundY: 0.86,
  ),
  PictoType.handstand: _Spec(
    const [
      _Pose(
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
      _Pose(
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
    ],
    groundY: 0.86,
  ),
  PictoType.march: _Spec(
    const [
      _Pose(
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
      _Pose(
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
    ],
    kettlebell: true,
    duration: const Duration(milliseconds: 800),
  ),
  PictoType.superman: _Spec(
    const [
      _Pose(
        head: Offset(0.14, 0.68),
        neck: Offset(0.26, 0.70),
        hip: Offset(0.52, 0.71),
        knee: Offset(0.68, 0.71),
        foot: Offset(0.85, 0.71),
        elbow: Offset(0.18, 0.72),
        hand: Offset(0.07, 0.72),
      ),
      _Pose(
        head: Offset(0.14, 0.55),
        neck: Offset(0.26, 0.61),
        hip: Offset(0.52, 0.70),
        knee: Offset(0.68, 0.64),
        foot: Offset(0.85, 0.54),
        elbow: Offset(0.17, 0.61),
        hand: Offset(0.06, 0.53),
      ),
    ],
    groundY: 0.78,
  ),
};
