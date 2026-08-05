import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/db.dart';
import 'data/repositories.dart';
import 'domain/content.dart';
import 'domain/models.dart';
import 'presentation/screens/home_screen.dart';
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

final _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/track/:groupId',
      builder: (context, state) =>
          TrackScreen(groupId: state.pathParameters['groupId']!),
    ),
    GoRoute(path: '/workout', builder: (context, state) => const WorkoutScreen()),
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
    if (profile == null) {
      return MaterialApp(
        title: 'Fitness Game',
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        home: const OnboardingScreen(),
        debugShowCheckedModeBanner: false,
      );
    }
    return MaterialApp.router(
      title: 'Fitness Game',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
