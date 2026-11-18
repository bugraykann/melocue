import 'package:flutter/material.dart';
import 'dart:math' as math;

class LogoLoader extends StatefulWidget {
  final double size;
  
  const LogoLoader({
    super.key,
    this.size = 80.0,
  });

  @override
  State<LogoLoader> createState() => _LogoLoaderState();
}

class _LogoLoaderState extends State<LogoLoader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildRipple(double delay) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Calculate the progress of this specific ripple (0.0 to 1.0)
        double progress = (_controller.value + delay) % 1.0;
        
        // Apply an easeOut curve for a more natural outward expansion
        progress = Curves.easeOutCubic.transform(progress);
        
        // Size grows from 1x to 2.5x of the base size
        double currentSize = widget.size + (widget.size * 1.5 * progress);
        
        // Opacity fades out as it grows (softer, max 0.4)
        double currentOpacity = (1.0 - progress) * 0.4;
        
        return Center(
          child: Container(
            width: currentSize,
            height: currentSize,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(currentSize * 0.3),
              border: Border.all(
                color: const Color(0xFF1ED760).withValues(alpha: currentOpacity),
                width: 1.5,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: widget.size * 2.5,
        height: widget.size * 2.5,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 3 Soundwave ripples
            _buildRipple(0.0),
            _buildRipple(0.33),
            _buildRipple(0.66),
            
            // The pulsing logo in the center
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                // Sine wave pulse: very subtle scale change
                final scale = 1.0 + 0.03 * math.sin(_controller.value * math.pi * 2);
                return Transform.scale(
                  scale: scale,
                  child: child,
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(widget.size * 0.3),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1ED760).withValues(alpha: 0.3),
                      blurRadius: widget.size * 0.4,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(widget.size * 0.3),
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: widget.size,
                    height: widget.size,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

