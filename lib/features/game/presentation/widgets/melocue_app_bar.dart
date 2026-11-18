import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:melocue/core/utils/context_extensions.dart';
import 'package:melocue/features/game/presentation/bloc/ranks/ranks_bloc.dart';
import 'package:melocue/features/game/presentation/bloc/ranks/ranks_state.dart';

class MelocueAppBar extends StatelessWidget {
  final String title;
  final String subtitle;

  const MelocueAppBar({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RanksBloc, RanksState>(
      builder: (context, state) {
        int streak = 0;
        if (state is RanksLoaded && state.currentUserEntry != null) {
          streak = state.currentUserEntry!.streak;
        }
        
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  // App Logo
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                  ),
                  8.w,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: context.typography.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: context.typography.labelSmall?.copyWith(
                            color: const Color(0xFF1ED760),
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                // Streak Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1712),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF32231A)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.local_fire_department, color: Color(0xFFF08C36), size: 18),
                      6.w,
                      Text(
                        streak.toString(),
                        style: context.typography.labelMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          ],
        );
      },
    );
  }
}
