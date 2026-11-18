import 'dart:ui' as dart_ui;
import 'package:flutter/material.dart';
import 'package:melocue/core/utils/context_extensions.dart';

class VinylVisualizer extends StatefulWidget {
  final String? albumArtUrl;
  final bool isPlaying;
  final bool isBlurred;
  final Stream<Duration>? positionStream;
  final Duration? currentChunkDuration;

  const VinylVisualizer({
    super.key,
    this.albumArtUrl,
    required this.isPlaying,
    this.isBlurred = true,
    this.positionStream,
    this.currentChunkDuration,
  });

  @override
  State<VinylVisualizer> createState() => _VinylVisualizerState();
}

class _VinylVisualizerState extends State<VinylVisualizer> with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    if (widget.isPlaying) {
      _rotationController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant VinylVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _rotationController.repeat();
      } else {
        _rotationController.stop();
      }
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF151219),
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF231E2A),
            Color(0xFF111317),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Vinyl Record
          AnimatedBuilder(
            animation: _rotationController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationController.value * 2 * 3.141592653589793,
                child: child,
              );
            },
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1B1B22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 15,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer Grooves
                  for (double i = 0.9; i >= 0.65; i -= 0.08)
                    Container(
                      width: 180 * i,
                      height: 180 * i,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.03),
                          width: 1,
                        ),
                      ),
                    ),
                  
                  // Dark line immediately outside the album art
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF0A0A0F), // Dark line
                        width: 2,
                      ),
                    ),
                  ),

                  // Center Label
                  Builder(
                    builder: (context) {
                      double sigma = 0;
                      if (widget.isBlurred) {
                        final ms = widget.currentChunkDuration?.inMilliseconds ?? 0;
                        // Starts at 20 blur, decreases as ms approaches 30000
                        sigma = 20.0 * (1.0 - (ms / 30000.0)).clamp(0.0, 1.0);
                      }
                      
                      return Container(
                        width: 104, // Increased size to make it more visible
                        height: 104,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF5A2A82),
                        ),
                        child: widget.albumArtUrl != null
                            ? ClipOval(
                                child: sigma > 0
                                    ? ImageFiltered(
                                        imageFilter: dart_ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
                                        child: Image.network(widget.albumArtUrl!, fit: BoxFit.cover),
                                      )
                                    : Image.network(widget.albumArtUrl!, fit: BoxFit.cover),
                              )
                            : const SizedBox.shrink(),
                      );
                    },
                  ),
                  // Spindle Hole
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          32.h,
          
          StreamBuilder<Duration>(
            stream: widget.isPlaying ? widget.positionStream : Stream.value(Duration.zero),
            builder: (context, snapshot) {
              final currentPosMs = (widget.isPlaying && snapshot.hasData) 
                  ? snapshot.data!.inMilliseconds 
                  : 0;
              final chunkMs = widget.currentChunkDuration?.inMilliseconds ?? 2000;
              // We assume max song duration is 30s = 30000ms.
              const int totalBars = 30;
              const int maxMs = 30000;
              
              // Organic waveform pattern for realism
              const List<double> wavePattern = [
                0.2, 0.4, 0.3, 0.6, 0.8, 1.0, 0.7, 0.4, 0.5, 0.8,
                0.9, 0.5, 0.3, 0.6, 0.8, 0.6, 0.9, 1.0, 0.7, 0.4,
                0.6, 0.8, 0.5, 0.7, 0.9, 0.6, 0.8, 0.5, 0.3, 0.2,
              ];
              
              // Formatting time
              String formatTime(int ms) {
                int sec = (ms / 1000).floor();
                int millis = (ms % 1000) ~/ 100;
                return '0:${sec.toString().padLeft(2, '0')}.$millis';
              }
              
              return Column(
                children: [
                  // Soundwaves
                  AnimatedBuilder(
                    animation: _rotationController,
                    builder: (context, child) {
                      return SizedBox(
                        height: 48,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end, // Align bars to the bottom
                          children: List.generate(totalBars, (index) {
                            // Determine colors
                            final barStartMs = (index * maxMs) / totalBars;
                            
                            Color barColor;
                            if (barStartMs < currentPosMs) {
                              barColor = const Color(0xFF1ED760); // Green (Played)
                            } else if (barStartMs < chunkMs) {
                              barColor = const Color(0xFFD4B3F7); // Purple (Unplayed but available)
                            } else {
                              barColor = const Color(0xFF333333); // Grey (Locked)
                            }

                            // Determine height with animation
                            final baseHeight = 8.0 + (wavePattern[index % wavePattern.length] * 20.0);
                            double height = baseHeight;
                            
                            if (widget.isPlaying && barStartMs < chunkMs) {
                              // Using the rotation controller directly for a bouncing effect.
                              double val = ((_rotationController.value * 20 + index) % 3.14159);
                              // rough sin approx: val * (3.14 - val)
                              double sinApprox = val * (3.14159 - val);
                              height = baseHeight + (sinApprox * 4.0).abs();
                            }
                            
                            return Container(
                              width: 5,
                              height: height,
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(
                                color: barColor,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            );
                          }),
                        ),
                      );
                    }
                  ),
                  
                  16.h,
                  
                  // Timestamp & Hz
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.graphic_eq, color: Color(0xFF1ED760), size: 16),
                          4.w,
                          Text(
                            formatTime(currentPosMs),
                            style: context.typography.labelMedium?.copyWith(
                              color: const Color(0xFF1ED760),
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '/ ${formatTime(chunkMs)}',
                        style: context.typography.labelMedium?.copyWith(
                          color: const Color(0xFFB3B3B3),
                          fontFamily: 'monospace',
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.tune, color: Color(0xFFB3B3B3), size: 16),
                          4.w,
                          Text(
                            '44.1kHz',
                            style: context.typography.labelMedium?.copyWith(
                              color: const Color(0xFFB3B3B3),
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              );
            }
          ),
        ],
      ),
    );
  }
}
