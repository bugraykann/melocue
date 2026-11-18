import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:melocue/core/utils/context_extensions.dart';
import 'package:melocue/features/game/domain/entities/game_mode.dart';
import 'package:melocue/features/game/presentation/widgets/melocue_app_bar.dart';
import 'package:melocue/features/game/presentation/bloc/game_bloc.dart';
import 'package:melocue/features/game/presentation/bloc/game_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:melocue/features/game/data/datasources/local_storage_service.dart';
import 'package:melocue/features/game/presentation/widgets/playlist_selector_sheet.dart';
import 'package:melocue/features/game/presentation/widgets/coin_display.dart';
import 'package:melocue/core/services/location_service.dart';
import 'package:flutter/services.dart';
import 'package:melocue/core/presentation/widgets/pulsing_glow_widget.dart';
import 'package:melocue/features/game/presentation/widgets/banner_ad_widget.dart';
import 'package:melocue/core/services/ad_service.dart';

class ModesScreen extends StatefulWidget {
  const ModesScreen({super.key});

  @override
  State<ModesScreen> createState() => _ModesScreenState();
}

class _ModesScreenState extends State<ModesScreen> {
  String _selectedFilter = 'all';
  bool _isLoadingLocation = true;

  late LocalStorageService _storage;

  @override
  void initState() {
    super.initState();
    _storage = context.read<LocalStorageService>();
    _storage.regionNotifier.addListener(_onRegionChanged);
    _initLocation();
  }

  void _onRegionChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _storage.regionNotifier.removeListener(_onRegionChanged);
    super.dispose();
  }

  Future<void> _initLocation() async {
    final locationService = context.read<LocationService>();
    await locationService.determineUserCountry();
    if (mounted) {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final storage = context.watch<LocalStorageService>();

    if (_isLoadingLocation) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: CircularProgressIndicator(color: Colors.amber)),
      );
    }

    final allCategories = _allCategories(context, storage);
    final filteredCategories = _selectedFilter == 'all'
        ? allCategories
        : allCategories.where((c) => c['filter'] == _selectedFilter).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Custom App Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 24.0,
                  right: 24.0,
                  top: 16.0,
                ),
                child: MelocueAppBar(
                  title: 'Melocue',
                  subtitle: context.l10n.modesTitle,
                ),
              ),
            ),

            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    24.h,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.l10n.gameModes,
                                style: context.typography.headlineMedium
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                    ),
                              ),
                              4.h,
                              Text(
                                context.l10n.modesSubtitle,
                                style: context.typography.bodyMedium?.copyWith(
                                  color: const Color(0xFFB3B3B3),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const CoinDisplay(),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Daily & Endless Modes
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    32.h,
                    PulsingGlowWidget(
                      glowColor: context.colors.primary,
                      borderRadius: BorderRadius.circular(30),
                      minOpacity: 0.1,
                      maxOpacity: 0.4,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          final storage = context.read<LocalStorageService>();
                          if (storage.hasPlayedDailyToday) {
                            _showDailyReplayDialog(context);
                          } else {
                            _startGame(context, GameMode.daily, '');
                          }
                        },
                        icon: const Icon(
                          Icons.calendar_today_rounded,
                          color: Colors.black,
                        ),
                        label: Text(
                          context.l10n.dailyChallenge,
                          style: context.typography.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.colors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),

                    16.h,

                    PulsingGlowWidget(
                      glowColor: const Color(0xFF1ED760),
                      borderRadius: BorderRadius.circular(30),
                      minOpacity: 0.05,
                      maxOpacity: 0.3,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          final storage = context.read<LocalStorageService>();
                          if (storage.spotifyAccessToken == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(
                                      Icons.error_outline_rounded,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        context.l10n.connectSpotifyFirst,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                backgroundColor: const Color(0xFFE91429),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                margin: const EdgeInsets.only(
                                  bottom: 24,
                                  left: 16,
                                  right: 16,
                                ),
                                duration: const Duration(seconds: 3),
                                elevation: 0,
                              ),
                            );
                          } else {
                            PlaylistSelectorSheet.show(context);
                          }
                        },
                        icon: const Icon(
                          Icons.library_music_rounded,
                          color: Color(0xFF1ED760),
                        ),
                        label: Text(
                          context.l10n.myPlaylist,
                          style: context.typography.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1ED760),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color(0xFF1ED760),
                            width: 2,
                          ),
                          backgroundColor: const Color(0xFF1ED760)
                              .withValues(alpha: 0.1),
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),

                    16.h,

                    OutlinedButton.icon(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        _startGame(context, GameMode.endless, '');
                      },
                      icon: const Icon(
                        Icons.all_inclusive_rounded,
                        color: Colors.white,
                      ),
                      label: Text(
                        context.l10n.endlessMode,
                        style: context.typography.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 2,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),

                    16.h,

                    OutlinedButton.icon(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              'Görsel İpuçları modu şu anda yapım aşamasında. Çok yakında sizlerle!',
                            ),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            margin: const EdgeInsets.only(
                              bottom: 24,
                              left: 16,
                              right: 16,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.build_rounded, // Tools icon instead of emoji
                        color: Colors.grey,
                      ),
                      label: Text(
                        'Yakında: ${context.l10n.emojiModeTitle}',
                        style: context.typography.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.grey, width: 2),
                        backgroundColor: Colors.grey.withValues(alpha: 0.1),
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Fan Tests
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  32.h,
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Color(0xFF1ED760),
                          size: 20,
                        ),
                        8.w,
                        Text(
                          context.l10n.fanTests,
                          style: context.typography.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          context.l10n.popular,
                          style: context.typography.labelMedium?.copyWith(
                            color: const Color(0xFFB3B3B3),
                          ),
                        ),
                      ],
                    ),
                  ),
                  16.h,
                  SizedBox(
                    height: 175,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: _buildFanTests(context, storage),
                    ),
                  ),
                ],
              ),
            ),

            // Categories
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  32.h,
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          context.l10n.categories,
                          style: context.typography.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              context.l10n.all,
                              style: context.typography.labelMedium?.copyWith(
                                color: const Color(0xFF1ED760),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            4.w,
                            const Icon(
                              Icons.shuffle_rounded,
                              color: Color(0xFF1ED760),
                              size: 16,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  16.h,

                  // Filter Pills
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        _buildFilterPill(
                          context,
                          context.l10n.filterAll,
                          'all',
                        ),
                        if (storage.countryCode?.toUpperCase() == 'TR') ...[
                          _buildFilterPill(
                            context,
                            context.l10n.filterTurkish,
                            'turkish',
                          ),
                          _buildFilterPill(
                            context,
                            context.l10n.filterForeign,
                            'foreign',
                          ),
                          _buildFilterPill(
                            context,
                            context.l10n.filterNostalgia,
                            'nostalgia',
                          ),
                        ],
                        _buildFilterPill(
                          context,
                          context.l10n.filterRap,
                          'rap',
                        ),
                        _buildFilterPill(
                          context,
                          context.l10n.filterRock,
                          'rock',
                        ),
                        _buildFilterPill(context, context.l10n.filterRb, 'rb'),
                        _buildFilterPill(
                          context,
                          context.l10n.filterKpop,
                          'kpop',
                        ),
                        _buildFilterPill(
                          context,
                          context.l10n.filterIndie,
                          'indie',
                        ),
                        _buildFilterPill(
                          context,
                          context.l10n.filterLatin,
                          'latin',
                        ),
                      ],
                    ),
                  ),
                  24.h,
                ],
              ),
            ),

            // Category List
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final cat = filteredCategories[index];
                  return _buildGenreCard(
                    context,
                    title: cat['title'] as String,
                    subtitle: cat['subtitle'] as String,
                    badge: cat['badge'] as String,
                    badgeColor: cat['badgeColor'] as Color,
                    difficulty: cat['difficulty'] as String,
                    accuracy: _getAccuracyText(storage, cat['key'] as String),
                    progress: _getAccuracyProgress(
                      storage,
                      cat['key'] as String,
                    ),
                    gradientColors: cat['gradientColors'] as List<Color>,
                    onTap: cat['onTap'] as VoidCallback,
                  );
                }, childCount: filteredCategories.length),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32.0),
                child: const BannerAdWidget(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _allCategories(
    BuildContext context,
    LocalStorageService storage,
  ) {
    final country = storage.countryCode?.toUpperCase();
    final isTR = country == 'TR';

    final baseCategories = <Map<String, dynamic>>[
      if (isTR) ...[
        {
          'filter': 'turkish',
          'key': 'Türkçe Pop',
          'title': context.l10n.genreTurkPopTitle,
          'subtitle': context.l10n.genreTurkPopDesc,
          'badge': context.l10n.badgePopular,
          'badgeColor': const Color(0xFF1ED760),
          'difficulty': context.l10n.difficultyMedium,
          'gradientColors': [const Color(0xFFF72585), const Color(0xFF7209B7)],
          'onTap': () => _startGame(context, GameMode.category, 'Türkçe Pop'),
        },
        {
          'filter': 'rap',
          'key': 'Türkçe Rap',
          'title': context.l10n.genreTurkRapTitle,
          'subtitle': context.l10n.genreTurkRapDesc,
          'badge': context.l10n.badgeNew,
          'badgeColor': const Color(0xFF4CC9F0),
          'difficulty': context.l10n.difficultyHard,
          'gradientColors': [const Color(0xFF4361EE), const Color(0xFF3A0CA3)],
          'onTap': () => _startGame(context, GameMode.category, 'Türkçe Rap'),
        },
        {
          'filter': 'nostalgia',
          'key': '2000ler Türkçe Pop',
          'title': context.l10n.genre2000PopTitle,
          'subtitle': context.l10n.genre2000PopDesc,
          'badge': context.l10n.badgeNostalgia,
          'badgeColor': const Color(0xFFF8961E),
          'difficulty': context.l10n.difficultyEasy,
          'gradientColors': [const Color(0xFFF9C74F), const Color(0xFFF3722C)],
          'onTap': () =>
              _startGame(context, GameMode.category, '2000ler Türkçe Pop'),
        },
      ],
      {
        'filter': isTR ? 'foreign' : 'all',
        'key': 'Global Pop',
        'title': context.l10n.genreGlobalPopTitle,
        'subtitle': context.l10n.genreGlobalPopDesc,
        'badge': context.l10n.badgeGlobal,
        'badgeColor': const Color(0xFF1ED760),
        'difficulty': context.l10n.difficultyMedium,
        'gradientColors': [const Color(0xFFF72585), const Color(0xFF7209B7)],
        'onTap': () => _startGame(context, GameMode.category, 'Global Pop'),
      },
      {
        'filter': 'rock',
        'key': 'Rock Classics',
        'title': context.l10n.genreRockTitle,
        'subtitle': context.l10n.genreRockDesc,
        'badge': context.l10n.badgePopular,
        'badgeColor': const Color(0xFFE63946),
        'difficulty': context.l10n.difficultyHard,
        'gradientColors': [const Color(0xFFD62828), const Color(0xFF003049)],
        'onTap': () => _startGame(context, GameMode.category, 'Rock Classics'),
      },
      {
        'filter': 'rb',
        'key': 'R&B Soul',
        'title': context.l10n.genreRbTitle,
        'subtitle': context.l10n.genreRbDesc,
        'badge': context.l10n.badgeNew,
        'badgeColor': const Color(0xFFF77F00),
        'difficulty': context.l10n.difficultyMedium,
        'gradientColors': [const Color(0xFFF77F00), const Color(0xFFD62828)],
        'onTap': () => _startGame(context, GameMode.category, 'R&B Soul'),
      },
      {
        'filter': 'kpop',
        'key': 'K-Pop',
        'title': context.l10n.genreKpopTitle,
        'subtitle': context.l10n.genreKpopDesc,
        'badge': context.l10n.badgePopular,
        'badgeColor': const Color(0xFFFFB703),
        'difficulty': context.l10n.difficultyHard,
        'gradientColors': [const Color(0xFFFFB703), const Color(0xFFFB8500)],
        'onTap': () => _startGame(context, GameMode.category, 'K-Pop'),
      },
      {
        'filter': 'indie',
        'key': 'Indie',
        'title': context.l10n.genreIndieTitle,
        'subtitle': context.l10n.genreIndieDesc,
        'badge': context.l10n.badgeNew,
        'badgeColor': const Color(0xFF023047),
        'difficulty': context.l10n.difficultyEasy,
        'gradientColors': [const Color(0xFF219EBC), const Color(0xFF023047)],
        'onTap': () => _startGame(context, GameMode.category, 'Indie'),
      },
      {
        'filter': 'latin',
        'key': 'Latin',
        'title': context.l10n.genreLatinTitle,
        'subtitle': context.l10n.genreLatinDesc,
        'badge': context.l10n.badgePopular,
        'badgeColor': const Color(0xFF8ECAE6),
        'difficulty': context.l10n.difficultyMedium,
        'gradientColors': [const Color(0xFF8ECAE6), const Color(0xFF219EBC)],
        'onTap': () => _startGame(context, GameMode.category, 'Latin'),
      },
    ];

    if (!isTR) {
      baseCategories.add({
        'filter': 'rap',
        'key': 'Hip Hop',
        'title': 'Hip Hop',
        'subtitle': 'Drake, Eminem, Kendrick Lamar...',
        'badge': context.l10n.badgeNew,
        'badgeColor': const Color(0xFF4CC9F0),
        'difficulty': context.l10n.difficultyHard,
        'gradientColors': [const Color(0xFF4361EE), const Color(0xFF3A0CA3)],
        'onTap': () => _startGame(context, GameMode.category, 'Hip Hop'),
      });
    }

    return baseCategories;
  }

  List<Widget> _buildFanTests(
    BuildContext context,
    LocalStorageService storage,
  ) {
    final country = storage.countryCode?.toUpperCase();

    final Map<String, List<Map<String, dynamic>>> countryTopArtists = {
      'TR': [
        {
          'title': 'Tarkan',
          'subtitle': 'Megastar',
          'icon': Icons.timer_rounded,
          'color': const Color(0xFFF72585),
          'bg': const Color(0xFF1A0814),
        },
        {
          'title': 'Sezen Aksu',
          'subtitle': 'Minik Serçe',
          'icon': Icons.mic_rounded,
          'color': const Color(0xFF6C63FF),
          'bg': const Color(0xFF1A1730),
        },
        {
          'title': 'Müslüm Gürses',
          'subtitle': 'Arabeskin babası',
          'icon': Icons.radio_rounded,
          'color': const Color(0xFFE63946),
          'bg': const Color(0xFF1A0D0E),
        },
        {
          'title': 'Manifest',
          'subtitle': 'Türk kız grubu hitleri',
          'icon': Icons.star_rounded,
          'color': const Color(0xFF1ED760),
          'bg': const Color(0xFF0F1A13),
          'isNew': true,
        },
        {
          'title': 'Blok3',
          'subtitle': 'Dönemi domine eden parçalar',
          'icon': Icons.whatshot_rounded,
          'color': const Color(0xFFFF6B35),
          'bg': const Color(0xFF1C1510),
          'isNew': true,
        },
        {
          'title': 'Lvbel C5',
          'subtitle': 'Sokak müziği',
          'icon': Icons.headphones_rounded,
          'color': const Color(0xFF4CC9F0),
          'bg': const Color(0xFF0C191C),
        },
        {
          'title': 'Ceza',
          'subtitle': 'Türkçe rap efsanesi',
          'icon': Icons.bolt_rounded,
          'color': const Color(0xFFF9C74F),
          'bg': const Color(0xFF1A170F),
        },
        {
          'title': 'Uzi',
          'subtitle': 'Trap sahnesi',
          'icon': Icons.local_fire_department_rounded,
          'color': const Color(0xFFF3722C),
          'bg': const Color(0xFF1A0F0C),
        },
        {
          'title': 'Motive',
          'subtitle': 'Yeni nesil rap',
          'icon': Icons.music_note_rounded,
          'color': const Color(0xFF7209B7),
          'bg': const Color(0xFF13091A),
        },
        {
          'title': 'Gülşen',
          'subtitle': 'Pop kraliçesi',
          'icon': Icons.favorite_rounded,
          'color': const Color(0xFFF72585),
          'bg': const Color(0xFF1A0814),
        },
      ],
      'GB': [
        {
          'title': 'Ed Sheeran',
          'subtitle': 'Acoustic pop hits',
          'icon': Icons.music_note_rounded,
          'color': const Color(0xFFFF6B35),
          'bg': const Color(0xFF1C1510),
        },
        {
          'title': 'Adele',
          'subtitle': 'Soulful vocals',
          'icon': Icons.mic_rounded,
          'color': const Color(0xFF6C63FF),
          'bg': const Color(0xFF1A1730),
        },
        {
          'title': 'Harry Styles',
          'subtitle': 'As It Was',
          'icon': Icons.star_rounded,
          'color': const Color(0xFFF72585),
          'bg': const Color(0xFF1A0814),
        },
        {
          'title': 'Coldplay',
          'subtitle': 'Stadium anthems',
          'icon': Icons.public_rounded,
          'color': const Color(0xFF4CC9F0),
          'bg': const Color(0xFF0C191C),
        },
        {
          'title': 'Arctic Monkeys',
          'subtitle': 'Indie rock legends',
          'icon': Icons.headphones_rounded,
          'color': const Color(0xFFE63946),
          'bg': const Color(0xFF1A0D0E),
        },
        {
          'title': 'Dua Lipa',
          'subtitle': 'Future Nostalgia',
          'icon': Icons.auto_awesome_rounded,
          'color': const Color(0xFFF9C74F),
          'bg': const Color(0xFF1A170F),
        },
        {
          'title': 'Queen',
          'subtitle': 'Classic rock',
          'icon': Icons.bolt_rounded,
          'color': const Color(0xFF7209B7),
          'bg': const Color(0xFF13091A),
        },
        {
          'title': 'The Beatles',
          'subtitle': 'The Fab Four',
          'icon': Icons.library_music_rounded,
          'color': const Color(0xFF1ED760),
          'bg': const Color(0xFF0F1A13),
        },
        {
          'title': 'Elton John',
          'subtitle': 'Rocketman',
          'icon': Icons.radio_rounded,
          'color': const Color(0xFFF3722C),
          'bg': const Color(0xFF1A0F0C),
        },
        {
          'title': 'Sam Smith',
          'subtitle': 'Emotional ballads',
          'icon': Icons.favorite_rounded,
          'color': const Color(0xFFF72585),
          'bg': const Color(0xFF1A0814),
        },
      ],
      'KR': [
        {
          'title': 'BTS',
          'subtitle': 'Global phenomenon',
          'icon': Icons.star_rounded,
          'color': const Color(0xFFF72585),
          'bg': const Color(0xFF1A0814),
        },
        {
          'title': 'BLACKPINK',
          'subtitle': 'In your area',
          'icon': Icons.mic_rounded,
          'color': const Color(0xFF6C63FF),
          'bg': const Color(0xFF1A1730),
        },
        {
          'title': 'EXO',
          'subtitle': 'K-pop kings',
          'icon': Icons.bolt_rounded,
          'color': const Color(0xFFE63946),
          'bg': const Color(0xFF1A0D0E),
        },
        {
          'title': 'TWICE',
          'subtitle': 'Nation\'s girl group',
          'icon': Icons.favorite_rounded,
          'color': const Color(0xFF1ED760),
          'bg': const Color(0xFF0F1A13),
        },
        {
          'title': 'Stray Kids',
          'subtitle': 'Self-producing idols',
          'icon': Icons.music_note_rounded,
          'color': const Color(0xFF4CC9F0),
          'bg': const Color(0xFF0C191C),
        },
        {
          'title': 'SEVENTEEN',
          'subtitle': 'Performance kings',
          'icon': Icons.local_fire_department_rounded,
          'color': const Color(0xFFF9C74F),
          'bg': const Color(0xFF1A170F),
        },
        {
          'title': 'IU',
          'subtitle': 'Nation\'s sweetheart',
          'icon': Icons.headphones_rounded,
          'color': const Color(0xFFFF6B35),
          'bg': const Color(0xFF1C1510),
        },
        {
          'title': 'NewJeans',
          'subtitle': 'Y2K vibes',
          'icon': Icons.auto_awesome_rounded,
          'color': const Color(0xFF7209B7),
          'bg': const Color(0xFF13091A),
        },
      ],
      'BR': [
        {
          'title': 'Anitta',
          'subtitle': 'Funk pop queen',
          'icon': Icons.star_rounded,
          'color': const Color(0xFFF72585),
          'bg': const Color(0xFF1A0814),
        },
        {
          'title': 'Marília Mendonça',
          'subtitle': 'Rainha da Sofrência',
          'icon': Icons.mic_rounded,
          'color': const Color(0xFF6C63FF),
          'bg': const Color(0xFF1A1730),
        },
        {
          'title': 'Gusttavo Lima',
          'subtitle': 'Sertanejo hits',
          'icon': Icons.music_note_rounded,
          'color': const Color(0xFFE63946),
          'bg': const Color(0xFF1A0D0E),
        },
        {
          'title': 'Henrique & Juliano',
          'subtitle': 'Sertanejo duo',
          'icon': Icons.people_rounded,
          'color': const Color(0xFF1ED760),
          'bg': const Color(0xFF0F1A13),
        },
        {
          'title': 'Alok',
          'subtitle': 'Electronic vibes',
          'icon': Icons.headphones_rounded,
          'color': const Color(0xFF4CC9F0),
          'bg': const Color(0xFF0C191C),
        },
        {
          'title': 'Ludmilla',
          'subtitle': 'Funk & Pop',
          'icon': Icons.local_fire_department_rounded,
          'color': const Color(0xFFF9C74F),
          'bg': const Color(0xFF1A170F),
        },
        {
          'title': 'Luísa Sonza',
          'subtitle': 'Pop star',
          'icon': Icons.favorite_rounded,
          'color': const Color(0xFFFF6B35),
          'bg': const Color(0xFF1C1510),
        },
        {
          'title': 'Wesley Safadão',
          'subtitle': 'Forró mix',
          'icon': Icons.bolt_rounded,
          'color': const Color(0xFF7209B7),
          'bg': const Color(0xFF13091A),
        },
      ],
      'DE': [
        {
          'title': 'Rammstein',
          'subtitle': 'Industrial metal',
          'icon': Icons.bolt_rounded,
          'color': const Color(0xFFE63946),
          'bg': const Color(0xFF1A0D0E),
        },
        {
          'title': 'Apache 207',
          'subtitle': 'German rap & pop',
          'icon': Icons.mic_rounded,
          'color': const Color(0xFF4CC9F0),
          'bg': const Color(0xFF0C191C),
        },
        {
          'title': 'Sido',
          'subtitle': 'Rap legend',
          'icon': Icons.radio_rounded,
          'color': const Color(0xFFF9C74F),
          'bg': const Color(0xFF1A170F),
        },
        {
          'title': 'Bonez MC',
          'subtitle': '187 Strassenbande',
          'icon': Icons.local_fire_department_rounded,
          'color': const Color(0xFFF3722C),
          'bg': const Color(0xFF1A0F0C),
        },
        {
          'title': 'Capital Bra',
          'subtitle': 'Bratan hits',
          'icon': Icons.star_rounded,
          'color': const Color(0xFF7209B7),
          'bg': const Color(0xFF13091A),
        },
        {
          'title': 'Helene Fischer',
          'subtitle': 'Schlager queen',
          'icon': Icons.favorite_rounded,
          'color': const Color(0xFFF72585),
          'bg': const Color(0xFF1A0814),
        },
        {
          'title': 'Robin Schulz',
          'subtitle': 'Electronic dance',
          'icon': Icons.headphones_rounded,
          'color': const Color(0xFF1ED760),
          'bg': const Color(0xFF0F1A13),
        },
        {
          'title': 'Luciano',
          'subtitle': 'Drill king',
          'icon': Icons.whatshot_rounded,
          'color': const Color(0xFFFF6B35),
          'bg': const Color(0xFF1C1510),
        },
      ],
      'FR': [
        {
          'title': 'Daft Punk',
          'subtitle': 'Electronic pioneers',
          'icon': Icons.headphones_rounded,
          'color': const Color(0xFF1ED760),
          'bg': const Color(0xFF0F1A13),
        },
        {
          'title': 'David Guetta',
          'subtitle': 'EDM superstar',
          'icon': Icons.music_note_rounded,
          'color': const Color(0xFF4CC9F0),
          'bg': const Color(0xFF0C191C),
        },
        {
          'title': 'Jul',
          'subtitle': 'Le J c\'est le S',
          'icon': Icons.bolt_rounded,
          'color': const Color(0xFFF9C74F),
          'bg': const Color(0xFF1A170F),
        },
        {
          'title': 'Ninho',
          'subtitle': 'French rap boss',
          'icon': Icons.mic_rounded,
          'color': const Color(0xFFE63946),
          'bg': const Color(0xFF1A0D0E),
        },
        {
          'title': 'Orelsan',
          'subtitle': 'La Quête',
          'icon': Icons.radio_rounded,
          'color': const Color(0xFF6C63FF),
          'bg': const Color(0xFF1A1730),
        },
        {
          'title': 'Stromae',
          'subtitle': 'Belgian maestro',
          'icon': Icons.star_rounded,
          'color': const Color(0xFF7209B7),
          'bg': const Color(0xFF13091A),
        },
        {
          'title': 'PNL',
          'subtitle': 'Cloud rap',
          'icon': Icons.cloud_rounded,
          'color': const Color(0xFF8ECAE6),
          'bg': const Color(0xFF0B191F),
        },
        {
          'title': 'Aya Nakamura',
          'subtitle': 'Pop & R&B',
          'icon': Icons.favorite_rounded,
          'color': const Color(0xFFF72585),
          'bg': const Color(0xFF1A0814),
        },
      ],
      'IT': [
        {
          'title': 'Måneskin',
          'subtitle': 'Rock revival',
          'icon': Icons.bolt_rounded,
          'color': const Color(0xFFE63946),
          'bg': const Color(0xFF1A0D0E),
        },
        {
          'title': 'Sfera Ebbasta',
          'subtitle': 'Trap king',
          'icon': Icons.whatshot_rounded,
          'color': const Color(0xFFFF6B35),
          'bg': const Color(0xFF1C1510),
        },
        {
          'title': 'Blanco',
          'subtitle': 'Brividi',
          'icon': Icons.mic_rounded,
          'color': const Color(0xFF4CC9F0),
          'bg': const Color(0xFF0C191C),
        },
        {
          'title': 'Laura Pausini',
          'subtitle': 'Italian pop queen',
          'icon': Icons.favorite_rounded,
          'color': const Color(0xFFF72585),
          'bg': const Color(0xFF1A0814),
        },
        {
          'title': 'Andrea Bocelli',
          'subtitle': 'Classical crossover',
          'icon': Icons.music_note_rounded,
          'color': const Color(0xFF1ED760),
          'bg': const Color(0xFF0F1A13),
        },
        {
          'title': 'Tiziano Ferro',
          'subtitle': 'Pop ballads',
          'icon': Icons.radio_rounded,
          'color': const Color(0xFF6C63FF),
          'bg': const Color(0xFF1A1730),
        },
        {
          'title': 'Mahmood',
          'subtitle': 'Urban pop',
          'icon': Icons.star_rounded,
          'color': const Color(0xFFF9C74F),
          'bg': const Color(0xFF1A170F),
        },
        {
          'title': 'Fedez',
          'subtitle': 'Rap & Pop',
          'icon': Icons.headphones_rounded,
          'color': const Color(0xFF7209B7),
          'bg': const Color(0xFF13091A),
        },
      ],
      'ES': [
        {
          'title': 'Rosalía',
          'subtitle': 'Motomami',
          'icon': Icons.local_fire_department_rounded,
          'color': const Color(0xFFE63946),
          'bg': const Color(0xFF1A0D0E),
        },
        {
          'title': 'Alejandro Sanz',
          'subtitle': 'Pop legend',
          'icon': Icons.mic_rounded,
          'color': const Color(0xFF4CC9F0),
          'bg': const Color(0xFF0C191C),
        },
        {
          'title': 'Enrique Iglesias',
          'subtitle': 'Latin pop king',
          'icon': Icons.star_rounded,
          'color': const Color(0xFFF9C74F),
          'bg': const Color(0xFF1A170F),
        },
        {
          'title': 'C. Tangana',
          'subtitle': 'El Madrileño',
          'icon': Icons.headphones_rounded,
          'color': const Color(0xFFF3722C),
          'bg': const Color(0xFF1A0F0C),
        },
        {
          'title': 'Quevedo',
          'subtitle': 'Reggaeton hits',
          'icon': Icons.bolt_rounded,
          'color': const Color(0xFF1ED760),
          'bg': const Color(0xFF0F1A13),
        },
        {
          'title': 'Bad Gyal',
          'subtitle': 'Dancehall queen',
          'icon': Icons.favorite_rounded,
          'color': const Color(0xFFF72585),
          'bg': const Color(0xFF1A0814),
        },
        {
          'title': 'Aitana',
          'subtitle': 'Pop princess',
          'icon': Icons.music_note_rounded,
          'color': const Color(0xFF6C63FF),
          'bg': const Color(0xFF1A1730),
        },
        {
          'title': 'Morad',
          'subtitle': 'MDLR',
          'icon': Icons.radio_rounded,
          'color': const Color(0xFF7209B7),
          'bg': const Color(0xFF13091A),
        },
      ],
      'MX': [
        {
          'title': 'Peso Pluma',
          'subtitle': 'Corridos tumbados',
          'icon': Icons.bolt_rounded,
          'color': const Color(0xFFE63946),
          'bg': const Color(0xFF1A0D0E),
        },
        {
          'title': 'Christian Nodal',
          'subtitle': 'Regional Mexican',
          'icon': Icons.music_note_rounded,
          'color': const Color(0xFFF3722C),
          'bg': const Color(0xFF1A0F0C),
        },
        {
          'title': 'Luis Miguel',
          'subtitle': 'El Sol de México',
          'icon': Icons.wb_sunny_rounded,
          'color': const Color(0xFFF9C74F),
          'bg': const Color(0xFF1A170F),
        },
        {
          'title': 'Vicente Fernández',
          'subtitle': 'El Rey',
          'icon': Icons.star_rounded,
          'color': const Color(0xFF6C63FF),
          'bg': const Color(0xFF1A1730),
        },
        {
          'title': 'Thalía',
          'subtitle': 'Queen of Latin Pop',
          'icon': Icons.favorite_rounded,
          'color': const Color(0xFFF72585),
          'bg': const Color(0xFF1A0814),
        },
        {
          'title': 'Maná',
          'subtitle': 'Latin rock',
          'icon': Icons.headphones_rounded,
          'color': const Color(0xFF1ED760),
          'bg': const Color(0xFF0F1A13),
        },
        {
          'title': 'Julieta Venegas',
          'subtitle': 'Indie pop',
          'icon': Icons.mic_rounded,
          'color': const Color(0xFF4CC9F0),
          'bg': const Color(0xFF0C191C),
        },
        {
          'title': 'Grupo Firme',
          'subtitle': 'Banda hits',
          'icon': Icons.people_rounded,
          'color': const Color(0xFFFF6B35),
          'bg': const Color(0xFF1C1510),
        },
      ],
      'JP': [
        {
          'title': 'YOASOBI',
          'subtitle': 'J-Pop sensations',
          'icon': Icons.music_note_rounded,
          'color': const Color(0xFFF72585),
          'bg': const Color(0xFF1A0814),
        },
        {
          'title': 'Kenshi Yonezu',
          'subtitle': 'Lemon & Kick Back',
          'icon': Icons.mic_rounded,
          'color': const Color(0xFF4CC9F0),
          'bg': const Color(0xFF0C191C),
        },
        {
          'title': 'Hikaru Utada',
          'subtitle': 'First Love',
          'icon': Icons.star_rounded,
          'color': const Color(0xFFF9C74F),
          'bg': const Color(0xFF1A170F),
        },
        {
          'title': 'LiSA',
          'subtitle': 'Anime anthems',
          'icon': Icons.bolt_rounded,
          'color': const Color(0xFFE63946),
          'bg': const Color(0xFF1A0D0E),
        },
        {
          'title': 'Ado',
          'subtitle': 'Usseewa',
          'icon': Icons.headphones_rounded,
          'color': const Color(0xFF6C63FF),
          'bg': const Color(0xFF1A1730),
        },
        {
          'title': 'Vaundy',
          'subtitle': 'Genre-bending pop',
          'icon': Icons.radio_rounded,
          'color': const Color(0xFF1ED760),
          'bg': const Color(0xFF0F1A13),
        },
        {
          'title': 'ONE OK ROCK',
          'subtitle': 'J-Rock kings',
          'icon': Icons.whatshot_rounded,
          'color': const Color(0xFFFF6B35),
          'bg': const Color(0xFF1C1510),
        },
        {
          'title': 'Aimyon',
          'subtitle': 'Singer-songwriter',
          'icon': Icons.favorite_rounded,
          'color': const Color(0xFFF3722C),
          'bg': const Color(0xFF1A0F0C),
        },
      ],
      'IN': [
        {
          'title': 'Arijit Singh',
          'subtitle': 'Bollywood\'s voice',
          'icon': Icons.mic_rounded,
          'color': const Color(0xFFE63946),
          'bg': const Color(0xFF1A0D0E),
        },
        {
          'title': 'Neha Kakkar',
          'subtitle': 'Pop & Playback',
          'icon': Icons.favorite_rounded,
          'color': const Color(0xFFF72585),
          'bg': const Color(0xFF1A0814),
        },
        {
          'title': 'Badshah',
          'subtitle': 'Desi Hip Hop',
          'icon': Icons.bolt_rounded,
          'color': const Color(0xFFF9C74F),
          'bg': const Color(0xFF1A170F),
        },
        {
          'title': 'Shreya Ghoshal',
          'subtitle': 'Melody queen',
          'icon': Icons.star_rounded,
          'color': const Color(0xFF4CC9F0),
          'bg': const Color(0xFF0C191C),
        },
        {
          'title': 'AR Rahman',
          'subtitle': 'Musical genius',
          'icon': Icons.music_note_rounded,
          'color': const Color(0xFF1ED760),
          'bg': const Color(0xFF0F1A13),
        },
        {
          'title': 'Jubin Nautiyal',
          'subtitle': 'Romantic hits',
          'icon': Icons.headphones_rounded,
          'color': const Color(0xFF6C63FF),
          'bg': const Color(0xFF1A1730),
        },
        {
          'title': 'Guru Randhawa',
          'subtitle': 'Punjabi pop',
          'icon': Icons.radio_rounded,
          'color': const Color(0xFFFF6B35),
          'bg': const Color(0xFF1C1510),
        },
        {
          'title': 'Sidhu Moose Wala',
          'subtitle': 'Legend',
          'icon': Icons.local_fire_department_rounded,
          'color': const Color(0xFFF3722C),
          'bg': const Color(0xFF1A0F0C),
        },
      ],
      'GR': [
        {
          'title': 'Eleni Foureira',
          'subtitle': 'Fuego',
          'icon': Icons.local_fire_department_rounded,
          'color': const Color(0xFFE63946),
          'bg': const Color(0xFF1A0D0E),
        },
        {
          'title': 'Konstantinos Argiros',
          'subtitle': 'Laiko hits',
          'icon': Icons.mic_rounded,
          'color': const Color(0xFF4CC9F0),
          'bg': const Color(0xFF0C191C),
        },
        {
          'title': 'Nikos Vertis',
          'subtitle': 'Greek superstar',
          'icon': Icons.star_rounded,
          'color': const Color(0xFFF9C74F),
          'bg': const Color(0xFF1A170F),
        },
        {
          'title': 'Anna Vissi',
          'subtitle': 'Greek Madonna',
          'icon': Icons.favorite_rounded,
          'color': const Color(0xFFF72585),
          'bg': const Color(0xFF1A0814),
        },
        {
          'title': 'Helena Paparizou',
          'subtitle': 'Number One',
          'icon': Icons.music_note_rounded,
          'color': const Color(0xFF1ED760),
          'bg': const Color(0xFF0F1A13),
        },
        {
          'title': 'Sakis Rouvas',
          'subtitle': 'Pop icon',
          'icon': Icons.bolt_rounded,
          'color': const Color(0xFFFF6B35),
          'bg': const Color(0xFF1C1510),
        },
        {
          'title': 'Antonis Remos',
          'subtitle': 'Romantic ballads',
          'icon': Icons.headphones_rounded,
          'color': const Color(0xFF6C63FF),
          'bg': const Color(0xFF1A1730),
        },
        {
          'title': 'Melisses',
          'subtitle': 'Top band',
          'icon': Icons.people_rounded,
          'color': const Color(0xFFF3722C),
          'bg': const Color(0xFF1A0F0C),
        },
      ],
      'LT': [
        {
          'title': 'The Roop',
          'subtitle': 'On Fire',
          'icon': Icons.local_fire_department_rounded,
          'color': const Color(0xFFF9C74F),
          'bg': const Color(0xFF1A170F),
        },
        {
          'title': 'Monika Liu',
          'subtitle': 'Sentimentai',
          'icon': Icons.mic_rounded,
          'color': const Color(0xFFF72585),
          'bg': const Color(0xFF1A0814),
        },
        {
          'title': 'SEL',
          'subtitle': 'Electronic legends',
          'icon': Icons.bolt_rounded,
          'color': const Color(0xFF4CC9F0),
          'bg': const Color(0xFF0C191C),
        },
        {
          'title': 'Daddy Was A Milkman',
          'subtitle': 'Indie pop',
          'icon': Icons.music_note_rounded,
          'color': const Color(0xFF1ED760),
          'bg': const Color(0xFF0F1A13),
        },
        {
          'title': 'GJan',
          'subtitle': 'Pop star',
          'icon': Icons.star_rounded,
          'color': const Color(0xFF6C63FF),
          'bg': const Color(0xFF1A1730),
        },
        {
          'title': 'Leon Somov',
          'subtitle': 'Electronic producer',
          'icon': Icons.headphones_rounded,
          'color': const Color(0xFFFF6B35),
          'bg': const Color(0xFF1C1510),
        },
        {
          'title': 'Jessica Shy',
          'subtitle': 'Lithuanian hits',
          'icon': Icons.favorite_rounded,
          'color': const Color(0xFFE63946),
          'bg': const Color(0xFF1A0D0E),
        },
        {
          'title': 'Vaidas Baumila',
          'subtitle': 'Kunigunda',
          'icon': Icons.radio_rounded,
          'color': const Color(0xFFF3722C),
          'bg': const Color(0xFF1A0F0C),
        },
      ],
      'AR': [
        {
          'title': 'Bizarrap',
          'subtitle': 'BZRP Music Sessions',
          'icon': Icons.headphones_rounded,
          'color': const Color(0xFF4CC9F0),
          'bg': const Color(0xFF0C191C),
        },
        {
          'title': 'TINI',
          'subtitle': 'Pop sensation',
          'icon': Icons.star_rounded,
          'color': const Color(0xFFF72585),
          'bg': const Color(0xFF1A0814),
        },
        {
          'title': 'Duki',
          'subtitle': 'Trap king',
          'icon': Icons.bolt_rounded,
          'color': const Color(0xFFF9C74F),
          'bg': const Color(0xFF1A170F),
        },
        {
          'title': 'Maria Becerra',
          'subtitle': 'La Nena de Argentina',
          'icon': Icons.favorite_rounded,
          'color': const Color(0xFF6C63FF),
          'bg': const Color(0xFF1A1730),
        },
        {
          'title': 'Paulo Londra',
          'subtitle': 'Urban hits',
          'icon': Icons.mic_rounded,
          'color': const Color(0xFFFF6B35),
          'bg': const Color(0xFF1C1510),
        },
        {
          'title': 'L-Gante',
          'subtitle': 'Cumbia 420',
          'icon': Icons.local_fire_department_rounded,
          'color': const Color(0xFFE63946),
          'bg': const Color(0xFF1A0D0E),
        },
        {
          'title': 'Trueno',
          'subtitle': 'Hip Hop',
          'icon': Icons.radio_rounded,
          'color': const Color(0xFF1ED760),
          'bg': const Color(0xFF0F1A13),
        },
        {
          'title': 'Nicki Nicole',
          'subtitle': 'R&B / Trap',
          'icon': Icons.music_note_rounded,
          'color': const Color(0xFF7209B7),
          'bg': const Color(0xFF13091A),
        },
      ],
      'CO': [
        {
          'title': 'Shakira',
          'subtitle': 'Global icon',
          'icon': Icons.public_rounded,
          'color': const Color(0xFFF72585),
          'bg': const Color(0xFF1A0814),
        },
        {
          'title': 'J Balvin',
          'subtitle': 'Colores',
          'icon': Icons.bolt_rounded,
          'color': const Color(0xFF1ED760),
          'bg': const Color(0xFF0F1A13),
        },
        {
          'title': 'Maluma',
          'subtitle': 'Papi Juancho',
          'icon': Icons.star_rounded,
          'color': const Color(0xFFF9C74F),
          'bg': const Color(0xFF1A170F),
        },
        {
          'title': 'Karol G',
          'subtitle': 'Bichota',
          'icon': Icons.favorite_rounded,
          'color': const Color(0xFF6C63FF),
          'bg': const Color(0xFF1A1730),
        },
        {
          'title': 'Camilo',
          'subtitle': 'Pop ballads',
          'icon': Icons.music_note_rounded,
          'color': const Color(0xFFFF6B35),
          'bg': const Color(0xFF1C1510),
        },
        {
          'title': 'Carlos Vives',
          'subtitle': 'Vallenato pop',
          'icon': Icons.radio_rounded,
          'color': const Color(0xFF4CC9F0),
          'bg': const Color(0xFF0C191C),
        },
        {
          'title': 'Juanes',
          'subtitle': 'Latin rock',
          'icon': Icons.headphones_rounded,
          'color': const Color(0xFFE63946),
          'bg': const Color(0xFF1A0D0E),
        },
        {
          'title': 'Sebastián Yatra',
          'subtitle': 'Romantic hits',
          'icon': Icons.mic_rounded,
          'color': const Color(0xFFF3722C),
          'bg': const Color(0xFF1A0F0C),
        },
      ],
      'AU': [
        {
          'title': 'Tame Impala',
          'subtitle': 'Psychedelic pop',
          'icon': Icons.headphones_rounded,
          'color': const Color(0xFF6C63FF),
          'bg': const Color(0xFF1A1730),
        },
        {
          'title': 'Sia',
          'subtitle': 'Chandelier',
          'icon': Icons.mic_rounded,
          'color': const Color(0xFFF72585),
          'bg': const Color(0xFF1A0814),
        },
        {
          'title': '5 Seconds of Summer',
          'subtitle': 'Pop rock',
          'icon': Icons.bolt_rounded,
          'color': const Color(0xFFFF6B35),
          'bg': const Color(0xFF1C1510),
        },
        {
          'title': 'The Kid LAROI',
          'subtitle': 'Stay',
          'icon': Icons.star_rounded,
          'color': const Color(0xFF4CC9F0),
          'bg': const Color(0xFF0C191C),
        },
        {
          'title': 'Vance Joy',
          'subtitle': 'Riptide',
          'icon': Icons.music_note_rounded,
          'color': const Color(0xFF1ED760),
          'bg': const Color(0xFF0F1A13),
        },
        {
          'title': 'AC/DC',
          'subtitle': 'Hard rock legends',
          'icon': Icons.local_fire_department_rounded,
          'color': const Color(0xFFE63946),
          'bg': const Color(0xFF1A0D0E),
        },
        {
          'title': 'Flume',
          'subtitle': 'Electronic beats',
          'icon': Icons.radio_rounded,
          'color': const Color(0xFFF9C74F),
          'bg': const Color(0xFF1A170F),
        },
        {
          'title': 'Kylie Minogue',
          'subtitle': 'Pop princess',
          'icon': Icons.favorite_rounded,
          'color': const Color(0xFFF3722C),
          'bg': const Color(0xFF1A0F0C),
        },
      ],
      'CA': [
        {
          'title': 'Drake',
          'subtitle': 'OVO Sound',
          'icon': Icons.bolt_rounded,
          'color': const Color(0xFF1ED760),
          'bg': const Color(0xFF0F1A13),
        },
        {
          'title': 'The Weeknd',
          'subtitle': 'Starboy',
          'icon': Icons.mic_rounded,
          'color': const Color(0xFFE63946),
          'bg': const Color(0xFF1A0D0E),
        },
        {
          'title': 'Justin Bieber',
          'subtitle': 'Pop superstar',
          'icon': Icons.star_rounded,
          'color': const Color(0xFF4CC9F0),
          'bg': const Color(0xFF0C191C),
        },
        {
          'title': 'Celine Dion',
          'subtitle': 'Vocal legend',
          'icon': Icons.favorite_rounded,
          'color': const Color(0xFFF72585),
          'bg': const Color(0xFF1A0814),
        },
        {
          'title': 'Shawn Mendes',
          'subtitle': 'Pop rock',
          'icon': Icons.headphones_rounded,
          'color': const Color(0xFFFF6B35),
          'bg': const Color(0xFF1C1510),
        },
        {
          'title': 'Shania Twain',
          'subtitle': 'Country pop',
          'icon': Icons.music_note_rounded,
          'color': const Color(0xFFF9C74F),
          'bg': const Color(0xFF1A170F),
        },
        {
          'title': 'Avril Lavigne',
          'subtitle': 'Pop punk',
          'icon': Icons.radio_rounded,
          'color': const Color(0xFF6C63FF),
          'bg': const Color(0xFF1A1730),
        },
        {
          'title': 'Michael Bublé',
          'subtitle': 'Jazz & Pop',
          'icon': Icons.mic_none_rounded,
          'color': const Color(0xFFF3722C),
          'bg': const Color(0xFF1A0F0C),
        },
      ],
      'NL': [
        {
          'title': 'Martin Garrix',
          'subtitle': 'EDM superstar',
          'icon': Icons.headphones_rounded,
          'color': const Color(0xFF4CC9F0),
          'bg': const Color(0xFF0C191C),
        },
        {
          'title': 'Tiësto',
          'subtitle': 'Trance legend',
          'icon': Icons.bolt_rounded,
          'color': const Color(0xFFE63946),
          'bg': const Color(0xFF1A0D0E),
        },
        {
          'title': 'Armin van Buuren',
          'subtitle': 'A State of Trance',
          'icon': Icons.radio_rounded,
          'color': const Color(0xFF6C63FF),
          'bg': const Color(0xFF1A1730),
        },
        {
          'title': 'Duncan Laurence',
          'subtitle': 'Arcade',
          'icon': Icons.mic_rounded,
          'color': const Color(0xFFF9C74F),
          'bg': const Color(0xFF1A170F),
        },
        {
          'title': 'Afrojack',
          'subtitle': 'Electronic hits',
          'icon': Icons.local_fire_department_rounded,
          'color': const Color(0xFFFF6B35),
          'bg': const Color(0xFF1C1510),
        },
        {
          'title': 'Snelle',
          'subtitle': 'Dutch rap',
          'icon': Icons.music_note_rounded,
          'color': const Color(0xFF1ED760),
          'bg': const Color(0xFF0F1A13),
        },
        {
          'title': 'Davina Michelle',
          'subtitle': 'Pop vocals',
          'icon': Icons.star_rounded,
          'color': const Color(0xFFF72585),
          'bg': const Color(0xFF1A0814),
        },
        {
          'title': 'Frenna',
          'subtitle': 'Urban pop',
          'icon': Icons.favorite_rounded,
          'color': const Color(0xFFF3722C),
          'bg': const Color(0xFF1A0F0C),
        },
      ],
      'SE': [
        {
          'title': 'ABBA',
          'subtitle': 'Dancing Queen',
          'icon': Icons.star_rounded,
          'color': const Color(0xFFF9C74F),
          'bg': const Color(0xFF1A170F),
        },
        {
          'title': 'Avicii',
          'subtitle': 'Wake Me Up',
          'icon': Icons.headphones_rounded,
          'color': const Color(0xFF4CC9F0),
          'bg': const Color(0xFF0C191C),
        },
        {
          'title': 'Swedish House Mafia',
          'subtitle': 'House legends',
          'icon': Icons.bolt_rounded,
          'color': const Color(0xFFE63946),
          'bg': const Color(0xFF1A0D0E),
        },
        {
          'title': 'Zara Larsson',
          'subtitle': 'Pop hits',
          'icon': Icons.mic_rounded,
          'color': const Color(0xFFF72585),
          'bg': const Color(0xFF1A0814),
        },
        {
          'title': 'Tove Lo',
          'subtitle': 'Habits',
          'icon': Icons.favorite_rounded,
          'color': const Color(0xFF6C63FF),
          'bg': const Color(0xFF1A1730),
        },
        {
          'title': 'Roxette',
          'subtitle': 'Listen To Your Heart',
          'icon': Icons.radio_rounded,
          'color': const Color(0xFFFF6B35),
          'bg': const Color(0xFF1C1510),
        },
        {
          'title': 'Robyn',
          'subtitle': 'Dancing On My Own',
          'icon': Icons.music_note_rounded,
          'color': const Color(0xFF1ED760),
          'bg': const Color(0xFF0F1A13),
        },
        {
          'title': 'Alesso',
          'subtitle': 'Progressive house',
          'icon': Icons.local_fire_department_rounded,
          'color': const Color(0xFFF3722C),
          'bg': const Color(0xFF1A0F0C),
        },
      ],
      'PL': [
        {
          'title': 'Dawid Podsiadło',
          'subtitle': 'Pop rock',
          'icon': Icons.mic_rounded,
          'color': const Color(0xFF1ED760),
          'bg': const Color(0xFF0F1A13),
        },
        {
          'title': 'sanah',
          'subtitle': 'Indie pop',
          'icon': Icons.favorite_rounded,
          'color': const Color(0xFFF72585),
          'bg': const Color(0xFF1A0814),
        },
        {
          'title': 'Taco Hemingway',
          'subtitle': 'Hip hop',
          'icon': Icons.headphones_rounded,
          'color': const Color(0xFF4CC9F0),
          'bg': const Color(0xFF0C191C),
        },
        {
          'title': 'Mata',
          'subtitle': 'Polish rap',
          'icon': Icons.bolt_rounded,
          'color': const Color(0xFFE63946),
          'bg': const Color(0xFF1A0D0E),
        },
        {
          'title': 'Quebonafide',
          'subtitle': 'Rap star',
          'icon': Icons.star_rounded,
          'color': const Color(0xFFF9C74F),
          'bg': const Color(0xFF1A170F),
        },
        {
          'title': 'Daria Zawiałow',
          'subtitle': 'Alternative',
          'icon': Icons.music_note_rounded,
          'color': const Color(0xFF6C63FF),
          'bg': const Color(0xFF1A1730),
        },
        {
          'title': 'Krzysztof Krawczyk',
          'subtitle': 'Legend',
          'icon': Icons.radio_rounded,
          'color': const Color(0xFFFF6B35),
          'bg': const Color(0xFF1C1510),
        },
        {
          'title': 'Oki',
          'subtitle': 'New wave rap',
          'icon': Icons.local_fire_department_rounded,
          'color': const Color(0xFFF3722C),
          'bg': const Color(0xFF1A0F0C),
        },
      ],
      'ZA': [
        {
          'title': 'Black Coffee',
          'subtitle': 'House maestro',
          'icon': Icons.headphones_rounded,
          'color': const Color(0xFF4CC9F0),
          'bg': const Color(0xFF0C191C),
        },
        {
          'title': 'Master KG',
          'subtitle': 'Jerusalema',
          'icon': Icons.public_rounded,
          'color': const Color(0xFF1ED760),
          'bg': const Color(0xFF0F1A13),
        },
        {
          'title': 'Cassper Nyovest',
          'subtitle': 'Hip hop',
          'icon': Icons.mic_rounded,
          'color': const Color(0xFFF9C74F),
          'bg': const Color(0xFF1A170F),
        },
        {
          'title': 'Nasty C',
          'subtitle': 'Rap star',
          'icon': Icons.bolt_rounded,
          'color': const Color(0xFFE63946),
          'bg': const Color(0xFF1A0D0E),
        },
        {
          'title': 'Sho Madjozi',
          'subtitle': 'John Cena',
          'icon': Icons.star_rounded,
          'color': const Color(0xFFF72585),
          'bg': const Color(0xFF1A0814),
        },
        {
          'title': 'DJ Maphorisa',
          'subtitle': 'Amapiano',
          'icon': Icons.radio_rounded,
          'color': const Color(0xFF6C63FF),
          'bg': const Color(0xFF1A1730),
        },
        {
          'title': 'Kabza De Small',
          'subtitle': 'Amapiano King',
          'icon': Icons.music_note_rounded,
          'color': const Color(0xFFFF6B35),
          'bg': const Color(0xFF1C1510),
        },
        {
          'title': 'Miriam Makeba',
          'subtitle': 'Mama Africa',
          'icon': Icons.favorite_rounded,
          'color': const Color(0xFFF3722C),
          'bg': const Color(0xFF1A0F0C),
        },
      ],
      'NG': [
        {
          'title': 'Burna Boy',
          'subtitle': 'African Giant',
          'icon': Icons.public_rounded,
          'color': const Color(0xFF1ED760),
          'bg': const Color(0xFF0F1A13),
        },
        {
          'title': 'Wizkid',
          'subtitle': 'Starboy',
          'icon': Icons.star_rounded,
          'color': const Color(0xFFF9C74F),
          'bg': const Color(0xFF1A170F),
        },
        {
          'title': 'Davido',
          'subtitle': 'Afrobeats King',
          'icon': Icons.mic_rounded,
          'color': const Color(0xFF4CC9F0),
          'bg': const Color(0xFF0C191C),
        },
        {
          'title': 'Rema',
          'subtitle': 'Calm Down',
          'icon': Icons.bolt_rounded,
          'color': const Color(0xFFE63946),
          'bg': const Color(0xFF1A0D0E),
        },
        {
          'title': 'Asake',
          'subtitle': 'Mr. Money',
          'icon': Icons.local_fire_department_rounded,
          'color': const Color(0xFFF72585),
          'bg': const Color(0xFF1A0814),
        },
        {
          'title': 'Tiwa Savage',
          'subtitle': 'Afrobeats Queen',
          'icon': Icons.favorite_rounded,
          'color': const Color(0xFF6C63FF),
          'bg': const Color(0xFF1A1730),
        },
        {
          'title': 'Olamide',
          'subtitle': 'Baddo',
          'icon': Icons.headphones_rounded,
          'color': const Color(0xFFFF6B35),
          'bg': const Color(0xFF1C1510),
        },
        {
          'title': 'Fireboy DML',
          'subtitle': 'Peru',
          'icon': Icons.music_note_rounded,
          'color': const Color(0xFFF3722C),
          'bg': const Color(0xFF1A0F0C),
        },
      ],
      'PH': [
        {
          'title': 'Ben&Ben',
          'subtitle': 'Folk pop',
          'icon': Icons.people_rounded,
          'color': const Color(0xFFF9C74F),
          'bg': const Color(0xFF1A170F),
        },
        {
          'title': 'Moira Dela Torre',
          'subtitle': 'Emotional ballads',
          'icon': Icons.mic_rounded,
          'color': const Color(0xFFF72585),
          'bg': const Color(0xFF1A0814),
        },
        {
          'title': 'Zack Tabudlo',
          'subtitle': 'Binibini',
          'icon': Icons.headphones_rounded,
          'color': const Color(0xFF4CC9F0),
          'bg': const Color(0xFF0C191C),
        },
        {
          'title': 'Arthur Nery',
          'subtitle': 'R&B / Soul',
          'icon': Icons.music_note_rounded,
          'color': const Color(0xFF6C63FF),
          'bg': const Color(0xFF1A1730),
        },
        {
          'title': 'SB19',
          'subtitle': 'P-Pop kings',
          'icon': Icons.star_rounded,
          'color': const Color(0xFF1ED760),
          'bg': const Color(0xFF0F1A13),
        },
        {
          'title': 'Eraserheads',
          'subtitle': 'Legendary band',
          'icon': Icons.radio_rounded,
          'color': const Color(0xFFE63946),
          'bg': const Color(0xFF1A0D0E),
        },
        {
          'title': 'Sarah Geronimo',
          'subtitle': 'Pop superstar',
          'icon': Icons.favorite_rounded,
          'color': const Color(0xFFFF6B35),
          'bg': const Color(0xFF1C1510),
        },
        {
          'title': 'December Avenue',
          'subtitle': 'Alt pop',
          'icon': Icons.bolt_rounded,
          'color': const Color(0xFFF3722C),
          'bg': const Color(0xFF1A0F0C),
        },
      ],
    };

    final defaultArtists = [
      {
        'title': 'Taylor Swift',
        'subtitle': 'The Eras Tour essentials',
        'icon': Icons.auto_awesome_rounded,
        'color': const Color(0xFFF72585),
        'bg': const Color(0xFF1A0814),
      },
      {
        'title': 'The Weeknd',
        'subtitle': 'Starboy, Blinding Lights',
        'icon': Icons.mic_rounded,
        'color': const Color(0xFF6C63FF),
        'bg': const Color(0xFF1A1730),
      },
      {
        'title': 'Eminem',
        'subtitle': 'The Rap God himself',
        'icon': Icons.radio_rounded,
        'color': const Color(0xFFE63946),
        'bg': const Color(0xFF1A0D0E),
      },
      {
        'title': 'Drake',
        'subtitle': 'OVO Sound hits',
        'icon': Icons.library_music_rounded,
        'color': const Color(0xFF1ED760),
        'bg': const Color(0xFF0F1A13),
      },
      {
        'title': 'Ariana Grande',
        'subtitle': 'Pop perfection',
        'icon': Icons.star_rounded,
        'color': const Color(0xFF4CC9F0),
        'bg': const Color(0xFF0C191C),
      },
      {
        'title': 'Billie Eilish',
        'subtitle': 'Alternative pop vibes',
        'icon': Icons.headphones_rounded,
        'color': const Color(0xFFF9C74F),
        'bg': const Color(0xFF1A170F),
      },
      {
        'title': 'Bruno Mars',
        'subtitle': '24K Magic',
        'icon': Icons.music_note_rounded,
        'color': const Color(0xFFFF6B35),
        'bg': const Color(0xFF1C1510),
      },
      {
        'title': 'Kendrick Lamar',
        'subtitle': 'Compton\'s finest',
        'icon': Icons.bolt_rounded,
        'color': const Color(0xFF7209B7),
        'bg': const Color(0xFF13091A),
      },
      {
        'title': 'Post Malone',
        'subtitle': 'Hip-hop / Pop blend',
        'icon': Icons.local_fire_department_rounded,
        'color': const Color(0xFFF3722C),
        'bg': const Color(0xFF1A0F0C),
      },
      {
        'title': 'Beyoncé',
        'subtitle': 'Queen Bey',
        'icon': Icons.favorite_rounded,
        'color': const Color(0xFFF72585),
        'bg': const Color(0xFF1A0814),
      },
    ];

    final artists = countryTopArtists[country] ?? defaultArtists;

    return artists.map((artist) {
      return _buildFanTestCard(
        context,
        title: artist['title'] as String,
        subtitle: artist['subtitle'] as String,
        stat: context.l10n.recordScore(
          storage.getFanTestHighScore(artist['title'] as String),
        ),
        accentColor: artist['color'] as Color,
        bgColor: artist['bg'] as Color,
        icon: artist['icon'] as IconData,
        isNew: (artist['isNew'] as bool?) ?? false,
        onTap: () =>
            _startGame(context, GameMode.fanTest, artist['title'] as String),
      );
    }).toList();
  }

  void _showDailyReplayDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E28),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.calendar_today_rounded, color: Color(0xFF1ED760)),
            SizedBox(width: 10),
            Text('Günün Şarkısı', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Bugünkü resmi mücadeleyi zaten tamamladın! 🏆\n\nKısa bir video izleyerek tekrar pratik yapabilir ve kendini test edebilirsin.',
          style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Kapat', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1ED760),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              final adService = context.read<AdService>();
              adService.showRewardedAd(
                onUserEarnedReward: () {
                  _startGame(context, GameMode.daily, '');
                },
                onAdFailed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Reklam yüklenemedi, lütfen tekrar deneyin.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              );
            },
            icon: const Icon(Icons.play_circle_filled_rounded, color: Colors.black, size: 20),
            label: const Text(
              'Video İzle ve Oyna',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _startGame(BuildContext context, GameMode mode, String parameter) {
    context.read<GameBloc>().add(
      GameStarted(
        mode: mode,
        modeParameter: parameter.isNotEmpty ? parameter : null,
      ),
    );
    context.go('/game');
  }

  Widget _buildFanTestCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String stat,
    required Color accentColor,
    required Color bgColor,
    required IconData icon,
    required VoidCallback onTap,
    bool isNew = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 215,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: accentColor.withValues(alpha: 0.4)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Background blur glow
              Positioned(
                bottom: -30,
                right: -30,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accentColor.withValues(alpha: 0.25),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
              // Large faded icon as background art
              Positioned(
                bottom: -8,
                right: -8,
                child: Icon(
                  icon,
                  size: 90,
                  color: accentColor.withValues(alpha: 0.12),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              Icon(icon, color: accentColor, size: 11),
                              4.w,
                              Text(
                                context.l10n.tenSongs,
                                style: context.typography.labelSmall?.copyWith(
                                  color: accentColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isNew) ...[
                          6.w,
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1ED760),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              context.l10n.badgeNew,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    10.h,
                    Text(
                      title,
                      style: context.typography.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    4.h,
                    Text(
                      subtitle,
                      style: context.typography.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 11,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          stat,
                          style: context.typography.labelSmall?.copyWith(
                            color: accentColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: accentColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.black,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterPill(
    BuildContext context,
    String label,
    String filterKey,
  ) {
    final isSelected = _selectedFilter == filterKey;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = filterKey),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1ED760) : const Color(0xFF181820),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF1ED760)
                : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildGenreCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String badge,
    required Color badgeColor,
    required String difficulty,
    required String accuracy,
    required double progress,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF181820),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Album Art
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradientColors,
                ),
              ),
              child: const Icon(
                Icons.music_note_rounded,
                color: Colors.white54,
                size: 32,
              ),
            ),
            16.w,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          badge,
                          style: context.typography.labelSmall?.copyWith(
                            color: badgeColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        difficulty,
                        style: context.typography.labelSmall?.copyWith(
                          color: const Color(0xFFB3B3B3),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  8.h,
                  Text(
                    title,
                    style: context.typography.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  4.h,
                  Text(
                    subtitle,
                    style: context.typography.bodySmall?.copyWith(
                      color: const Color(0xFFB3B3B3),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  12.h,
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: const Color(0xFF2A2A35),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF1ED760),
                      ),
                      minHeight: 4,
                    ),
                  ),
                  12.h,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.check_circle_outline_rounded,
                            color: Color(0xFFB3B3B3),
                            size: 14,
                          ),
                          4.w,
                          Text(
                            accuracy,
                            style: context.typography.labelSmall?.copyWith(
                              color: const Color(0xFFB3B3B3),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1ED760),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Text(
                              context.l10n.playButton,
                              style: context.typography.labelMedium?.copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            4.w,
                            const Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.black,
                              size: 14,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getAccuracyText(LocalStorageService storage, String category) {
    final played = storage.getCategoryPlayed(category);
    if (played == 0) return '0% Başarı';
    final won = storage.getCategoryWon(category);
    final accuracy = (won / played) * 100;
    return '${accuracy.toInt()}% Başarı';
  }

  double _getAccuracyProgress(LocalStorageService storage, String category) {
    final played = storage.getCategoryPlayed(category);
    if (played == 0) return 0.0;
    final won = storage.getCategoryWon(category);
    return won / played;
  }
}
