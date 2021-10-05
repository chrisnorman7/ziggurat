/// Provides the [BoxMap] class.
import 'dart:math';

import '../error.dart';
import '../sound/ambiance.dart';
import 'box.dart';

/// A map made up of boxes.
///
/// Each box in the [boxes] list gets added to the [_tiles] 2d array.
class BoxMap {
  /// Create an instance.
  BoxMap({
    required this.name,
    required this.boxes,
    Point<double>? initialCoordinates,
    this.initialHeading = 0,
    List<Ambiance>? ambiances,
  })  : initialCoordinates = initialCoordinates ?? Point(0, 0),
        ambiances = ambiances ?? [] {
    var sizeX = 0;
    var sizeY = 0;
    for (final box in boxes) {
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
    for (final box in boxes) {
      for (var x = box.start.x; x <= box.end.x; x++) {
        for (var y = box.start.y; y <= box.end.y; y++) {
          _tiles[x][y] = box;
        }
      }
    }
  }

  /// The name of this map.
  final String name;

  /// Initial coordinates.
  ///
  /// These are the coordinates that players should be placed on when first
  /// joining the map.
  Point<double> initialCoordinates;

  /// The initial direction the player will face when starting on this map.
  final double initialHeading;

  /// All the ambiances of this map.
  final List<Ambiance> ambiances;

  /// All the boxes on this map.
  final List<Box> boxes;

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
