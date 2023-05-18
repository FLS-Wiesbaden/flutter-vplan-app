import 'package:flutter/material.dart';

/// Behavior object to ensure, that the 
/// glow effects are hidden.
class NoGlowBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}