import 'package:flutter/material.dart';

class CustomPageViewScrollPhysics extends ScrollPhysics {
  const CustomPageViewScrollPhysics({super.parent});

  @override
  CustomPageViewScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomPageViewScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  bool shouldAcceptUserOffset(ScrollMetrics position) => true;

  /* @override
  SpringDescription get spring => const SpringDescription(
        mass: 80,
        stiffness: 1601.24996,
        damping: 80,
      ); */
  @override
  SpringDescription get spring => SpringDescription.withDurationAndBounce(
        duration: Duration(milliseconds: 800),
        bounce: 0.2,
      );
}