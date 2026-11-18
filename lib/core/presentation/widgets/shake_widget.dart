import 'package:flutter/material.dart';
import 'dart:math' as math;

class ShakeWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double shakeOffset;
  final int shakeCount;
  final bool shouldShake;

  const ShakeWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.shakeOffset = 10.0,
    this.shakeCount = 3,
    required this.shouldShake,
  });

  @override
  State<ShakeWidget> createState() => _ShakeWidgetState();
}

class _ShakeWidgetState extends State<ShakeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    if (widget.shouldShake) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant ShakeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shouldShake && !oldWidget.shouldShake) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final sineValue =
            math.sin(_controller.value * widget.shakeCount * math.pi * 2);
        return Transform.translate(
          offset: Offset(sineValue * widget.shakeOffset * (1 - _controller.value), 0),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
