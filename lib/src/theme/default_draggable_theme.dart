import 'dart:ui';

import 'package:draggable_route/src/theme/draggable_route_theme.dart';
import 'package:flutter/widgets.dart';

final kDefaultTheme = DraggableRouteTheme(
  settings: kDefaultSettings,
  transitionDuration: const Duration(milliseconds: 300),
  transitionCurve: Curves.linear,
  transitionCurveOut: Curves.easeInOutCubic,
  borderRadius: const BorderRadius.all(Radius.circular(24)),
  backdropBuilder: (animation, child) => BackdropFilter(
    filter: ImageFilter.blur(
      sigmaX: 5 * animation.value,
      sigmaY: 5 * animation.value,
    ),
    child: child,
  ),
  dissolveBuilder: (animation, child) {
    final reverse = ReverseAnimation(animation);
    return ImageFiltered(
      enabled: animation.isAnimating,
      imageFilter: ImageFilter.blur(
        sigmaX: 10 * reverse.value,
        sigmaY: 10 * reverse.value,
        tileMode: TileMode.decal,
      ),
      child: child,
    );
  },
  opacityBuilder: (animation, child) => FadeTransition(
    opacity: Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: animation,
        curve: Interval(
          0.1,
          0.5,
          curve: Curves.easeInOut,
        ),
      ),
    ),
    child: child,
  ),
  sourceOpacityBuilder: (animation, child) => FadeTransition(
    opacity: Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: animation,
        curve: Interval(
          0.1,
          0.5,
          curve: Curves.easeInOut,
        ),
      ),
    ),
    child: child,
  ),
);

// TODO(@melvspace): 10/02/24 research why this magic numbers works
const kDefaultSettings = DraggableRouteSettings(edgeSlop: 4, slop: 100);
