import 'package:flutter/material.dart';
import 'package:melocue/core/utils/context_extensions.dart';
import 'package:melocue/features/game/presentation/widgets/melocue_app_bar.dart';
import 'package:melocue/features/game/presentation/widgets/edit_profile_dialog.dart';
import 'package:melocue/features/game/presentation/bloc/ranks/ranks_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:melocue/features/game/presentation/bloc/ranks/ranks_state.dart';
import 'package:melocue/features/game/data/datasources/local_storage_service.dart';
import 'package:melocue/features/game/presentation/widgets/banner_ad_widget.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    MelocueAppBar(
                      title: 'Melocue',
                      subtitle: context.l10n.statsTitle,
                    ),
                    24.h,
                    _buildProfileCard(context),
                    24.h,
                    _buildGridStats(context),
                    24.h,
                    _buildGuessDistribution(context),
                    24.h,
                    _buildGenreDNA(context),
                    24.h,
                    _buildLastSolvedVictory(context),
                    24.h,
                    const BannerAdWidget(),
                    40.h,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // bottomNavigationBar is handled by MainScaffold
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    return BlocBuilder<RanksBloc, RanksState>(
      builder: (context, state) {
        String displayName = context.l10n.player;
        int points = 0;
        if (state is RanksLoaded && state.currentUserEntry != null) {
          displayName = state.currentUserEntry!.displayName;
          points = state.currentUserEntry!.points;
        }

        final level = (points / 1000).floor() + 1;
        final currentXp = points % 1000;
        final nextLevelXp = 1000;

        String userTitle = context.l10n.novice;
        if (level >= 5) userTitle = context.l10n.risingStar;
        if (level >= 10) userTitle = context.l10n.soundMaestro;
        if (level >= 20) userTitle = context.l10n.musicDeity;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF181820),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF2A2A35)),
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.bottomCenter,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF1ED760),
                            width: 2,
                          ),
                          color: const Color(0xFF2A2A35),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white54,
                          size: 32,
                        ),
                      ),
                      Positioned(
                        bottom: -8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1ED760),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.flash_on_rounded,
                                color: Colors.black,
                                size: 10,
                              ),
                              Text(
                                context.l10n.lvlText(level),
                                style: context.typography.labelSmall?.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 9,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  16.w,
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                displayName,
                                style: context.typography.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            4.w,
                            const Icon(
                              Icons.check_circle_rounded,
                              color: Color(0xFF1ED760),
                              size: 16,
                            ),
                          ],
                        ),
                        2.h,
                        Text(
                          '@${displayName.replaceAll(' ', '').toLowerCase()}',
                          style: context.typography.bodySmall?.copyWith(
                            color: const Color(0xFFB3B3B3),
                          ),
                        ),
                        8.h,
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF9D4EDD)
                                    .withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFF9D4EDD)
                                      .withValues(alpha: 0.5),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    color: Color(0xFFD4B3F7),
                                    size: 12,
                                  ),
                                  4.w,
                                  Text(
                                    userTitle,
                                    style: context.typography.labelSmall
                                        ?.copyWith(
                                          color: const Color(0xFFD4B3F7),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              24.h,
              // XP Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.l10n.levelProgressText(level, level + 1),
                    style: context.typography.labelSmall?.copyWith(
                      color: const Color(0xFF1ED760),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    context.l10n.xpProgressText(currentXp, nextLevelXp),
                    style: context.typography.labelSmall?.copyWith(
                      color: const Color(0xFFB3B3B3),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              8.h,
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: currentXp / nextLevelXp,
                  backgroundColor: const Color(0xFF2A2A35),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF1ED760),
                  ),
                  minHeight: 6,
                ),
              ),
              8.h,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.hourglass_empty_rounded,
                        color: Color(0xFFF9C74F),
                        size: 12,
                      ),
                      4.w,
                      Text(
                        context.l10n.xpToNextLevel(
                          nextLevelXp - currentXp,
                          level + 1,
                        ),
                        style: context.typography.labelSmall?.copyWith(
                          color: const Color(0xFFB3B3B3),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    context.l10n.totalXp(points),
                    style: context.typography.labelSmall?.copyWith(
                      color: const Color(0xFFB3B3B3),
                    ),
                  ),
                ],
              ),
              24.h,
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        showEditProfileDialog(context, displayName);
                      },
                      icon: const Icon(
                        Icons.edit_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                      label: Text(context.l10n.editProfile),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFF2A2A35)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGridStats(BuildContext context) {
    final storage = context.read<LocalStorageService>();
    final played = storage.gamesPlayed;
    final won = storage.gamesWon;
    final winRate = played > 0 ? ((won / played) * 100).round() : 0;
    final currentStreak = storage.currentStreak;
    final bestStreak = storage.maxStreak;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildGridCard(
                context,
                title: context.l10n.challenges,
                icon: Icons.gamepad_rounded,
                iconColor: const Color(0xFF9D4EDD),
                content: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '$played',
                      style: context.typography.headlineLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                footer: Text(
                  context.l10n.totalPlayed,
                  style: context.typography.labelSmall?.copyWith(
                    color: const Color(0xFFB3B3B3),
                  ),
                ),
              ),
            ),
            12.w,
            Expanded(
              child: _buildGridCard(
                context,
                title: context.l10n.winRate,
                icon: Icons.pie_chart_rounded,
                iconColor: const Color(0xFFF9C74F),
                content: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '$winRate%',
                      style: context.typography.headlineLarge?.copyWith(
                        color: const Color(0xFF1ED760),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                footer: Text(
                  context.l10n.solvedCount(won),
                  style: context.typography.labelSmall?.copyWith(
                    color: const Color(0xFFB3B3B3),
                  ),
                ),
              ),
            ),
          ],
        ),
        12.h,
        Row(
          children: [
            Expanded(
              child: _buildGridCard(
                context,
                title: context.l10n.currentStreakTitle,
                icon: Icons.local_fire_department_rounded,
                iconColor: const Color(0xFFF3722C),
                content: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '$currentStreak',
                      style: context.typography.headlineLarge?.copyWith(
                        color: const Color(0xFFF9C74F),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    4.w,
                    Text(
                      context.l10n.days,
                      style: context.typography.labelSmall?.copyWith(
                        color: const Color(0xFFB3B3B3),
                      ),
                    ),
                  ],
                ),
                footer: Text(
                  context.l10n.activeDays,
                  style: context.typography.labelSmall?.copyWith(
                    color: const Color(0xFFB3B3B3),
                  ),
                ),
              ),
            ),
            12.w,
            Expanded(
              child: _buildGridCard(
                context,
                title: context.l10n.bestStreakTitle,
                icon: Icons.emoji_events_rounded,
                iconColor: const Color(0xFF1ED760),
                content: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '$bestStreak',
                      style: context.typography.headlineLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    4.w,
                    Text(
                      context.l10n.days,
                      style: context.typography.labelSmall?.copyWith(
                        color: const Color(0xFFB3B3B3),
                      ),
                    ),
                  ],
                ),
                footer: Text(
                  context.l10n.allTimeHigh,
                  style: context.typography.labelSmall?.copyWith(
                    color: const Color(0xFFB3B3B3),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGridCard(
    BuildContext context, {
    required String title,
    IconData? icon,
    Color? iconColor,
    Widget? trailing,
    required Widget content,
    required Widget footer,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF181820),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2A2A35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: context.typography.labelMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (trailing != null)
                trailing
              else if (icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: (iconColor ?? Colors.white).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 14),
                ),
              ],
            ],
          ),
          16.h,
          content,
          8.h,
          footer,
        ],
      ),
    );
  }

  Widget _buildGuessDistribution(BuildContext context) {
    final storage = context.read<LocalStorageService>();
    final counts = List.generate(6, (i) => storage.getGuessCount(i));
    int maxCount = counts.isEmpty ? 0 : counts.reduce((a, b) => a > b ? a : b);
    if (maxCount == 0) maxCount = 1; // Prevent division by zero

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF181820),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF2A2A35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                context.l10n.guessDistribution,
                style: context.typography.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              8.w,
              const Icon(
                Icons.bar_chart_rounded,
                color: Color(0xFF1ED760),
                size: 18,
              ),
            ],
          ),
          4.h,
          Text(
            context.l10n.guessDistributionDesc,
            style: context.typography.bodySmall?.copyWith(
              color: const Color(0xFFB3B3B3),
            ),
          ),
          16.h,
          _buildDistributionBar(
            context,
            label: '0.5s',
            value: counts[0],
            percentage: counts[0] / maxCount,
            color: const Color(0xFF1ED760),
            isPeak: counts[0] > 0 && counts[0] == maxCount,
          ),
          8.h,
          _buildDistributionBar(
            context,
            label: '1.5s',
            value: counts[1],
            percentage: counts[1] / maxCount,
            color: const Color(0xFF1ED760),
            isPeak: counts[1] > 0 && counts[1] == maxCount,
          ),
          8.h,
          _buildDistributionBar(
            context,
            label: '5.0s',
            value: counts[2],
            percentage: counts[2] / maxCount,
            color: const Color(0xFF9D4EDD),
            isPeak: counts[2] > 0 && counts[2] == maxCount,
          ),
          8.h,
          _buildDistributionBar(
            context,
            label: '10s',
            value: counts[3],
            percentage: counts[3] / maxCount,
            color: counts[3] > 0
                ? const Color(0xFF9D4EDD)
                : const Color(0xFF2A2A35),
            textColor: counts[3] > 0 ? Colors.white : const Color(0xFFB3B3B3),
            isPeak: counts[3] > 0 && counts[3] == maxCount,
          ),
          8.h,
          _buildDistributionBar(
            context,
            label: '20s',
            value: counts[4],
            percentage: counts[4] / maxCount,
            color: counts[4] > 0
                ? const Color(0xFF9D4EDD)
                : const Color(0xFF2A2A35),
            textColor: counts[4] > 0 ? Colors.white : const Color(0xFFB3B3B3),
            isPeak: counts[4] > 0 && counts[4] == maxCount,
          ),
          8.h,
          _buildDistributionBar(
            context,
            label: context.l10n.fail,
            value: counts[5],
            percentage: counts[5] / maxCount,
            color: counts[5] > 0
                ? const Color(0xFFF3722C)
                : const Color(0xFF2A2A35),
            textColor: counts[5] > 0 ? Colors.white : const Color(0xFFB3B3B3),
            isPeak: counts[5] > 0 && counts[5] == maxCount,
          ),
        ],
      ),
    );
  }

  Widget _buildDistributionBar(
    BuildContext context, {
    required String label,
    required int value,
    required double percentage,
    required Color color,
    Color textColor = Colors.black,
    bool isPeak = false,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 36,
          child: Text(
            label,
            style: context.typography.labelMedium?.copyWith(
              color: const Color(0xFFB3B3B3),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        8.w,
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final barWidth = constraints.maxWidth * percentage;
              final showContent = barWidth > 40;
              return Stack(
                children: [
                  Container(
                    height: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFF181820),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 24,
                      width: barWidth,
                      color: color,
                      padding: showContent
                          ? const EdgeInsets.symmetric(horizontal: 8)
                          : EdgeInsets.zero,
                      child: showContent
                          ? Row(
                              mainAxisAlignment: isPeak
                                  ? MainAxisAlignment.spaceBetween
                                  : MainAxisAlignment.end,
                              children: [
                                if (isPeak)
                                  const Icon(
                                    Icons.star_border_rounded,
                                    color: Colors.black,
                                    size: 14,
                                  ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '$value',
                                      style: TextStyle(
                                        color: textColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                    if (isPeak) ...[
                                      4.w,
                                      Text(
                                        context.l10n.peak,
                                        style: TextStyle(
                                          color: textColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            )
                          : null,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGenreDNA(BuildContext context) {
    final storage = context.read<LocalStorageService>();
    final topGenres = storage.getTopGenres();

    if (topGenres.isEmpty) {
      return const SizedBox.shrink();
    }

    final totalGenresCount = topGenres.fold<int>(
      0,
      (sum, entry) => sum + entry.value,
    );
    final top4 = topGenres.take(4).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF181820),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF2A2A35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.genreDna,
                    style: context.typography.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  4.h,
                  Text(
                    context.l10n.genreDnaDesc,
                    style: context.typography.bodySmall?.copyWith(
                      color: const Color(0xFFB3B3B3),
                    ),
                  ),
                ],
              ),
              const Icon(
                Icons.fingerprint_rounded,
                color: Color(0xFFD4B3F7),
                size: 24,
              ),
            ],
          ),
          24.h,
          ...top4.asMap().entries.map((entry) {
            final index = entry.key;
            final genreEntry = entry.value;
            final percentage = ((genreEntry.value / totalGenresCount) * 100)
                .round();

            // Assign colors and tiers dynamically based on rank
            Color color;
            Color tierColor;
            IconData icon;
            String tier;

            if (index == 0) {
              tier = context.l10n.diamond;
              color = const Color(0xFF9D4EDD);
              tierColor = const Color(0xFFD4B3F7);
              icon = Icons.diamond_rounded;
            } else if (index == 1) {
              tier = context.l10n.gold;
              color = const Color(0xFF1ED760);
              tierColor = const Color(0xFF1ED760);
              icon = Icons.emoji_events_rounded;
            } else if (index == 2) {
              tier = context.l10n.silver;
              color = const Color(0xFFF9C74F);
              tierColor = const Color(0xFFF9C74F);
              icon = Icons.military_tech_rounded;
            } else {
              tier = context.l10n.bronze;
              color = const Color(0xFFF3722C);
              tierColor = const Color(0xFFF3722C);
              icon = Icons.military_tech_rounded;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: _buildGenreBar(
                context,
                genre: genreEntry.key,
                tier: tier,
                percentage: percentage,
                color: color,
                tierColor: tierColor,
                icon: icon,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildGenreBar(
    BuildContext context, {
    required String genre,
    required String tier,
    required int percentage,
    required Color color,
    required Color tierColor,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.album_outlined, color: Colors.white70, size: 16),
                8.w,
                Text(
                  genre,
                  style: context.typography.labelMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withValues(alpha: 0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: tierColor, size: 12),
                  4.w,
                  Text(
                    '$tier $percentage%',
                    style: context.typography.labelSmall?.copyWith(
                      color: tierColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        8.h,
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: const Color(0xFF2A2A35),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildLastSolvedVictory(BuildContext context) {
    final storage = context.read<LocalStorageService>();
    final trackName = storage.lastSolvedTrackName;
    final artistName = storage.lastSolvedArtistName;
    final artUrl = storage.lastSolvedAlbumArt;

    if (trackName == null || artistName == null || artUrl == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF181820),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF2A2A35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n.lastSolvedVictory,
                style: context.typography.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                context.l10n.recent,
                style: context.typography.labelSmall?.copyWith(
                  color: const Color(0xFFB3B3B3),
                ),
              ),
            ],
          ),
          16.h,
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0xFF2A2A35),
                  image: DecorationImage(
                    image: NetworkImage(artUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              16.w,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trackName,
                      style: context.typography.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    4.h,
                    Text(
                      artistName,
                      style: context.typography.bodySmall?.copyWith(
                        color: const Color(0xFFB3B3B3),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
