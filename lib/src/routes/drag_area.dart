import 'package:draggable_route/draggable_route.dart';
import 'package:draggable_route/src/gestures/monodrag.dart';
import 'package:flutter/widgets.dart';

class DragArea extends StatefulWidget {
  final Widget child;

  final DraggableRouteSettings? settings;

  const DragArea({
    super.key,
    required this.child,
    this.settings,
  });

  @override
  State<DragArea> createState() => _DragAreaState();
}

enum _Edge {
  start,
  middle,
  end;
}

class _DragAreaState extends State<DragArea> {
  _Edge horizontalEdge = _Edge.start;
  _Edge verticalEdge = _Edge.start;

  late DraggableRoute route;

  @override
  void didChangeDependencies() {
    route = ModalRoute.of(context) as DraggableRoute;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final settings = widget.settings ?? //
        DraggableRouteTheme.of(context).settings;

    return RawGestureDetector(
      gestures: {
        _PanGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<_PanGestureRecognizer>(
          () => _PanGestureRecognizer(
            () => horizontalEdge,
            () => verticalEdge,
            settings.edgeSlop,
            settings.slop,
            settings.leftReceptiveEdge,
            settings.topReceptiveEdge,
          ),
          (instance) => instance //
            ..onStart = onPanStart
            ..onCancel = onPanCancel
            ..onUpdate = onPanUpdate
            ..onEnd = onPanEnd,
        ),
      },
      child: ScrollConfiguration(
        behavior: const _DraggableScrollBehavior(),
        child: NotificationListener<Notification>(
          onNotification: (notification) {
            switch (notification) {
              case ScrollMetricsNotification(:final metrics):
              case ScrollUpdateNotification(:final metrics):
                _Edge edge;
                if (metrics.pixels == metrics.minScrollExtent) {
                  edge = _Edge.start;
                } else if (metrics.pixels == metrics.maxScrollExtent) {
                  edge = _Edge.end;
                } else {
                  edge = _Edge.middle;
                }

                switch (metrics.axis) {
                  case Axis.vertical:
                    verticalEdge = edge;

                  case Axis.horizontal:
                    horizontalEdge = edge;
                }
            }

            return false;
          },
          child: widget.child,
        ),
      ),
    );
  }

  void onPanStart(DragStartDetails details) {
    route.handleDragStart(details);
  }

  void onPanCancel() {
    route.handleDragCancel();
  }

  void onPanUpdate(DragUpdateDetails details) {
    route.handleDragUpdate(details);
  }

  void onPanEnd(DragEndDetails details) {
    route.handleDragEnd(details);
  }

  @override
  void dispose() {
    onPanCancel();
    super.dispose();
  }
}

class _DraggableScrollBehavior extends ScrollBehavior {
  const _DraggableScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const _DraggableScrollPhysics();
  }
}

class _DraggableScrollPhysics extends ClampingScrollPhysics {
  const _DraggableScrollPhysics();
}

class _PanGestureRecognizer extends PanGestureRecognizer {
  final ValueGetter<_Edge> horizontalEdge;
  final ValueGetter<_Edge> verticalEdge;

  final double edgeSlop;
  final double defaultSlop;
  double? leftReceptiveEdge;
  double? topReceptiveEdge;

  _PanGestureRecognizer(
    this.horizontalEdge,
    this.verticalEdge,
    this.edgeSlop,
    this.defaultSlop,
    this.leftReceptiveEdge,
    this.topReceptiveEdge,
  );

  @override
  bool hasSufficientGlobalDistanceToAccept(
    PointerDeviceKind pointerDeviceKind,
    double? deviceTouchSlop,
  ) {
    // 获取初始位置的 x 和 y 坐标
    final initialX = initialPosition.global.dx;
    final initialY = initialPosition.global.dy;

    // 获取 delta 值
    var delta = (finalPosition.global - initialPosition.global);

    // 检查手势方向和起始位置
    if (delta.dx.abs() > delta.dy.abs()) {
      if (leftReceptiveEdge != null) {
        // 横向手势
        if (delta.dx > 0 && initialX <= leftReceptiveEdge!) {
          // 从左往右滑动，且起始位置在左边缘 40 像素以内
          // 符合条件，继续执行原有逻辑
        } else {
          return false; // 不满足条件，返回 false
        }
      }
    } else {
      if (topReceptiveEdge != null) {
        // 纵向手势
        if (delta.dy > 0 && initialY <= topReceptiveEdge!) {
          // 从上往下滑动，且起始位置在上边缘 100 像素以内
          // 符合条件，继续执行原有逻辑
        } else {
          return false; // 不满足条件，返回 false
        }
      }
    }

    // 如果水平和垂直边缘都在中间位置，调用父类实现
    if (horizontalEdge() == _Edge.middle && verticalEdge() == _Edge.middle) {
      return super.hasSufficientGlobalDistanceToAccept(
        pointerDeviceKind,
        deviceTouchSlop,
      );
    }

    var ySlop = switch (verticalEdge()) {
      _Edge.start when delta.dy > 0 => edgeSlop,
      _Edge.end when delta.dy < 0 => edgeSlop,
      _ => defaultSlop,
    };

    var xSlop = switch (horizontalEdge()) {
      _Edge.start when delta.dx > 0 => edgeSlop,
      _Edge.end when delta.dx < 0 => edgeSlop,
      _ => defaultSlop,
    };

    final slop = delta.dx.abs() > delta.dy.abs() ? xSlop : ySlop;

    return globalDistanceMoved.abs() > slop; // 返回是否接受其他情况的手势
  }
}
