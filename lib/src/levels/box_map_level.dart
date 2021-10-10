/// Provides the [BoxMapLevel] class.
import 'dart:math';

import '../box_map/box.dart';
import '../box_map/box_map.dart';
import '../error.dart';
import '../game.dart';
import '../sound/ambiance.dart';
import '../sound/random_sound.dart';
import 'level.dart';

/// A level that can be used to play a [BoxMap] instance.
class BoxMapLevel extends Level {
  /// Create an instance.
  BoxMapLevel(Game game, this.boxMap,
      {List<Ambiance>? ambiances, List<RandomSound>? randomSounds})
      : super(game, ambiances: ambiances, randomSounds: randomSounds) {
    var sizeX = 0;
    var sizeY = 0;
    for (final box in boxMap.boxes) {
      if (box.start.x < 0 ||
          box.start.y < 0 ||
          box.end.x < 0 ||
          box.end.y < 0) {
        throw NegativeCoordinatesError(box);
      }
      sizeX = max(sizeX, box.end.x);
      sizeY = max(sizeY, box.end.y);
    }
    width = sizeX + 1;
    height = sizeY + 1;
    _tiles = List<List<Box?>>.from(<List<Box?>>[
      for (var x = 0; x <= sizeX; x++)
        List<Box?>.from(<Box?>[for (var y = 0; y <= sizeY; y++) null])
    ]);
    for (final box in boxMap.boxes) {
      for (var x = box.start.x; x <= box.end.x; x++) {
        for (var y = box.start.y; y <= box.end.y; y++) {
          _tiles[x][y] = box;
        }
      }
    }
  }

  /// The box map to render.
  final BoxMap boxMap;

  /// All the tiles present on this map.
  late final List<List<Box?>> _tiles;

  /// The width of this map.
  late final int width;

  /// The depth of this map.
  late final int height;

  /// Get the tile at the given coordinates.
  Box? tileAt(int x, int y) => _tiles[x][y];

  /// Get the tile at the given point.
  Box? tileAtPoint(Point<int> coordinates) =>
      tileAt(coordinates.x, coordinates.y);
}
