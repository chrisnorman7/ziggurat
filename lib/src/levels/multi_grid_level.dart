/// Provides the [MultiGridLevel] class.
import 'dart:math';

import 'package:dart_sdl/dart_sdl.dart';

import '../controller_axis_dispatcher.dart';
import '../game.dart';
import '../json/message.dart';
import '../multi_grid.dart';
import '../sound/ambiance.dart';
import '../sound/events/playback.dart';
import '../sound/random_sound.dart';
import 'level.dart';

/// A level which presents a series of rows, each one containing different
/// information.
///
/// At the top, the [title] will be shown. Moving down from that will present
/// each entry in [rows], with actions to the left, and entries to the right.
class MultiGridLevel extends Level {
  /// Create an instance.
  MultiGridLevel(
      {required Game game,
      required this.title,
      required this.rows,
      this.onCancel,
      int? verticalPosition,
      int? horizontalPosition,
      GameControllerAxis leftRightAxis = GameControllerAxis.leftx,
      this.leftScanCode = ScanCode.SCANCODE_LEFT,
      this.rightScanCode = ScanCode.SCANCODE_RIGHT,
      GameControllerAxis upDownAxis = GameControllerAxis.lefty,
      this.upScanCode = ScanCode.SCANCODE_UP,
      this.downScanCode = ScanCode.SCANCODE_DOWN,
      GameControllerAxis activateAxis = GameControllerAxis.triggerright,
      this.activateScanCode = ScanCode.SCANCODE_SPACE,
      GameControllerAxis cancelAxis = GameControllerAxis.triggerleft,
      this.cancelScanCode = ScanCode.SCANCODE_ESCAPE,
      double axisSensitivity = 0.5,
      int axisInterval = 400,
      List<Ambiance>? ambiances,
      List<RandomSound>? randomSounds})
      : axisDispatcher = ControllerAxisDispatcher({},
            axisSensitivity: axisSensitivity, functionInterval: axisInterval),
        _horizontalPositions = [],
        _verticalPosition = verticalPosition,
        super(game, ambiances: ambiances, randomSounds: randomSounds) {
    if (verticalPosition != null && horizontalPosition != null) {
      while (_horizontalPositions.length <= verticalPosition) {
        _horizontalPositions.add(null);
      }
      _horizontalPositions[verticalPosition] = horizontalPosition;
    }
    axisDispatcher.axes[leftRightAxis] = (double value) {
      if (value < 0) {
        left();
      } else {
        right();
      }
    };
    axisDispatcher.axes[upDownAxis] = (double value) {
      if (value > 0) {
        down();
      } else {
        up();
      }
    };
    axisDispatcher.axes[activateAxis] = (double value) => activate();
    axisDispatcher.axes[cancelAxis] = (double value) => cancel();
  }

  /// The title of this level.
  ///
  /// This value will be shown at the top of the level.
  final Message title;

  /// The rows of this level.
  ///
  /// It will be possible to cycle through the rows, either with [upScanCode]
  /// and [downScanCode], or by using the axis specified in the `upDownAxis`
  /// argument passed to the constructor.
  final List<MultiGridLevelRow> rows;

  /// What happens when this level is cancelled.
  ///
  /// This method will be called either by the [cancelScanCode], or the axis
  /// specified as the `cancelAxis` argument to the constructor.
  final void Function()? onCancel;

  /// The scan code that will call the [up] method.
  final ScanCode upScanCode;

  /// The scan code that will call the [down] method.
  final ScanCode downScanCode;

  /// The method that will call the [left] method.
  final ScanCode leftScanCode;

  /// The scan code that will call the [right] method.
  final ScanCode rightScanCode;

  /// The scan code that will call the [activate] method.
  final ScanCode activateScanCode;

  /// The scan code that will call the [cancel] method.
  final ScanCode cancelScanCode;

  /// The axis controller for this level.
  final ControllerAxisDispatcher axisDispatcher;

  /// The currently-playing sound, if any.
  PlaySound? _oldSound;

  /// The vertical position.
  int? _verticalPosition;

  /// The positions in each row.
  final List<int?> _horizontalPositions;

  /// Get the current vertical position.
  int? get verticalPosition => _verticalPosition;

  /// Set the vertical position.
  set verticalPosition(int? value) {
    if (value != null) {
      while (_horizontalPositions.length < (value + 1)) {
        _horizontalPositions.add(null);
      }
    }
    _verticalPosition = value;
  }

  /// Get the current row.
  MultiGridLevelRow? get currentRow {
    final verticalPosition = _verticalPosition;
    if (verticalPosition == null) {
      return null;
    }
    return rows[verticalPosition];
  }

  /// Get the current horizontal position.
  int? get horizontalPosition {
    final vp = verticalPosition;
    if (vp == null) {
      return null;
    }
    try {
      return _horizontalPositions.elementAt(vp);
    } on IndexError {
      return null;
    }
  }

  /// Show the label of the current object.
  void showCurrent() {
    final row = currentRow;
    if (row == null) {
      _oldSound = game.outputMessage(title, oldSound: _oldSound);
    } else {
      final position = horizontalPosition;
      if (position == null) {
        _oldSound = game.outputMessage(row.label, oldSound: _oldSound);
      } else if (position < 0) {
        final action = row.actions.reversed.elementAt((position * -1) - 1);
        _oldSound = game.outputMessage(action.label, oldSound: _oldSound);
      } else {
        final label = row.getEntryLabel(position);
        _oldSound = game.outputMessage(label, oldSound: _oldSound);
      }
    }
  }

  /// Move up in the list of rows.
  void up() {
    final vp = verticalPosition;
    if (vp != null) {
      if (vp == 0) {
        verticalPosition = null;
      } else {
        verticalPosition = vp - 1;
      }
    }
    showCurrent();
  }

  /// Move down in the list of rows.
  void down() {
    final vp = verticalPosition;
    if (vp == null) {
      if (rows.isNotEmpty) {
        verticalPosition = 0;
      }
    } else {
      verticalPosition = min(rows.length - 1, vp + 1);
    }
    showCurrent();
  }

  /// Move left through row values.
  void left() {
    final vp = verticalPosition;
    if (vp != null) {
      final row = currentRow!;
      final rowActions = row.actions;
      final positionInRow = horizontalPosition;
      if (positionInRow == null) {
        if (rowActions.isNotEmpty) {
          _horizontalPositions[vp] = -1;
        }
      } else if (positionInRow < 0) {
        _horizontalPositions[vp] =
            max(positionInRow - 1, rowActions.length * -1);
      } else if (positionInRow == 0) {
        _horizontalPositions[vp] = null;
      } else {
        _horizontalPositions[vp] = positionInRow - 1;
      }
    }
    showCurrent();
  }

  /// Move right through row values.
  void right() {
    final vp = verticalPosition;
    if (vp != null) {
      final row = currentRow!;
      final positionInRow = horizontalPosition;
      final numberOfEntries = row.getNumberOfEntries();
      if (positionInRow == null) {
        if (numberOfEntries > 0) {
          _horizontalPositions[vp] = 0;
        }
      } else if (positionInRow == -1) {
        _horizontalPositions[vp] = null;
      } else {
        _horizontalPositions[vp] = min(positionInRow + 1, numberOfEntries - 1);
      }
    }
    showCurrent();
  }

  /// Activate an object in the grid.
  ///
  /// This method can activate both actions and row entries.
  void activate() {
    final row = currentRow;
    if (row != null) {
      final hp = horizontalPosition;
      if (hp != null) {
        if (hp >= 0) {
          row.onActivate(hp);
        } else {
          row.actions[(hp * -1) - 1].func();
        }
      }
    }
  }

  /// Cancel this level.
  ///
  /// This method calls [onCancel].
  void cancel() {
    final cancelFunc = onCancel;
    if (cancelFunc != null) {
      cancelFunc();
    }
  }

  @override
  void onPush() {
    super.onPush();
    showCurrent();
  }

  @override
  void onPop(double? fadeLength) {
    super.onPop(fadeLength);
    _oldSound?.destroy();
  }

  @override
  void handleSdlEvent(Event event) {
    if (event is ControllerAxisEvent) {
      axisDispatcher.handleAxisValue(event.axis, event.smallValue);
    } else if (event is KeyboardEvent &&
        event.repeat == false &&
        event.key.modifiers.isEmpty &&
        event.state == PressedState.pressed) {
      final scanCode = event.key.scancode;
      if (scanCode == upScanCode) {
        up();
      } else if (scanCode == downScanCode) {
        down();
      } else if (scanCode == leftScanCode) {
        left();
      } else if (scanCode == rightScanCode) {
        right();
      } else if (scanCode == activateScanCode) {
        activate();
      } else if (scanCode == cancelScanCode) {
        cancel();
      }
    }
  }
}
