import 'dart:ui';

import 'package:draggable_route/src/theme/default_draggable_theme.dart';
import 'package:flutter/material.dart';

typedef DraggableRouteTransitionBuilder = Widget Function(
  Animation<double> animation,
  Widget child,
);

/// {@template draggable_route.DraggableRouteTheme}
/// Theme to control styling of [DraggableRoute]
/// {@endtemplate}
class DraggableRouteTheme extends ThemeExtension<DraggableRouteTheme> {
  final Duration transitionDuration;

// #region Curves

  /// Curve for entering animation
  final Curve transitionCurve;

  /// Curve for exiting animation
  final Curve? transitionCurveOut;

// #endregion

// #region Filters

  /// Background animation builder
  final DraggableRouteTransitionBuilder? backdropBuilder;

  /// Dissolve animation builder.
  ///
  /// Used when source was not provided or no longer alive
  final DraggableRouteTransitionBuilder? dissolveBuilder;

  /// source widget opacity animation builder.
  final DraggableRouteTransitionBuilder? sourceOpacityBuilder;

  /// opacity animation builder.
  final DraggableRouteTransitionBuilder? opacityBuilder;

// #endregion

  // shape

// #region Shape

  /// Border radius of card when dragging around
  final BorderRadius borderRadius;

// #endregion

// #region Other

  final DraggableRouteSettings settings;

// #endregion

  /// {@macro draggable_route.DraggableRouteTheme}
  const DraggableRouteTheme({
    required this.transitionDuration,
    required this.transitionCurve,
    this.borderRadius = BorderRadius.zero,
    this.settings = kDefaultSettings,
    this.transitionCurveOut,
    this.backdropBuilder,
    this.dissolveBuilder,
    this.opacityBuilder,
    this.sourceOpacityBuilder,
  });

  /// {@macro draggable_route.DraggableRouteTheme}
  ///
  /// Get instance from ancestor [Theme]
  static DraggableRouteTheme of(BuildContext context) {
    return Theme.of(context).extension<DraggableRouteTheme>() ?? kDefaultTheme;
  }

  @override
  ThemeExtension<DraggableRouteTheme> copyWith() {
    return this;
  }

  @override
  ThemeExtension<DraggableRouteTheme> lerp(
    covariant ThemeExtension<DraggableRouteTheme>? other,
    double t,
  ) {
    return other ?? this;
  }
}

class DraggableRouteSettings {
  /// drag slop in the middle of scrollable
  final double slop;

  /// drag slop on the edge on scrollable
  final double edgeSlop;

  final double? leftReceptiveEdge;

  final double? topReceptiveEdge;

  const DraggableRouteSettings({
    required this.slop,
    required this.edgeSlop,
    required this.leftReceptiveEdge,
    required this.topReceptiveEdge,
  });
}
