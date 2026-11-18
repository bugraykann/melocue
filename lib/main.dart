import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:melocue/l10n/app_localizations.dart';
import 'package:melocue/core/network/dio_client.dart';
import 'package:melocue/core/router/app_router.dart';
import 'package:melocue/core/theme/app_theme.dart';
import 'package:melocue/core/services/location_service.dart';
import 'package:melocue/features/game/data/datasources/itunes_remote_data_source.dart';
import 'package:melocue/features/game/data/datasources/local_storage_service.dart';
import 'package:melocue/features/game/data/repositories/game_repository_impl.dart';
import 'package:melocue/features/game/data/services/audio_player_service_impl.dart';
import 'package:melocue/features/game/domain/repositories/game_repository.dart';
import 'package:melocue/features/game/domain/services/audio_player_service.dart';
import 'package:melocue/features/game/presentation/bloc/game_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

import 'package:melocue/features/game/domain/repositories/leaderboard_repository.dart';
import 'package:melocue/features/game/data/repositories/firebase_leaderboard_repository_impl.dart';
import 'package:melocue/features/game/presentation/bloc/ranks/ranks_bloc.dart';
import 'package:melocue/features/game/presentation/bloc/ranks/ranks_event.dart';
import 'package:melocue/features/game/presentation/bloc/emoji_game/emoji_game_bloc.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:melocue/core/services/ad_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await MobileAds.instance.initialize();
  final prefs = await SharedPreferences.getInstance();

  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  const MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<DioClient>(create: (_) => DioClient()),
        RepositoryProvider<LocalStorageService>(
          create: (_) => LocalStorageService(prefs),
        ),
        RepositoryProvider<ItunesRemoteDataSource>(
          create: (context) => ItunesRemoteDataSourceImpl(
            context.read<DioClient>(),
            context.read<LocalStorageService>(),
          ),
        ),
        RepositoryProvider<GameRepository>(
          create: (context) =>
              GameRepositoryImpl(context.read<ItunesRemoteDataSource>()),
        ),
        RepositoryProvider<AudioPlayerService>(
          create: (_) => AudioPlayerServiceImpl(),
        ),
        RepositoryProvider<LocationService>(
          create: (context) =>
              LocationService(context.read<LocalStorageService>()),
        ),
        RepositoryProvider<LeaderboardRepository>(
          create: (_) => FirebaseLeaderboardRepositoryImpl(),
        ),
        RepositoryProvider<AdService>(
          create: (_) => AdService()
            ..createInterstitialAd()
            ..createRewardedAd(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<GameBloc>(
            create: (context) => GameBloc(
              gameRepository: context.read<GameRepository>(),
              leaderboardRepository: context.read<LeaderboardRepository>(),
              audioPlayerService: context.read<AudioPlayerService>(),
              localStorageService: context.read<LocalStorageService>(),
            ),
          ),
          BlocProvider<RanksBloc>(
            create: (context) => RanksBloc(
              leaderboardRepository: context.read<LeaderboardRepository>(),
            )..add(const LoadLeaderboard()),
          ),
          BlocProvider<EmojiGameBloc>(
            create: (context) => EmojiGameBloc(
              localStorageService: context.read<LocalStorageService>(),
              gameRepository: context.read<GameRepository>(),
            ),
          ),
        ],
        child: Builder(
          builder: (context) {
            return ValueListenableBuilder<Locale>(
              valueListenable: context
                  .read<LocalStorageService>()
                  .localeNotifier,
              builder: (context, locale, child) {
                return MaterialApp.router(
                  title: 'Melocue',
                  theme: AppTheme.darkTheme,
                  routerConfig: appRouter,
                  locale: locale,
                  localizationsDelegates:
                      AppLocalizations.localizationsDelegates,
                  supportedLocales: AppLocalizations.supportedLocales,
                  debugShowCheckedModeBanner: false,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
