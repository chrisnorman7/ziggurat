/// Provides the [Wall] class.
import '../../json/reverb_preset.dart';
import 'surface.dart';

/// A wall on a map.
class Wall extends Surface {
  /// Create a wall.
  const Wall({ReverbPreset? reverbPreset, this.filterFrequency = 20000.0})
      : super(reverbPreset: reverbPreset);

  /// How much filtering should be applied to sounds heard on the other side of
  /// this wall.
  final double filterFrequency;
}
