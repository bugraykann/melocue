// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class FlashOverlayWidget extends StatefulWidget {
  final Widget child;
  final bool flashRed;
  final bool flashGreen;
  final Duration duration;

  const FlashOverlayWidget({
    super.key,
    required this.child,
    required this.flashRed,
    required this.flashGreen,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  State<FlashOverlayWidget> createState() => _FlashOverlayWidgetState();
}

class _FlashOverlayWidgetState extends State<FlashOverlayWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  Color _flashColor = Colors.transparent;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.decelerate));
    _checkFlash();
  }

  @override
  void didUpdateWidget(covariant FlashOverlayWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((widget.flashRed && !oldWidget.flashRed) ||
        (widget.flashGreen && !oldWidget.flashGreen)) {
      _checkFlash();
    }
  }

  void _checkFlash() {
    if (widget.flashRed) {
      _flashColor = Colors.red.withOpacity(0.3);
      _controller.forward(from: 0.0).then((_) => _controller.reverse());
    } else if (widget.flashGreen) {
      _flashColor = Colors.green.withOpacity(0.3);
      _controller.forward(from: 0.0).then((_) => _controller.reverse());
    }
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
        widget.child,
        IgnorePointer(
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Container(
                color: _flashColor.withOpacity(
                  _flashColor.opacity * _animation.value,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
