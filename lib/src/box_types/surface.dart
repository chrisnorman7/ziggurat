/// Provides the [Surface] class.
import '../sound/reverb_preset.dart';
import 'base.dart';

/// A simple surface that can be walked on.
class Surface extends BoxType {
  /// Create a surface.
  Surface({this.moveInterval = 500, this.reverbPreset});

  /// How many milliseconds must elapse between player footsteps.
  final int moveInterval;

  /// The reverb preset for the box this surface represents.
  final ReverbPreset? reverbPreset;
}
