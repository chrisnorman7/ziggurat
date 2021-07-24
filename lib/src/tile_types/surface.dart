/// Provides the [Surface] class.
import '../reverb_preset.dart';
import 'base.dart';

/// A simple surface that can be walked on.
class Surface extends TileType {
  /// Create a surface.
  Surface({this.walkInterval = 0.5, this.reverbPreset});

  /// How many seconds must elapse between player footsteps.
  final double walkInterval;

  /// The reverb preset for the tile this surface represents.
  final ReverbPreset? reverbPreset;
}
