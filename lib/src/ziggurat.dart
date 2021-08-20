/// Provides the [Ziggurat] class.
import 'dart:math';

import 'box_map/box.dart';
import 'sound/ambiance.dart';
import 'sound/random_sound.dart';

/// A map.
///
/// This class is not call Map, is [Map] already exists.
class Ziggurat {
  /// Create a map.
  Ziggurat(this.name,
      {List<Box>? boxesList,
      List<Ambiance>? ambiancesList,
      List<RandomSound>? randomSoundsList,
      this.initialHeading = 0,
      Point<double>? coordinates})
      : initialCoordinates = coordinates ?? Point<double>(0, 0),
        boxes = boxesList ?? <Box>[],
        ambiances = ambiancesList ?? <Ambiance>[],
        randomSounds = randomSoundsList ?? <RandomSound>[];

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

  /// All the random sounds on this map.
  final List<RandomSound> randomSounds;

  /// All the boxes on this map.
  final List<Box> boxes;
}
