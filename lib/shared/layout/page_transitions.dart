import 'package:flutter/material.dart';

/// Custom page route with 300ms easeInOutCubic transition per spec §1.5.
///
/// Use this instead of `MaterialPageRoute` for screen-to-screen navigation
/// to get consistent, smooth transitions across the app.
class VaelPageRoute<T> extends PageRouteBuilder<T> {
  VaelPageRoute({required WidgetBuilder builder})
    : super(
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) =>
            builder(context),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.05, 0),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      );
}
