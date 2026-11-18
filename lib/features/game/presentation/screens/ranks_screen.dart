import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:melocue/core/utils/context_extensions.dart';
import 'package:melocue/features/game/presentation/bloc/ranks/ranks_bloc.dart';
import 'package:melocue/features/game/presentation/bloc/ranks/ranks_state.dart';
import 'package:melocue/features/game/domain/entities/leaderboard_entry.dart';
import 'package:melocue/features/game/presentation/widgets/melocue_app_bar.dart';
import 'package:melocue/features/game/presentation/widgets/banner_ad_widget.dart';

class RanksScreen extends StatelessWidget {
  const RanksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(left: 24.0, right: 24.0, top: 16.0),
                child: MelocueAppBar(
                  title: 'Melocue',
                  subtitle: context.l10n.leaderboardsTitle,
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    24.h,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.l10n.leaderboardsTitle,
                                style: context.typography.headlineMedium
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                    ),
                              ),
                              4.h,
                              Text(
                                context.l10n.leaderboardsSubtitle,
                                style: context.typography.bodyMedium?.copyWith(
                                  color: const Color(0xFFB3B3B3),
                                ),
                              ),
                            ],
                          ),
                        ),
                        16.w,
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF181820),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFFF9C74F)
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.timer_outlined,
                                color: Color(0xFFF9C74F),
                                size: 14,
                              ),
                              6.w,
                              Text(
                                '08:42:12',
                                style: context.typography.labelSmall?.copyWith(
                                  color: const Color(0xFFF9C74F),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    24.h,

                    // Podium
                    BlocBuilder<RanksBloc, RanksState>(
                      builder: (context, state) {
                        if (state is RanksLoaded && state.entries.isNotEmpty) {
                          return _buildPodium(context, state.entries);
                        } else if (state is RanksLoading) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF1ED760),
                            ),
                          );
                        } else {
                          return const SizedBox();
                        }
                      },
                    ),

                    32.h,

                    // Current User Rank
                    BlocBuilder<RanksBloc, RanksState>(
                      builder: (context, state) {
                        if (state is RanksLoaded &&
                            state.currentUserEntry != null) {
                          return _buildCurrentUserCard(
                            context,
                            rank: state.currentUserRank,
                            entry: state.currentUserEntry!,
                          );
                        }
                        return const SizedBox();
                      },
                    ),

                    16.h,

                    24.h,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          context.l10n.rankAndPlayer,
                          style: context.typography.labelSmall?.copyWith(
                            color: const Color(0xFFB3B3B3),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Text(
                          context.l10n.pointsAndStreak,
                          style: context.typography.labelSmall?.copyWith(
                            color: const Color(0xFFB3B3B3),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    16.h,
                  ],
                ),
              ),
            ),

            // Leaderboard List
            BlocBuilder<RanksBloc, RanksState>(
              builder: (context, state) {
                if (state is RanksLoaded) {
                  final listEntries = state.entries.length > 3
                      ? state.entries.sublist(3)
                      : <LeaderboardEntry>[];
                  if (listEntries.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Text(
                            context.l10n.noPlayersYet,
                            style: context.typography.bodyMedium?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final entry = listEntries[index];
                        final rank = index + 4; // Because top 3 are on podium
                        return _buildLeaderboardItem(
                          context,
                          rank: rank,
                          name: entry.displayName,
                          isVip: entry.isVip,
                          pts: '${entry.points}',
                          avg: '${entry.avgTime.toStringAsFixed(1)}s',
                          streak: '${entry.streak}',
                          change: 0,
                        );
                      }, childCount: listEntries.length),
                    ),
                  );
                } else if (state is RanksError) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          context.l10n.failedToLoadRanks(state.failure.message),
                          style: context.typography.bodyMedium?.copyWith(
                            color: Colors.red,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                }
                return const SliverToBoxAdapter(child: SizedBox());
              },
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: const BannerAdWidget(),
              ),
            ),
            SliverToBoxAdapter(child: 16.h),
          ],
        ),
      ),
      // bottomNavigationBar is handled by MainScaffold
    );
  }

  Widget _buildPodium(BuildContext context, List<LeaderboardEntry> entries) {
    if (entries.isEmpty) return const SizedBox();

    // We expect up to 3 for podium
    final first = entries.isNotEmpty ? entries[0] : null;
    final second = entries.length > 1 ? entries[1] : null;
    final third = entries.length > 2 ? entries[2] : null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // #2
        if (second != null)
          Expanded(
            child: _buildPodiumAvatar(
              context,
              rank: 2,
              name: second.displayName,
              pts: '${second.points} ${context.l10n.points}',
              avg:
                  '${second.avgTime.toStringAsFixed(1)}s ${context.l10n.average}',
              streak: second.streak,
              color: second.avatarColor,
              size: 80,
              medalIcon: Icons.workspace_premium,
            ),
          )
        else
          const Expanded(child: SizedBox()),

        // #1
        if (first != null)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: _buildPodiumAvatar(
                context,
                rank: 1,
                name: first.displayName,
                pts: '${first.points} ${context.l10n.points}',
                avg:
                    '${first.avgTime.toStringAsFixed(1)}s ${context.l10n.average}',
                streak: first.streak,
                color: first.avatarColor,
                size: 110,
                medalIcon: Icons.workspace_premium,
                isCenter: true,
              ),
            ),
          )
        else
          const Expanded(child: SizedBox()),

        // #3
        if (third != null)
          Expanded(
            child: _buildPodiumAvatar(
              context,
              rank: 3,
              name: third.displayName,
              pts: '${third.points} ${context.l10n.points}',
              avg:
                  '${third.avgTime.toStringAsFixed(1)}s ${context.l10n.average}',
              streak: third.streak,
              color: third.avatarColor,
              size: 80,
              medalIcon: Icons.workspace_premium,
            ),
          )
        else
          const Expanded(child: SizedBox()),
      ],
    );
  }

  Widget _buildPodiumAvatar(
    BuildContext context, {
    required int rank,
    required String name,
    required String pts,
    required String avg,
    required int streak,
    required Color color,
    required double size,
    required IconData medalIcon,
    bool isCenter = false,
  }) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color, width: isCenter ? 4 : 2),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color.withValues(alpha: 0.5), Colors.black],
                ),
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 40),
            ),
            Positioned(
              top: -12,
              child: Icon(medalIcon, color: color, size: isCenter ? 24 : 20),
            ),
            Positioned(
              bottom: -10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '#$rank',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
        if (isCenter) ...[
          20.h,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              context.l10n.soundDeity,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ),
        ] else
          16.h,
        Text(
          name,
          style: context.typography.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        4.h,
        Text(
          pts,
          style: context.typography.labelMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        12.h,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF181820),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isCenter)
                const Icon(Icons.flash_on, color: Color(0xFFF9C74F), size: 12),
              if (isCenter) 4.w,
              Text(
                avg,
                style: context.typography.labelSmall?.copyWith(
                  color: const Color(0xFFB3B3B3),
                ),
              ),
            ],
          ),
        ),
        8.h,
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.local_fire_department_rounded,
              color: Color(0xFFF3722C),
              size: 14,
            ),
            4.w,
            Text(
              '$streak',
              style: context.typography.labelMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        if (isCenter) ...[
          4.h,
          Text(
            context.l10n.streak,
            style: context.typography.labelSmall?.copyWith(
              color: const Color(0xFFF9C74F),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCurrentUserCard(
    BuildContext context, {
    required int rank,
    required LeaderboardEntry entry,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF181820),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF2A2A35)),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                '#$rank',
                style: context.typography.titleLarge?.copyWith(
                  color: const Color(0xFF1ED760),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.arrow_drop_up_rounded,
                    color: Color(0xFF1ED760),
                    size: 16,
                  ),
                  Text(
                    '0',
                    style: context.typography.labelSmall?.copyWith(
                      color: const Color(0xFF1ED760),
                    ),
                  ),
                ],
              ),
            ],
          ),
          16.w,
          Stack(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: entry.avatarColor.withValues(alpha: 0.2),
                  border: Border.all(color: entry.avatarColor),
                ),
                child: Icon(Icons.person, color: entry.avatarColor),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF181820),
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF1ED760),
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          16.w,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        context.l10n.youRankText(entry.displayName),
                        style: context.typography.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (entry.isVip) ...[
                      8.w,
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF9D4EDD),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          context.l10n.vipBadge,
                          style: context.typography.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                8.h,
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${entry.points}',
                            style: context.typography.labelLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            context.l10n.points,
                            style: context.typography.labelSmall?.copyWith(
                              color: const Color(0xFFB3B3B3),
                            ),
                          ),
                        ],
                      ),
                      12.w,
                      Container(
                        width: 1,
                        height: 20,
                        color: const Color(0xFF2A2A35),
                      ),
                      12.w,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.average,
                            style: context.typography.labelSmall?.copyWith(
                              color: const Color(0xFFB3B3B3),
                            ),
                          ),
                          Text(
                            '${entry.avgTime.toStringAsFixed(1)}s',
                            style: context.typography.labelMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      12.w,
                      Container(
                        width: 1,
                        height: 20,
                        color: const Color(0xFF2A2A35),
                      ),
                      12.w,
                      Row(
                        children: [
                          const Icon(
                            Icons.local_fire_department_rounded,
                            color: Color(0xFFF3722C),
                            size: 16,
                          ),
                          4.w,
                          Text(
                            '${entry.streak}',
                            style: context.typography.labelLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
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
          8.w,
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1ED760).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  context.l10n.topFivePercent,
                  style: context.typography.labelSmall?.copyWith(
                    color: const Color(0xFF1ED760),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              8.h,
              Row(
                children: [
                  Text(
                    context.l10n.compareBtn,
                    style: context.typography.labelSmall?.copyWith(
                      color: const Color(0xFFD4B3F7),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFFD4B3F7),
                    size: 16,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardItem(
    BuildContext context, {
    required int rank,
    required String name,
    required bool isVip,
    required String pts,
    required String avg,
    required String streak,
    required int change,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Text(
                    '#$rank',
                    style: context.typography.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (change > 0) ...[
                    2.w,
                    const Icon(
                      Icons.arrow_drop_up_rounded,
                      color: Color(0xFF1ED760),
                      size: 16,
                    ),
                    Text(
                      '$change',
                      style: const TextStyle(
                        color: Color(0xFF1ED760),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ] else if (change < 0) ...[
                    2.w,
                    const Icon(
                      Icons.arrow_drop_down_rounded,
                      color: Color(0xFFF3722C),
                      size: 16,
                    ),
                    Text(
                      '${change.abs()}',
                      style: const TextStyle(
                        color: Color(0xFFF3722C),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ] else ...[
                    6.w,
                    const Text(
                      '-',
                      style: TextStyle(
                        color: Color(0xFFB3B3B3),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          12.w,
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF9D4EDD).withValues(alpha: 0.2),
            ),
            child: const Icon(Icons.person, color: Colors.white54),
          ),
          12.w,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        style: context.typography.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isVip) ...[
                      8.w,
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF9D4EDD),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          context.l10n.vipBadge,
                          style: context.typography.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 8,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                4.h,
                Text(
                  context.l10n.avgAndDailyText(avg),
                  style: context.typography.bodySmall?.copyWith(
                    color: const Color(0xFFB3B3B3),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$pts ${context.l10n.points}',
                style: context.typography.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              4.h,
              Row(
                children: [
                  const Icon(
                    Icons.local_fire_department_rounded,
                    color: Color(0xFFF3722C),
                    size: 12,
                  ),
                  4.w,
                  Text(
                    streak,
                    style: context.typography.labelSmall?.copyWith(
                      color: const Color(0xFFF9C74F),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
