import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// A widget that slides between two icons.
///
/// For convenience, [SlidingIcon] provides named constructors for vertical and horizontal
/// orientation, with property names that reflect the given direction.
///
/// In vertical orientation, the `top` is the `start` and `bottom` is the `end`.
///
/// In horizontal orientation, the `left` is the `start` and `right` is the `end`.
///
/// [SlidingIcon] doesn't impose any size constraints on itself. The parent widget must impose a bounded
/// width and a bounded height.
///
/// A [SlidingIcon] slides from one icon to another when [showStart] changes from `true`
/// to `false` or `false` to `true`.
class SlidingIcon extends SlottedMultiChildRenderObjectWidget<SlidingIconSlot, RenderBox> {
  /// Builds a vertical [SlidingIcon], surrounded by a [ShaderMask], which fades out the
  /// sliding icon near the top and bottom boundaries.
  static Widget verticalWithFade({
    Key? key,
    required Widget top,
    required Widget bottom,
    required bool showTop,
  }) {
    return ShaderMask(
      key: key,
      shaderCallback: (rect) {
        return LinearGradient(
          colors: [
            const Color(0x00FFFFFF),
            const Color(0xFFFFFFFF),
            const Color(0xFFFFFFFF),
            const Color(0x00FFFFFF),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.1, 0.35, 0.65, 0.9],
        ).createShader(rect);
      },
      child: SlidingIcon.vertical(
        top: top,
        bottom: bottom,
        showTop: showTop,
      ),
    );
  }

  const SlidingIcon.vertical({
    super.key,
    required Widget top,
    required Widget bottom,
    required bool showTop,
  })  : direction = SlidingIconDirection.vertical,
        start = top,
        end = bottom,
        showStart = showTop;

  /// Builds a horizontal [SlidingIcon], surrounded by a [ShaderMask], which fades out the
  /// sliding icon near the left and right boundaries.
  static Widget horizontalWithFade({
    Key? key,
    required Widget left,
    required Widget right,
    required bool showLeft,
  }) {
    return ShaderMask(
      key: key,
      shaderCallback: (rect) {
        return LinearGradient(
          colors: [
            const Color(0x00FFFFFF),
            const Color(0xFFFFFFFF),
            const Color(0xFFFFFFFF),
            const Color(0x00FFFFFF),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: [0.1, 0.35, 0.65, 0.9],
        ).createShader(rect);
      },
      child: SlidingIcon.horizontal(
        left: left,
        right: right,
        showLeft: showLeft,
      ),
    );
  }

  const SlidingIcon.horizontal({
    super.key,
    required Widget left,
    required Widget right,
    required bool showLeft,
  })  : direction = SlidingIconDirection.horizontal,
        start = left,
        end = right,
        showStart = showLeft;

  final SlidingIconDirection direction;
  final Widget start;
  final Widget end;
  final bool showStart;

  @override
  Iterable<SlidingIconSlot> get slots => SlidingIconSlot.values;

  @override
  Widget? childForSlot(SlidingIconSlot slot) => switch (slot) {
        SlidingIconSlot.start => start,
        SlidingIconSlot.end => end,
      };

  @override
  RenderSlidingIcon createRenderObject(BuildContext context) {
    final renderObject = RenderSlidingIcon(direction);
    if (showStart) {
      renderObject.showStart();
    } else {
      renderObject.showEnd();
    }
    return renderObject;
  }

  @override
  void updateRenderObject(BuildContext context, RenderSlidingIcon renderObject) {
    renderObject.direction = direction;
    if (showStart) {
      renderObject.showStart();
    } else {
      renderObject.showEnd();
    }
  }
}

class RenderSlidingIcon extends RenderBox with SlottedContainerRenderObjectMixin<SlidingIconSlot, RenderBox> {
  RenderSlidingIcon(this._direction);

  SlidingIconDirection _direction;
  set direction(SlidingIconDirection direction) {
    if (direction == _direction) {
      return;
    }

    _direction = direction;
    markNeedsLayout();
  }

  SlidingIconSlot _destination = SlidingIconSlot.start;

  late final Ticker _ticker;
  double _slideUpPercent = 0;
  double _velocity = 0;
  Simulation? _flipSimulation;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);

    _ticker = Ticker(_onSlideTick);

    visitChildren((child) {
      child.attach(owner);
    });

    _slideToDestination();
  }

  @override
  void detach() {
    _ticker.dispose();

    super.detach();
  }

  void showStart() {
    if (_destination == SlidingIconSlot.start) {
      return;
    }

    _destination = SlidingIconSlot.start;
    _slideToDestination();
  }

  void showEnd() {
    if (_destination == SlidingIconSlot.end) {
      return;
    }

    _destination = SlidingIconSlot.end;
    _slideToDestination();
  }

  void _slideToDestination() {
    if (!attached) {
      return;
    }

    _ticker.stop();

    final destinationOffset = switch (_destination) {
      SlidingIconSlot.start => 0.0,
      SlidingIconSlot.end => 1.0,
    };

    _flipSimulation = SpringSimulation(
      const SpringDescription(
        mass: 1.0,
        stiffness: 500,
        damping: 45,
      ),
      _slideUpPercent, // Start value
      destinationOffset, // End value
      _velocity, // Initial velocity
    );

    _ticker.start();
  }

  void _onSlideTick(Duration elapsedTime) {
    final seconds = elapsedTime.inMilliseconds / 1000;
    _slideUpPercent = _flipSimulation!.x(seconds);
    _velocity = _flipSimulation!.dx(seconds);

    if (_flipSimulation!.isDone(seconds)) {
      _ticker.stop();

      _flipSimulation = null;
      _velocity = 0;
    }

    markNeedsLayout();
  }

  @override
  void performLayout() {
    if (!constraints.hasBoundedWidth) {
      throw FlutterError("SlidingIcon must have a bounded width, but incoming constraints are unbounded");
    }
    if (!constraints.hasBoundedHeight) {
      throw FlutterError("SlidingIcon must have a bounded height, but incoming constraints are unbounded");
    }

    size = constraints.biggest;

    final start = childForSlot(SlidingIconSlot.start);
    if (start != null) {
      start.layout(BoxConstraints.tight(size));
      start.parentData = BoxParentData()..offset = _startOffset;
    }

    final end = childForSlot(SlidingIconSlot.end);
    if (end != null) {
      end.layout(BoxConstraints.tight(size));
      end.parentData = BoxParentData()..offset = _endOffset;
    }
  }

  Offset get _startOffset => switch (_direction) {
        SlidingIconDirection.horizontal => Offset(-size.width * _slideUpPercent, 0),
        SlidingIconDirection.vertical => Offset(0, -size.height * _slideUpPercent),
      };

  Offset get _endOffset => switch (_direction) {
        SlidingIconDirection.horizontal => Offset(size.width - (size.width * _slideUpPercent), 0),
        SlidingIconDirection.vertical => Offset(0, size.height - (size.height * _slideUpPercent)),
      };

  @override
  bool hitTestChildren(
    BoxHitTestResult result, {
    required Offset position,
  }) {
    final start = childForSlot(SlidingIconSlot.start);
    if (start != null) {
      final childParentData = start.parentData! as BoxParentData;
      final didHit = result.addWithPaintOffset(
        offset: childParentData.offset,
        position: position,
        hitTest: (BoxHitTestResult result, Offset transformed) {
          assert(transformed == position - childParentData.offset);
          return start.hitTest(result, position: transformed);
        },
      );

      if (didHit) {
        return true;
      }
    }

    final end = childForSlot(SlidingIconSlot.end);
    if (end != null) {
      final childParentData = end.parentData! as BoxParentData;
      final didHit = result.addWithPaintOffset(
        offset: childParentData.offset,
        position: position,
        hitTest: (BoxHitTestResult result, Offset transformed) {
          assert(transformed == position - childParentData.offset);
          return end.hitTest(result, position: transformed);
        },
      );

      if (didHit) {
        return true;
      }
    }

    return false;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    context.clipRectAndPaint(offset & size, Clip.hardEdge, Offset.zero & size, () {
      final start = childForSlot(SlidingIconSlot.start);
      if (start != null) {
        context.paintChild(start, offset + (start.parentData as BoxParentData).offset);
      }

      final end = childForSlot(SlidingIconSlot.end);
      if (end != null) {
        context.paintChild(end, offset + (end.parentData as BoxParentData).offset);
      }
    });
  }
}

enum SlidingIconDirection {
  horizontal,
  vertical;
}

enum SlidingIconSlot {
  start,
  end;
}
