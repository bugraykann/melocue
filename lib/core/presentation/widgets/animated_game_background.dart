// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import 'dart:math' as math;

class AnimatedGameBackground extends StatefulWidget {
  final Widget child;
  const AnimatedGameBackground({super.key, required this.child});

  @override
  State<AnimatedGameBackground> createState() => _AnimatedGameBackgroundState();
}

class _AnimatedGameBackgroundState extends State<AnimatedGameBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10), // Slow breathing
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base dark color
        Container(color: const Color(0xFF0A0A0F)),

        // Animated gradient blobs
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            final yOffset1 = math.sin(_animation.value * math.pi) * 100;
            final yOffset2 = math.cos(_animation.value * math.pi) * 100;

            return Stack(
              children: [
                Positioned(
                  top: -100 + yOffset1,
                  left: -50,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF1ED760).withOpacity(0.15),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -150 + yOffset2,
                  right: -100,
                  child: Container(
                    width: 400,
                    height: 400,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF8A2BE2)
                              .withOpacity(0.12), // Deep purple accent
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),

        // Frosting glass effect / noise overlay can go here, but a subtle black overlay works too
        Container(color: Colors.black.withOpacity(0.1)),

        // Foreground content
        widget.child,
      ],
    );
  }
}
