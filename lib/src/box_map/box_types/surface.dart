/// Provides the [Surface] class.
import '../../sound/reverb_preset.dart';
import 'base.dart';

/// A simple surface that can be walked on.
class Surface extends BoxType {
  /// Create a surface.
  Surface(
      {this.minMoveInterval = 500,
      this.footstepSize = 1.0,
      this.minTurnInterval = 100,
      this.turnAmount = 5.0,
      this.reverbPreset});

  /// The minimum number of milliseconds that must elapse between player
  /// footsteps.
  final int minMoveInterval;

  /// The size of each player footstep.
  final double footstepSize;

  /// The minimum number of milliseconds that must elapse between player turns.
  final int minTurnInterval;

  /// The size of each player turn.
  final double turnAmount;

  /// The reverb preset for the box this surface represents.
  final ReverbPreset? reverbPreset;
}
