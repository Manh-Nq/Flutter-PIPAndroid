import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class ScalingGestureDetector extends StatefulWidget {
  final Widget child;
  final void Function(Offset initialPoint)? onPanStart;
  final void Function(
          Offset initialPoint, DragUpdateDetails pointer, Offset delta)?
      onPanUpdate;
  final void Function(Offset point)? onPanEnd;

  final void Function(Offset initialFocusPoint)? onScaleStart;
  final void Function(Offset changedFocusPoint, double scale)? onScaleUpdate;
  final void Function()? onScaleEnd;

  final void Function(double dx)? onHorizontalDragUpdate;
  final void Function(double dy)? onVerticalDragUpdate;

  const ScalingGestureDetector({
    Key? key,
    required this.child,
    this.onPanStart,
    this.onPanUpdate,
    this.onPanEnd,
    this.onScaleStart,
    this.onScaleUpdate,
    this.onScaleEnd,
    this.onHorizontalDragUpdate,
    this.onVerticalDragUpdate,
  }) : super(key: key);

  @override
  _ScalingGestureDetectorState createState() => _ScalingGestureDetectorState();
}

class _ScalingGestureDetectorState extends State<ScalingGestureDetector> {
  final List<Touch> _touches = [];
  late double _initialScalingDistance;

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      gestures: {
        ImmediateMultiDragGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<
                ImmediateMultiDragGestureRecognizer>(
          () => ImmediateMultiDragGestureRecognizer(),
          (ImmediateMultiDragGestureRecognizer instance) {
            instance.onStart = (Offset offset) {
              final touch = Touch(
                offset,
                onUpdate: (drag, details) =>
                    _onTouchUpdate(drag as Touch, details),
                onEnd: (drag, details) => _onTouchEnd(drag as Touch, details),
              );
              _onTouchStart(touch);
              return touch;
            };
          },
        ),
      },
      child: widget.child,
    );
  }

  void _onTouchStart(Touch touch) {
    _touches.add(touch);
    if (_touches.length == 1 && widget.onPanStart != null) {
      widget.onPanStart!(touch._startOffset);
    } else if (_touches.length == 2 && widget.onScaleStart != null) {
      _initialScalingDistance =
          (_touches[0]._currentOffset - _touches[1]._currentOffset).distance;
      widget.onScaleStart!(
          (_touches[0]._currentOffset + _touches[1]._currentOffset) / 2);
    } else {
      // Do nothing/ ignore
    }
  }

  final _DXY = 10;

  void _onTouchUpdate(Touch touch, DragUpdateDetails details) {
    assert(_touches.isNotEmpty);
    touch._currentOffset = details.localPosition;

    if (_touches.length == 1) {
      if (widget.onPanUpdate != null) {
        var delta = details.localPosition - touch._startOffset;
        widget.onPanUpdate!(touch._startOffset, details, delta);
      }

      final dx = (details.localPosition.dx - touch._startOffset.dx).abs();
      if (dx > _DXY && widget.onHorizontalDragUpdate != null) {
        widget.onHorizontalDragUpdate!(
            (details.localPosition.dx - touch._startOffset.dx)
                .clamp(-2.0, 2.0));
      }

      final dy = (details.localPosition.dy - touch._startOffset.dy).abs();
      if (dy > _DXY && widget.onVerticalDragUpdate != null) {
        widget.onVerticalDragUpdate!(
            (details.localPosition.dy - touch._startOffset.dy)
                .clamp(-2.0, 2.0));
      }
    } else {
      // TODO average of ALL offsets, not only 2 first
      var newDistance =
          (_touches[0]._currentOffset - _touches[1]._currentOffset).distance;
      if (widget.onScaleUpdate != null) {
        widget.onScaleUpdate!(
            (_touches[0]._currentOffset + _touches[1]._currentOffset) / 2,
            newDistance / _initialScalingDistance);
      }
    }
  }

  void _onTouchEnd(Touch touch, DragEndDetails details) {
    _touches.remove(touch);
    if (_touches.isEmpty) {
      widget.onPanEnd!(touch._currentOffset);
    } else if (_touches.length == 1) {
      widget.onScaleEnd!();

      // Restart pan
      _touches[0]._startOffset = _touches[0]._currentOffset;
      widget.onPanStart!(_touches[0]._startOffset);
    }
  }
}

class Touch extends Drag {
  Offset _startOffset;
  late Offset _currentOffset;

  final void Function(Drag drag, DragUpdateDetails details) onUpdate;
  final void Function(Drag drag, DragEndDetails details) onEnd;

  Touch(this._startOffset, {required this.onUpdate, required this.onEnd}) {
    _currentOffset = _startOffset;
  }

  @override
  void update(DragUpdateDetails details) {
    super.update(details);
    onUpdate(this, details);
  }

  @override
  void end(DragEndDetails details) {
    super.end(details);
    onEnd(this, details);
    _currentOffset = _startOffset;
  }
}
Widget scalingWidget() {
  return ScalingGestureDetector(
    onPanStart: (initialPoint) {},
    onPanEnd: (pointer) {
      print("[POINTER]  $pointer");

    },
    onPanUpdate: (initialPoint, details, delta) {
      // var delta = details.delta;
      var pointer = details.localPosition;
      var pointerGlobal = details.globalPosition;

    },
    onScaleStart: (initialFocusPoint) {},
    onScaleUpdate: (changedFocusPoint, scale) {},
    onScaleEnd: () {},
    child: Container(
      color: Colors.red,
    ),
  );
}