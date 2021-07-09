/// Provides the [Ziggurat] class.
import 'dart:math';

import 'ambiance.dart';
import 'random_sound.dart';
import 'tile.dart';
import 'wall.dart';

/// A map.
///
/// This class is not call Map, is [Map] already exists.
class Ziggurat {
  /// Create a map.
  Ziggurat(this.name,
      {this.initialHeading = 0, this.musicPath, Point<double>? coordinates})
      : initialCoordinates = coordinates ?? Point<double>(0, 0),
        ambiances = <Ambiance>[],
        randomSounds = <RandomSound>[],
        tiles = <Tile>[],
        walls = <Wall>[];

  /// The name of this map.
  final String name;

  /// Initial coordinates.
  ///
  /// These are the coordinates that players should be placed on when first
  /// joining the map.
  final Point<double> initialCoordinates;

  /// The initial direction the player will face when starting on this map.
  final double initialHeading;

  /// Any music that should play on this map.
  final String? musicPath;

  /// All the ambiances of this map.
  final List<Ambiance> ambiances;

  /// All the random sounds on this map.
  final List<RandomSound> randomSounds;

  /// All the tiles on this map.
  final List<Tile> tiles;

  /// All the walls on this map.
  final List<Wall> walls;
}
