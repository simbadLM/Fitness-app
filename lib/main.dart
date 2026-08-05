import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'data/repositories.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final program = await ContentRepository.load();
  runApp(ProviderScope(
    overrides: [
      prefsProvider.overrideWithValue(prefs),
      programProvider.overrideWithValue(program),
    ],
    child: const FitnessGameApp(),
  ));
}
