/// Provides the [Surface] class.
import '../reverb_preset.dart';
import 'base.dart';

/// A simple surface that can be walked on.
class Surface extends BoxType {
  /// Create a surface.
  Surface(
      {this.moveInterval = const Duration(milliseconds: 500),
      this.reverbPreset});

  /// How many seconds must elapse between player footsteps.
  final Duration moveInterval;

  /// The reverb preset for the box this surface represents.
  final ReverbPreset? reverbPreset;
}
