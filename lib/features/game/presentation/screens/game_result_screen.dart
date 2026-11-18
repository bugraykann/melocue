import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:melocue/core/router/route_names.dart';
import 'package:melocue/core/utils/context_extensions.dart';
import 'package:melocue/features/game/presentation/bloc/game_state.dart';
import 'package:melocue/features/game/domain/entities/game_mode.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:melocue/core/services/ad_service.dart';
import 'package:melocue/features/game/data/datasources/local_storage_service.dart';

class GameResultScreen extends StatefulWidget {
  final GameOver state;

  const GameResultScreen({super.key, required this.state});

  @override
  State<GameResultScreen> createState() => _GameResultScreenState();
}

class _GameResultScreenState extends State<GameResultScreen> {
  bool _hasDoubledReward = false;

  GameOver get state => widget.state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D12),
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
                    _buildTopBar(context),
                    16.h,
                    _buildHeader(context),
                    24.h,
                    _buildPerformanceStats(context),
                    32.h,
                    Text(
                      context.l10n.sessionSummary,
                      style: context.typography.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    16.h,
                    _buildSessionTracksList(context),
                    32.h,
                    _buildActionFooter(context),
                    32.h,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // bottomNavigationBar is handled by MainScaffold or omitted for full screen result
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(
            'assets/images/logo.png',
            width: 32,
            height: 32,
            fit: BoxFit.cover,
          ),
        ),
        10.w,
        Text(
          'Melocue',
          style: context.typography.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final modeName = state.mode == GameMode.fanTest
        ? 'FAN TESTİ: ${state.modeParameter?.toUpperCase()}'
        : state.mode == GameMode.category
        ? 'KATEGORİ: ${state.modeParameter?.toUpperCase()}'
        : state.mode == GameMode.myPlaylist
        ? 'KENDİ LİSTEMDEN'
        : 'DAILY MÜCADELE';

    final totalTracks = state.sessionHistory.length;
    final correctTracks = state.sessionHistory.where((i) => i.isVictory).length;
    final isSuccess =
        (correctTracks / (totalTracks > 0 ? totalTracks : 1)) >= 0.5;

    final highlightColor = isSuccess
        ? const Color(0xFF1ED760)
        : const Color(0xFFF9C74F);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: highlightColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: highlightColor.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isSuccess
                        ? Icons.workspace_premium_rounded
                        : Icons.local_fire_department_rounded,
                    color: highlightColor,
                    size: 14,
                  ),
                  6.w,
                  Text(
                    modeName,
                    style: context.typography.labelSmall?.copyWith(
                      color: highlightColor,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        16.h,
        Text(
          isSuccess ? context.l10n.congratulations : context.l10n.goodTry,
          style: context.typography.headlineMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        8.h,
        Text(
          context.l10n.completedSeries(totalTracks),
          textAlign: TextAlign.center,
          style: context.typography.bodyMedium?.copyWith(
            color: const Color(0xFFB3B3B3),
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceStats(BuildContext context) {
    final totalTracks = state.sessionHistory.length;
    final correctTracks = state.sessionHistory.where((i) => i.isVictory).length;
    final accuracy = totalTracks == 0
        ? 0
        : (correctTracks / totalTracks * 100).toInt();

    // XP Calculation: 10 XP per correct track
    final xpEarned = correctTracks * 10;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF181820),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF2A2A35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                context,
                '$correctTracks',
                context.l10n.correctLabel,
                Colors.white,
              ),
              Container(width: 1, height: 40, color: const Color(0xFF2A2A35)),
              _buildStatItem(
                context,
                '%$accuracy',
                context.l10n.successRateLabel,
                const Color(0xFF1ED760),
              ),
              Container(width: 1, height: 40, color: const Color(0xFF2A2A35)),
              _buildStatItem(
                context,
                '+$xpEarned',
                context.l10n.xpEarnedLabel,
                const Color(0xFF9D4EDD),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String value,
    String label,
    Color valueColor,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: context.typography.headlineMedium?.copyWith(
            color: valueColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        4.h,
        Text(
          label,
          style: context.typography.labelSmall?.copyWith(
            color: const Color(0xFF666666),
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildSessionTracksList(BuildContext context) {
    return Column(
      children: state.sessionHistory.map((item) {
        final track = item.track;
        final isVictory = item.isVictory;
        final color = isVictory
            ? const Color(0xFF1ED760)
            : const Color(0xFFE91429);
        final icon = isVictory
            ? Icons.check_circle_rounded
            : Icons.cancel_rounded;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF181820),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  track.albumArtUrl,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 48,
                    height: 48,
                    color: const Color(0xFF2A2A35),
                    child: const Icon(
                      Icons.music_note_rounded,
                      color: Colors.white54,
                    ),
                  ),
                ),
              ),
              12.w,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track.trackName,
                      style: context.typography.bodyLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    2.h,
                    Text(
                      track.artistName,
                      style: context.typography.bodySmall?.copyWith(
                        color: const Color(0xFFB3B3B3),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              8.w,
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDoubleRewardCard(BuildContext context, int rewardCoins) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _hasDoubledReward
              ? [
                  const Color(0xFF1ED760).withValues(alpha: 0.2),
                  const Color(0xFF1ED760).withValues(alpha: 0.1),
                ]
              : [
                  const Color(0xFFFFD700).withValues(alpha: 0.25),
                  const Color(0xFFFF9100).withValues(alpha: 0.25),
                ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _hasDoubledReward
              ? const Color(0xFF1ED760).withValues(alpha: 0.6)
              : const Color(0xFFFFD700).withValues(alpha: 0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (_hasDoubledReward ? const Color(0xFF1ED760) : const Color(0xFFFFD700))
                .withValues(alpha: 0.15),
            blurRadius: 16,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: _hasDoubledReward
              ? null
              : () {
                  final adService = context.read<AdService>();
                  final storage = context.read<LocalStorageService>();
                  adService.showRewardedAd(
                    onUserEarnedReward: () {
                      storage.addCoins(rewardCoins);
                      setState(() {
                        _hasDoubledReward = true;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('🎉 2x Ödül Kazanıldı! +$rewardCoins MeloCoin eklendi!'),
                          backgroundColor: const Color(0xFF1ED760),
                          duration: const Duration(seconds: 3),
                        ),
                      );
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (_hasDoubledReward ? const Color(0xFF1ED760) : const Color(0xFFFFD700))
                        .withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _hasDoubledReward ? Icons.check_circle_rounded : Icons.play_circle_filled_rounded,
                    color: _hasDoubledReward ? const Color(0xFF1ED760) : const Color(0xFFFFD700),
                    size: 28,
                  ),
                ),
                16.w,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _hasDoubledReward ? 'Ödülün 2\'ye Katlandı! ✓' : 'Ödülünü 2\'ye Katla! 🎬',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      4.h,
                      Text(
                        _hasDoubledReward
                            ? '+$rewardCoins MeloCoin hesabına aktarıldı.'
                            : 'Kısa bir video izle, +$rewardCoins MeloCoin kazan!',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!_hasDoubledReward) ...[
                  8.w,
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '2x Al',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionFooter(BuildContext context) {
    final correctTracks = state.sessionHistory.where((i) => i.isVictory).length;
    final rewardCoins = correctTracks > 0 ? (correctTracks * 15) : 25;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildDoubleRewardCard(context, rewardCoins),
        ElevatedButton(
          onPressed: () {
            context.read<AdService>().showInterstitialAdWithFrequency(
              frequency: 2,
              onAdDismissed: () {
                context.goNamed(RouteNames.modes);
              },
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1ED760),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.grid_view_rounded,
                color: Colors.black,
                size: 20,
              ),
              8.w,
              Text(
                context.l10n.returnToModes,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        16.h,
        ElevatedButton.icon(
          onPressed: () {
            context.read<AdService>().showInterstitialAdWithFrequency(
              frequency: 2,
              onAdDismissed: () {
                context.pushReplacementNamed(
                  RouteNames.game,
                  extra: {'mode': state.mode, 'parameter': state.modeParameter},
                );
              },
            );
          },
          icon: const Icon(
            Icons.replay_rounded,
            color: Color(0xFF1ED760),
            size: 20,
          ),
          label: Text(
            context.l10n.playAgain,
            style: const TextStyle(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF181820),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            side: const BorderSide(color: Color(0xFF2A2A35)),
          ),
        ),
      ],
    );
  }
}
