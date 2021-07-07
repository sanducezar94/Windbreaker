import 'package:flutter/material.dart';
import 'package:path/path.dart';

class SnapScrollPhysics extends ScrollPhysics {
  final double itemDimension;

  SnapScrollPhysics({this.itemDimension, ScrollPhysics parent}) : super(parent: parent);

  @override
  SnapScrollPhysics applyTo(ScrollPhysics ancestor) {
    return SnapScrollPhysics(itemDimension: itemDimension, parent: buildParent(ancestor));
  }

  double _getPage(ScrollPosition position) {
    return position.pixels / itemDimension;
  }

  double _getPixels(double page) {
    return page * itemDimension;
  }

  double _getTargetPixels(ScrollPosition position, Tolerance tolerance, double velocity) {
    int page = _getPage(position).floor();
    if (velocity < -tolerance.velocity) {
      page -= 1;
    } else if (velocity > tolerance.velocity) {
      page += 1;
    }
    return _getPixels(page.roundToDouble());
  }

  @override
  Simulation createBallisticSimulation(ScrollMetrics position, double velocity) {
    // If we're out of range and not headed back in range, defer to the parent
    // ballistics, which should put us back in range at a page boundary.
    if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) || (velocity >= 0.0 && position.pixels >= position.maxScrollExtent))
      return super.createBallisticSimulation(position, velocity);
    final Tolerance tolerance = this.tolerance;
    double target = _getTargetPixels(position, tolerance, velocity);
    if (target != position.pixels) return ScrollSpringSimulation(spring, position.pixels, target, velocity, tolerance: tolerance);
    return null;
  }

  @override
  bool get allowImplicitScrolling => false;
}
