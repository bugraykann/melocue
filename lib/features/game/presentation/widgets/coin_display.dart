import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:melocue/core/utils/context_extensions.dart';
import 'package:melocue/features/game/data/datasources/local_storage_service.dart';
import 'package:melocue/core/services/ad_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class CoinDisplay extends StatelessWidget {
  const CoinDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = context.read<LocalStorageService>();
    final adService = context.read<AdService>();

    return ValueListenableBuilder<int>(
      valueListenable: storage.coinNotifier,
      builder: (context, coins, _) {
        return GestureDetector(
          onTap: () {
            // Show Rewarded Ad
            adService.showRewardedAd(
              onUserEarnedReward: (RewardItem reward) {
                storage.addCoins(25);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('25 Jeton Kazandın!'),
                    backgroundColor: const Color(0xFF1ED760),
                    duration: const Duration(seconds: 3),
                  ),
                );
              },
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E28),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.1),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.monetization_on_rounded,
                  color: Color(0xFFFFD700),
                  size: 16,
                ),
                const SizedBox(width: 6),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: Text(
                    coins.toString(),
                    key: ValueKey<int>(coins),
                    style: context.typography.labelMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.add_circle_rounded,
                  color: Color(0xFF1ED760),
                  size: 16,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
