/// Provides the [Box] class.
import 'dart:math';

import 'package:meta/meta.dart';

import '../json/sound_reference.dart';
import 'box_types/agents/agent.dart';
import 'box_types/base.dart';
import 'box_types/door.dart';
import 'box_types/surface.dart';
import 'box_types/wall.dart';

/// A box on a map.
class Box<T extends BoxType> {
  /// Create a box.
  Box(this.name, Point<int> start, Point<int> end, this.type, {this.sound})
      : _start = start,
        _end = end {
    onAfterMove();
  }

  /// The name of this box.
  final String name;

  Point<int> _start;

  /// The start coordinates of this box.
  Point<int> get start => _start;

  Point<int> _end;

  /// The end coordinates of this box.
  Point<int> get end => _end;

  late int _width;

  /// The width of this box.
  ///
  /// This is the distance east to west.
  int get width => _width;

  late int _height;

  /// The height of this box.
  ///
  /// This is the distance north to south.
  int get height => _height;

  late double _halfWidth;

  /// Half the width of this box.
  double get halfWidth => _halfWidth;

  late double _halfHeight;

  /// Half the height of this box.
  double get halfHeight => _halfHeight;

  late Point<int> _cornerNw;

  /// The coordinates at the northwest corner of this box.
  Point<int> get cornerNw => _cornerNw;

  late Point<int> _cornerSe;

  /// The coordinates of the southeast corner of this box.
  Point<int> get cornerSe => _cornerSe;

  late Point<double> _centre;

  /// The centre coordinates of this box.
  Point<double> get centre => _centre;

  /// The type of this box.
  final T type;

  /// The sound of this box.
  ///
  /// If this box is a [Wall], this sound will be heard when a player walks
  /// into it.
  ///
  /// If this box is a [Surface], this sound will be heard when walking on
  /// it.
  final SoundReference? sound;

  /// Move this tile to a new set of coordinates.
  ///
  /// !! WARNING !!
  /// This should not be done lightly. This functionality should only be used
  /// for mobiles, the player, and any other agents that may arise in the
  /// lifetime of this package.
  void move(Point<int> newStart, Point<int> newEnd) {
    _start = newStart;
    _end = newEnd;
    onAfterMove();
  }

  /// Returns `true` if this box contains the point [p].
  bool containsPoint(Point<int> p) =>
      p.x >= start.x && p.y >= start.y && p.x <= end.x && p.y <= end.y;

  /// What happens after this tile is moved.
  void onAfterMove() {
    _width = (_end.x - _start.x) + 1;
    _height = (_end.y - _start.y) + 1;
    _halfWidth = _width / 2;
    _halfHeight = _height / 2;
    _cornerNw = Point<int>(_start.x, _end.y);
    _cornerSe = Point<int>(_end.x, _start.y);
    _centre = Point<double>(_start.x + _halfWidth, _start.y + _halfHeight);
  }

  /// What happens when this box is "activated".
  ///
  /// Exactly when a box is activated is left up to the programmer, but maybe
  /// when the enter key is pressed.
  void onActivate() {}

  /// What happens when [agent] enters this box.
  @mustCallSuper
  void onEnter(Box<Agent> agent, Point<double> oldCoordinates) {
    final t = type;
    if (t is Door) {
      t.closeWhen = null;
      if (t.open == false) {
        // runner.openDoor(t, oldCoordinates);
      }
    }
  }

  /// What happens when [agent] leaves this box.
  void onExit(Box<Agent> agent, Point<double> oldCoordinates) {
    final t = type;
    if (t is Door) {
      final closeAfter = t.closeAfter;
      if (closeAfter != null) {
        t
          ..closeWhen = DateTime.now().millisecondsSinceEpoch + closeAfter
          ..closeCoordinates = oldCoordinates;
      }
    }
  }
}
