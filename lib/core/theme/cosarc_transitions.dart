import 'package:flutter/material.dart';
import 'cosarc_motion.dart';

/// Premium fade-through page transition — inspired by Material motion spec.
class CosarcFadeThroughRoute<T> extends PageRouteBuilder<T> {
  CosarcFadeThroughRoute({
    required this.builder,
    super.settings,
    this.duration = CosarcMotion.medium,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
          transitionDuration: duration,
          reverseTransitionDuration: duration,
        );

  final WidgetBuilder builder;
  final Duration duration;

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final fadeIn = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
    );
    final fadeOut = CurvedAnimation(
      parent: secondaryAnimation,
      curve: const Interval(0.4, 1.0, curve: Curves.easeInCubic),
    );
    final scale = Tween<double>(begin: 0.96, end: 1.0).animate(
      CurvedAnimation(parent: animation, curve: CosarcMotion.easeOut),
    );

    return FadeTransition(
      opacity: fadeIn,
      child: ScaleTransition(
        scale: scale,
        child: FadeTransition(
          opacity: Tween<double>(begin: 1.0, end: 0.0).animate(fadeOut),
          child: child,
        ),
      ),
    );
  }
}

/// Shared-axis vertical transition for modal flows (auth, onboarding).
class CosarcSharedAxisRoute<T> extends PageRouteBuilder<T> {
  CosarcSharedAxisRoute({
    required this.builder,
    super.settings,
    this.duration = CosarcMotion.slow,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
          transitionDuration: duration,
          reverseTransitionDuration: duration,
        );

  final WidgetBuilder builder;
  final Duration duration;

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(parent: animation, curve: CosarcMotion.easeOut);
    final offset = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(curved);

    return SlideTransition(
      position: offset,
      child: FadeTransition(opacity: curved, child: child),
    );
  }
}

extension CosarcNavigator on NavigatorState {
  Future<T?> pushFadeThrough<T>(Widget page) => push<T>(
        CosarcFadeThroughRoute(builder: (_) => page),
      );

  Future<T?> pushSharedAxis<T>(Widget page) => push<T>(
        CosarcSharedAxisRoute(builder: (_) => page),
      );
}
