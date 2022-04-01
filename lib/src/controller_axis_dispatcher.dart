/// Provides the [ControllerAxisDispatcher] class.
import 'package:dart_sdl/dart_sdl.dart';

import 'levels/editor.dart';
import 'menu/menu.dart';

/// A class for linking controller axes to functions.
///
/// You can use this class to speed up the task of mapping controller axes to
/// functions.
///
/// For example:
///
/// ```
/// final dispatcher = ControllerAxisDispatcher({
///   GameControllerAxis.triggerLeft:
///   (double value) => print('Left trigger: $value.')});
/// ```
///
/// Now, from a `handleSdlEvent` method:
///
/// ```
/// if (event is ControllerAxisEvent) {
///   dispatcher.handleAxisValue(event.axis, event.smallValue);
/// }
/// ```
///
/// For examples of this class in action, see the source code for the [Menu] and
/// [Editor] classes.
class ControllerAxisDispatcher {
  /// Create an instance.
  ControllerAxisDispatcher(
    this.axes, {
    this.axisSensitivity = 0.5,
    this.functionInterval = 400,
  }) : _controllerLastMoved = 0;

  /// The axes that are handled by this instance.
  final Map<GameControllerAxis, void Function(double value)> axes;

  /// The sensitivity of this class.
  ///
  /// Axis values which are less than this value will be ignored.
  final double axisSensitivity;

  /// How often (in milliseconds) functions will be called.
  final int functionInterval;

  /// The last time controller movement was checked.
  int _controllerLastMoved;

  /// Handle an axis value.
  void handleAxisValue(final GameControllerAxis axis, final double value) {
    final f = axes[axis];
    if (f == null || value.abs() < axisSensitivity) {
      return;
    }
    if (functionInterval != 0) {
      final now = DateTime.now().millisecondsSinceEpoch;
      if ((now - _controllerLastMoved) >= functionInterval) {
        _controllerLastMoved = now;
      } else {
        return;
      }
    }
    f(value);
  }
}
