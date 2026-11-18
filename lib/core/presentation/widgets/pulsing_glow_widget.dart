// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class PulsingGlowWidget extends StatefulWidget {
  final Widget child;
  final Color glowColor;
  final double minOpacity;
  final double maxOpacity;
  final double blurRadius;
  final double spreadRadius;
  final Duration duration;
  final BoxShape shape;
  final BorderRadiusGeometry? borderRadius;

  const PulsingGlowWidget({
    super.key,
    required this.child,
    this.glowColor = const Color(0xFF1ED760),
    this.minOpacity = 0.2,
    this.maxOpacity = 0.6,
    this.blurRadius = 20.0,
    this.spreadRadius = 4.0,
    this.duration = const Duration(milliseconds: 1500),
    this.shape = BoxShape.rectangle,
    this.borderRadius,
  });

  @override
  State<PulsingGlowWidget> createState() => _PulsingGlowWidgetState();
}

class _PulsingGlowWidgetState extends State<PulsingGlowWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);

    _animation = Tween<double>(begin: widget.minOpacity, end: widget.maxOpacity)
        .animate(
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
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            shape: widget.shape,
            borderRadius: widget.shape == BoxShape.circle
                ? null
                : widget.borderRadius,
            boxShadow: [
              BoxShadow(
                color: widget.glowColor.withOpacity(_animation.value),
                blurRadius: widget.blurRadius + (_animation.value * 10),
                spreadRadius: widget.spreadRadius,
              ),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
