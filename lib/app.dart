import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/backup.dart';
import 'data/db.dart';
import 'data/repositories.dart';
import 'domain/content.dart';
import 'domain/models.dart';
import 'presentation/palettes.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/method_screen.dart';
import 'presentation/screens/onboarding_screen.dart';
import 'presentation/screens/summary_screen.dart';
import 'presentation/screens/track_screen.dart';
import 'presentation/screens/workout_screen.dart';
import 'presentation/theme.dart';

/// Renseignés au démarrage via les overrides de [ProviderScope] dans main.dart.
final programProvider = Provider<Program>((ref) => throw UnimplementedError());
final prefsProvider =
    Provider<SharedPreferences>((ref) => throw UnimplementedError());

final dbProvider = Provider<AppDatabase>((ref) => AppDatabase());
final gameRepoProvider =
    Provider<GameRepository>((ref) => GameRepository(ref.watch(dbProvider)));
final workoutServiceProvider =
    Provider<WorkoutService>((ref) => WorkoutService(ref.watch(gameRepoProvider)));
final backupServiceProvider =
    Provider<BackupService>((ref) => BackupService(ref.watch(gameRepoProvider)));

/// Coloris choisi, persisté dans les préférences.
class PaletteController extends Notifier<AppPalette> {
  static const _key = 'palette';

  @override
  AppPalette build() {
    final raw = ref.watch(prefsProvider).getString(_key);
    return AppPalette.values.asNameMap()[raw] ?? AppPalette.turquoise;
  }

  Future<void> select(AppPalette palette) async {
    await ref.read(prefsProvider).setString(_key, palette.name);
    state = palette;
  }
}

final paletteProvider =
    NotifierProvider<PaletteController, AppPalette>(PaletteController.new);

class ProfileController extends Notifier<Profile?> {
  @override
  Profile? build() => ProfileRepository(ref.watch(prefsProvider)).load();

  Future<void> save(Profile profile) async {
    await ProfileRepository(ref.read(prefsProvider)).save(profile);
    state = profile;
  }
}

final profileProvider =
    NotifierProvider<ProfileController, Profile?>(ProfileController.new);

final playerProvider = StreamProvider<PlayerSnapshot>(
    (ref) => ref.watch(gameRepoProvider).watchPlayer());

final progressProvider = StreamProvider<Map<String, GroupProgress>>(
    (ref) => ref.watch(gameRepoProvider).watchProgress());

/// Numéro du jour dans le voyage 365 (jours distincts avec séance).
final dayNumberProvider =
    StreamProvider<int>((ref) => ref.watch(gameRepoProvider).watchDayNumber());

final _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/track/:groupId',
      builder: (context, state) =>
          TrackScreen(groupId: state.pathParameters['groupId']!),
    ),
    GoRoute(path: '/workout', builder: (context, state) => const WorkoutScreen()),
    GoRoute(path: '/method', builder: (context, state) => const MethodScreen()),
    GoRoute(
      path: '/summary',
      builder: (context, state) =>
          SummaryScreen(result: state.extra! as SessionResult),
    ),
  ],
);

class FitnessGameApp extends ConsumerWidget {
  const FitnessGameApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final palette = ref.watch(paletteProvider);
    if (profile == null) {
      return MaterialApp(
        title: '365',
        theme: AppTheme.light(palette),
        darkTheme: AppTheme.dark(palette),
        home: const OnboardingScreen(),
        debugShowCheckedModeBanner: false,
      );
    }
    return MaterialApp.router(
      title: '365',
      theme: AppTheme.light(palette),
      darkTheme: AppTheme.dark(palette),
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
