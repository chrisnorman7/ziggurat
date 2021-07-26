/// Provides the [Ziggurat] class.
import 'dart:math';

import 'ambiance.dart';
import 'random_sound.dart';
import 'tile.dart';

/// A map.
///
/// This class is not call Map, is [Map] already exists.
class Ziggurat {
  /// Create a map.
  Ziggurat(this.name,
      {List<Tile>? tilesList,
      List<Ambiance>? ambiancesList,
      List<RandomSound>? randomSoundsList,
      this.initialHeading = 0,
      Point<double>? coordinates})
      : initialCoordinates = coordinates ?? Point<double>(0, 0),
        tiles = tilesList ?? <Tile>[],
        ambiances = ambiancesList ?? <Ambiance>[],
        randomSounds = randomSoundsList ?? <RandomSound>[];

  /// The name of this map.
  final String name;

  /// Initial coordinates.
  ///
  /// These are the coordinates that players should be placed on when first
  /// joining the map.
  final Point<double> initialCoordinates;

  /// The initial direction the player will face when starting on this map.
  final double initialHeading;

  /// All the ambiances of this map.
  final List<Ambiance> ambiances;

  /// All the random sounds on this map.
  final List<RandomSound> randomSounds;

  /// All the tiles on this map.
  final List<Tile> tiles;
}
