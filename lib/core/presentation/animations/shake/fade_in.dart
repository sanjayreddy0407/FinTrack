// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:fintrack/core/presentation/animations/animation_controller.dart';

class FadeIn extends StatefulWidget {
  const FadeIn({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 200),
  });

  final Widget child;
  final Duration duration;

  @override
  // ignore: no_logic_in_create_state
  _FadeInState createState() => _FadeInState(duration);
}

class _FadeInState extends AnimationControllerState<FadeIn> {
  _FadeInState(super.duration);

  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    // TO DISABLE THE ANIMATION:
    // if (!saveBattery) {
    //   _controller.forward();
    // }

    _opacityAnimation =
        Tween<double>(begin: 0, end: 1).animate(animationController);

    animationController.forward();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // if (saveBattery) {
    //   return widget.child;
    // }

    return AnimatedBuilder(
      animation: _opacityAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
