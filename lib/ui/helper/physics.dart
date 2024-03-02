import 'package:flutter/material.dart';

class CustomPageViewScrollPhysics extends ScrollPhysics {
  const CustomPageViewScrollPhysics({super.parent});

  @override
  CustomPageViewScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomPageViewScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  bool shouldAcceptUserOffset(ScrollMetrics position) => true;

  @override
  SpringDescription get spring => const SpringDescription(
        mass: 80,
        stiffness: 100,
        damping: 1,
      );
}