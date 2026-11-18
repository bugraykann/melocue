import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:melocue/core/utils/context_extensions.dart';
import 'package:melocue/features/game/domain/repositories/leaderboard_repository.dart';

void showEditProfileDialog(BuildContext context, String currentName) {
  showDialog(
    context: context,
    builder: (context) {
      final controller = TextEditingController(text: currentName);
      bool isLoading = false;

      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF181820),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(color: const Color(0xFF2A2A35)),
            ),
            title: Text(
              context.l10n.editProfileDialogTitle,
              style: context.typography.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.l10n.editProfileDialogDesc,
                  style: context.typography.bodyMedium?.copyWith(
                    color: const Color(0xFFB3B3B3),
                  ),
                ),
                16.h,
                TextField(
                  controller: controller,
                  style: const TextStyle(color: Colors.white),
                  maxLength: 15,
                  decoration: InputDecoration(
                    hintText: context.l10n.newNameHint,
                    hintStyle: const TextStyle(color: Colors.white54),
                    counterStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: const Color(0xFF0D0D12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.pop(context),
                child: Text(
                  context.l10n.cancel,
                  style: context.typography.labelLarge?.copyWith(
                    color: Colors.white54,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        final newName = controller.text.trim();
                        if (newName.isNotEmpty && newName != currentName) {
                          setState(() => isLoading = true);
                          final result = await context
                              .read<LeaderboardRepository>()
                              .updateDisplayName(newName);

                          if (context.mounted) {
                            setState(() => isLoading = false);
                            result.fold(
                              (data) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      context.l10n.nameUpdatedSuccess,
                                    ),
                                    backgroundColor: Color(0xFF1ED760),
                                  ),
                                );
                              },
                              (failure) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(failure.message),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              },
                            );
                          }
                        } else {
                          Navigator.pop(context);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1ED760),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        context.l10n.save,
                        style: context.typography.labelLarge?.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          );
        },
      );
    },
  );
}
