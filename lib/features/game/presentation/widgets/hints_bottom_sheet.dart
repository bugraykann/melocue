import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:melocue/core/utils/context_extensions.dart';
import 'package:melocue/features/game/presentation/bloc/game_bloc.dart';
import 'package:melocue/features/game/presentation/bloc/game_event.dart';
import 'package:melocue/features/game/presentation/bloc/game_state.dart';
import 'package:melocue/features/game/data/datasources/local_storage_service.dart';
import 'package:melocue/core/services/ad_service.dart';

class HintsBottomSheet extends StatelessWidget {
  final GameReady gameState;

  const HintsBottomSheet({super.key, required this.gameState});

  @override
  Widget build(BuildContext context) {
    final storage = context.watch<LocalStorageService>();
    final coins = storage.coins;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF151219),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Jokerler',
                style: context.typography.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.monetization_on_rounded, color: Color(0xFFFFD700), size: 18),
                  const SizedBox(width: 4),
                  Text(
                    '$coins Coin',
                    style: context.typography.titleMedium?.copyWith(
                      color: const Color(0xFFFFD700),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildHintOption(
            context: context,
            icon: Icons.abc_rounded,
            title: 'Harf Aç',
            description: 'Şarkı adından rastgele bir harf açar.',
            cost: 10,
            coins: coins,
            onTap: () {
              Navigator.pop(context);
              context.read<GameBloc>().add(BuyLetterHintRequested());
            },
          ),
          const SizedBox(height: 12),
          _buildHintOption(
            context: context,
            icon: Icons.person_rounded,
            title: 'Sanatçıyı Göster',
            description: 'Şarkıyı söyleyen sanatçının adını gösterir.',
            cost: 20,
            coins: coins,
            isLocked: gameState.hasRevealedArtist,
            onTap: () {
              Navigator.pop(context);
              context.read<GameBloc>().add(BuyArtistHintRequested());
            },
          ),
          const SizedBox(height: 12),
          _buildHintOption(
            context: context,
            icon: Icons.skip_next_rounded,
            title: 'Şarkıyı Atla',
            description: 'Serini bozmadan sıradaki şarkıya geç.',
            cost: 20,
            coins: coins,
            onTap: () {
              Navigator.pop(context);
              context.read<GameBloc>().add(SkipTrackRequested());
            },
          ),
          const SizedBox(height: 16),
          _buildEarnCoinsBanner(context),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildEarnCoinsBanner(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFFD700).withValues(alpha: 0.15),
            const Color(0xFF1ED760).withValues(alpha: 0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFFD700).withValues(alpha: 0.3),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _watchAdForCoins(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_circle_fill_rounded,
                    color: Color(0xFFFFD700),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Video İzle, +30 Coin Kazan!',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Kısa bir video izleyerek anında joker alabilirsin.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1ED760),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'İzle',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _watchAdForCoins(BuildContext context) {
    final adService = context.read<AdService>();
    final storage = context.read<LocalStorageService>();

    adService.showRewardedAd(
      onUserEarnedReward: () {
        storage.addCoins(30);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('+30 MeloCoin Hesabına Eklendi! 🎉'),
            backgroundColor: Color(0xFF1ED760),
            duration: Duration(seconds: 3),
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
  }

  void _showNotEnoughCoinsDialog(BuildContext context, int missingCoins) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E28),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.monetization_on_rounded, color: Color(0xFFFFD700)),
            SizedBox(width: 8),
            Text('Yetersiz Coin', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Text(
          'Bu joker için $missingCoins Coin daha gerekiyor. Kısa bir video izleyerek anında +30 Coin kazanmak ister misin?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Vazgeç', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1ED760),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              _watchAdForCoins(context);
            },
            icon: const Icon(Icons.play_circle_filled_rounded, color: Colors.black, size: 18),
            label: const Text(
              'İzle ve +30 Kazan',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHintOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required int cost,
    required int coins,
    required VoidCallback onTap,
    bool isLocked = false,
  }) {
    final canAfford = coins >= cost;
    final isEnabled = canAfford && !isLocked;

    final VoidCallback? handleTap;
    if (isLocked) {
      handleTap = null;
    } else if (canAfford) {
      handleTap = onTap;
    } else {
      handleTap = () => _showNotEnoughCoinsDialog(context, cost - coins);
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: handleTap,
        borderRadius: BorderRadius.circular(16),
        child: Opacity(
          opacity: isLocked ? 0.4 : (canAfford ? 1.0 : 0.75),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E28),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isEnabled ? context.colors.primary.withValues(alpha: 0.3) : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: context.colors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: context.colors.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: context.typography.bodyLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: context.typography.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                      if (isLocked)
                        Text(
                          'Kullanıldı',
                          style: context.typography.labelSmall?.copyWith(
                            color: context.colors.primary,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: canAfford ? const Color(0xFFFFD700).withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text(
                        cost.toString(),
                        style: context.typography.labelLarge?.copyWith(
                          color: canAfford ? const Color(0xFFFFD700) : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.monetization_on_rounded, color: canAfford ? const Color(0xFFFFD700) : Colors.grey, size: 14),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
