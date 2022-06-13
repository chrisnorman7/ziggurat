/// Provides the [Reverb] class.
import 'package:dart_synthizer/dart_synthizer.dart';

import '../json/reverb_preset.dart';

/// A reverb object.
class Reverb {
  /// Create an instance.
  const Reverb({
    required this.id,
    required this.name,
    required this.reverb,
  });

  /// The ID of the event that generated this instance.
  final int id;

  /// The name of the reverb preset that was used to create this instance.
  final String name;

  /// The reverb instance.
  ///
  /// This value is usually made from a [ReverbPreset] instance.
  final GlobalFdnReverb reverb;
}
