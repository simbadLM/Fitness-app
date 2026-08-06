// Outil de prévisualisation (pas un test de CI) : rend chaque pictogramme en
// PNG pour contrôle visuel. Lancer avec :
//   flutter test test/render_pictograms_preview.dart --dart-define=render=1
import 'dart:io';
import 'dart:ui' as ui;

import 'package:fitness_game/domain/content.dart';
import 'package:fitness_game/presentation/pictograms.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const enabled = String.fromEnvironment('render') == '1';

  testWidgets('rendu des pictogrammes', (tester) async {
    if (!enabled) return;
    await tester.binding.setSurfaceSize(const Size(1000, 1000));
    tester.view.physicalSize = const Size(1000, 1000);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xFFFDFBF5),
        body: RepaintBoundary(
          key: const Key('grid'),
          child: GridView.count(
            crossAxisCount: 4,
            children: [
              for (final t in PictoType.values)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedPictogram(
                        type: t, size: 170, color: const Color(0xFF121830)),
                    Text(t.name, style: const TextStyle(fontSize: 14)),
                  ],
                ),
            ],
          ),
        ),
      ),
    ));
    // Avance l'animation à mi-course pour une pose intermédiaire parlante.
    await tester.pump(const Duration(milliseconds: 650));

    final boundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(const Key('grid')));
    await tester.runAsync(() async {
      final image = await boundary.toImage();
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      File('build/pictograms_preview.png')
          .writeAsBytesSync(bytes!.buffer.asUint8List());
    });
  });
}
